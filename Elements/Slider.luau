local Slider = {}
function Slider:Create(Fancy, container, settings)
	local Utility = Fancy.Modules.Utility
	settings = typeof(settings) == "table" and settings or {}

	local hasDescription = typeof(settings.Description) == "string" and settings.Description ~= ""
	settings.Height = hasDescription and 74 or 58

	local Step = tonumber(settings.Step)
    if Step and Step <= 0 then
        Step = nil
    end

	local Card, Label, Description, settings = Utility.ElementBase(Fancy, container, settings)
	Label.Size = UDim2.new(1, -100, 0, Label.Size.Y.Offset)
	if Description then
		Description.Size = UDim2.new(1, -100, 0, 14)
	end
	
	local Min = tonumber(settings.Min) or 0
	local Max = tonumber(settings.Max) or 100
	local Precision = math.clamp(tonumber(settings.Precision or settings.Decimals) or 0, 0, 4)
	local Suffix = typeof(settings.Suffix) == "string" and settings.Suffix or ""

	local ValueLabel = Fancy.Modules.Instance:Create("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, hasDescription and 8 or 0),
		Size = UDim2.new(0, 90, 0, hasDescription and 14 or 34),
		BackgroundTransparency = 1,
		Font = Fancy.Theme.TitleFont,
		Text = "0",
		TextSize = 13,
		TextColor3 = Fancy.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = Card,
	})
	ValueLabel:SetAttribute("FancyText", "Text")

	local Track = Fancy.Modules.Instance:Create("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 10, 1, -12),
		Size = UDim2.new(1, -20, 0, 6),
		BackgroundColor3 = Fancy.Theme.Secondary[1],
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Parent = Card,
	})
	Track:SetAttribute("FancyBackground", "Secondary.1")
	Fancy.Modules.Instance:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Track })

	local Fill = Fancy.Modules.Instance:Create("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Fancy.Theme.Accent,
		BorderSizePixel = 0,
		Parent = Track,
	})
	Fill:SetAttribute("FancyBackground", "Accent")
	Fancy.Modules.Instance:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Fill })

	local Knob = Fancy.Modules.Instance:Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Parent = Track,
	})
	Fancy.Modules.Instance:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Knob })
	local KnobScale = Fancy.Modules.Instance:Create("UIScale", { Parent = Knob })

	local Slider = {}
	local value = Min
	local dragging = false

	local function formatNumber(v)
		local text
		if Precision <= 0 then
			text = Utility.Comma(math.floor(v + 0.5))
		else
			text = string.format("%." .. Precision .. "f", v)
		end
		return text .. Suffix
	end

	local function render(instant)
		local percent = (Max == Min) and 0 or (value - Min) / (Max - Min)
		if instant or dragging then
			Fill.Size = UDim2.fromScale(percent, 1)
			Knob.Position = UDim2.new(percent, 0, 0.5, 0)
		else
			Utility.Tween(Fill, 0.08, { Size = UDim2.fromScale(percent, 1) })
			Utility.Tween(Knob, 0.08, { Position = UDim2.new(percent, 0, 0.5, 0) })
		end
		ValueLabel.Text = formatNumber(value)
	end

    function Slider:Set(newValue, silent)
        newValue = tonumber(newValue) or value
        if Step then
            newValue = Min + math.floor((newValue - Min) / Step + 0.5) * Step
        end
        newValue = math.clamp(newValue, Min, Max)
        if Precision <= 0 then
            newValue = math.floor(newValue + 0.5)
        else
            local factor = 10 ^ Precision
            newValue = math.floor(newValue * factor + 0.5) / factor
        end
        value = newValue
        render()
        if not silent then
            Utility.SafeCallback(settings.Callback, value)
        end
    end

	function Slider:Get()
		return value
	end

	function Slider:SetCallback(callback)
		settings.Callback = callback
	end

	function Slider:SetRange(min, max, silent)
		Min = tonumber(min) or Min
		Max = tonumber(max) or Max
		Slider:Set(value, silent)
	end

	local Hitbox = Fancy.Modules.Instance:Create("TextButton", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 10, 1, -4),
		Size = UDim2.new(1, -20, 0, 24),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = Card,
	})

	local function updateFromX(x)
		local relative = math.clamp((x - Track.AbsolutePosition.X) / math.max(Track.AbsoluteSize.X, 1), 0, 1)
		Slider:Set(Min + (Max - Min) * relative)
	end

	Hitbox.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
            ValueLabel.TextColor3 = Fancy.Theme.Accent
			Utility.Tween(KnobScale, 0.1, { Scale = 1.3 })
			updateFromX(input.Position.X)
		end
	end)

	local endedConnection
	local changedConnection

	local function disconnect()
		endedConnection:Disconnect()
		changedConnection:Disconnect()
	end

    endedConnection = Fancy.Services.UserInputService.InputEnded:Connect(function(input)
        if not Card.Parent then disconnect() return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            ValueLabel.TextColor3 = Fancy.Theme.Text
            Utility.Tween(KnobScale, 0.18, { Scale = 1 })
        end
    end)

	changedConnection = Fancy.Services.UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if not Card.Parent then disconnect() return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			updateFromX(input.Position.X)
		end
	end)
	
    if settings.Flag then
        Fancy.Modules.SaveManager.Register(settings.Flag, {
            Instance = Card,
            Get = function()
                return Slider:Get()
            end,
            Set = function(value)
                Slider:Set(value)
            end,
        })
    end
	
	Slider:Set(settings.Default or settings.Value or Min, true)
	Slider.Instance = Card
	return Slider
end
return Slider
