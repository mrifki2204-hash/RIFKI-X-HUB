-- Chiyo Loader
-- Ubah BASE di bawah ini ke repo GitHub kamu

local BASE = "https://raw.githubusercontent.com/USER/REPO/BRANCH"

local function fetch(path)
    return game:HttpGet(BASE .. "/" .. path)
end

local ok, res = pcall(function()
    local src = fetch("src/roblox/StarterPlayer/StarterPlayerScripts/init.client.lua")
    local fn = loadstring(src)
    return fn
end)

if not ok or type(res) ~= "function" then
    warn("[Chiyo] gagal memuat init.client.lua: ", res)
    return
end

-- jalankan init dengan BASE url agar module lain bisa di-`fetch`
res(BASE)

