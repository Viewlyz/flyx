# Create the upgraded ViewlyXstore Lua script with ESP Player included

lua_code = r'''--[[
    ViewlyXstore Ultimate Hub
    Features:
    - Fly
    - NoClip
    - Speed Control
    - Player ESP
    - Draggable UI
    - Toggle UI (RightShift)
]]

-- SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CHARACTER
local Character
local HumanoidRootPart

local function SetupChar()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
end
SetupChar()
LocalPlayer.CharacterAdded:Connect(SetupChar)

-- SETTINGS
local FlyEnabled = false
local NoClipEnabled = false
local ESPEnabled = false
local FlySpeed = 60

local BV
local BG
local ESPContainer = {}

-- INPUT CONTROL
local Control = {F=0,B=0,L=0,R=0,U=0,D=0}

-- UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ViewlyXstoreUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0,220,0,220)
Frame.Position = UDim2.new(0.5,-110,0.5,-110)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0,35)
Title.BackgroundTransparency = 1
Title.Text = "ViewlyXstore"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

local function CreateButton(y,text)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(1,-20,0,30)
    btn.Position = UDim2.new(0,10,0,y)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Text = text
    return btn
end

local FlyBtn = CreateButton(45,"Fly: OFF")
local NoClipBtn = CreateButton(80,"NoClip: OFF")
local ESPBtn = CreateButton(115,"ESP Player: OFF")
local SpeedBtn = CreateButton(150,"Speed: 60")

-- FLY
local function StartFly()
    BV = Instance.new("BodyVelocity")
    BV.MaxForce = Vector3.new(1e5,1e5,1e5)
    BV.Velocity = Vector3.zero
    BV.Parent = HumanoidRootPart

    BG = Instance.new("BodyGyro")
    BG.MaxTorque = Vector3.new(1e5,1e5,1e5)
    BG.P = 1e4
    BG.CFrame = HumanoidRootPart.CFrame
    BG.Parent = HumanoidRootPart
end

local function StopFly()
    if BV then BV:Destroy() end
    if BG then BG:Destroy() end
end

-- ESP SYSTEM
local function CreateESP(player)
    if player == LocalPlayer then return end
    if ESPContainer[player] then return end

    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.Parent = game.CoreGui

    local function attach()
        if player.Character then
            highlight.Adornee = player.Character
        end
    end

    attach()
    player.CharacterAdded:Connect(attach)

    ESPContainer[player] = highlight
end

local function RemoveESP(player)
    if ESPContainer[player] then
        ESPContainer[player]:Destroy()
        ESPContainer[player] = nil
    end
end

local function ToggleESP(state)
    ESPEnabled = state
    if state then
        for _,p in pairs(Players:GetPlayers()) do
            CreateESP(p)
        end
    else
        for p,_ in pairs(ESPContainer) do
            RemoveESP(p)
        end
    end
end

Players.PlayerAdded:Connect(function(p)
    if ESPEnabled then
        CreateESP(p)
    end
end)

Players.PlayerRemoving:Connect(function(p)
    RemoveESP(p)
end)

-- LOOP
RunService.RenderStepped:Connect(function()
    if FlyEnabled and BV and BG then
        local camCF = Camera.CFrame
        local move = (camCF.LookVector*(Control.F+Control.B) +
                     camCF.RightVector*(Control.R+Control.L) +
                     camCF.UpVector*(Control.U+Control.D))

        BV.Velocity = move * FlySpeed
        BG.CFrame = camCF
    end

    if NoClipEnabled and Character then
        for _,v in pairs(Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

-- INPUT
UIS.InputBegan:Connect(function(i,g)
    if g then return end

    if i.KeyCode == Enum.KeyCode.W then Control.F = 1 end
    if i.KeyCode == Enum.KeyCode.S then Control.B = -1 end
    if i.KeyCode == Enum.KeyCode.A then Control.L = -1 end
    if i.KeyCode == Enum.KeyCode.D then Control.R = 1 end
    if i.KeyCode == Enum.KeyCode.Space then Control.U = 1 end
    if i.KeyCode == Enum.KeyCode.LeftControl then Control.D = -1 end

    if i.KeyCode == Enum.KeyCode.RightShift then
        Frame.Visible = not Frame.Visible
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.W then Control.F = 0 end
    if i.KeyCode == Enum.KeyCode.S then Control.B = 0 end
    if i.KeyCode == Enum.KeyCode.A then Control.L = 0 end
    if i.KeyCode == Enum.KeyCode.D then Control.R = 0 end
    if i.KeyCode == Enum.KeyCode.Space then Control.U = 0 end
    if i.KeyCode == Enum.KeyCode.LeftControl then Control.D = 0 end
end)

-- BUTTONS
FlyBtn.MouseButton1Click:Connect(function()
    FlyEnabled = not FlyEnabled
    FlyBtn.Text = "Fly: "..(FlyEnabled and "ON" or "OFF")
    if FlyEnabled then StartFly() else StopFly() end
end)

NoClipBtn.MouseButton1Click:Connect(function()
    NoClipEnabled = not NoClipEnabled
    NoClipBtn.Text = "NoClip: "..(NoClipEnabled and "ON" or "OFF")
end)

ESPBtn.MouseButton1Click:Connect(function()
    ToggleESP(not ESPEnabled)
    ESPBtn.Text = "ESP Player: "..(ESPEnabled and "ON" or "OFF")
end)

SpeedBtn.MouseButton1Click:Connect(function()
    FlySpeed += 20
    if FlySpeed > 200 then FlySpeed = 20 end
    SpeedBtn.Text = "Speed: "..FlySpeed
end)

print("ViewlyXstore Ultimate Loaded")
'''

file_path = "/mnt/data/viewlyxstore_main.lua"
with open(file_path, "w", encoding="utf-8") as f:
    f.write(lua_code)

file_path
