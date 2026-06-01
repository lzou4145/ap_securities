#!/usr/bin/env python3
"""Rename Chinese-named settings icons to English + Flutter 2.0x/3.0x layout."""

from __future__ import annotations

import shutil
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
ICONS_ROOT = REPO_ROOT / "assets" / "app_icons"

# Chinese basename -> English basename (no extension)
RENAMES = {
    "个性化交易": "ic_settings_personalized_trading",
    "切换语言": "ic_settings_switch_language",
    "客服": "ic_settings_customer_service",
    "后台链接": "ic_settings_backend_link",
    "实名认证": "ic_settings_real_name_auth",
}


def main() -> int:
    for zh, en in RENAMES.items():
        for suffix, folder in (
            ("", ICONS_ROOT),
            ("@2x", ICONS_ROOT / "2.0x"),
            ("@3x", ICONS_ROOT / "3.0x"),
        ):
            src = ICONS_ROOT / f"{zh}{suffix}.png"
            if not src.is_file():
                print(f"SKIP missing: {src.name}")
                continue
            dest = folder / f"{en}.png"
            dest.parent.mkdir(parents=True, exist_ok=True)
            if dest.exists():
                print(f"SKIP exists: {dest.relative_to(REPO_ROOT)}")
                src.unlink()
            else:
                shutil.move(str(src), str(dest))
                print(f"MOVED: {src.name} -> {dest.relative_to(REPO_ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
