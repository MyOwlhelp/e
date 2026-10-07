local Input = {}
function Input:Create(Fancy, container, settings)
	local Utility = Fancy.Modules.Utility
	local Card, Label, Description, settings = Utility.ElementBase(Fancy, container, settings)

	Label.Size = UDim2.new(0.5, -10, 0, Label.Size.Y.Offset)
	if Description then
		Description.Size = UDim2.new(0.5, -10, 0, 14)
	end

	local Box = Fancy.Modules.Instance:Create("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.new(0.45, 0, 0, 22),
		BackgroundTransparency = 1,
		Font = Fancy.Theme.Font,
		Text = tostring(settings.Default or settings.Value or ""),
		PlaceholderText = settings.Placeholder or "Type here...",
		TextColor3 = Fancy.Theme.Text,
		PlaceholderColor3 = Fancy.Theme.SubText,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Right,
		ClearTextOnFocus = settings.ClearOnFocus == true,
		Parent = Card,
	})
	Box:SetAttribute("FancyText", "Text")

	local Underline = Fancy.Modules.Instance:Create("Frame", {
		Position = UDim2.new(0, 0, 1, 2),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Fancy.Theme.Accent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = Box,
	})
	Underline:SetAttribute("FancyBackground", "Accent")

	Box.Focused:Connect(function()
		Utility.Tween(Underline, 0.2, { BackgroundTransparency = 0 })
	end)

	Box.FocusLost:Connect(function(enterPressed)
		Utility.Tween(Underline, 0.2, { BackgroundTransparency = 1 })
		if enterPressed or not settings.EnterOnly then
			Utility.SafeCallback(settings.Callback, Box.Text)
		end
	end)

	local Input = {}

	function Input:Set(text)
		Box.Text = tostring(text or "")
	end

	function Input:Get()
		return Box.Text
	end

	function Input:SetPlaceholder(text)
		Box.PlaceholderText = tostring(text or "")
	end

	function Input:SetCallback(callback)
		settings.Callback = callback
	end
	
	if settings.Flag then
		Fancy.Modules.SaveManager.Register(settings.Flag, {
			Instance = Card,
			Get = function()
				return Input:Get()
			end,
			Set = function(value)
				Input:Set(value)
			end
		})
	end
	
	Input.Instance = Card
	Input.Box = Box
	return Input
end
return Input