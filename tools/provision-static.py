#!/usr/bin/env python3
"""One-time root setup on v; preserve nginx and the currently published content."""
import ctypes
import datetime
import json
import os
import pwd
import shutil
import subprocess
import sys
from pathlib import Path

SITE = Path("/var/www/mymaterials.ru")
RELEASES = Path("/var/www/mymaterials-releases")
USER = "mymaterials-deploy"


def main():
    if os.geteuid() != 0 or len(sys.argv) != 2:
        raise SystemExit("Usage (as root): provision-static.py DEPLOY_PUBLIC_KEY_FILE")
    public_key = Path(sys.argv[1]).read_text().strip()
    if not public_key.startswith("ssh-ed25519 ") or "\n" in public_key:
        raise SystemExit("Expected one Ed25519 public key")
    try:
        account = pwd.getpwnam(USER)
    except KeyError:
        subprocess.run(["useradd", "--create-home", "--shell", "/bin/bash", USER], check=True)
        account = pwd.getpwnam(USER)
    ssh = Path(account.pw_dir) / ".ssh"
    ssh.mkdir(mode=0o700, exist_ok=True)
    authorized = ssh / "authorized_keys"
    line = 'restrict ' + public_key + '\n'
    existing = authorized.read_text() if authorized.exists() else ""
    if public_key not in existing:
        authorized.write_text(existing + line)
    authorized.chmod(0o600)
    os.chown(ssh, account.pw_uid, account.pw_gid)
    os.chown(authorized, account.pw_uid, account.pw_gid)
    RELEASES.mkdir(exist_ok=True)
    os.chown(RELEASES, account.pw_uid, account.pw_gid)
    helper = Path(__file__).with_name("activate-release.py")
    shutil.copy2(helper, RELEASES / "activate.py")
    (RELEASES / "activate.py").chmod(0o755)
    if SITE.is_symlink():
        if os.readlink(SITE) != str(RELEASES / "current"):
            raise SystemExit("Unexpected existing site symlink; manual inspection required")
        print("Static release layout already configured")
        return
    if not SITE.is_dir() or not (SITE / "index.html").is_file():
        raise SystemExit("Existing site missing; refusing migration")
    stamp = datetime.datetime.now(datetime.timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    initial = RELEASES / ("initial-" + stamp)
    initial.mkdir()
    subprocess.run(["rsync", "-a", str(SITE) + "/", str(initial) + "/"], check=True)
    differences = subprocess.check_output(["rsync", "-acni", "--delete", str(SITE) + "/", str(initial) + "/"], text=True)
    if differences:
        raise SystemExit("Site changed during copy; retry when no other deployment is running")
    (initial / "pdf-manifest.json").write_text(json.dumps([]) + "\n")
    current = RELEASES / "current"
    if current.exists() or current.is_symlink():
        raise SystemExit("Unexpected current link before migration")
    current.symlink_to(initial.name)
    temporary = SITE.with_name("mymaterials-before-pipeline-" + stamp)
    temporary.symlink_to(current)
    # Linux RENAME_EXCHANGE swaps a directory and symlink without a missing-path window.
    libc = ctypes.CDLL(None, use_errno=True)
    result = libc.renameat2(-100, os.fsencode(SITE), -100, os.fsencode(temporary), 2)
    if result != 0:
        error = ctypes.get_errno()
        temporary.unlink()
        current.unlink()
        raise OSError(error, os.strerror(error))
    print(f"Current content preserved. Original directory backup: {temporary}")
    print(f"Public path: {SITE} -> {current}")


if __name__ == "__main__":
    main()
