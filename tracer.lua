-- [[ TRACER SYSTEM V22 - CLEAN & PRO EDITION ]] --

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 1. Configuration
local Config = {
    Thickness_FP = 2.5,
    Thickness_TP = 4.0,
    WireOp = 0.8,      -- Tracer Opacity
    HitboxOp = 0.5,    -- Hitbox Opacity
    ShowHP = true,     -- Default HP ON
    HitboxColor = Color3.new(1, 1, 1)
}

-- Variables
local TrackedPlayers = {}
local PlayerCheckboxes = {}
local VisualCache = {}

-- 2. GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RevenantESP_V22_Clean"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = game:GetService("CoreGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 370)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -185)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

-- Gear Settings Button (⚙️)
local SettingsBtn = Instance.new("TextButton")
SettingsBtn.Size = UDim2.new(0, 30, 0, 30)
SettingsBtn.Position = UDim2.new(0, 0, 0, 0)
SettingsBtn.BackgroundTransparency = 1
SettingsBtn.Text = "⚙️"
SettingsBtn.TextColor3 = Color3.new(1, 1, 1)
SettingsBtn.TextSize = 16
SettingsBtn.Parent = TitleBar

-- Title Label
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 30, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "REVENANT TRACER V22"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = TitleBar

-- Close Button (X)
local CloseButton = Instance.new("TextButton")
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 16
CloseButton.Parent = TitleBar

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Position = UDim2.new(0, 10, 0, 38)
StatusLabel.Size = UDim2.new(1, -20, 0, 22)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "0 target(s) tracked"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 15
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- Player Selection Container
local SelectionFrame = Instance.new("Frame")
SelectionFrame.Position = UDim2.new(0, 10, 0, 65)
SelectionFrame.Size = UDim2.new(1, -20, 0, 250)
SelectionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SelectionFrame.BorderSizePixel = 0
SelectionFrame.Parent = MainFrame

-- Player List ScrollFrame
local PlayerScrollFrame = Instance.new("ScrollingFrame")
PlayerScrollFrame.Position = UDim2.new(0, 5, 0, 5)
PlayerScrollFrame.Size = UDim2.new(1, -10, 1, -10)
PlayerScrollFrame.BackgroundTransparency = 1
PlayerScrollFrame.BorderSizePixel = 0
PlayerScrollFrame.ScrollBarThickness = 5
PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerScrollFrame.Parent = SelectionFrame

-- Select All / Deselect All Buttons
local SelectAllButton = Instance.new("TextButton")
SelectAllButton.Position = UDim2.new(0, 10, 0, 325)
SelectAllButton.Size = UDim2.new(0.5, -15, 0, 32)
SelectAllButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
SelectAllButton.BorderSizePixel = 0
SelectAllButton.Text = "SELECT ALL"
SelectAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectAllButton.Font = Enum.Font.SourceSansBold
SelectAllButton.TextSize = 14
SelectAllButton.Parent = MainFrame

local DeselectAllButton = Instance.new("TextButton")
DeselectAllButton.Position = UDim2.new(0.5, 5, 0, 325)
DeselectAllButton.Size = UDim2.new(0.5, -15, 0, 32)
DeselectAllButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
DeselectAllButton.BorderSizePixel = 0
DeselectAllButton.Text = "DESELECT ALL"
DeselectAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DeselectAllButton.Font = Enum.Font.SourceSansBold
DeselectAllButton.TextSize = 14
DeselectAllButton.Parent = MainFrame

-- Settings Side Panel (Right)
local SettingsFrame = Instance.new("Frame")
SettingsFrame.Size = UDim2.new(0, 150, 0, 220)
SettingsFrame.Position = UDim2.new(1, 8, 0, 0)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SettingsFrame.BorderSizePixel = 0
SettingsFrame.Visible = false
SettingsFrame.Parent = MainFrame

local SetTitle = Instance.new("TextLabel")
SetTitle.Size = UDim2.new(1, 0, 0, 30)
SetTitle.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
SetTitle.BorderSizePixel = 0
SetTitle.Text = "SETTINGS"
SetTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
SetTitle.Font = Enum.Font.SourceSansBold
SetTitle.TextSize = 14
SetTitle.Parent = SettingsFrame

local SetContainer = Instance.new("Frame")
SetContainer.Size = UDim2.new(1, -10, 1, -35)
SetContainer.Position = UDim2.new(0, 5, 0, 35)
SetContainer.BackgroundTransparency = 1
SetContainer.Parent = SettingsFrame

local Layout = Instance.new("UIListLayout", SetContainer)
Layout.Padding = UDim.new(0, 6)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- 3. Visuals & Respawn-Safe Logic
local function ClearPlayerVisuals(playerName)
    if VisualCache[playerName] then
        local v = VisualCache[playerName]
        if v.Line then v.Line:Destroy() end
        if v.HealthGui then v.HealthGui:Destroy() end
        if v.Boxes then
            for _, b in pairs(v.Boxes) do
                if b then b:Destroy() end
            end
        end
        VisualCache[playerName] = nil
    end
end

