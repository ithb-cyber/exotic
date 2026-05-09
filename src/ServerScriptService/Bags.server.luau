local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local BagPart = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Models"):WaitForChild("Bag")
local BagSpawn = workspace:WaitForChild("Contraption"):WaitForChild("Spawn")
local SettingsGui = script:WaitForChild("Settings")
local SettingsScript = script.Parent:WaitForChild("UIHandler")

local SETTINGS = require(ReplicatedStorage.Libraries.Settings)
local LocalSettings = {
	["Interval"] = SETTINGS.Interval.Default,
	["Effect"] = SETTINGS.Effect.Default,
}

local SingularAuthorizedUser = nil

local function SpawnBag()
	local NewBag = BagPart:Clone()
	NewBag.CFrame = BagSpawn.CFrame
	NewBag.Parent = workspace

	local SpawnEffect = TweenService:Create(
		NewBag,
		TweenInfo.new(LocalSettings.Effect, Enum.EasingStyle.Quint),
		{ CFrame = BagSpawn.CFrame - Vector3.new(0, 10, 0) }
	) --The bag is 3 studs tall, the spawn is 11 studs above the conveyor height.

	SpawnEffect:Play()
	SpawnEffect.Completed:Wait()
	NewBag.Anchored = false
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

while true do
	task.spawn(SpawnBag)
	task.wait(LocalSettings.Interval)
end
