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

--// CREATE UI
--// SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

--// MAIN GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "FlyUI"
ScreenGui.ResetOnSpawn = false

--// MAIN FRAME
local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 230, 0, 190)
Frame.Position = UDim2.new(0.05, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(15, 25, 45)
Frame.Active = true
Frame.Draggable = true

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,16)

local Stroke = Instance.new("UIStroke", Frame)
Stroke.Color = Color3.fromRGB(0,170,255)
Stroke.Thickness = 2

local Gradient = Instance.new("UIGradient", Frame)
Gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0,140,255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0,80,200))
}
Gradient.Rotation = 90

--// TITLE
local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Size = UDim2.new(1,0,0,35)
Title.BackgroundTransparency = 1
Title.Text = "ViewlyXstore"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.new(1,1,1)

--// CONTAINER
local Container = Instance.new("Frame")
Container.Parent = Frame
Container.Size = UDim2.new(1,0,1,-40)
Container.Position = UDim2.new(0,0,0,40)
Container.BackgroundTransparency = 1

local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0,10)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

--// BUTTON STYLE FUNCTION
local function createButton(text)
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(0.9,0,0,35)
	Btn.BackgroundColor3 = Color3.fromRGB(25,35,60)
	Btn.TextColor3 = Color3.new(1,1,1)
	Btn.TextSize = 14
	Btn.Font = Enum.Font.GothamSemibold
	Btn.Text = text
	
	Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,12)
	
	local HoverStroke = Instance.new("UIStroke", Btn)
	HoverStroke.Color = Color3.fromRGB(0,170,255)
	HoverStroke.Thickness = 0
	
	-- Hover Effect
	Btn.MouseEnter:Connect(function()
		HoverStroke.Thickness = 2
	end)
	
	Btn.MouseLeave:Connect(function()
		HoverStroke.Thickness = 0
	end)
	
	Btn.Parent = Container
	return Btn
end

--// BUTTONS
local FlyBtn = createButton("Fly: OFF")
local NoClipBtn = createButton("NoClip: OFF")
local SpeedBtn = createButton("Speed: 16")

--// TOGGLE LOGIC
local FlyEnabled = false
FlyBtn.MouseButton1Click:Connect(function()
	FlyEnabled = not FlyEnabled
	FlyBtn.Text = FlyEnabled and "Fly: ON" or "Fly: OFF"
	FlyBtn.BackgroundColor3 = FlyEnabled and Color3.fromRGB(0,170,255) or Color3.fromRGB(25,35,60)
end)

local NoClipEnabled = false
NoClipBtn.MouseButton1Click:Connect(function()
	NoClipEnabled = not NoClipEnabled
	NoClipBtn.Text = NoClipEnabled and "NoClip: ON" or "NoClip: OFF"
	NoClipBtn.BackgroundColor3 = NoClipEnabled and Color3.fromRGB(0,170,255) or Color3.fromRGB(25,35,60)
end)

local Speed = 16
SpeedBtn.MouseButton1Click:Connect(function()
	Speed = Speed + 10
	if Speed > 100 then
		Speed = 16
	end
	SpeedBtn.Text = "Speed: "..Speed
end)

--// TOGGLE UI (RightShift)
UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		Frame.Visible = not Frame.Visible
	end
end)

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
