-- [[ TRACER SYSTEM V22 - ULTRA MINIMALIST ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 1. Configuration
local Config = {
    Thickness_FP = 2.5,
    Thickness_TP = 4.0,
    WireOp = 0.8,      -- Tracer Opacity (Wire)
    HitboxOp = 0.5,    -- Hitbox Opacity
    ShowHP = true,     -- Default HP ON
    HitboxColor = Color3.new(1, 1, 1)
}

-- 2. UI Construction
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VisualSystem_V22"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 350)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

-- Legacy Gear Button (⚙️)
local SettingsBtn = Instance.new("TextButton", MainFrame)
SettingsBtn.Size = UDim2.new(0, 30, 0, 30)
SettingsBtn.Position = UDim2.new(0, 5, 0, 5)
SettingsBtn.BackgroundTransparency = 1
SettingsBtn.Text = "⚙️"
SettingsBtn.TextColor3 = Color3.new(1, 1, 1)
SettingsBtn.TextSize = 18

-- Settings Panel (Right)
local SettingsFrame = Instance.new("Frame", MainFrame)
SettingsFrame.Size = UDim2.new(0, 130, 1, 0)
SettingsFrame.Position = UDim2.new(1, 5, 0, 0)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SettingsFrame.BorderSizePixel = 0
SettingsFrame.Visible = false

local Layout = Instance.new("UIListLayout", SettingsFrame)
Layout.Padding = UDim.new(0, 5)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local Title = Instance.new("TextLabel", SettingsFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "SET"
Title.TextColor3 = Color3.new(0.7, 0.7, 0.7)
Title.BackgroundTransparency = 1

-- Close Button (X)
local CloseButton = Instance.new("TextButton", MainFrame)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.BorderSizePixel = 0

local ScrollFrame = Instance.new("ScrollingFrame", MainFrame)
ScrollFrame.Size = UDim2.new(1, -20, 1, -55)
ScrollFrame.Position = UDim2.new(0, 10, 0, 45)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0

-- 3. Core Logic
local TrackedPlayers = {} 
local VisualCache = {} 

local function ClearPlayerVisuals(playerName)
    if VisualCache[playerName] then
        local v = VisualCache[playerName]
        if v.Line then v.Line:Destroy() end
        if v.HealthGui then v.HealthGui:Destroy() end
        if v.Boxes then for _, b in pairs(v.Boxes) do if b then b:Destroy() end end end
        VisualCache[playerName] = nil
    end
end

local function CreateVisuals(player)
    local char = player.Character
    if not char or not char:FindFirstChild("Humanoid") then return end
    local hum = char.Humanoid
    local elements = {Boxes = {}}
    
    -- Hitbox
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            local box = Instance.new("SelectionBox")
            box.Adornee = part
            box.Color3 = Config.HitboxColor
            box.LineThickness = 0.005
            box.Transparency = 1 - Config.HitboxOp
            box.Parent = part
            table.insert(elements.Boxes, box)
        end
    end

    -- Wire (Tracer)
    local line = Instance.new("LineHandleAdornment")
    line.AlwaysOnTop = true
    line.Color3 = Color3.new(1, 1, 1)
    line.Adornee = workspace.Terrain
    line.Parent = workspace.Terrain
    line.Visible = false 
    elements.Line = line

    -- HP
    local bgui = Instance.new("BillboardGui")
    bgui.Size = UDim2.new(0, 200, 0, 50)
    bgui.Adornee = char:FindFirstChild("Head")
    bgui.ExtentsOffset = Vector3.new(0, 2.5, 0)
    bgui.AlwaysOnTop = true
    bgui.Enabled = Config.ShowHP
    bgui.Parent = ScreenGui

    local nameLabel = Instance.new("TextLabel", bgui)
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextSize = 14

    local hpBack = Instance.new("Frame", bgui)
    hpBack.Size = UDim2.new(0.5, 0, 0.1, 0)
    hpBack.Position = UDim2.new(0.25, 0, 0.6, 0)
    hpBack.BackgroundColor3 = Color3.new(0, 0, 0)

    local hpMain = Instance.new("Frame", hpBack)
    hpMain.Size = UDim2.new(1, 0, 1, 0)
    hpMain.BackgroundColor3 = Color3.new(0, 1, 0)
    hpMain.BorderSizePixel = 0

    elements.HealthGui = bgui
    elements.HealthLabel = nameLabel
    elements.HealthBar = hpMain
    
    VisualCache[player.Name] = elements
end

-- 4. Loop
RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local head = myChar:FindFirstChild("Head")
    local isFP = head and head.LocalTransparencyModifier > 0.5

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not VisualCache[player.Name] and player.Character then CreateVisuals(player) end

        local cache = VisualCache[player.Name]
        if cache and player.Character then
            local tHum = player.Character:FindFirstChild("Humanoid")
            local tHead = player.Character:FindFirstChild("Head")
            if tHum and tHead then
                cache.HealthGui.Enabled = Config.ShowHP
                cache.HealthLabel.Text = player.Name .. " [" .. math.floor(tHum.Health) .. "]"
                cache.HealthBar.Size = UDim2.new(math.clamp(tHum.Health/tHum.MaxHealth, 0, 1), 0, 1, 0)
                cache.HealthBar.BackgroundColor3 = Color3.new(1, 0, 0):Lerp(Color3.new(0, 1, 0), tHum.Health/tHum.MaxHealth)
                
                if TrackedPlayers[player.Name] then
                    cache.Line.Visible = true
                    local startPos = isFP and (Camera.CFrame * CFrame.new(0, 0, -0.3)).Position or (myChar.PrimaryPart and myChar.PrimaryPart.Position or Vector3.new(0,0,0))
                    cache.Line.Thickness = isFP and Config.Thickness_FP or Config.Thickness_TP
                    cache.Line.Transparency = 1 - Config.WireOp
                    cache.Line.CFrame = CFrame.new(startPos, tHead.Position)
                    cache.Line.Length = (tHead.Position - startPos).Magnitude
                    if cache.Boxes then
                        for _, b in pairs(cache.Boxes) do b.Visible = true b.Transparency = 1 - Config.HitboxOp end
                    end
                else
                    cache.Line.Visible = false
                    if cache.Boxes then for _, b in pairs(cache.Boxes) do b.Visible = false end end
                end
            end
        end
    end
end)

-- 5. Minimal Helpers
local function AddIn(txt, def, cb)
    local f = Instance.new("Frame", SettingsFrame); f.Size = UDim2.new(1, -10, 0, 30); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.5, 0, 1, 0); l.Text = txt; l.TextColor3 = Color3.new(1,1,1); l.TextSize = 10; l.BackgroundTransparency = 1
    local i = Instance.new("TextBox", f); i.Size = UDim2.new(0.4, 0, 0.8, 0); i.Position = UDim2.new(0.55, 0, 0.1, 0); i.Text = tostring(def); i.BackgroundColor3 = Color3.fromRGB(50,50,50); i.TextColor3 = Color3.new(1,1,1); i.FocusLost:Connect(function() cb(i.Text) end)
end

local function AddTg(txt, def, cb)
    local f = Instance.new("Frame", SettingsFrame); f.Size = UDim2.new(1, -10, 0, 30); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.5, 0, 1, 0); l.Text = txt; l.TextColor3 = Color3.new(1,1,1); l.TextSize = 10; l.BackgroundTransparency = 1
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(0.4, 0, 0.8, 0); b.Position = UDim2.new(0.55, 0, 0.1, 0); b.Text = def and "ON" or "OFF"; b.BackgroundColor3 = def and Color3.new(0,0.4,0) or Color3.new(0.4,0,0); b.TextColor3 = Color3.new(1,1,1)
    b.MouseButton1Click:Connect(function() Config.ShowHP = not Config.ShowHP b.Text = Config.ShowHP and "ON" or "OFF" b.BackgroundColor3 = Config.ShowHP and Color3.new(0,0.4,0) or Color3.new(0.4,0,0) cb(Config.ShowHP) end)
