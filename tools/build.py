#!/usr/bin/env python3
"""Build Zola and optional independent Typst documents as one release."""
import argparse
import functools
import http.server
import io
import json
import shutil
import subprocess
import tarfile
import tempfile
import threading
import time
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VERSIONS = json.loads((ROOT / "tools/versions.json").read_text())
OUTPUT = ROOT / ".build/public"


def run(*args, **kwargs):
    subprocess.run([str(arg) for arg in args], check=True, **kwargs)


def tool(name):
    local = ROOT / ".tools/bin" / name
    executable = str(local) if local.exists() else shutil.which(name)
    if not executable:
        raise ValueError(f"{name} is missing; run make tools")
    actual = subprocess.check_output([executable, "--version"], text=True).split()[1]
    if actual != VERSIONS[name]:
        raise ValueError(f"Expected {name} {VERSIONS[name]}, found {actual}; run make tools")
    return executable


def frontmatter(path):
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines(keepends=True)
    if not lines or lines[0].strip() != "+++":
        raise ValueError(f"{path}: expected TOML front matter delimited by +++")
    end = next((i for i in range(1, len(lines)) if lines[i].strip() == "+++"), None)
    if end is None:
        raise ValueError(f"{path}: unclosed front matter")
    return tomllib.loads("".join(lines[1:end])), lines, end


def private_files(directory, names):
    return [n for n in names if n == "print" or n == ".git" or n.endswith(".typ")]


def build(*, drafts=False, base_url=None):
    zola = tool("zola")
    build_dir = ROOT / ".build"
    build_dir.mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="release-", dir=build_dir) as temporary:
        stage = Path(temporary) / "site"
        stage.mkdir()
        shutil.copy2(ROOT / "zola.toml", stage)
        for directory in ("content", "templates", "sass", "static"):
            if (ROOT / directory).exists():
                shutil.copytree(ROOT / directory, stage / directory, ignore=private_files)
        # Build from the locked upstream theme; local customizations belong in templates/.
        theme = stage / "themes/apollo"
        theme.mkdir(parents=True)
        archive = subprocess.check_output([
            "git", "-C", str(ROOT / "themes/apollo"), "archive", VERSIONS["apollo"],
        ])
        with tarfile.open(fileobj=io.BytesIO(archive)) as stream:
            stream.extractall(theme, filter="data")
        manifest = []
        typst = None
        for page in sorted((ROOT / "content").rglob("*.md")):
            if "print" in page.relative_to(ROOT / "content").parts:
                continue
            meta, lines, end = frontmatter(page)
            extra = meta.get("extra", {})
            if "build" in extra:
                raise ValueError(f"{page}: extra.build is reserved for generated metadata")
            if "pdf" not in extra:
                continue
            pdf = extra["pdf"]
            if not isinstance(pdf, dict) or set(pdf) != {"source"} or not isinstance(pdf["source"], str):
                raise ValueError(f"{page}: use [extra.pdf] with only source = \"print/document.typ\"")
            if page.name == "_index.md":
                raise ValueError(f"{page}: PDF attachments currently require a page, not a section")
            if meta.get("draft", False) and not drafts:
                continue
            source = (page.parent / pdf["source"]).resolve()
            if not source.is_relative_to(ROOT / "content") or source.suffix != ".typ" or not source.is_file():
                raise ValueError(f"{page}: missing or invalid Typst source: {pdf['source']}")
            if "print" not in source.relative_to(ROOT / "content").parts:
                raise ValueError(f"{page}: keep Typst sources and private resources in a print/ directory")
            relative = page.relative_to(ROOT / "content")
            # Source-derived paths remain stable if a public slug or permalink changes.
            asset = Path("downloads") / relative.with_suffix("") / "document.pdf"
            target = stage / "static" / asset
            if target.exists():
                raise ValueError(f"Generated PDF would overwrite a static asset: {asset}")
            target.parent.mkdir(parents=True, exist_ok=True)
            typst = typst or tool("typst")
            run(typst, "compile", "--root", ROOT, source, target, cwd=ROOT)
            if not target.read_bytes().startswith(b"%PDF-"):
                raise ValueError(f"Typst did not produce a PDF: {source}")
            generated = '\n[extra.build]\npdf = ' + json.dumps(asset.as_posix()) + '\n'
            lines.insert(end, generated)
            (stage / "content" / relative).write_text("".join(lines), encoding="utf-8")
            manifest.append({"page": relative.as_posix(), "pdf": asset.as_posix()})
        result = Path(temporary) / "public"
        command = [zola, "build", "--output-dir", result]
        if drafts:
            command.append("--drafts")
        if base_url:
            command.extend(["--base-url", base_url])
        run(*command, cwd=stage)
        for entry in manifest:
            if not (result / entry["pdf"]).is_file():
                raise ValueError(f"PDF missing from release: {entry['pdf']}")
        (result / "pdf-manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n")
        previous = build_dir / "previous"
        if previous.exists():
            shutil.rmtree(previous)
        if OUTPUT.exists():
            OUTPUT.rename(previous)
        result.rename(OUTPUT)
        if previous.exists():
            shutil.rmtree(previous)
    print(f"Built {len(manifest)} PDF attachment(s): {OUTPUT}", flush=True)


def fingerprint():
    paths = [ROOT / "zola.toml"]
    for folder in ("content", "templates", "sass", "static", "typst", "tools"):
        paths.extend(p for p in (ROOT / folder).rglob("*") if p.is_file() and "__pycache__" not in p.parts)
    return tuple((str(p), p.stat().st_mtime_ns, p.stat().st_size) for p in sorted(paths))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--drafts", action="store_true")
    parser.add_argument("--serve", action="store_true", help="Rebuild on changes; refresh browser to see updates")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8000)
    parser.add_argument("--base-url")
    args = parser.parse_args()
    options = {"drafts": args.drafts or args.serve, "base_url": args.base_url}
    if args.serve and not options["base_url"]:
        options["base_url"] = f"http://localhost:{args.port}"
    build(**options)
    if args.serve:
        handler = functools.partial(http.server.SimpleHTTPRequestHandler, directory=str(OUTPUT))
        server = http.server.ThreadingHTTPServer((args.host, args.port), handler)
        threading.Thread(target=server.serve_forever, daemon=True).start()
        print(f"Preview: {options['base_url']} (refresh after rebuild)", flush=True)
        previous = fingerprint()
        try:
            while True:
                time.sleep(1)
                current = fingerprint()
                if current != previous:
                    previous = current
                    try:
                        build(**options)
                    except (ValueError, subprocess.CalledProcessError) as error:
                        print(f"Build failed; keeping previous preview: {error}", flush=True)
        finally:
            server.shutdown()


if __name__ == "__main__":
    try:
        main()
    except (ValueError, subprocess.CalledProcessError) as error:
        raise SystemExit(str(error)) from error
