--// SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// SETTINGS
local FlyEnabled = false
local FlySpeed = 80

--// VARIABLES
local Character, HRP
local BV, BG

--// GET CHARACTER
local function SetupChar()
    Character = Player.Character or Player.CharacterAdded:Wait()
    HRP = Character:WaitForChild("HumanoidRootPart")
end

SetupChar()
Player.CharacterAdded:Connect(SetupChar)

--// MOVEMENT
local Control = {F=0,B=0,L=0,R=0,U=0,D=0}

UIS.InputBegan:Connect(function(i,g)
    if g then return end

    if i.KeyCode == Enum.KeyCode.W then Control.F = 1 end
    if i.KeyCode == Enum.KeyCode.S then Control.B = -1 end
    if i.KeyCode == Enum.KeyCode.A then Control.L = -1 end
    if i.KeyCode == Enum.KeyCode.D then Control.R = 1 end
    if i.KeyCode == Enum.KeyCode.Space then Control.U = 1 end
    if i.KeyCode == Enum.KeyCode.LeftControl then Control.D = -1 end

    -- TOGGLE FLY
    if i.KeyCode == Enum.KeyCode.E then
        FlyEnabled = not FlyEnabled

        if FlyEnabled then
            BV = Instance.new("BodyVelocity")
            BV.MaxForce = Vector3.new(1e5,1e5,1e5)
            BV.Velocity = Vector3.zero
            BV.Parent = HRP

            BG = Instance.new("BodyGyro")
            BG.MaxTorque = Vector3.new(1e5,1e5,1e5)
            BG.P = 1e4
            BG.CFrame = HRP.CFrame
            BG.Parent = HRP
        else
            if BV then BV:Destroy() end
            if BG then BG:Destroy() end
        end
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

--// FLY LOOP
RunService.RenderStepped:Connect(function()
    if not FlyEnabled or not HRP then return end

    local camCF = Camera.CFrame

    local move =
        camCF.LookVector * (Control.F + Control.B) +
        camCF.RightVector * (Control.R + Control.L) +
        Vector3.new(0, Control.U + Control.D, 0)

    if move.Magnitude > 0 then
        BV.Velocity = move.Unit * FlySpeed
    else
        BV.Velocity = Vector3.zero
    end

    BG.CFrame = camCF
end)
