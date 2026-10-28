#!/usr/bin/env python3
"""Install the pinned Linux x86_64 build tools into a chosen directory."""
import argparse
import hashlib
import io
import json
import platform
import tarfile
import urllib.request
from pathlib import Path

VERSIONS = json.loads(Path(__file__).with_name("versions.json").read_text())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--bin-dir", type=Path, default=Path(".tools/bin"))
    args = parser.parse_args()
    if platform.system() != "Linux" or platform.machine() != "x86_64":
        parser.error("Automatic installation supports Linux x86_64; install pinned tools manually.")
    args.bin_dir.mkdir(parents=True, exist_ok=True)
    for name, artifact in (
        ("zola", f"zola-v{VERSIONS['zola']}-x86_64-unknown-linux-gnu.tar.gz"),
        ("typst", "typst-x86_64-unknown-linux-musl.tar.xz"),
    ):
        owner = "getzola" if name == "zola" else "typst"
        url = f"https://github.com/{owner}/{name}/releases/download/v{VERSIONS[name]}/{artifact}"
        print(f"Downloading {name} {VERSIONS[name]}", flush=True)
        with urllib.request.urlopen(url, timeout=120) as response:
            data = response.read()
        if hashlib.sha256(data).hexdigest() != VERSIONS[f"{name}_sha256"]:
            raise SystemExit(f"Checksum mismatch: {name}")
        with tarfile.open(fileobj=io.BytesIO(data)) as archive:
            members = [m for m in archive.getmembers() if m.isfile() and Path(m.name).name == name]
            if len(members) != 1:
                raise SystemExit(f"Unexpected archive: {name}")
            target = args.bin_dir / name
            target.write_bytes(archive.extractfile(members[0]).read())
            target.chmod(0o755)


if __name__ == "__main__":
    main()
