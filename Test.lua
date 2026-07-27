local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local godMode = false
local connections = {}

local function setGodMode(state)
    godMode = state
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if godMode then
        hum.MaxHealth = math.huge
        hum.Health = math.huge

        table.insert(connections, hum.HealthChanged:Connect(function()
            if godMode and hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end))

        table.insert(connections, hum:GetPropertyChangedSignal("Health"):Connect(function()
            if godMode and hum.Health <= 0 then
                hum.Health = hum.MaxHealth
            end
        end))
    else
        for _, conn in ipairs(connections) do
            conn:Disconnect()
        end
        connections = {}
        hum.MaxHealth = 100
        hum.Health = 100
    end
end

-- Re-apply on respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if godMode then
        setGodMode(true)
    end
end)

-- Keep forcing health while enabled
RunService.Heartbeat:Connect(function()
    if not godMode then return end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.MaxHealth = math.huge
            if hum.Health < math.huge then
                hum.Health = math.huge
            end
        end
    end
end)

-- Simple GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GodModeGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0, 140, 0, 40)
Button.Position = UDim2.new(0, 20, 0.5, -20)
Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.Font = Enum.Font.GothamBold
Button.TextSize = 16
Button.Text = "God Mode: OFF"
Button.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Button

Button.MouseButton1Click:Connect(function()
    setGodMode(not godMode)
    if godMode then
        Button.Text = "God Mode: ON"
        Button.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
    else
        Button.Text = "God Mode: OFF"
        Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end
end)
