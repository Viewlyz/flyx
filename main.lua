-- VIEWLYXSTORE V5

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = Player:GetMouse()

-- SETTINGS
local Fly = false
local TurboFly = false
local NoClip = false
local InfiniteJump = false

local ESP = false
local RainbowESP = false

local Aimbot = false
local AimKey = Enum.UserInputType.MouseButton2

local Speed = 60
local FOV = 120
local Smooth = 0.15

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ViewlyXstore"
gui.Parent = game.CoreGui

-- MAIN WINDOW
local main = Instance.new("Frame",gui)
main.Size = UDim2.new(0,780,0,460)
main.Position = UDim2.new(0.5,-390,0.5,-230)
main.BackgroundColor3 = Color3.fromRGB(22,22,22)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

Instance.new("UICorner",main).CornerRadius = UDim.new(0,8)

-- SIDEBAR
local sidebar = Instance.new("Frame",main)
sidebar.Size = UDim2.new(0,170,1,0)
sidebar.BackgroundColor3 = Color3.fromRGB(17,17,17)

local layout = Instance.new("UIListLayout",sidebar)
layout.Padding = UDim.new(0,6)

local function Tab(name)

local b = Instance.new("TextButton",sidebar)

b.Size = UDim2.new(1,-10,0,40)

b.Text = name

b.BackgroundColor3 = Color3.fromRGB(30,30,30)

b.TextColor3 = Color3.new(1,1,1)

b.Font = Enum.Font.Gotham

b.TextSize = 14

Instance.new("UICorner",b)

return b

end

Tab("Movement")
Tab("ESP")
Tab("Combat")
Tab("Settings")

-- PANEL
local panel = Instance.new("Frame",main)
panel.Position = UDim2.new(0,180,0,10)
panel.Size = UDim2.new(1,-190,1,-20)
panel.BackgroundTransparency = 1

local layout2 = Instance.new("UIListLayout",panel)
layout2.Padding = UDim.new(0,10)

-- TOGGLE UI
local function Toggle(name,callback)

local f = Instance.new("Frame",panel)

f.Size = UDim2.new(1,0,0,42)

f.BackgroundColor3 = Color3.fromRGB(35,35,35)

Instance.new("UICorner",f)

local t = Instance.new("TextLabel",f)

t.Text = name

t.Size = UDim2.new(0.7,0,1,0)

t.BackgroundTransparency = 1

t.TextColor3 = Color3.new(1,1,1)

t.Font = Enum.Font.Gotham

local btn = Instance.new("TextButton",f)

btn.Size = UDim2.new(0,60,0,24)

btn.Position = UDim2.new(1,-70,0.5,-12)

btn.Text = "OFF"

btn.BackgroundColor3 = Color3.fromRGB(60,60,60)

Instance.new("UICorner",btn)

local state = false

btn.MouseButton1Click:Connect(function()

state = not state

btn.Text = state and "ON" or "OFF"

btn.BackgroundColor3 = state and Color3.fromRGB(0,170,255) or Color3.fromRGB(60,60,60)

callback(state)

end)

end

-- MOVEMENT
Toggle("Fly",function(v) Fly=v end)
Toggle("Turbo Fly",function(v) TurboFly=v end)
Toggle("NoClip",function(v) NoClip=v end)
Toggle("Infinite Jump",function(v) InfiniteJump=v end)

-- ESP
Toggle("Player ESP",function(v) ESP=v end)
Toggle("Rainbow ESP",function(v) RainbowESP=v end)

-- COMBAT
Toggle("Aimbot",function(v) Aimbot=v end)

-- FLY SYSTEM
local BV
local BG

local function StartFly()

local char = Player.Character
local hrp = char:WaitForChild("HumanoidRootPart")

BV = Instance.new("BodyVelocity",hrp)
BV.MaxForce = Vector3.new(1e5,1e5,1e5)

BG = Instance.new("BodyGyro",hrp)
BG.MaxTorque = Vector3.new(1e5,1e5,1e5)

end

RunService.RenderStepped:Connect(function()

if Fly then

if not BV then StartFly() end

local dir = Vector3.zero

if UIS:IsKeyDown(Enum.KeyCode.W) then dir+=Camera.CFrame.LookVector end
if UIS:IsKeyDown(Enum.KeyCode.S) then dir-=Camera.CFrame.LookVector end
if UIS:IsKeyDown(Enum.KeyCode.A) then dir-=Camera.CFrame.RightVector end
if UIS:IsKeyDown(Enum.KeyCode.D) then dir+=Camera.CFrame.RightVector end

local sp = TurboFly and Speed*2 or Speed

BV.Velocity = dir * sp
BG.CFrame = Camera.CFrame

end

end)

-- NOCLIP
RunService.Stepped:Connect(function()

if NoClip and Player.Character then

for _,v in pairs(Player.Character:GetDescendants()) do

if v:IsA("BasePart") then

v.CanCollide=false

end

end

end

end)

-- INFINITE JUMP
UIS.JumpRequest:Connect(function()

if InfiniteJump then

Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")

end

end)

-- AIMBOT
RunService.RenderStepped:Connect(function()

if Aimbot and UIS:IsMouseButtonPressed(AimKey) then

local closest
local dist = FOV

for _,v in pairs(Players:GetPlayers()) do

if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then

local pos,visible = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)

if visible then

local diff = (Vector2.new(pos.X,pos.Y)-Vector2.new(Mouse.X,Mouse.Y)).Magnitude

if diff < dist then

dist = diff
closest = v

end

end

end

end

if closest then

local target = closest.Character.HumanoidRootPart.Position

Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position,target),Smooth)

end

end

end)

-- UI TOGGLE
UIS.InputBegan:Connect(function(i,g)

if g then return end

if i.KeyCode == Enum.KeyCode.RightShift then

main.Visible = not main.Visible

end

end)

print("ViewlyXstore V5 Loaded")
