-- Minimal UI library with sidebar and cards
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local function getGuiParent()
    if gethui then return gethui() end
    local cg = game:FindFirstChildOfClass("CoreGui")
    return cg or Players.LocalPlayer:WaitForChild("PlayerGui")
end

local Theme = {
    Bg = Color3.fromRGB(23,25,29),
    Panel = Color3.fromRGB(31,34,39),
    Muted = Color3.fromRGB(119,127,146),
    Accent = Color3.fromRGB(86,213,154),
    Text = Color3.fromRGB(232,236,243),
    Outline = Color3.fromRGB(48,53,62),
}

local UI = {}
UI.__index = UI

local function make(instance, props, children)
    local obj = Instance.new(instance)
    for k,v in pairs(props or {}) do obj[k] = v end
    for _,c in ipairs(children or {}) do c.Parent = obj end
    return obj
end

local function applyDrag(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging, startPos, startInput
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startInput = input
            startPos = input.Position
            frame.AnchorPoint = Vector2.new(0,0)
            frame.Position = frame.Position
        end
    end)
    dragHandle.InputEnded:Connect(function(input)
        if input == startInput then dragging = false end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startPos
            frame.Position = UDim2.fromOffset(frame.Position.X.Offset + delta.X, frame.Position.Y.Offset + delta.Y)
            startPos = input.Position
        end
    end)
end

local function toggleSwitch(parent, default, callback)
    local holder = make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0,28)
    }, {})
    local back = make("Frame", {
        BackgroundColor3 = Theme.Outline,
        BorderSizePixel = 0,
        Size = UDim2.new(0,44,0,22),
        Position = UDim2.new(1,-56,0,3)
    }, {
        make("UICorner", { CornerRadius = UDim.new(0,11)}),
    })
    back.Parent = holder

    local knob = make("Frame", {
        BackgroundColor3 = Color3.fromRGB(200,205,214),
        BorderSizePixel = 0,
        Size = UDim2.new(0,18,0,18),
        Position = UDim2.new(0,2,0,2)
    }, {
        make("UICorner", { CornerRadius = UDim.new(0,9)}),
    })
    knob.Parent = back

    local btn = make("TextButton", {
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.new(1,0,1,0)
    })
    btn.Parent = back

    local state = default and true or false

    local function render()
        local goalPos = state and UDim2.new(0,24,0,2) or UDim2.new(0,2,0,2)
        local goalBack = state and Theme.Accent or Theme.Outline
        TweenService:Create(knob, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = goalPos}):Play()
        TweenService:Create(back, TweenInfo.new(0.12), {BackgroundColor3 = goalBack}):Play()
        if callback then task.spawn(callback, state) end
    end

    btn.MouseButton1Click:Connect(function()
        state = not state
        render()
    end)

    render()
    return holder, function(val) state = val; render() end
end

