local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local EffectsFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("VFX")
local BagPart = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Models"):WaitForChild("Bag")
local Contraption = workspace:WaitForChild("Contraption")
local BagSpawn = Contraption:WaitForChild("Spawn")
local ClaimPart = Contraption:WaitForChild("Claim")
local SettingsGui = script:WaitForChild("Settings")
local SettingsScript = script.Parent:WaitForChild("UIHandler")

local SETTINGS = require(ReplicatedStorage.Libraries.Settings)
local MATERIALS = require(ReplicatedStorage.Libraries.Materials)

local BagTotal = 0
local LocalSettings = {
	["Interval"] = SETTINGS.Interval.Default,
	["Effect"] = SETTINGS.Effect.Default,
}

local SingularAuthorizedUser = nil

local function ApplyRandomColorAndMaterial(BasePart: BasePart)
	BasePart.Color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
	BasePart.Material = MATERIALS[math.random(1, #MATERIALS)]
end

local function Emit(Part)
	for _, ParticleEmitter: ParticleEmitter in Part:GetDescendants() do
		if ParticleEmitter:IsA("ParticleEmitter") then
			task.wait()
			ParticleEmitter:Emit(ParticleEmitter:GetAttribute("EmitCount") :: number? or 1)
		end
	end
end

local function SpawnVFX(Location: CFrame, EffectName: string)
	local NewEffect = EffectsFolder:WaitForChild(EffectName):Clone()
	NewEffect.CFrame = Location
	NewEffect.Parent = workspace -- Could use a debris folder here

	Emit(NewEffect)

	task.wait(0.5)

	NewEffect:Destroy()
end

local function SpawnBag()
	BagTotal += 1
	local BagID = "BAG_" .. BagTotal --Not sure what the purpose of the "ID" is so I don't know exactly how to format it

	local NewBag: BasePart = BagPart:Clone()
	local ClickDetector: ClickDetector = NewBag:WaitForChild("ClickDetector") :: ClickDetector

	local function BagClicked(Player: Player)
		print(BagID)
		ReplicatedStorage.Remotes.BagID:FireClient(Player, BagID)
	end

	ClickDetector.MouseClick:Connect(BagClicked)

	ApplyRandomColorAndMaterial(NewBag)
	NewBag.CFrame = BagSpawn.CFrame
	NewBag.Parent = workspace

	local TargetCFrame = BagSpawn.CFrame - Vector3.new(0, 10, 0)

	local SpawnEffect = TweenService:Create(
		NewBag,
		TweenInfo.new(LocalSettings.Effect, Enum.EasingStyle.Quint),
		{ CFrame = TargetCFrame }
	) --The bag is 3 studs tall, the spawn is 11 studs above the conveyor height.

	task.spawn(SpawnVFX, TargetCFrame, "Landing")

	SpawnEffect:Play()
	SpawnEffect.Completed:Wait()
	NewBag.Anchored = false

	local TouchedConnection = nil

	local function BagTouched(Hit: BasePart)
		if Hit == ClaimPart then
			TouchedConnection:Disconnect()

			task.spawn(SpawnVFX, NewBag.CFrame, "Claimed")

			NewBag:Destroy()
		end
	end

	TouchedConnection = NewBag.Touched:Connect(BagTouched)
end

local function SettingUpdated(Player: Player, SettingName: string, Value: number)
	if Player == SingularAuthorizedUser then
		LocalSettings[SettingName] = Value
	end
end

local function PlayerAdded(Player: Player)
	if not SingularAuthorizedUser then
		SingularAuthorizedUser = Player

		local NewGui = SettingsGui:Clone()
		local NewScript = SettingsScript:Clone()
		NewScript.Parent = NewGui
		NewGui.Parent = Player:WaitForChild("PlayerGui")
	end
end

local function PlayerRemoving(RemovingPlayer: Player)
	if SingularAuthorizedUser and (RemovingPlayer == SingularAuthorizedUser) then
		SingularAuthorizedUser = nil

		for _, ServerPlayer in Players:GetPlayers() do
			task.spawn(PlayerAdded, ServerPlayer)

			break
		end
	end
end

for _, Player in Players:GetPlayers() do
	task.spawn(PlayerAdded, Player)
end

Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(PlayerRemoving)
ReplicatedStorage.Remotes.Settings.OnServerEvent:Connect(SettingUpdated)

SpawnBag()
task.wait(LocalSettings.Interval)

while true do
	task.spawn(SpawnBag)
	task.wait(LocalSettings.Interval)
end
