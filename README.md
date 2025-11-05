Chiyo UI (Plants vs Brainrots)

Ringkas: UI lokal pemain untuk Roblox dengan sidebar seperti contoh gambar, dapat dimuat via loadstring dari GitHub (raw).

Struktur:

- loader.lua
- src/roblox/StarterPlayer/StarterPlayerScripts/init.client.lua
- src/roblox/lib/ui.lua
- src/roblox/lib/config.lua
- src/roblox/lib/notify.lua

Cara pakai (ganti USER/REPO/BRANCH sesuai GitHub kamu):

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/USER/REPO/BRANCH/loader.lua"))()
```

Catatan:
- Script ini fokus pada UI/kerangka fitur (toggle, dropdown, slider, input, notifikasi, simpan konfigurasi). Kamu bisa mengisi logika per‑game di folder `src/roblox/features` (atau langsung di `init.client.lua`).
- Konfigurasi disimpan menggunakan fungsi executor (`isfile`, `writefile`, `readfile`, `makefolder`). Jika tidak tersedia, penyimpanan otomatis dinonaktifkan.

