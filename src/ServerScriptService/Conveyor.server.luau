local RunService = game:GetService("RunService")

local Contraption = workspace:WaitForChild("Contraption")
local Conveyor = Contraption:WaitForChild("Conveyor")

local CONVEYOR_VELOCITY = 10

while Conveyor do
	Conveyor.AssemblyLinearVelocity = Conveyor.CFrame.LookVector * CONVEYOR_VELOCITY
	RunService.Heartbeat:Wait()
end
