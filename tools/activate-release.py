#!/usr/bin/env python3
"""Installed on v next to releases; accepts only a completed release ID."""
import fcntl
import json
import os
import re
import sys
from pathlib import Path


def activate(root, release):
    if not re.fullmatch(r"[A-Za-z0-9_-]+", release) or release in {"current", "previous"}:
        raise ValueError("Invalid release ID")
    root = root.resolve()
    candidate = root / release
    if candidate.is_symlink() or not candidate.is_dir():
        raise ValueError("Release must be a directory")
    if not (candidate / "index.html").is_file():
        raise ValueError("Missing index.html")
    manifest = json.loads((candidate / "pdf-manifest.json").read_text())
    for entry in manifest:
        pdf = (candidate / entry["pdf"]).resolve()
        if not pdf.is_relative_to(candidate) or not pdf.is_file():
            raise ValueError("Missing or invalid PDF attachment")
        with pdf.open("rb") as stream:
            if stream.read(5) != b"%PDF-":
                raise ValueError("Invalid PDF attachment")
    with (root / ".deploy.lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        current = root / "current"
        if current.exists() and not current.is_symlink():
            raise ValueError("current must be a symlink")
        if current.is_symlink():
            old = os.readlink(current)
            if not re.fullmatch(r"[A-Za-z0-9_-]+", old):
                raise ValueError("Unexpected current target")
            previous = root / f".previous-{os.getpid()}"
            previous.symlink_to(old)
            previous.replace(root / "previous")
        pending = root / f".current-{os.getpid()}"
        pending.symlink_to(release)
        pending.replace(current)
    print(f"Active release: {release}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("Usage: activate.py RELEASE_ID")
    activate(Path(__file__).resolve().parent, sys.argv[1])
