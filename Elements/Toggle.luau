local Toggle = {}
function Toggle:Create(Fancy, container, settings)
	local Utility = Fancy.Modules.Utility
	local Card, Label, Description, settings = Utility.ElementBase(Fancy, container, settings)
	if Description then
		Description.Size = UDim2.new(1, -60, 0, 14)
	end
	
	local Click = Fancy.Modules.Instance:Create("TextButton", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = Card,
	})

	local Track = Fancy.Modules.Instance:Create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(40, 20),
		BackgroundColor3 = Fancy.Theme.Secondary[1],
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Parent = Card,
	})
	Fancy.Modules.Instance:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Track })

	local Knob = Fancy.Modules.Instance:Create("Frame", {
		Position = UDim2.new(0, 2, 0.5, -8),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Parent = Track,
	})
	Fancy.Modules.Instance:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Knob })
	local KnobScale = Fancy.Modules.Instance:Create("UIScale", { Parent = Knob })

	local Toggle = {}
	local state = settings.Default or settings.Value or false

	local function render(instant)
		local time = instant and 0 or 0.25
		local theme = Fancy.Theme
		Track:SetAttribute("FancyBackground", state and "Accent" or "Secondary.1")
		Utility.Tween(Track, time, {
			BackgroundColor3 = state and theme.Accent or theme.Secondary[1],
		})
		Utility.Tween(Knob, time, {
			Position = UDim2.new(0, state and 22 or 2, 0.5, -8),
		})
	end

	function Toggle:Set(value, silent)
		state = value == true
		render()
		if not silent then
			Utility.SafeCallback(settings.Callback, state)
		end
	end

	function Toggle:Get()
		return state
	end

	function Toggle:SetCallback(callback)
		settings.Callback = callback
	end

	Click.MouseEnter:Connect(function()
		Utility.Tween(Card, 0.15, { BackgroundTransparency = 0.22 })
	end)
	Click.MouseLeave:Connect(function()
		Utility.Tween(Card, 0.2, { BackgroundTransparency = 0.35 })
	end)

	Click.Activated:Connect(function()
		Toggle:Set(not state)
		Utility.Tween(KnobScale, 0.07, { Scale = 1.2 })
		task.delay(0.1, function()
			Utility.Tween(KnobScale, 0.2, { Scale = 1 })
		end)
	end)
	
	if settings.Flag then
		Fancy.Modules.SaveManager.Register(settings.Flag, {
			Instance = Card,
			Get = function()
				return Toggle:Get()
			end,
			Set = function(value)
				Toggle:Set(value)
			end
		})
	end

	render(true)
	Toggle.Instance = Card
	return Toggle
end
return Toggle