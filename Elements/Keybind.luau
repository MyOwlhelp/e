local Keybind = {}
function Keybind:Create(Fancy, container, settings)
	local Utility = Fancy.Modules.Utility
	local Card, Label, Description, settings = Utility.ElementBase(Fancy, container, settings)
	if Description then
		Description.Size = UDim2.new(1, -80, 0, 14)
	end

	local Chip = Fancy.Modules.Instance:Create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(64, 24),
		BackgroundColor3 = Fancy.Theme.Secondary[1],
		BackgroundTransparency = 0.2,
		Font = Fancy.Theme.Font,
		Text = settings.Default and settings.Default.Name or "None",
		TextSize = 12,
		TextColor3 = Fancy.Theme.SubText,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = Card,
	})
	Chip:SetAttribute("FancyBackground", "Secondary.1")
	Chip:SetAttribute("FancyText", "SubText")
	Fancy.Modules.Instance:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Chip })

	local Keybind = {}
	local key = settings.Default
	local listening = false

	local connection
	connection = Fancy.Services.UserInputService.InputBegan:Connect(function(input, processed)
		if not Card.Parent then
			connection:Disconnect()
			return
		end

		if listening then
			if input.KeyCode ~= Enum.KeyCode.Escape and input.UserInputType == Enum.UserInputType.Keyboard then
				key = input.KeyCode
			end
			listening = false
			Chip.Text = key and key.Name or "None"
			Chip.TextColor3 = Fancy.Theme.SubText
			return
		end

		if processed then return end
		if key and input.KeyCode == key then
			Utility.SafeCallback(settings.Callback, key)
		end
	end)

	Chip.Activated:Connect(function()
		listening = true
		Chip.Text = "..."
		Chip.TextColor3 = Fancy.Theme.Accent
	end)

	function Keybind:Set(keyCode)
		key = keyCode
		Chip.Text = key and key.Name or "None"
	end

	function Keybind:Get()
		return key
	end

	function Keybind:SetCallback(callback)
		settings.Callback = callback
	end
	
	if settings.Flag then
		Fancy.Modules.SaveManager.Register(settings.Flag, {
			Instance = Card,
			Get = function()
				local key = Keybind:Get()
				return key and key.Name or nil
			end,
			Set = function(value)
				if typeof(value) == "string" then
					value = Enum.KeyCode[value]
				end
				Keybind:Set(value)
			end
		})
	end
	
	Keybind.Instance = Card
	return Keybind
end
return Keybind