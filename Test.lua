-- FE Usable Sword Script | Delta Executor
-- Click to swing | Fixed damage + grip

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Mouse = LocalPlayer:GetMouse()

-- Remove old swords
for _, v in pairs(Backpack:GetChildren()) do
    if v:IsA("Tool") and v.Name == "Sword" then v:Destroy() end
end
for _, v in pairs(Character:GetChildren()) do
    if v:IsA("Tool") and v.Name == "Sword" then v:Destroy() end
end

-- Create Sword
local sword = Instance.new("Tool")
sword.Name = "Sword"
sword.RequiresHandle = true
sword.CanBeDropped = false
sword.Grip = CFrame.new(0, -0.8, -1.4) * CFrame.Angles(math.rad(-90), 0, 0)
sword.Parent = Backpack

-- Handle
local handle = Instance.new("Part")
handle.Name = "Handle"
handle.Size = Vector3.new(0.3, 0.3, 1.2)
handle.BrickColor = BrickColor.new("Really black")
handle.Material = Enum.Material.Metal
handle.CanCollide = false
handle.Parent = sword

-- Blade
local blade = Instance.new("Part")
blade.Name = "Blade"
blade.Size = Vector3.new(0.2, 0.6, 3.4)
blade.BrickColor = BrickColor.new("Institutional white")
blade.Material = Enum.Material.Metal
blade.CanCollide = false
blade.Parent = sword

local weld = Instance.new("Weld")
weld.Part0 = handle
weld.Part1 = blade
weld.C0 = CFrame.new(0, 0, -2.1)
weld.Parent = handle

-- Settings
local damage = 40
local cooldown = 0.4
local canAttack = true

-- Damage function
local function dealDamage(humanoid)
    if not humanoid or humanoid.Health <= 0 then return end
    if humanoid.Parent == Character then return end

    humanoid.Health = humanoid.Health - damage
    pcall(function()
        humanoid:TakeDamage(damage)
    end)
end

-- Swing function
local function swing()
    if not canAttack then return end
    canAttack = false

    -- Simple swing animation (moves the tool)
    local originalGrip = sword.Grip
    sword.Grip = originalGrip * CFrame.Angles(math.rad(-70), 0, 0)

    -- Hit detection while swinging
    local connection
    connection = blade.Touched:Connect(function(hit)
        local humanoid = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
        if humanoid then
            dealDamage(humanoid)
        end
    end)

    task.wait(0.25)
    if connection then connection:Disconnect() end
    sword.Grip = originalGrip

    task.wait(cooldown - 0.25)
    canAttack = true
end

-- Click to attack
sword.Activated:Connect(swing)

-- Also keep passive touch damage (optional)
blade.Touched:Connect(function(hit)
    if not canAttack then -- only when swinging
        local humanoid = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
        if humanoid then
            dealDamage(humanoid)
        end
    end
end)

-- Auto equip
sword.Parent = Character

print("✅ Sword ready! Click to swing | Damage: " .. damage)
