local Section = {}
function Section:Create(Fancy, container, settings)
	settings = typeof(settings) == "table" and settings or {}

	local Theme = Fancy.Theme
	local Section = {}

	local Frame = Fancy.Modules.Instance:Create("Frame", {
		Name = "Section_" .. tostring(settings.Name or "Section"),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = container,
	})

	local Bar = Fancy.Modules.Instance:Create("Frame", {
		Position = UDim2.new(0, 0, 0, 3),
		Size = UDim2.new(0, 2, 0, 12),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Parent = Frame,
	})
	Bar:SetAttribute("FancyBackground", "Accent")
	Fancy.Modules.Instance:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Bar })

	local Header = Fancy.Modules.Instance:Create("TextLabel", {
		Position = UDim2.new(0, 8, 0, 0),
		Size = UDim2.new(1, -8, 0, 18),
		BackgroundTransparency = 1,
		Font = Theme.TitleFont,
		Text = tostring(settings.Name or "Section"),
		TextSize = 12,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = Frame,
	})
	Header:SetAttribute("FancyText", "Text")

	local Container = Fancy.Modules.Instance:Create("Frame", {
		Position = UDim2.new(0, 0, 0, 24),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = Frame,
	})
	Fancy.Modules.Instance:Create("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = Container,
	})

	function Section:NewSection(props)
		return Fancy.Elements.Section:Create(Fancy, Container, props)
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
		Section[methodName] = function(_, props)
			return Fancy.Elements[elementName]:Create(Fancy, Container, props)
		end
	end

	function Section:SetTitle(text)
		Header.Text = tostring(text or "Section")
	end

	Section.Instance = Frame
	Section.Container = Container

	return Section
end
return Section