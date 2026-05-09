local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Gui = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Settings")
local Sliders = Gui:WaitForChild("Sliders")

local MouseDown = false
local LastPublish = os.clock()

local SETTINGS = require(ReplicatedStorage.Libraries.Settings)
local PUBLISH_INTERVAL = 0.2 -- Arbitrary number that won't harm performance at this interval (Will be attempting quite a bit)

local function FormatDecimal(number)
	local rounded = math.round(number * 10) / 10

	if rounded % 1 == 0 then
		return tostring(math.floor(rounded))
	end

	return string.format("%.1f", rounded)
end

local function AttemptPublish(SliderType: string, Value: number)
	local ThisPublish = os.clock()
	local LastPublishAtAttempt = LastPublish

	local function Publish()
		LastPublish = ThisPublish

		ReplicatedStorage.Remotes.Settings:FireServer(SliderType, Value)
	end

	if ThisPublish - LastPublish > PUBLISH_INTERVAL then
		Publish()
	else
		task.wait(PUBLISH_INTERVAL)

		if LastPublishAtAttempt == LastPublish then
			Publish()
		end
	end
end

local function AddSlider(Slider: Frame)
	local SLIDER_TYPE = Slider.Name
	local SLIDER_SETTINGS = SETTINGS[SLIDER_TYPE]

	if not SLIDER_SETTINGS then
		warn("Invalid setting slider", Slider)

		return
	end

	local Circle = Slider:WaitForChild("Circle")
	local Button = Circle:WaitForChild("Button")
	local ValueLabel = Slider:WaitForChild("Value")

	local function Interacted()
		MouseDown = true

		while MouseDown do
			local SLIDER_POS = Slider.AbsolutePosition.X
			local SLIDER_SIZE = Slider.AbsoluteSize.X
			local MOUSE_X = Mouse.X

			local alpha = (MOUSE_X - SLIDER_POS) / SLIDER_SIZE
			alpha = math.clamp(alpha, 0, 1)

			Circle.Position = UDim2.new(alpha, 0, Circle.Position.Y.Scale, Circle.Position.Y.Offset)

			local Value = SLIDER_SETTINGS.Min + alpha * (SLIDER_SETTINGS.Max - SLIDER_SETTINGS.Min)
			ValueLabel.Text = FormatDecimal(Value)

			task.spawn(AttemptPublish, SLIDER_TYPE, Value)

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
