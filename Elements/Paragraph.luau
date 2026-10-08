local Paragraph = {}
function Paragraph:Create(Fancy, container, settings)
	settings = typeof(settings) == "table" and settings or {}

	local Card = Fancy.Modules.Instance:Create("Frame", {
		Name = "Paragraph",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Fancy.Theme.Secondary[2],
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Parent = container,
	})
	Card:SetAttribute("FancyBackground", "Secondary.2")
	Fancy.Modules.Instance:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Card })

	local stroke = Fancy.Modules.Instance:Create("UIStroke", {
		Color = Fancy.Theme.Stroke,
		Transparency = Fancy.Theme.StrokeTransparency or 0.92,
		Parent = Card,
	})
	stroke:SetAttribute("FancyStroke", "Stroke")

	Fancy.Modules.Instance:Create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = Card,
	})
	Fancy.Modules.Instance:Create("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		Parent = Card,
	})

	local Title = Fancy.Modules.Instance:Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundTransparency = 1,
		Font = Fancy.Theme.TitleFont,
		Text = tostring(settings.Title or settings.Name or "Paragraph"),
		TextSize = 13,
		TextColor3 = Fancy.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = Card,
	})
	Title:SetAttribute("FancyText", "Text")

	local Text = Fancy.Modules.Instance:Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Font = Fancy.Theme.Font,
		Text = tostring(settings.Text or settings.Content or ""),
		TextSize = 12,
		TextColor3 = Fancy.Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		Parent = Card,
	})
	Text:SetAttribute("FancyText", "SubText")

	local Paragraph = {}

	function Paragraph:Set(title, body)
		if title ~= nil then Title.Text = tostring(title) end
		if body ~= nil then Text.Text = tostring(body) end
	end

	Paragraph.Instance = Card
	return Paragraph
end
return Paragraph
