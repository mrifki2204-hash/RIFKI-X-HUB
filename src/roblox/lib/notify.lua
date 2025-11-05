local TweenService = game:GetService("TweenService")

local Notify = {}

local function getGuiParent()
    if gethui then return gethui() end
    local cg = game:FindFirstChildOfClass("CoreGui")
    return cg or game.Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function createRoot()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ChiyoNotify"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = getGuiParent()

    local holder = Instance.new("Frame")
    holder.Name = "Holder"
    holder.AnchorPoint = Vector2.new(1,0)
    holder.Position = UDim2.new(1,-20,0,20)
    holder.Size = UDim2.new(0,350,1,-40)
    holder.BackgroundTransparency = 1
    holder.Parent = gui

    local list = Instance.new("UIListLayout")
    list.FillDirection = Enum.FillDirection.Vertical
    list.HorizontalAlignment = Enum.HorizontalAlignment.Right
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0,8)
    list.Parent = holder

    return gui, holder
end

local Gui, Holder

function Notify:Show(text, timeSec)
    if not Gui or not Gui.Parent then Gui, Holder = createRoot() end
    timeSec = timeSec or 3

    local item = Instance.new("Frame")
    item.BackgroundColor3 = Color3.fromRGB(32,36,40)
    item.BackgroundTransparency = 0.05
    item.BorderSizePixel = 0
    item.Size = UDim2.new(1,0,0,0)
    item.Parent = Holder

    local corner = Instance.new("UICorner", item)
    corner.CornerRadius = UDim.new(0,6)

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.Text = tostring(text)
    lbl.TextColor3 = Color3.fromRGB(225,229,235)
    lbl.TextSize = 14
    lbl.TextWrapped = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Size = UDim2.new(1,-20,1,-20)
    lbl.Position = UDim2.new(0,10,0,10)
    lbl.Parent = item

    item.ClipsDescendants = true
    item.Size = UDim2.new(1,0,0,0)
    TweenService:Create(item, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,48)}):Play()

    task.delay(timeSec, function()
        if item and item.Parent then
            local t = TweenService:Create(item, TweenInfo.new(0.2), {BackgroundTransparency = 1})
            t:Play()
            t.Completed:Wait()
            item:Destroy()
        end
    end)
end

return Notify

