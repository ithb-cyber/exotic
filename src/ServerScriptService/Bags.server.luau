local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local BagPart = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Models"):WaitForChild("Bag")
local BagSpawn = workspace:WaitForChild("Contraption"):WaitForChild("Spawn")

local BAG_SPAWN_INTERVAL = 1

local function SpawnBag()
	local NewBag = BagPart:Clone()
	NewBag.CFrame = BagSpawn.CFrame
	NewBag.Parent = workspace

	local SpawnEffect = TweenService:Create(
		NewBag,
		TweenInfo.new(0.5, Enum.EasingStyle.Quint),
		{ CFrame = BagSpawn.CFrame - Vector3.new(0, 10, 0) }
	) --The bag is 3 studs tall, the spawn is 11 studs above the conveyor height.

	SpawnEffect:Play()
	SpawnEffect.Completed:Wait()
	NewBag.Anchored = false
end

while true do
	task.spawn(SpawnBag)
	task.wait(BAG_SPAWN_INTERVAL)
end