local function CreateVisuals(player)
    ClearPlayerVisuals(player.Name)
    local char = player.Character
    if not char then return end

    local hum = char:WaitForChild("Humanoid", 5)
    local head = char:WaitForChild("Head", 5)
    if not hum or not head then return end

    local elements = {Boxes = {}}

    -- Hitbox
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            local box = Instance.new("SelectionBox")
            box.Adornee = part
            box.Color3 = Config.HitboxColor
            box.LineThickness = 0.005
            box.Transparency = 1 - Config.HitboxOp
            box.Visible = false
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

    -- HP Billboard
    local bgui = Instance.new("BillboardGui")
    bgui.Size = UDim2.new(0, 200, 0, 50)
    bgui.Adornee = head
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

-- 4. UI Helpers & Player List Management
local function UpdateStatus()
    local count = 0
    for _ in pairs(TrackedPlayers) do count = count + 1 end
    if count > 0 then
        StatusLabel.Text = "Tracking " .. count .. " target(s)"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
    else
        StatusLabel.Text = "Select targets to track"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end

local function RefreshPlayerList()
    for _, child in pairs(PlayerScrollFrame:GetChildren()) do
        child:Destroy()
    end
    PlayerCheckboxes = {}

    local PlayerList = Players:GetPlayers()
    table.sort(PlayerList, function(a, b) return a.Name:lower() < b.Name:lower() end)

    local yPosition = 5
    for _, player in ipairs(PlayerList) do
        if player ~= LocalPlayer then
            local PlayerEntry = Instance.new("Frame")
            PlayerEntry.Size = UDim2.new(1, -10, 0, 30)
            PlayerEntry.Position = UDim2.new(0, 5, 0, yPosition)
            PlayerEntry.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            PlayerEntry.BorderSizePixel = 0
            PlayerEntry.Parent = PlayerScrollFrame

            local Checkbox = Instance.new("Frame")
            Checkbox.Size = UDim2.new(0, 22, 0, 22)
            Checkbox.Position = UDim2.new(0, 4, 0.5, -11)
            Checkbox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            Checkbox.BorderSizePixel = 0
            Checkbox.Parent = PlayerEntry

            local Checkmark = Instance.new("TextLabel")
            Checkmark.Size = UDim2.new(1, 0, 1, 0)
            Checkmark.BackgroundTransparency = 1
            Checkmark.Text = "✓"
            Checkmark.TextColor3 = Color3.fromRGB(0, 255, 0)
            Checkmark.TextSize = 18
            Checkmark.Font = Enum.Font.SourceSansBold
            Checkmark.Visible = TrackedPlayers[player.Name] ~= nil
            Checkmark.Parent = Checkbox

            local NameLabel = Instance.new("TextLabel")
            NameLabel.Size = UDim2.new(1, -35, 1, 0)
            NameLabel.Position = UDim2.new(0, 32, 0, 0)
            NameLabel.BackgroundTransparency = 1
            NameLabel.Text = player.Name
            NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            NameLabel.TextSize = 15
            NameLabel.Font = Enum.Font.SourceSans
            NameLabel.TextXAlignment = Enum.TextXAlignment.Left
            NameLabel.Parent = PlayerEntry

            local ClickArea = Instance.new("TextButton")
            ClickArea.Size = UDim2.new(1, 0, 1, 0)
            ClickArea.BackgroundTransparency = 1
            ClickArea.Text = ""
            ClickArea.ZIndex = 2
            ClickArea.Parent = PlayerEntry

            ClickArea.MouseButton1Click:Connect(function()
                if TrackedPlayers[player.Name] then
                    TrackedPlayers[player.Name] = nil
                    Checkmark.Visible = false
                else
                    TrackedPlayers[player.Name] = true
                    Checkmark.Visible = true
                end
                UpdateStatus()
            end)

            PlayerCheckboxes[player.Name] = {
                Entry = PlayerEntry,
                Checkmark = Checkmark
            }

            yPosition = yPosition + 35
        end
    end

    PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPosition + 5)
    UpdateStatus()
end

local function ToggleAllPlayers(select)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local data = PlayerCheckboxes[player.Name]
            if data then
                if select then
                    TrackedPlayers[player.Name] = true
                    data.Checkmark.Visible = true
                else
                    TrackedPlayers[player.Name] = nil
                    data.Checkmark.Visible = false
                end
            end
        end
    end
    UpdateStatus()
end

-- Settings Helpers
local function AddSettingInput(txt, def, cb)
    local f = Instance.new("Frame", SetContainer)
    f.Size = UDim2.new(1, 0, 0, 28)
    f.BackgroundTransparency = 1

    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(0.55, 0, 1, 0)
    l.Text = txt
    l.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    l.TextSize = 13
    l.Font = Enum.Font.SourceSans
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1

    local i = Instance.new("TextBox", f)
    i.Size = UDim2.new(0.4, 0, 0.85, 0)
    i.Position = UDim2.new(0.58, 0, 0.075, 0)
    i.Text = tostring(def)
    i.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    i.BorderSizePixel = 0
    i.TextColor3 = Color3.new(1, 1, 1)
    i.Font = Enum.Font.SourceSans
    i.TextSize = 13
    i.FocusLost:Connect(function() cb(i.Text) end)
