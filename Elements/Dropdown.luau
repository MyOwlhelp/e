local Dropdown = {}
function Dropdown:Create(Fancy, container, settings)
	local Utility = Fancy.Modules.Utility
	local Icons = Fancy.Modules.Icons

	local Card, Label, Description, settings = Utility.ElementBase(Fancy, container, settings)
	Card.ClipsDescendants = true
	local baseHeight = Card.Size.Y.Offset

	Label.Size = UDim2.new(1, -140, 0, Label.Size.Y.Offset)
	if Description then
		Description.Size = UDim2.new(1, -140, 0, 14)
	end

	local options = (typeof(settings.Options) == "table" and settings.Options) or {}
	local selected = settings.Default or settings.Value
	local expanded = false

	local Chip = Fancy.Modules.Instance:Create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0, baseHeight / 2),
		Size = UDim2.fromOffset(124, 24),
		BackgroundColor3 = Fancy.Theme.Secondary[1],
		BackgroundTransparency = 0.2,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = Card,
	})
	Chip:SetAttribute("FancyBackground", "Secondary.1")
	Fancy.Modules.Instance:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Chip })

	local ValueLabel = Fancy.Modules.Instance:Create("TextLabel", {
		Position = UDim2.new(0, 8, 0, 0),
		Size = UDim2.new(1, -28, 1, 0),
		BackgroundTransparency = 1,
		Font = Fancy.Theme.Font,
		Text = selected ~= nil and tostring(selected) or "Select...",
		TextSize = 12,
		TextColor3 = Fancy.Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = Chip,
	})
	ValueLabel:SetAttribute("FancyText", "SubText")

	local Chevron = Fancy.Modules.Instance:Create("ImageLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -7, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		BackgroundTransparency = 1,
		Image = Icons.Get("chevron-down"),
		ImageColor3 = Fancy.Theme.SubText,
		Parent = Chip,
	})
	Chevron:SetAttribute("FancyImage", "SubText")

	local List = Fancy.Modules.Instance:Create("ScrollingFrame", {
		Position = UDim2.new(0, 6, 0, baseHeight),
		Size = UDim2.new(1, -12, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Fancy.Theme.Accent,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Visible = false,
		Parent = Card,
	})
	List:SetAttribute("FancyScrollBar", "Accent")
	Fancy.Modules.Instance:Create("UIListLayout", {
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = List,
	})

	local Dropdown = {}

	local function rebuild()
		for _, child in List:GetChildren() do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		for index, option in options do
			local Option = Fancy.Modules.Instance:Create("TextButton", {
				Size = UDim2.new(1, 0, 0, 24),
				BackgroundColor3 = Fancy.Theme.Secondary[1],
				BackgroundTransparency = option == selected and 0.75 or 1,
				Text = "",
				AutoButtonColor = false,
				BorderSizePixel = 0,
				LayoutOrder = index,
				Parent = List,
			})
			Option:SetAttribute("FancyBackground", "Secondary.1")
			Fancy.Modules.Instance:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Option })

			Fancy.Modules.Instance:Create("TextLabel", {
				Position = UDim2.new(0, 8, 0, 0),
				Size = UDim2.new(1, -30, 1, 0),
				BackgroundTransparency = 1,
				Font = Fancy.Theme.Font,
				Text = tostring(option),
				TextSize = 12,
				TextColor3 = option == selected and Fancy.Theme.Text or Fancy.Theme.SubText,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = Option,
			}):SetAttribute("FancyText", option == selected and "Text" or "SubText")

			if option == selected then
				local Check = Fancy.Modules.Instance:Create("ImageLabel", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -6, 0.5, 0),
					Size = UDim2.fromOffset(14, 14),
					BackgroundTransparency = 1,
					Image = Icons.Get("check"),
					ImageColor3 = Fancy.Theme.Accent,
					Parent = Option,
				})
				Check:SetAttribute("FancyImage", "Accent")
			end

			Option.MouseEnter:Connect(function()
				if option ~= selected then
					Utility.Tween(Option, 0.15, { BackgroundTransparency = 0.5 })
				end
			end)
			Option.MouseLeave:Connect(function()
				if option ~= selected then
					Utility.Tween(Option, 0.2, { BackgroundTransparency = 1 })
				end
			end)
			Option.Activated:Connect(function()
				Dropdown:Set(option)
				Dropdown:SetExpanded(false)
			end)
		end
	end

	function Dropdown:SetExpanded(state)
		expanded = state == true
		local visibleCount = math.clamp(#options, 0, 6)
		local listHeight = math.max(visibleCount * 24 + math.max(visibleCount - 1, 0) * 2, 0)

		if expanded then
			List.Size = UDim2.new(1, -12, 0, listHeight)
			rebuild()
			List.Visible = true
			Utility.Tween(Card, 0.25, { Size = UDim2.new(1, 0, 0, baseHeight + 6 + listHeight + 4) })
			Utility.Tween(Chevron, 0.25, { Rotation = 180 })
		else
			Utility.Tween(Chevron, 0.25, { Rotation = 0 })
			Utility.Tween(Card, 0.25, { Size = UDim2.new(1, 0, 0, baseHeight) })
			task.delay(0.25, function()
				if not expanded then
					List.Visible = false
				end
			end)
		end
	end

	function Dropdown:Set(option, silent)
		selected = option
		ValueLabel.Text = selected ~= nil and tostring(selected) or "Select..."
		if expanded then
			rebuild()
		end
		if not silent then
			Utility.SafeCallback(settings.Callback, selected)
		end
	end

	function Dropdown:Get()
		return selected
	end

	function Dropdown:SetOptions(newOptions)
		options = (typeof(newOptions) == "table" and newOptions) or {}
		if selected ~= nil then
			local found = false
			for _, option in options do
				if option == selected then
					found = true
					break
				end
			end
			if not found then
				selected = nil
				ValueLabel.Text = "Select..."
			end
		end
		if expanded then
			rebuild()
		end
	end

	function Dropdown:SetCallback(callback)
		settings.Callback = callback
	end

	Chip.Activated:Connect(function()
		Dropdown:SetExpanded(not expanded)
	end)
	
	if settings.Flag then
		Fancy.Modules.SaveManager.Register(settings.Flag, {
			Instance = Card,
			Get = function()
				return Dropdown:Get()
			end,
			Set = function(value)
				Dropdown:Set(value)
			end
		})
	end
	
	Dropdown.Instance = Card
	return Dropdown
end
return Dropdown