-- God Mode (Anti Item / Sword / Tool Damage) - Delta Executor
-- Click the button to toggle ON/OFF

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local godMode = false
local connections = {}

local function clearConnections()
	for _, conn in ipairs(connections) do
		pcall(function() conn:Disconnect() end)
	end
	connections = {}
end

local function protect(hum)
	if not hum then return end

	hum.MaxHealth = math.huge
	hum.Health = math.huge
	hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

	-- Instantly restore any damage (works against most tools/swords)
	table.insert(connections, hum.HealthChanged:Connect(function()
		if godMode then
			hum.Health = math.huge
		end
	end))

	table.insert(connections, hum:GetPropertyChangedSignal("Health"):Connect(function()
		if godMode then
			hum.Health = math.huge
		end
	end))

	table.insert(connections, hum:GetPropertyChangedSignal("MaxHealth"):Connect(function()
		if godMode then
			hum.MaxHealth = math.huge
		end
	end))

	table.insert(connections, hum.Died:Connect(function()
		if godMode then
			hum.Health = math.huge
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end))
end

local function setGodMode(state)
	godMode = state
	clearConnections()

	local char = LocalPlayer.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	if godMode then
		protect(hum)
	else
		hum.MaxHealth = 100
		hum.Health = 100
		hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
		hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
		hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
	end
end

-- Re-apply on respawn
LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.35)
	if godMode then
		setGodMode(true)
	end
end)

-- Force protection every frame (this is what stops sword/tool damage)
RunService.Heartbeat:Connect(function()
	if not godMode then return end

	local char = LocalPlayer.Character
	if not char then return end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.MaxHealth = math.huge
		hum.Health = math.huge
		hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	end
end)

-- Extra fast loop (helps against fast tool damage scripts)
RunService.RenderStepped:Connect(function()
	if not godMode then return end
	local char = LocalPlayer.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health < math.huge then
			hum.Health = math.huge
		end
	end
end)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GodModeGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0, 170, 0, 42)
Button.Position = UDim2.new(0, 20, 0.5, -21)
Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.Font = Enum.Font.GothamBold
Button.TextSize = 15
Button.Text = "God Mode: OFF"
Button.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Button

Button.MouseButton1Click:Connect(function()
	setGodMode(not godMode)
	if godMode then
		Button.Text = "God Mode: ON"
		Button.BackgroundColor3 = Color3.fromRGB(0, 170, 70)
	else
		Button.Text = "God Mode: OFF"
		Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	end
end)
