#!/usr/bin/env python3
"""Normalize Flutter resolution assets under assets/app_icons.

Moves files named with Apple-style density suffixes into Flutter folders:
  logo@2x.png  ->  assets/app_icons/2.0x/logo.png
  logo@3x.png  ->  assets/app_icons/3.0x/logo.png

Only processes **files directly in** assets/app_icons (not subfolders).
Skips if the destination file already exists (no overwrite).

Usage (from repo root):
  python3 scripts/normalize_app_icon_assets.py
  python3 scripts/normalize_app_icon_assets.py --dry-run
"""

from __future__ import annotations

import argparse
import re
import shutil
import sys
from pathlib import Path

# Repo root = parent of scripts/
REPO_ROOT = Path(__file__).resolve().parent.parent
ICONS_ROOT = REPO_ROOT / "assets" / "app_icons"

PAT_2X = re.compile(r"^(.+)@2x(\.[^/]+)$", re.IGNORECASE)
PAT_3X = re.compile(r"^(.+)@3x(\.[^/]+)$", re.IGNORECASE)


def plan_moves() -> list[tuple[Path, Path, str]]:
    """Return list of (src, dest, reason) for each planned move."""
    if not ICONS_ROOT.is_dir():
        return []

    planned: list[tuple[Path, Path, str]] = []
    for path in sorted(ICONS_ROOT.iterdir()):
        if not path.is_file():
            continue
        name = path.name
        for pat, folder in ((PAT_2X, "2.0x"), (PAT_3X, "3.0x")):
            m = pat.match(name)
            if not m:
                continue
            base, ext = m.group(1), m.group(2)
            dest_dir = ICONS_ROOT / folder
            dest = dest_dir / f"{base}{ext}"
            if dest.exists():
                planned.append((path, dest, "skip_exists"))
            else:
                planned.append((path, dest, "move"))
            break
    return planned


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print actions without moving files.",
    )
    args = parser.parse_args()

    if not ICONS_ROOT.is_dir():
        print(f"Error: directory not found: {ICONS_ROOT}", file=sys.stderr)
        return 1

    moves = plan_moves()
    if not moves:
        print(f"No @2x/@3x files found in {ICONS_ROOT}")
        return 0

    done = 0
    for src, dest, kind in moves:
        rel_src = src.relative_to(REPO_ROOT)
        rel_dest = dest.relative_to(REPO_ROOT)
        if kind == "skip_exists":
            print(f"SKIP (exists): {rel_src} -> would be {rel_dest}")
            continue
        if args.dry_run:
            print(f"DRY-RUN: {rel_src} -> {rel_dest}")
        else:
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.move(str(src), str(dest))
            print(f"MOVED: {rel_src} -> {rel_dest}")
        done += 1

    suffix = " (dry-run)" if args.dry_run else ""
    print(f"Summary: {done} file(s){suffix}.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
