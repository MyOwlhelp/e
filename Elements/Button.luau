local Button = {}
function Button:Create(Fancy, container, settings)
	local Utility = Fancy.Modules.Utility
	local Icons = Fancy.Modules.Icons
	local Card, Label, Description, settings = Utility.ElementBase(Fancy, container, settings)

	local Icon
	if settings.Icon then
		Icon = Fancy.Modules.Instance:Create("ImageLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(16, 16),
			BackgroundTransparency = 1,
			Image = Icons.Get(settings.Icon),
			ImageColor3 = Fancy.Theme.SubText,
			Parent = Card,
		})
		Icon:SetAttribute("FancyImage", "SubText")
		if Description then
			Description.Size = UDim2.new(1, -34, 0, 14)
		end
	end

	local Click = Fancy.Modules.Instance:Create("TextButton", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = Card,
	})

	Click.MouseEnter:Connect(function()
		Utility.Tween(Card, 0.15, { BackgroundTransparency = 0.15 })
		if Icon then
			Utility.Tween(Icon, 0.15, { ImageColor3 = Fancy.Theme.Text })
		end
	end)
	
	Click.MouseLeave:Connect(function()
		Utility.Tween(Card, 0.2, { BackgroundTransparency = 0.35 })
		if Icon then
			Utility.Tween(Icon, 0.2, { ImageColor3 = Fancy.Theme.SubText })
		end
	end)
	
	Click.MouseButton1Down:Connect(function()
		Utility.Tween(Card, 0.08, { BackgroundTransparency = 0.05 })
	end)
	
	Click.MouseButton1Up:Connect(function()
		Utility.Tween(Card, 0.12, { BackgroundTransparency = 0.15 })
	end)
	
	Click.Activated:Connect(function()
		Utility.SafeCallback(settings.Callback)
	end)

	local Button = {}

	function Button:SetText(text)
		Label.Text = tostring(text or "")
	end

	function Button:SetIcon(name)
		if Icon then Icon.Image = Icons.Get(name) end
	end

	function Button:SetDescription(text)
		if Description then Description.Text = tostring(text or "") end
	end

	function Button:SetCallback(callback)
		settings.Callback = callback
	end

	function Button:Fire()
		Utility.SafeCallback(settings.Callback)
	end

	Button.Instance = Card
	return Button
end
return Button