end

-- Settings Layout
AddTg("HP", true, function(v) Config.ShowHP = v end)
AddIn("Wire", 0.8, function(v) Config.WireOp = tonumber(v) or 0.8 end)
AddIn("Hitbox", 0.5, function(v) Config.HitboxOp = tonumber(v) or 0.5 end)
AddIn("1p", 2.5, function(v) Config.Thickness_FP = tonumber(v) or 2.5 end)
AddIn("3p", 4.0, function(v) Config.Thickness_TP = tonumber(v) or 4.0 end)

SettingsBtn.MouseButton1Click:Connect(function() SettingsFrame.Visible = not SettingsFrame.Visible end)

local function Refresh()
    for _, c in pairs(ScrollFrame:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    local y = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local r = Instance.new("Frame", ScrollFrame); r.Size = UDim2.new(1, -10, 0, 35); r.Position = UDim2.new(0, 5, 0, y); r.BackgroundColor3 = TrackedPlayers[p.Name] and Color3.new(0, 0.4, 0) or Color3.new(0.15, 0.15, 0.15); r.BorderSizePixel = 0
            local b = Instance.new("TextButton", r); b.Size = UDim2.new(1, 0, 1, 0); b.Text = p.Name .. (TrackedPlayers[p.Name] and " [ON]" or " [OFF]"); b.TextColor3 = Color3.new(1, 1, 1); b.BackgroundTransparency = 1
            b.MouseButton1Click:Connect(function() TrackedPlayers[p.Name] = not TrackedPlayers[p.Name] or nil Refresh() end)
            y = y + 40
        end
    end
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, y)
end

CloseButton.MouseButton1Click:Connect(function() for n, _ in pairs(VisualCache) do ClearPlayerVisuals(n) end ScreenGui:Destroy() end)
Players.PlayerAdded:Connect(Refresh); Players.PlayerRemoving:Connect(function(p) ClearPlayerVisuals(p.Name) Refresh() end)
Refresh()
