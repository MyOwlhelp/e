local Tab = {}
function Tab:Create(Fancy, settings)
	if not Fancy.Window or not Fancy.Refs then return nil end
	settings = typeof(settings) == "table" and settings or {}

	local Utility = Fancy.Modules.Utility
	local Icons = Fancy.Modules.Icons
	local Theme = Fancy.Theme
	local Refs = Fancy.Refs

	local Tab = {}
	Tab.Settings = settings

	local Button = Fancy.Modules.Instance:Create("TextButton", {
		Name = "Tab_" .. tostring(settings.Name or "Tab"),
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		LayoutOrder = #Fancy.Tabs + 1,
		Parent = Refs.TabList,
	})

	local Fill = Fancy.Modules.Instance:Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Theme.Secondary[2],
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = Button,
	})
	Fill:SetAttribute("FancyBackground", "Secondary.2")
	Fancy.Modules.Instance:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Fill })

	local Icon = Fancy.Modules.Instance:Create("ImageLabel", {
		Position = UDim2.new(0, 15, 0.5, -9),
		Size = UDim2.fromOffset(18, 18),
		BackgroundTransparency = 1,
		Image = Icons.Get(settings.Icon),
		ImageColor3 = Theme.SubText,
		Parent = Button,
	})
	Icon:SetAttribute("FancyImage", "SubText")

	local Label = Fancy.Modules.Instance:Create("TextLabel", {
		Position = UDim2.new(0, 42, 0, 0),
		Size = UDim2.new(1, -50, 1, 0),
		BackgroundTransparency = 1,
		Font = Theme.Font,
		Text = tostring(settings.Name or "Tab"),
		TextSize = 13,
		TextColor3 = Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = Button
	})
	Label:SetAttribute("FancyText", "SubText")

	local Indicator
	if Refs.TabIndicator then
		Indicator = Refs.TabIndicator
	else
		Indicator = Fancy.Modules.Instance:Create("Frame", {
			Name = "TabIndicator",
			Position = UDim2.new(0, 4, 0.5, -8),
			Size = UDim2.new(0, 3, 0, 16),
			BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Parent = Button,
		})
		Indicator:SetAttribute("FancyBackground", "Accent")
		Fancy.Modules.Instance:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Indicator })
		Refs.TabIndicator = Indicator
	end

	local Page = Fancy.Modules.Instance:Create("ScrollingFrame", {
		Name = "Page",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Accent,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Visible = false,
		Parent = Refs.PageHolder,
	})
	Page:SetAttribute("FancyScrollBar", "Accent")
	Fancy.Modules.Instance:Create("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = Page,
	})
	Fancy.Modules.Instance:Create("UIPadding", {
		PaddingTop = UDim.new(0, 2),
		PaddingBottom = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 0),
		PaddingRight = UDim.new(0, 4),
		Parent = Page,
	})

	function Tab:Select()
		if Fancy.SelectedTab == Tab then return end
		local previous = Fancy.SelectedTab
		Fancy.SelectedTab = Tab
		if previous then previous:Deselect() end

		local theme = Fancy.Theme
		if Indicator.Parent ~= Button then
			local old = Indicator.AbsolutePosition
			Indicator.Parent = Button
			Indicator.Position = UDim2.fromOffset(
				old.X - Button.AbsolutePosition.X,
				old.Y - Button.AbsolutePosition.Y
			)
		end
		Indicator.BackgroundTransparency = 0
		Utility.Tween(Indicator, 0.28, { Position = UDim2.new(0, 4, 0.5, -8) }, Enum.EasingStyle.Quart)

		Utility.Tween(Fill, 0.25, { BackgroundTransparency = 0.78 })
		Utility.Tween(Icon, 0.22, { ImageColor3 = theme.Text, Position = UDim2.new(0, 17, 0.5, -9) })
		Utility.Tween(Label, 0.22, { TextColor3 = theme.Text, Position = UDim2.new(0, 44, 0, 0) })

		Page.Visible = true
		Page.Position = UDim2.new(0, 10, 0, 0)
		Utility.Tween(Page, 0.22, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Quart)

		Utility.Tween(Refs.PageTitle, 0.09, { TextTransparency = 1 })
		task.delay(0.1, function()
			if Fancy.SelectedTab == Tab and Refs.PageTitle and Refs.PageTitle.Parent then
				Refs.PageTitle.Text = tostring(settings.Name or "Tab")
				Utility.Tween(Refs.PageTitle, 0.14, { TextTransparency = 0 })
			end
		end)
	end

	function Tab:Deselect()
		local theme = Fancy.Theme
		Utility.Tween(Fill, 0.25, { BackgroundTransparency = 1 })
		Utility.Tween(Icon, 0.22, { ImageColor3 = theme.SubText, Position = UDim2.new(0, 15, 0.5, -9) })
		Utility.Tween(Label, 0.22, { TextColor3 = theme.SubText, Position = UDim2.new(0, 42, 0, 0) })
		Page.Visible = false
	end

	function Tab:SetTitle(text)
		local value = tostring(text or "Tab")
		settings.Name = value
		Label.Text = value
		if Fancy.SelectedTab == Tab then
			Refs.PageTitle.Text = value
		end
	end

	Button.Activated:Connect(function()
		Tab:Select()
	end)

	Button.MouseEnter:Connect(function()
		if Fancy.SelectedTab ~= Tab then
			Utility.Tween(Fill, 0.15, { BackgroundTransparency = 0.88 })
		end
	end)

	Button.MouseLeave:Connect(function()
		if Fancy.SelectedTab ~= Tab then
			Utility.Tween(Fill, 0.2, { BackgroundTransparency = 1 })
		end
	end)

	function Tab:NewSection(props)
		return Fancy.Elements.Section:Create(Fancy, Page, props)
	end

	local elements = {
		NewButton = "Button",
		NewToggle = "Toggle",
		NewSlider = "Slider",
		NewInput = "Input",
		NewParagraph = "Paragraph",
		NewKeybind = "Keybind",
		NewDropdown = "Dropdown",
	}

	for methodName, elementName in elements do
		Tab[methodName] = function(_, props)
			return Fancy.Elements[elementName]:Create(Fancy, Page, props)
		end
	end

	Tab.Button = Button
	Tab.Page = Page

	table.insert(Fancy.Tabs, Tab)
	if #Fancy.Tabs == 1 then
		Tab:Select()
	end

	return Tab
end
return Tab