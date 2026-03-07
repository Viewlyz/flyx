-- ViewlyXstore V3 Hub
-- UI Framework + Tabs + Toggle + Slider + Keybind + Notification

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ViewlyXstore"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

-- MAIN FRAME
local main = Instance.new("Frame",gui)
main.Size = UDim2.new(0,420,0,320)
main.Position = UDim2.new(0.5,-210,0.5,-160)
main.BackgroundColor3 = Color3.fromRGB(22,22,22)
main.BorderSizePixel = 0

Instance.new("UICorner",main).CornerRadius = UDim.new(0,8)

-- TITLE
local title = Instance.new("TextLabel",main)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "ViewlyXstore V3"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.new(1,1,1)

-- TAB BAR
local tabBar = Instance.new("Frame",main)
tabBar.Size = UDim2.new(1,0,0,35)
tabBar.Position = UDim2.new(0,0,0,40)
tabBar.BackgroundTransparency = 1

-- CONTENT
local content = Instance.new("Frame",main)
content.Size = UDim2.new(1,0,1,-75)
content.Position = UDim2.new(0,0,0,75)
content.BackgroundTransparency = 1

-- DRAG SYSTEM
local drag = false
local dragInput
local start
local startPos

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		drag = true
		start = input.Position
		startPos = main.Position
	end
end)

UIS.InputChanged:Connect(function(input)
	if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - start
		main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		drag = false
	end
end)

-- KEYBIND (RightShift)
UIS.InputBegan:Connect(function(input,gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		main.Visible = not main.Visible
	end
end)

-- TAB SYSTEM
local tabs = {}
local currentTab

function createTab(name)

	local btn = Instance.new("TextButton",tabBar)
	btn.Size = UDim2.new(0,120,1,0)
	btn.Text = name
	btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14

	local page = Instance.new("Frame",content)
	page.Size = UDim2.new(1,0,1,0)
	page.Visible = false
	page.BackgroundTransparency = 1

	btn.MouseButton1Click:Connect(function()

		if currentTab then
			currentTab.Visible = false
		end

		page.Visible = true
		currentTab = page

	end)

	table.insert(tabs,btn)

	if #tabs == 1 then
		page.Visible = true
		currentTab = page
	end

	for i,v in pairs(tabs) do
		v.Position = UDim2.new(0,(i-1)*130,0,0)
	end

	return page

end

-- UI ELEMENTS

function createToggle(parent,text)

	local btn = Instance.new("TextButton",parent)
	btn.Size = UDim2.new(0,180,0,30)
	btn.Text = text.." : OFF"
	btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 13

	local state = false

	btn.MouseButton1Click:Connect(function()

		state = not state
		btn.Text = text.." : "..(state and "ON" or "OFF")

	end)

	return btn

end

function createSlider(parent,text,min,max)

	local frame = Instance.new("Frame",parent)
	frame.Size = UDim2.new(0,200,0,40)
	frame.BackgroundTransparency = 1

	local label = Instance.new("TextLabel",frame)
	label.Size = UDim2.new(1,0,0,20)
	label.BackgroundTransparency = 1
	label.Text = text.." : "..min
	label.TextColor3 = Color3.new(1,1,1)
	label.Font = Enum.Font.Gotham
	label.TextSize = 12

	local bar = Instance.new("Frame",frame)
	bar.Size = UDim2.new(1,0,0,6)
	bar.Position = UDim2.new(0,0,0,25)
	bar.BackgroundColor3 = Color3.fromRGB(40,40,40)

	local fill = Instance.new("Frame",bar)
	fill.Size = UDim2.new(0,0,1,0)
	fill.BackgroundColor3 = Color3.fromRGB(0,170,255)

	local value = min

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then

			local pos = (input.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X
			pos = math.clamp(pos,0,1)

			fill.Size = UDim2.new(pos,0,1,0)

			value = math.floor(min + (max-min)*pos)

			label.Text = text.." : "..value

		end
	end)

	return frame

end

-- NOTIFICATION
function notify(msg)

	local note = Instance.new("TextLabel",gui)
	note.Size = UDim2.new(0,260,0,40)
	note.Position = UDim2.new(1,-270,1,-80)
	note.BackgroundColor3 = Color3.fromRGB(30,30,30)
	note.TextColor3 = Color3.new(1,1,1)
	note.Text = msg
	note.Font = Enum.Font.Gotham
	note.TextSize = 14

	Instance.new("UICorner",note)

	TweenService:Create(note,TweenInfo.new(.4),{
		Position = UDim2.new(1,-270,1,-120)
	}):Play()

	task.wait(3)

	note:Destroy()

end

-- CREATE TABS
local playerTab = createTab("Player")
local visualTab = createTab("Visual")
local settingsTab = createTab("Settings")

-- PLAYER TAB
local t1 = createToggle(playerTab,"Feature Toggle")
t1.Position = UDim2.new(0,10,0,10)

local s1 = createSlider(playerTab,"Speed",10,200)
s1.Position = UDim2.new(0,10,0,60)

-- VISUAL TAB
local t2 = createToggle(visualTab,"Visual Toggle")
t2.Position = UDim2.new(0,10,0,10)

-- SETTINGS TAB
local t3 = createToggle(settingsTab,"Enable UI Effects")
t3.Position = UDim2.new(0,10,0,10)

notify("ViewlyXstore V3 Loaded")

print("ViewlyXstore V3 Hub Ready")