local function dropdown(parent, list, default, callback, multi)
    list = list or {"---"}
    local holder = make("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,32)})
    local box = make("TextButton", {
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = Theme.Text,
        Text = (multi and (default and table.concat(default, ", ") or "---")) or (default or "---"),
        Size = UDim2.new(1,0,1,0)
    }, {
        make("UICorner", {CornerRadius = UDim.new(0,6)}),
        make("UIPadding", {PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,10)})
    })
    box.Parent = holder

    local menu = make("Frame", {BackgroundColor3 = Theme.Panel, BorderSizePixel = 0, Size = UDim2.new(1,0,0,0), Position = UDim2.new(0,0,1,4), ZIndex = 50, Visible = false})
    make("UICorner", {CornerRadius = UDim.new(0,6)}).Parent = menu
    local scroll = make("ScrollingFrame", {BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1,0,1,0), CanvasSize = UDim2.new(), ScrollBarThickness = 4})
    scroll.Parent = menu
    make("UIListLayout", {Padding = UDim.new(0,4)}).Parent = scroll
    menu.Parent = holder

    local value = multi and {} or (default or list[1])

    local function setLabel()
        if multi then
            local t = {}
            for k,_ in pairs(value) do table.insert(t, k) end
            box.Text = #t > 0 and table.concat(t, ", ") or "---"
        else
            box.Text = tostring(value)
        end
    end

    local function addItem(text)
        local item = make("TextButton", {Text = text, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Theme.Text, BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, Size = UDim2.new(1,-8,0,28)})
        make("UICorner", {CornerRadius = UDim.new(0,4)}).Parent = item
        item.Parent = scroll
        item.MouseButton1Click:Connect(function()
            if multi then
                value[text] = not value[text] or nil
            else
                value = text
                menu.Visible = false
                menu.Size = UDim2.new(1,0,0,0)
            end
            setLabel()
            if callback then callback(value) end
        end)
    end

    for _,opt in ipairs(list) do addItem(opt) end

    box.MouseButton1Click:Connect(function()
        menu.Visible = not menu.Visible
        local h = math.clamp(#list * 32, 60, 180)
        TweenService:Create(menu, TweenInfo.new(0.12), {Size = menu.Visible and UDim2.new(1,0,0,h) or UDim2.new(1,0,0,0)}):Play()
    end)

    setLabel()
    return holder, function(v) value = v; setLabel(); if callback then callback(value) end end
end

local function slider(parent, min, max, default, step, callback)
    min, max = min or 0, max or 100
    default = default or min
    step = step or 1
    local holder = make("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,38)})
    local back = make("Frame", {BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, Size = UDim2.new(1,0,0,8), Position = UDim2.new(0,0,0,22)})
    make("UICorner", {CornerRadius = UDim.new(0,4)}).Parent = back
    back.Parent = holder
    local fill = make("Frame", {BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Size = UDim2.new(0,0,1,0)})
    make("UICorner", {CornerRadius = UDim.new(0,4)}).Parent = fill
    fill.Parent = back
    local valLbl = make("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 13, Text = tostring(default), TextColor3 = Theme.Muted, Size = UDim2.new(1,0,0,18), TextXAlignment = Enum.TextXAlignment.Right})
    valLbl.Parent = holder

    local value = default
    local function pctFromX(x)
        local abs = back.AbsoluteSize.X
        if abs <= 0 then return 0 end
        local rel = math.clamp((x - back.AbsolutePosition.X) / abs, 0, 1)
        local num = min + (max - min) * rel
        num = math.round(num / step) * step
        return num
    end
    local function render()
        local p = (value - min) / (max - min)
        fill.Size = UDim2.new(p,0,1,0)
        valLbl.Text = tostring(value)
        if callback then callback(value) end
    end
    render()

    local UIS = game:GetService("UserInputService")
    local dragging = false
    back.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true value = pctFromX(i.Position.X) render() end
    end)
    back.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then value = pctFromX(i.Position.X) render() end
    end)

    return holder, function(v) value = v; render() end
end

local function textInput(parent, placeholder, default, numeric, callback)
    local holder = make("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,32)})
    local box = make("TextBox", {BackgroundColor3 = Theme.Panel, BorderSizePixel = 0, PlaceholderText = placeholder or "", Text = tostring(default or ""), Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Theme.Text, Size = UDim2.new(1,0,1,0)})
    make("UICorner", {CornerRadius = UDim.new(0,6)}).Parent = box
    make("UIPadding", {PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,10)}).Parent = box
    box.Parent = holder
    box.FocusLost:Connect(function()
        local v = box.Text
        if numeric then
            v = tonumber(v) or 0
            box.Text = tostring(v)
        end
        if callback then callback(v) end
    end)
    return holder, function(v) box.Text = tostring(v) end
end

local function card(parent, title)
    local frame = make("Frame", {BackgroundColor3 = Theme.Panel, BorderSizePixel = 0, Size = UDim2.new(1,0,0,160)})
    make("UICorner", {CornerRadius = UDim.new(0,6)}).Parent = frame
    local titleLbl = make("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Text = title or "Card", TextColor3 = Theme.Text, TextSize = 14, Size = UDim2.new(1,-16,0,24), Position = UDim2.new(0,8,0,6), TextXAlignment = Enum.TextXAlignment.Left})
    titleLbl.Parent = frame
    local body = make("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,-16,1,-36), Position = UDim2.new(0,8,0,30)})
    local list = make("UIListLayout", {Padding = UDim.new(0,8)})
    list.Parent = body
    body.Parent = frame
    frame.AutomaticSize = Enum.AutomaticSize.Y
    body.AutomaticSize = Enum.AutomaticSize.Y
    return frame, body
end

function UI:CreateWindow(opts)
    opts = opts or {}
    local title = opts.Title or "Chiyo"
    local subtitle = opts.Subtitle or ""
    local keybind = opts.Keybind or Enum.KeyCode.RightControl

    local gui = make("ScreenGui", {Name = "ChiyoUI", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    gui.Parent = getGuiParent()

    local main = make("Frame", {BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, Size = UDim2.new(0,960,0,560), Position = UDim2.fromOffset(120,120)})
    make("UICorner", {CornerRadius = UDim.new(0,8)}).Parent = main
    make("UIStroke", {Color = Theme.Outline, Thickness = 1}).Parent = main
    main.Parent = gui

    local top = make("Frame", {BackgroundColor3 = Theme.Panel, BorderSizePixel = 0, Size = UDim2.new(1,0,0,40)})
    make("UICorner", {CornerRadius = UDim.new(0,8)}).Parent = top
    top.Parent = main
    local titleLbl = make("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Text = title, TextColor3 = Theme.Text, TextSize = 16, Position = UDim2.new(0,14,0,0), Size = UDim2.new(0,200,1,0), TextXAlignment = Enum.TextXAlignment.Left})
    titleLbl.Parent = top
    local subLbl = make("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.Gotham, Text = subtitle, TextColor3 = Theme.Muted, TextSize = 12, Position = UDim2.new(0,120,0,0), Size = UDim2.new(0,400,1,0), TextXAlignment = Enum.TextXAlignment.Left})
    subLbl.Parent = top

    local sidebar = make("Frame", {BackgroundColor3 = Theme.Panel, BorderSizePixel = 0, Position = UDim2.new(0,0,0,40), Size = UDim2.new(0,220,1,-40)})
    sidebar.Parent = main
    make("UIStroke", {Color = Theme.Outline, Thickness = 1}).Parent = sidebar

    local navList = make("UIListLayout", {Padding = UDim.new(0,2), SortOrder = Enum.SortOrder.LayoutOrder})
    navList.Parent = sidebar

    local content = make("Frame", {BackgroundTransparency = 1, Position = UDim2.new(0,228,0,48), Size = UDim2.new(1,-236,1,-56)})
    content.Parent = main
    local pages = {}

    local function addTab(name)
        local btn = make("TextButton", {Text = name, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Theme.Text, BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, Size = UDim2.new(1,0,0,36)})
        btn.Parent = sidebar
        local page = make("ScrollingFrame", {BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1,0,1,0), CanvasSize = UDim2.new(), ScrollBarThickness = 4, Visible = false})
        page.Parent = content
        pages[name] = page

        local grid = Instance.new("UIGridLayout")
        grid.CellPadding = UDim2.new(0,12,0,12)
        grid.CellSize = UDim2.new(0,340,0,140)
        grid.SortOrder = Enum.SortOrder.LayoutOrder
        grid.Parent = page

        btn.MouseButton1Click:Connect(function()
            for n,pg in pairs(pages) do pg.Visible = (n == name) end
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Theme.Accent}):Play()
            for _,o in ipairs(sidebar:GetChildren()) do
                if o:IsA("TextButton") and o ~= btn then o.BackgroundColor3 = Theme.Bg end
            end
        end)

        return {
            AddCard = function(_, title)
                local c, body = card(page, title)
                c.Parent = page
                return {
                    AddToggle = function(_, label, default, cb)
                        local row = make("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,28)})
                        local lbl = make("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.Gotham, Text = label, TextColor3 = Theme.Muted, TextSize = 13, Size = UDim2.new(1,-64,1,0), TextXAlignment = Enum.TextXAlignment.Left})
                        lbl.Parent = row
                        local tgl, set = toggleSwitch(row, default or false, cb)
                        tgl.Parent = row
                        row.Parent = body
                        return { Set = set }
                    end,
                    AddDropdown = function(_, label, options, default, cb, multi)
                        local row = make("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,54)})
                        local lbl = make("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.Gotham, Text = label, TextColor3 = Theme.Muted, TextSize = 13, Size = UDim2.new(1,0,0,18), TextXAlignment = Enum.TextXAlignment.Left})
                        lbl.Parent = row
                        local dd, set = dropdown(row, options, default, cb, multi)
                        dd.Position = UDim2.new(0,0,0,22)
                        dd.Parent = row
                        row.Parent = body
                        return { Set = set }
                    end,
                    AddSlider = function(_, label, min, max, default, step, cb)
                        local row = make("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,54)})
                        local lbl = make("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.Gotham, Text = label, TextColor3 = Theme.Muted, TextSize = 13, Size = UDim2.new(1,0,0,18), TextXAlignment = Enum.TextXAlignment.Left})
                        lbl.Parent = row
                        local sl, set = slider(row, min, max, default, step, cb)
                        sl.Position = UDim2.new(0,0,0,22)
                        sl.Parent = row
                        row.Parent = body
                        return { Set = set }
                    end,
                    AddInput = function(_, label, placeholder, default, numeric, cb)
                        local row = make("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,54)})
                        local lbl = make("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.Gotham, Text = label, TextColor3 = Theme.Muted, TextSize = 13, Size = UDim2.new(1,0,0,18), TextXAlignment = Enum.TextXAlignment.Left})
                        lbl.Parent = row
                        local tb, set = textInput(row, placeholder, default, numeric, cb)
                        tb.Position = UDim2.new(0,0,0,22)
                        tb.Parent = row
                        row.Parent = body
                        return { Set = set }
                    end
                }
            end
        }
    end

    local window = {
        Gui = gui,
        Main = main,
        AddTab = addTab,
        Toggle = function()
            main.Visible = not main.Visible
        end
    }

    applyDrag(main, top)

    -- keybind toggle
    local UIS = game:GetService("UserInputService")
    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == keybind then
            window.Toggle()
        end
    end)

    return window
end

return setmetatable({}, UI)