end

local function AddSettingToggle(txt, def, cb)
    local f = Instance.new("Frame", SetContainer)
    f.Size = UDim2.new(1, 0, 0, 28)
    f.BackgroundTransparency = 1

    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(0.55, 0, 1, 0)
    l.Text = txt
    l.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    l.TextSize = 13
    l.Font = Enum.Font.SourceSans
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1

    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(0.4, 0, 0.85, 0)
    b.Position = UDim2.new(0.58, 0, 0.075, 0)
    b.Text = def and "ON" or "OFF"
    b.BackgroundColor3 = def and Color3.fromRGB(0, 140, 0) or Color3.fromRGB(140, 0, 0)
    b.BorderSizePixel = 0
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 12
    b.MouseButton1Click:Connect(function()
        Config.ShowHP = not Config.ShowHP
        b.Text = Config.ShowHP and "ON" or "OFF"
        b.BackgroundColor3 = Config.ShowHP and Color3.fromRGB(0, 140, 0) or Color3.fromRGB(140, 0, 0)
        cb(Config.ShowHP)
    end)
end

AddSettingToggle("Show HP", true, function(v) Config.ShowHP = v end)
AddSettingInput("Wire Op", 0.8, function(v) Config.WireOp = tonumber(v) or 0.8 end)
AddSettingInput("Hitbox Op", 0.5, function(v) Config.HitboxOp = tonumber(v) or 0.5 end)
AddSettingInput("1P Thick", 2.5, function(v) Config.Thickness_FP = tonumber(v) or 2.5 end)
AddSettingInput("3P Thick", 4.0, function(v) Config.Thickness_TP = tonumber(v) or 4.0 end)

-- 5. Render Loop
local RenderConn = RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local head = myChar:FindFirstChild("Head")
    local isFP = head and head.LocalTransparencyModifier > 0.5

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not VisualCache[player.Name] and player.Character then
            CreateVisuals(player)
        end

        local cache = VisualCache[player.Name]
        if cache and player.Character then
            local tHum = player.Character:FindFirstChild("Humanoid")
            local tHead = player.Character:FindFirstChild("Head")
            if tHum and tHead then
                cache.HealthGui.Enabled = Config.ShowHP
                cache.HealthLabel.Text = player.Name .. " [" .. math.floor(tHum.Health) .. "]"
                cache.HealthBar.Size = UDim2.new(math.clamp(tHum.Health / tHum.MaxHealth, 0, 1), 0, 1, 0)
                cache.HealthBar.BackgroundColor3 = Color3.new(1, 0, 0):Lerp(Color3.new(0, 1, 0), tHum.Health / tHum.MaxHealth)

                if TrackedPlayers[player.Name] then
                    cache.Line.Visible = true
                    local startPos = isFP and (Camera.CFrame * CFrame.new(0, 0, -0.3)).Position or (myChar.PrimaryPart and myChar.PrimaryPart.Position or Vector3.new(0, 0, 0))
                    cache.Line.Thickness = isFP and Config.Thickness_FP or Config.Thickness_TP
                    cache.Line.Transparency = 1 - Config.WireOp
                    cache.Line.CFrame = CFrame.new(startPos, tHead.Position)
                    cache.Line.Length = (tHead.Position - startPos).Magnitude
                    if cache.Boxes then
                        for _, b in pairs(cache.Boxes) do
                            b.Visible = true
                            b.Transparency = 1 - Config.HitboxOp
                        end
                    end
                else
                    cache.Line.Visible = false
                    if cache.Boxes then
                        for _, b in pairs(cache.Boxes) do
                            b.Visible = false
                        end
                    end
                end
            end
        end
    end
end)

-- 6. Event Connections & Cleanup
SettingsBtn.MouseButton1Click:Connect(function()
    SettingsFrame.Visible = not SettingsFrame.Visible
end)

SelectAllButton.MouseButton1Click:Connect(function()
    ToggleAllPlayers(true)
end)

DeselectAllButton.MouseButton1Click:Connect(function()
    ToggleAllPlayers(false)
end)

CloseButton.MouseButton1Click:Connect(function()
    if RenderConn then RenderConn:Disconnect() end
    for name, _ in pairs(VisualCache) do
        ClearPlayerVisuals(name)
    end
    ScreenGui:Destroy()
end)

local function BindPlayerEvents(p)
    if p == LocalPlayer then return end
    p.CharacterAdded:Connect(function()
        task.wait(1)
        CreateVisuals(p)
    end)
end

for _, p in ipairs(Players:GetPlayers()) do
    BindPlayerEvents(p)
end

Players.PlayerAdded:Connect(function(p)
    BindPlayerEvents(p)
    RefreshPlayerList()
end)

Players.PlayerRemoving:Connect(function(p)
    TrackedPlayers[p.Name] = nil
    ClearPlayerVisuals(p.Name)
    RefreshPlayerList()
end)

-- Initialize
RefreshPlayerList()
