local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function PrintBagID(ID: string)
	print(ID)
end

ReplicatedStorage.Remotes.BagID.OnClientEvent:Connect(PrintBagID)
