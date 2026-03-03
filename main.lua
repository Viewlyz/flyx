--// SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// VARIABLES
local Character, HRP
local FlyEnabled = false
local NoClip = false
local FlySpeed = 80

local BV, BG

--// CHARACTER SETUP
local function SetupChar()
    Character = Player.Character or Player.CharacterAdded:Wait()
    HRP = Character:WaitForChild("HumanoidRootPart")
end
SetupChar()
Player.CharacterAdded:Connect(SetupChar)

--// UI
local FlySpeed = 16

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "FlyUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0,200,0,150)
Frame.Position = UDim2.new(0.05,0,0.3,0)
Frame.BackgroundColor3 = Color3.fromRGB(10,25,60) -- ฟ้าเข้ม
Frame.Active = true
Frame.Draggable = true

-- ทำมุมโค้ง
local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0,12)

-- เส้นขอบฟ้าเรือง ๆ
local UIStroke = Instance.new("UIStroke", Frame)
UIStroke.Color = Color3.fromRGB(0,170,255)
UIStroke.Thickness = 2

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0,30)
Title.Text = "ViewlyXstore"
Title.TextColor3 = Color3.fromRGB(0,200,255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

local FlyBtn = Instance.new("TextButton", Frame)
FlyBtn.Size = UDim2.new(0.9,0,0,30)
FlyBtn.Position = UDim2.new(0.05,0,0.3,0)
FlyBtn.Text = "Fly: OFF"
FlyBtn.BackgroundColor3 = Color3.fromRGB(0,120,255) -- ฟ้า
FlyBtn.TextColor3 = Color3.new(1,1,1)
FlyBtn.Font = Enum.Font.GothamSemibold
FlyBtn.TextSize = 14

Instance.new("UICorner", FlyBtn).CornerRadius = UDim.new(0,10)

local NoClipBtn = Instance.new("TextButton", Frame)
NoClipBtn.Size = UDim2.new(0.9,0,0,30)
NoClipBtn.Position = UDim2.new(0.05,0,0.55,0)
NoClipBtn.Text = "NoClip: OFF"
NoClipBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
NoClipBtn.TextColor3 = Color3.new(1,1,1)
NoClipBtn.Font = Enum.Font.GothamSemibold
NoClipBtn.TextSize = 14

Instance.new("UICorner", NoClipBtn).CornerRadius = UDim.new(0,10)

local SpeedLabel = Instance.new("TextLabel", Frame)
SpeedLabel.Size = UDim2.new(1,0,0,20)
SpeedLabel.Position = UDim2.new(0,0,0.8,0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.TextColor3 = Color3.fromRGB(150,220,255)
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextSize = 14
SpeedLabel.Text = "Speed: "..FlySpeed
--// FLY FUNCTIONS
local function ToggleFly()
    FlyEnabled = not FlyEnabled
    FlyBtn.Text = "Fly: "..(FlyEnabled and "ON" or "OFF")

    if FlyEnabled then
        BV = Instance.new("BodyVelocity", HRP)
        BV.MaxForce = Vector3.new(1e5,1e5,1e5)

        BG = Instance.new("BodyGyro", HRP)
        BG.MaxTorque = Vector3.new(1e5,1e5,1e5)
        BG.P = 1e4
    else
        if BV then BV:Destroy() end
        if BG then BG:Destroy() end
    end
end

FlyBtn.MouseButton1Click:Connect(ToggleFly)

NoClipBtn.MouseButton1Click:Connect(function()
    NoClip = not NoClip
    NoClipBtn.Text = "NoClip: "..(NoClip and "ON" or "OFF")
end)

--// SPEED CHANGE (SCROLL)
UIS.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        FlySpeed = math.clamp(FlySpeed + input.Position.Z*5,20,200)
        SpeedLabel.Text = "Speed: "..FlySpeed
    end
end)

--// MOVEMENT
local Control = {F=0,B=0,L=0,R=0,U=0,D=0}

UIS.InputBegan:Connect(function(i,g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.W then Control.F=1 end
    if i.KeyCode == Enum.KeyCode.S then Control.B=-1 end
    if i.KeyCode == Enum.KeyCode.A then Control.L=-1 end
    if i.KeyCode == Enum.KeyCode.D then Control.R=1 end
    if i.KeyCode == Enum.KeyCode.Space then Control.U=1 end
    if i.KeyCode == Enum.KeyCode.LeftControl then Control.D=-1 end
end)

UIS.InputEnded:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.W then Control.F=0 end
    if i.KeyCode == Enum.KeyCode.S then Control.B=0 end
    if i.KeyCode == Enum.KeyCode.A then Control.L=0 end
    if i.KeyCode == Enum.KeyCode.D then Control.R=0 end
    if i.KeyCode == Enum.KeyCode.Space then Control.U=0 end
    if i.KeyCode == Enum.KeyCode.LeftControl then Control.D=0 end
end)

--// MAIN LOOP
RunService.RenderStepped:Connect(function()
    if FlyEnabled and HRP and BV then
        local camCF = Camera.CFrame

        local move =
            camCF.LookVector*(Control.F+Control.B)+
            camCF.RightVector*(Control.R+Control.L)+
            Vector3.new(0,Control.U+Control.D,0)

        BV.Velocity = move.Magnitude>0 and move.Unit*FlySpeed or Vector3.zero
        BG.CFrame = camCF
    end

    if NoClip and Character then
        for _,v in pairs(Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)
