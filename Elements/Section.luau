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
        Position = UDim2.new(0, 0, 0, 5),
        Size = UDim2.new(0, 2, 0, 11),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = Frame,
    })
    Bar:SetAttribute("FancyBackground", "Accent")
    Fancy.Modules.Instance:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Bar })

    local Header = Fancy.Modules.Instance:Create("TextLabel", {
        Position = UDim2.new(0, 9, 0, 2),
        Size = UDim2.new(1, -9, 0, 16),
        BackgroundTransparency = 1,
        Font = Theme.Font,
        Text = string.upper(tostring(settings.Name or "Section")),
        TextSize = 11,
        TextColor3 = Theme.SubText,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = Frame,
    })
    Header:SetAttribute("FancyText", "SubText")

    local Container = Fancy.Modules.Instance:Create("Frame", {
        Position = UDim2.new(0, 0, 0, 22),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = Frame,
    })
    Fancy.Modules.Instance:Create("UIListLayout", {
        Padding = UDim.new(0, 4),
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
        Header.Text = string.upper(tostring(text or "Section"))
    end

    Section.Instance = Frame
    Section.Container = Container

    return Section
end
return Section
