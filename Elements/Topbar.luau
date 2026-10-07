local Topbar = {}

local TOP_OFFSET = 14
local GAP = 6

local function Reflow(Fancy)
	local y = TOP_OFFSET
	for _, bar in Fancy.Topbars do
		if bar.Instance and bar.Instance.Parent and not bar.Dragged then
			bar.Instance.Position = UDim2.new(0.5, 0, 0, y)
			y += (bar.Height or 28) + GAP
		end
	end
end

function Topbar:Create(Fancy, settings)
    local Host = Fancy.TopbarUI or Fancy.MainUI
    if not Host then return nil end
    settings = typeof(settings) == "table" and settings or {}

	local Utility = Fancy.Modules.Utility
	local Icons = Fancy.Modules.Icons
	local UserInputService = Fancy.Services.UserInputService

	local Theme = Fancy.Theme or Fancy.Themes.Default

	Fancy.Topbars = Fancy.Topbars or {}

	local TextSize = math.clamp(tonumber(settings.TextSize) or 12, 8, 20)
	local Height = TextSize + 16

	local Pill = Fancy.Modules.Instance:Create("Frame", {
		Name = "Topbar_" .. tostring(settings.Name or #Fancy.Topbars + 1),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, TOP_OFFSET),
		Size = UDim2.fromOffset(0, Height),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Theme.Primary,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
        ZIndex = 10,
        Parent = Host
    })
	Pill:SetAttribute("FancyBackground", "Primary")

	Fancy.Modules.Instance:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Pill })

	do
		local stroke = Fancy.Modules.Instance:Create("UIStroke", {
			Color = Theme.Stroke,
			Transparency = Theme.StrokeTransparency or 0.92,
			Parent = Pill,
		})
		stroke:SetAttribute("FancyStroke", "Stroke")
	end

	Fancy.Modules.Instance:Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 8),
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = Pill,
	})

	Fancy.Modules.Instance:Create("UIPadding", {
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent = Pill,
	})

	local Dot = Fancy.Modules.Instance:Create("Frame", {
		Size = UDim2.fromOffset(6, 6),
		BackgroundColor3 = settings.Color or Theme.Accent,
		BorderSizePixel = 0,
		Visible = not settings.Icon,
		LayoutOrder = 1,
		Parent = Pill,
	})
	if not settings.Color then
		Dot:SetAttribute("FancyBackground", "Accent")
	end
	Fancy.Modules.Instance:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Dot })

	local Icon = Fancy.Modules.Instance:Create("ImageLabel", {
		Size = UDim2.fromOffset(TextSize + 2, TextSize + 2),
		BackgroundTransparency = 1,
		Image = Icons.Get(settings.Icon),
		ImageColor3 = settings.Color or Theme.Accent,
		Visible = settings.Icon ~= nil,
		LayoutOrder = 1,
		Parent = Pill,
	})
	if not settings.Color then
		Icon:SetAttribute("FancyImage", "Accent")
	end

	local Label = Fancy.Modules.Instance:Create("TextLabel", {
		Size = UDim2.fromOffset(0, TextSize + 4),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Font = settings.Font or Theme.Font,
		Text = tostring(settings.Text or settings.Default or "Topbar"),
		TextSize = TextSize,
		TextColor3 = Theme.Text,
		RichText = settings.RichText == true,
		LayoutOrder = 2,
		Parent = Pill,
	})
	Label:SetAttribute("FancyText", "Text")

    local Topbar = {}
    Topbar.Instance = Pill
    Topbar.Height = Height
    Topbar.Dragged = false
    Topbar.Persistent = settings.Persistent == false

	local connections = {}
	local dragging = false
	local dragStart, startPos

	Pill.InputBegan:Connect(function(input)
		if not Pill.Parent then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = Pill.Position
		end
	end)

	table.insert(connections, UserInputService.InputEnded:Connect(function(input)
		if not Pill.Parent then
			for _, connection in connections do connection:Disconnect() end
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end))

	table.insert(connections, UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if not Pill.Parent then
			for _, connection in connections do connection:Disconnect() end
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart
			if not Topbar.Dragged and (math.abs(delta.X) > 3 or math.abs(delta.Y) > 3) then
				Topbar.Dragged = true
				Pill.ZIndex = 12
			end
			if Topbar.Dragged then
				Pill.Position = UDim2.new(
					startPos.X.Scale, startPos.X.Offset + delta.X,
					startPos.Y.Scale, startPos.Y.Offset + delta.Y
				)
			end
		end
	end))

	Pill.MouseEnter:Connect(function()
		Utility.Tween(Pill, 0.15, { BackgroundTransparency = 0 })
	end)
	Pill.MouseLeave:Connect(function()
		Utility.Tween(Pill, 0.2, { BackgroundTransparency = 0.08 })
	end)

	function Topbar:SetText(text)
		Label.Text = tostring(text or "")
	end

	function Topbar:GetText()
		return Label.Text
	end

	function Topbar:SetIcon(name)
		Icon.Image = Icons.Get(name)
		Icon.Visible = true
		Dot.Visible = false
	end

	function Topbar:SetColor(color)
		if typeof(color) ~= "Color3" then return end
		Dot:SetAttribute("FancyBackground", nil)
		Icon:SetAttribute("FancyImage", nil)
		Dot.BackgroundColor3 = color
		Icon.ImageColor3 = color
	end

	function Topbar:Reset()
		Topbar.Dragged = false
		Pill.ZIndex = 10
		Reflow(Fancy)
	end

	function Topbar:Destroy()
		for _, connection in connections do
			connection:Disconnect()
		end
		table.clear(connections)

		local index = table.find(Fancy.Topbars, Topbar)
		if index then
			table.remove(Fancy.Topbars, index)
		end

		Pill:Destroy()
		Reflow(Fancy)
	end

	table.insert(Fancy.Topbars, Topbar)
	Reflow(Fancy)

	do
		local target = Pill.Position
		Pill.Position = UDim2.new(target.X.Scale, target.X.Offset, target.Y.Scale, target.Y.Offset - 8)
		Utility.Tween(Pill, 0.25, { Position = target }, Enum.EasingStyle.Quart)
	end

	return Topbar
end
return Topbar
