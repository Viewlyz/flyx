-- ViewlyXstore V3
-- Modern Hub UI

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- SETTINGS
local FlyEnabled = false
local NoClip = false
local FlySpeed = 60
local TurboFly = false

local ESPEnabled = false
local RainbowESP = false

local Aimbot = false
local FOV = 120

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ViewlyXstoreV3"
gui.Parent = Player.PlayerGui

local Main = Instance.new("Frame",gui)
Main.Size = UDim2.new(0,720,0,420)
Main.Position = UDim2.new(.5,-360,.5,-210)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.BorderSizePixel = 0

Instance.new("UICorner",Main)

-- SIDEBAR

local Sidebar = Instance.new("Frame",Main)
Sidebar.Size = UDim2.new(0,180,1,0)
Sidebar.BackgroundColor3 = Color3.fromRGB(15,15,15)
Sidebar.BorderSizePixel = 0

local Layout = Instance.new("UIListLayout",Sidebar)
Layout.Padding = UDim.new(0,6)

local Title = Instance.new("TextLabel",Sidebar)
Title.Text = "ViewlyXstore"
Title.TextColor3 = Color3.new(1,1,1)
Title.Size = UDim2.new(1,0,0,40)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

-- CONTENT

local Content = Instance.new("Frame",Main)
Content.Position = UDim2.new(0,180,0,0)
Content.Size = UDim2.new(1,-180,1,0)
Content.BackgroundTransparency = 1

local List = Instance.new("UIListLayout",Content)
List.Padding = UDim.new(0,10)

-- BUTTON CREATOR

function CreateToggle(name,callback)

local Btn = Instance.new("TextButton",Content)
Btn.Size = UDim2.new(1,-20,0,40)
Btn.Text = name.." : OFF"
Btn.Font = Enum.Font.Gotham
Btn.TextSize = 14
Btn.TextColor3 = Color3.new(1,1,1)
Btn.BackgroundColor3 = Color3.fromRGB(35,35,35)

Instance.new("UICorner",Btn)

local state=false

Btn.MouseButton1Click:Connect(function()

state=not state

Btn.Text = name.." : "..(state and "ON" or "OFF")

callback(state)

end)

end

-- TOGGLES

CreateToggle("Fly",function(v)
FlyEnabled=v
end)

CreateToggle("Turbo Fly",function(v)
TurboFly=v
end)

CreateToggle("NoClip",function(v)
NoClip=v
end)

CreateToggle("Player ESP",function(v)
ESPEnabled=v
end)

CreateToggle("Rainbow ESP",function(v)
RainbowESP=v
end)

CreateToggle("Aimbot",function(v)
Aimbot=v
end)

-- SPEED SLIDER

local Slider = Instance.new("TextButton",Content)
Slider.Size = UDim2.new(1,-20,0,40)
Slider.Text = "Speed : "..FlySpeed
Slider.Font = Enum.Font.Gotham
Slider.TextSize = 14
Slider.TextColor3 = Color3.new(1,1,1)
Slider.BackgroundColor3 = Color3.fromRGB(35,35,35)

Instance.new("UICorner",Slider)

Slider.MouseButton1Click:Connect(function()

FlySpeed = FlySpeed + 20
if FlySpeed > 200 then
FlySpeed = 20
end

Slider.Text = "Speed : "..FlySpeed

end)

-- FLY SYSTEM

local BV
local BG

RunService.RenderStepped:Connect(function()

if FlyEnabled then

local root = Character:FindFirstChild("HumanoidRootPart")

if not BV then

BV = Instance.new("BodyVelocity",root)
BG = Instance.new("BodyGyro",root)

BV.MaxForce = Vector3.new(9e9,9e9,9e9)
BG.MaxTorque = Vector3.new(9e9,9e9,9e9)

end

local speed = TurboFly and FlySpeed*2 or FlySpeed

BV.Velocity = Camera.CFrame.LookVector*speed
BG.CFrame = Camera.CFrame

else

if BV then BV:Destroy() BV=nil end
if BG then BG:Destroy() BG=nil end

end

end)

-- NOCLIP

RunService.Stepped:Connect(function()

if NoClip and Character then
for _,v in pairs(Character:GetDescendants()) do
if v:IsA("BasePart") then
v.CanCollide=false
end
end
end

end)

-- ESP

local ESP = {}

function CreateESP(plr)

if plr == Player then return end

local Box = Drawing.new("Square")
Box.Thickness = 1
Box.Filled = false

local Name = Drawing.new("Text")
Name.Size = 13
Name.Center = true
Name.Outline = true

local Line = Drawing.new("Line")

ESP[plr] = {Box=Box,Name=Name,Line=Line}

end

for _,p in pairs(Players:GetPlayers()) do
CreateESP(p)
end

Players.PlayerAdded:Connect(CreateESP)

RunService.RenderStepped:Connect(function()

for plr,data in pairs(ESP) do

local char = plr.Character

if char and char:FindFirstChild("HumanoidRootPart") and ESPEnabled then

local pos,vis = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)

if vis then

local dist = math.floor((Player.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude)

local color = RainbowESP and Color3.fromHSV(tick()%5/5,1,1) or Color3.fromRGB(255,80,80)

data.Box.Color = color
data.Name.Color = color
data.Line.Color = color

data.Box.Size = Vector2.new(40,60)
data.Box.Position = Vector2.new(pos.X-20,pos.Y-30)
data.Box.Visible = true

data.Name.Text = plr.Name.." ["..dist.."]"
data.Name.Position = Vector2.new(pos.X,pos.Y-40)
data.Name.Visible = true

data.Line.From = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y)
data.Line.To = Vector2.new(pos.X,pos.Y)
data.Line.Visible = true

else

data.Box.Visible=false
data.Name.Visible=false
data.Line.Visible=false

end

else

data.Box.Visible=false
data.Name.Visible=false
data.Line.Visible=false

end

end

end)

-- AIMBOT

RunService.RenderStepped:Connect(function()

if not Aimbot then return end

local closest=nil
local dist=FOV

for _,plr in pairs(Players:GetPlayers()) do

if plr~=Player and plr.Character and plr.Character:FindFirstChild("Head") then

local pos,vis = Camera:WorldToViewportPoint(plr.Character.Head.Position)

if vis then

local mag = (Vector2.new(pos.X,pos.Y) - UIS:GetMouseLocation()).Magnitude

if mag < dist then

dist = mag
closest = plr.Character.Head

end

end

end

end

if closest then
Camera.CFrame = CFrame.new(Camera.CFrame.Position,closest.Position)
end

end)

-- UI TOGGLE

UIS.InputBegan:Connect(function(i,g)

if g then return end

if i.KeyCode == Enum.KeyCode.RightShift then
Main.Visible = not Main.Visible
end

end)
