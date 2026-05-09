local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Gui = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Settings")
local Sliders = Gui:WaitForChild("Sliders")

local MouseDown = false

local function AddSlider(Slider: Frame)
	local Circle = Slider:WaitForChild("Circle")
	local Button = Circle:WaitForChild("Button")

	local function Interacted()
		MouseDown = true

		while MouseDown do
			local SLIDER_POS = Slider.AbsolutePosition.X
			local SLIDER_SIZE = Slider.AbsoluteSize.X
			local MOUSE_X = Mouse.X

			local alpha = (MOUSE_X - SLIDER_POS) / SLIDER_SIZE
			alpha = math.clamp(alpha, 0, 1)

			Circle.Position = UDim2.new(alpha, 0, Circle.Position.Y.Scale, Circle.Position.Y.Offset)

			RunService.RenderStepped:Wait()
		end
	end

	Button.MouseButton1Down:Connect(Interacted)
end

for _, Slider in Sliders:GetChildren() do
	task.spawn(AddSlider, Slider)
end

Sliders.ChildAdded:Connect(AddSlider)

UserInputService.InputEnded:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1 then
		MouseDown = false
	end
end)
