-- init.client.lua
-- Entry point for Chiyo UI (Plants vs Brainrots)

return function(BASE_URL)
    local function requireRemote(path)
        local ok, src = pcall(function()
            return game:HttpGet(BASE_URL .. "/" .. path)
        end)
        if not ok then error("[Chiyo] gagal fetch: " .. tostring(path) .. " => " .. tostring(src)) end
        local fn, err = loadstring(src)
        if not fn then error("[Chiyo] compile error: " .. tostring(err)) end
        local mod = fn()
        return mod
    end

    local UI = requireRemote("src/roblox/lib/ui.lua")
    local Config = requireRemote("src/roblox/lib/config.lua")
    local Notify = requireRemote("src/roblox/lib/notify.lua")

    Config:Setup("Chiyo", "pvsb_config.json")
    local settings = Config:Load()

    local function get(path, default)
        local seg = settings
        for token in string.gmatch(path, "[^%.]+") do
            seg = seg and seg[token]
        end
        return (seg == nil) and default or seg
    end
    local function set(path, val)
        local seg = settings
        local last = nil
        for token in string.gmatch(path, "[^%.]+") do
            last = {tbl = seg, key = token}
            seg[token] = seg[token] or {}
            seg = seg[token]
        end
        if last then
            last.tbl[last.key] = val
        end
        Config:Save(settings)
    end

    local window = UI:CreateWindow({
        Title = "Chiyo",
        Subtitle = "Plants vs Brainrots - v2.3",
        Keybind = Enum.KeyCode.RightControl,
    })

    -- Tabs mirip screenshot
    local tabs = {
        "COMBAT","GARDEN","AUTOMATION","INVENTORY","CARDS","PROGRESSION","EVENTS","UTILITIES","WEBHOOKS","SETTINGS"
    }

    local pages = {}
    for _,name in ipairs(tabs) do
        pages[name] = window:AddTab(name)
    end

    -- COMBAT page content (contoh kartu dan kontrol)
    do
        local card1 = pages.COMBAT:AddCard("Auto Gear")
        card1:AddToggle("Enable Auto Gear", get("combat.autoGear.enabled", false), function(v)
            set("combat.autoGear.enabled", v)
            if v then Notify:Show("Auto Gear enabled") else Notify:Show("Auto Gear disabled") end
        end)
        card1:AddDropdown("Gear to Use", {"Water Bucket","Frost Grenade","Seed Bomb"}, get("combat.autoGear.gear", "Water Bucket"), function(v)
            set("combat.autoGear.gear", v)
        end)
        card1:AddDropdown("Rarity Filter", {"Common","Uncommon","Rare","Limited","Secret"}, {"Limited","Secret"}, function(v)
            set("combat.autoGear.rarity", v)
        end, true)
        card1:AddSlider("Interval Per Use (Sec)", 0.1, 20, get("combat.autoGear.interval", 0.4), 0.1, function(v)
            set("combat.autoGear.interval", v)
        end)
        card1:AddInput("Minimum HP to Attack", "5000000", get("combat.autoGear.minHp", 5000000), true, function(v)
            set("combat.autoGear.minHp", v)
        end)

        local card2 = pages.COMBAT:AddCard("Auto Potions")
        card2:AddToggle("Enable Auto Potions", get("combat.autoPotions.enabled", false), function(v)
            set("combat.autoPotions.enabled", v)
        end)
        card2:AddDropdown("Potion to Use", {"---","Speed","Damage","Shield"}, get("combat.autoPotions.potion","---"), function(v)
            set("combat.autoPotions.potion", v)
        end)
        card2:AddToggle("Use Only During Events", get("combat.autoPotions.onEvents", false), function(v)
            set("combat.autoPotions.onEvents", v)
        end)

        local card3 = pages.COMBAT:AddCard("Auto Move Plants")
        card3:AddToggle("Enable Auto Move", get("combat.move.enabled", false), function(v)
            set("combat.move.enabled", v)
        end)
        card3:AddInput("Minimum HP to Trigger", "100000", get("combat.move.minHp", 100000), true, function(v)
            set("combat.move.minHp", v)
        end)
        card3:AddDropdown("Trigger on Rarity", {"Any","Rare","Limited","Secret"}, get("combat.move.rarity","Any"), function(v)
            set("combat.move.rarity", v)
        end)
        card3:AddDropdown("Trigger on Mutation", {"Any","Bloom","Toxic","Frost"}, get("combat.move.mutation","Any"), function(v)
            set("combat.move.mutation", v)
        end)

        local card4 = pages.COMBAT:AddCard("Auto Bot")
        card4:AddToggle("Enable Auto Bat", get("combat.bot.enabled", false), function(v)
            set("combat.bot.enabled", v)
        end)
        card4:AddDropdown("Rarity Filter", {"Common","Uncommon","Rare","Limited","Secret"}, get("combat.bot.rarity","Rare"), function(v)
            set("combat.bot.rarity", v)
        end)
        card4:AddInput("Minimum HP to Attack", "0", get("combat.bot.minHp", 0), true, function(v)
            set("combat.bot.minHp", v)
        end)
    end

    -- SETTINGS page: contoh utilitas
    do
        local sCard = pages.SETTINGS:AddCard("UI Settings")
        sCard:AddDropdown("Theme Accent", {"Green","Blue","Purple"}, get("ui.accent","Green"), function(v)
            set("ui.accent", v)
            Notify:Show("Accent set to " .. tostring(v))
        end)
        sCard:AddToggle("Show Notifications", get("ui.toast", true), function(v)
            set("ui.toast", v)
        end)
        sCard:AddInput("Config Filename", "pvsb_config.json", get("ui.cfg","pvsb_config.json"), false, function(v)
            set("ui.cfg", v)
        end)

        local uCard = pages.UTILITIES:AddCard("Quick Actions")
        uCard:AddToggle("Speed Boost (WalkSpeed 32)", false, function(v)
            local lp = game.Players.LocalPlayer
            local hum = lp and lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = v and 32 or 16 end
        end)
        uCard:AddToggle("Infinite Jump", false, function(v)
            getgenv()._Chiyo_InfJump = v
        end)
    end

    -- Infinite jump handler (opsional)
    do
        local UIS = game:GetService("UserInputService")
        UIS.JumpRequest:Connect(function()
            if getgenv()._Chiyo_InfJump then
                local lp = game.Players.LocalPlayer
                local hrp = lp and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                local hum = lp and lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
                if hum and hrp then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    end

    -- default: tampilkan tab pertama
    task.defer(function()
        local first = next(pages)
        if first then for n,pg in pairs(pages) do pg.Visible = (n == first) end end
        Notify:Show("Chiyo loaded. Toggle UI: RightCtrl")
    end)
end

