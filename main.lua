-- ViewlyXstore V2

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()

-- SETTINGS
local flySpeed = 80
local walkSpeed = 16
local flying = false
local esp = false
local infJump = false

-- UI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "ViewlyXstore"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,260,0,230)
frame.Position = UDim2.new(0,50,0,200)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0

local corner = Instance.new("UICorner",frame)
corner.CornerRadius = UDim.new(0,8)

-- TITLE
local title = Instance.new("TextLabel",frame)
title.Size = UDim2.new(1,0,0,35)
title.Text = "ViewlyXstore V2"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18

-- DRAG
local dragging
local dragInput
local dragStart
local startPos

title.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
dragging = true
dragStart = input.Position
startPos = frame.Position
end
end)

title.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
dragging = false
end
end)

UIS.InputChanged:Connect(function(input)
if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
local delta = input.Position - dragStart
frame.Position = UDim2.new(
startPos.X.Scale,
startPos.X.Offset + delta.X,
startPos.Y.Scale,
startPos.Y.Offset + delta.Y
)
end
end)

-- BUTTON FUNCTION
function createButton(text,pos,callback)

local btn = Instance.new("TextButton",frame)
btn.Size = UDim2.new(0,220,0,30)
btn.Position = UDim2.new(0,20,0,pos)
btn.Text = text
btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
btn.TextColor3 = Color3.new(1,1,1)
btn.Font = Enum.Font.Gotham
btn.TextSize = 14

local c = Instance.new("UICorner",btn)
c.CornerRadius = UDim.new(0,6)

btn.MouseButton1Click:Connect(callback)

end

-- FLY
createButton("Toggle Fly",45,function()
flying = not flying
end)

RunService.RenderStepped:Connect(function()

if flying and char:FindFirstChild("HumanoidRootPart") then

local hrp = char.HumanoidRootPart
local move = Vector3.new()

if UIS:IsKeyDown(Enum.KeyCode.W) then
move = move + workspace.CurrentCamera.CFrame.LookVector
end

if UIS:IsKeyDown(Enum.KeyCode.S) then
move = move - workspace.CurrentCamera.CFrame.LookVector
end

if UIS:IsKeyDown(Enum.KeyCode.A) then
move = move - workspace.CurrentCamera.CFrame.RightVector
end

if UIS:IsKeyDown(Enum.KeyCode.D) then
move = move + workspace.CurrentCamera.CFrame.RightVector
end

hrp.Velocity = move * flySpeed

end
end)

-- FLY SPEED
createButton("Fly Speed +20",85,function()
flySpeed = flySpeed + 20
end)

createButton("Fly Speed -20",120,function()
flySpeed = math.max(20,flySpeed-20)
end)

-- SPEED
createButton("Speed Toggle",155,function()

local hum = char:FindFirstChild("Humanoid")

if hum.WalkSpeed == 16 then
hum.WalkSpeed = 60
else
hum.WalkSpeed = 16
end

end)

-- ESP
createButton("ESP Player",190,function()

esp = not esp

for i,v in pairs(Players:GetPlayers()) do
if v ~= lp and v.Character then

if esp then

local h = Instance.new("Highlight")
h.FillColor = Color3.fromRGB(255,0,0)
h.Parent = v.Character

else

local h = v.Character:FindFirstChildOfClass("Highlight")
if h then h:Destroy() end

end

end
end

end)

-- INFINITE JUMP
createButton("Infinite Jump",225,function()
infJump = not infJump
end)

UIS.JumpRequest:Connect(function()
if infJump then
char:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
end
end)
