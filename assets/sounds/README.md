# Trade success sound

## Current file

`trade_success_whoosh.wav` — short, snappy UI swoosh (Mixkit “Fast small sweep transition”, [Mixkit License](https://mixkit.co/license/#sfxFree)), trimmed and time-compressed for in-app use.

## Use original MetaTrader 4 `Ok.wav` (recommended if you have MT4)

MT4 plays **`Ok.wav`** on successful trade operations. To use the exact terminal sound:

1. Open MetaTrader 4 → **File** → **Open Data Folder**
2. Go to the terminal install **Sounds** folder (or copy from `MetaTrader 4/Sounds/` under Program Files on Windows)
3. Copy **`Ok.wav`** into this folder and rename it to **`trade_success_whoosh.wav`** (replace the existing file)
4. Full restart the Flutter app (not hot reload)

Supported format: WAV only.
