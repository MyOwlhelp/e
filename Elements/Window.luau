local Window = {}
function Window:Create(Fancy, windowSettings, default)
    if not Fancy.MainUI or Fancy.Window then return nil end
    windowSettings = typeof(windowSettings) == "table" and windowSettings or {}

    local Utility = Fancy.Modules.Utility
    local Icons = Fancy.Modules.Icons

    local ThemeName = windowSettings.Theme or default.Theme or "Default"
    local Theme = Fancy.Themes[ThemeName] or Fancy.Themes.Default
    Fancy.Theme = Theme
    Fancy.ThemeName = ThemeName

    local function measureTitle(text)
        local size = Fancy.Services.TextService:GetTextSize(
            tostring(text or ""),
            14,
            Theme.TitleFont,
            Vector2.new(1000, 100)
        )
        return size.X
    end

    local Center = windowSettings.Center
    if Center == nil then
        Center = default.Center
    end
    if Center == nil then
        Center = true
    end

    local Resizeable = windowSettings.Resizeable
    if Resizeable == nil then
        Resizeable = default.Resizeable
    end
    if Resizeable == nil then
        Resizeable = true
    end

    local UserInputService = Fancy.Services.UserInputService
    local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled and not UserInputService.KeyboardEnabled

    local function getViewport()
        local camera = Fancy.Services.Workspace.CurrentCamera
        return camera and camera.ViewportSize or Vector2.new(1920, 1080)
    end

    local MARGIN = isMobile and 8 or 24
    local SidebarWidth = isMobile and 148 or 178

    local viewport = getViewport()
    local availX = math.max(viewport.X - MARGIN * 2, 200)
    local availY = math.max(viewport.Y - MARGIN * 2, 150)

    local Size = Utility.ResolveSize(windowSettings.Size or default.Size, 691, 457)
    if isMobile and windowSettings.Size == nil then
        Size = UDim2.fromOffset(math.floor(availX * 0.96), math.floor(availY * 0.92))
    end

    local width = math.min(Size.X.Offset, availX)
    local height = math.min(Size.Y.Offset, availY)
    Size = UDim2.fromOffset(width, height)

    local MinSize = windowSettings.MinSize or default.MinSize or Vector2.new(540, 350)
    local effMinX = math.min(MinSize.X, availX)
    local effMinY = math.min(MinSize.Y, availY)

    local Main = Fancy.Modules.Instance:Create("Frame", {
        Name = "Window",
        AnchorPoint = Center and Vector2.new(0.5, 0.5) or Vector2.zero,
        Position = Center and UDim2.fromScale(0.5, 0.5)
            or (windowSettings.Position or default.Position or UDim2.fromOffset(60, 60)),
        Size = Size,
        BackgroundColor3 = Theme.Primary,
        BorderSizePixel = 0,
        Parent = Fancy.MainUI,
    })
    Main:SetAttribute("FancyBackground", "Primary")
    Fancy.Modules.Instance:Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = Main })

    do
        local stroke = Fancy.Modules.Instance:Create("UIStroke", {
            Color = Theme.Stroke,
            Transparency = Theme.StrokeTransparency or 0.92,
            Parent = Main,
        })
        stroke:SetAttribute("FancyStroke", "Stroke")
    end

    local Scale = Fancy.Modules.Instance:Create("UIScale", { Scale = 0.97, Parent = Main })
    local Shadow = nil
    if windowSettings.Shadow then
        Shadow = Fancy.Modules.Instance:Create("ImageLabel", {
            Name = "Shadow",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.new(1, 60, 1, 60),
            BackgroundTransparency = 1,
            Image = "rbxassetid://6014261993",
            ImageColor3 = Theme.Shadow or Color3.new(0, 0, 0),
            ImageTransparency = 1,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(49, 49, 450, 450),
            ZIndex = 0,
            Parent = Main,
        })
    end

    local Sheen = Fancy.Modules.Instance:Create("Frame", {
        Name = "Sheen",
        Size = UDim2.new(1, 0, 0, 90),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Parent = Main,
    })
    Fancy.Modules.Instance:Create("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.955),
            NumberSequenceKeypoint.new(1, 1),
        }),
        Rotation = 90,
        Parent = Sheen,
    })

    local Topbar = Fancy.Modules.Instance:Create("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
        Active = true,
        Parent = Main,
    })

    local Window = {}
    local collapsed = false
    local maximized = false
    local savedBounds = nil
    local fullSize = Vector2.new(Size.X.Offset, Size.Y.Offset)
    local connections = {}
    local Grip

    local LIGHT_SIZE = 12
    local LIGHT_PITCH = 20
    local LIGHTS_X = 14
    local LIGHTS_IDLE = Color3.fromRGB(72, 74, 78)
    local GLYPH_COLOR = Color3.fromRGB(43, 43, 46)

    local lights = {}
    local deactivateToken = 0

    local function setLightsActive(active)
        for _, light in lights do
            Utility.Tween(light.Button, 0.15, {
                BackgroundColor3 = active and light.Color or LIGHTS_IDLE,
            })
            for _, bar in light.Bars do
                Utility.Tween(bar, 0.15, { BackgroundTransparency = active and 0 or 1 })
            end
        end
    end

    local function addBar(parent, size, rotation)
        return Fancy.Modules.Instance:Create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = size,
            Rotation = rotation or 0,
            BackgroundColor3 = GLYPH_COLOR,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = parent,
        })
    end

    local function TrafficLight(name, color, order, onClick)
        local Button = Fancy.Modules.Instance:Create("TextButton", {
            Name = name,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, LIGHTS_X + (order - 1) * LIGHT_PITCH, 0.5, 0),
            Size = UDim2.fromOffset(LIGHT_SIZE, LIGHT_SIZE),
            BackgroundColor3 = LIGHTS_IDLE,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            Parent = Topbar,
        })
        Fancy.Modules.Instance:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Button })

        local bars = {}
        if name == "Close" then
            table.insert(bars, addBar(Button, UDim2.fromOffset(7, 2), 45))
            table.insert(bars, addBar(Button, UDim2.fromOffset(7, 2), -45))
        elseif name == "Minimize" then
            table.insert(bars, addBar(Button, UDim2.fromOffset(7, 2), 0))
        elseif name == "Zoom" then
            table.insert(bars, addBar(Button, UDim2.fromOffset(7, 2), 0))
            table.insert(bars, addBar(Button, UDim2.fromOffset(2, 7), 0))
        end

        table.insert(lights, { Button = Button, Bars = bars, Color = color })

        Button.MouseEnter:Connect(function()
            deactivateToken += 1
            setLightsActive(true)
        end)
        Button.MouseLeave:Connect(function()
            deactivateToken += 1
            local token = deactivateToken
            task.delay(0.08, function()
                if token == deactivateToken then
                    setLightsActive(false)
                end
            end)
        end)
        Button.Activated:Connect(onClick)

        return Button
    end

    TrafficLight("Close", Theme.Danger, 1, function()
        Window:Destroy()
    end)
    TrafficLight("Minimize", Theme.Warning, 2, function()
        Window:Collapse()
    end)
    TrafficLight("Zoom", Theme.Success, 3, function()
        Window:ToggleMaximize()
    end)

    local hasIcon = typeof(windowSettings.Icon) == "string" and #windowSettings.Icon > 0
    local Logo = Fancy.Modules.Instance:Create("ImageLabel", {
        Name = "Logo",
        Position = UDim2.new(0, 78, 0.5, -9),
        Size = UDim2.fromOffset(18, 18),
        BackgroundTransparency = 1,
        Image = Icons.Get(windowSettings.Icon or "sparkles"),
        ImageColor3 = Theme.Accent,
        Visible = hasIcon,
        Parent = Topbar,
    })
    Logo:SetAttribute("FancyImage", "Accent")

    local Title = Fancy.Modules.Instance:Create("TextLabel", {
        Position = UDim2.new(0, hasIcon and 104 or 78, 0.5, -9),
        Size = UDim2.new(0, hasIcon and 240 or 266, 0, 18),
        BackgroundTransparency = 1,
        Font = Theme.TitleFont,
        Text = windowSettings.Title or default.Title or "Fancy UI",
        TextSize = 14,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = Topbar,
    })
    Title:SetAttribute("FancyText", "Text")

    local PageTitle = Fancy.Modules.Instance:Create("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -16, 0.5, 0),
        Size = UDim2.new(0, 160, 0, 16),
        BackgroundTransparency = 1,
        Font = Theme.Font,
        Text = "",
        TextSize = 12,
        TextColor3 = Theme.SubText,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = Topbar,
    })
    PageTitle:SetAttribute("FancyText", "SubText")

    local Version = typeof(windowSettings.Version) == "string" and windowSettings.Version or ""
    local VersionLabel = nil
    if #Version > 0 then
        VersionLabel = Fancy.Modules.Instance:Create("TextLabel", {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -16, 0, 27),
            Size = UDim2.new(0, 160, 0, 12),
            BackgroundTransparency = 1,
            Font = Theme.Font,
            Text = Version,
            TextSize = 10,
            TextColor3 = Theme.SubText,
            TextXAlignment = Enum.TextXAlignment.Right,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = Topbar,
        })
        VersionLabel:SetAttribute("FancyText", "SubText")
    end

    local function setChromeVisible(state)
        for _, light in lights do
            light.Button.Visible = state
        end
        PageTitle.Visible = state
        if VersionLabel then
            VersionLabel.Visible = state
        end
    end

    local Body = Fancy.Modules.Instance:Create("Frame", {
        Name = "Body",
        Position = UDim2.new(0, 0, 0, 44),
        Size = UDim2.new(1, 0, 1, -44),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = Main,
    })

    local Sidebar = Fancy.Modules.Instance:Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, SidebarWidth, 1, 0),
        BackgroundColor3 = Theme.Secondary[1],
        BorderSizePixel = 0,
        Parent = Body,
    })
    Sidebar:SetAttribute("FancyBackground", "Secondary.1")
    Fancy.Modules.Instance:Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = Sidebar })

    local Divider = Fancy.Modules.Instance:Create("Frame", {
        Name = "Divider",
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Stroke,
        BackgroundTransparency = 0.93,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = Body,
    })
    Divider:SetAttribute("FancyBackground", "Stroke")

    local Search = Fancy.Modules.Instance:Create("TextBox", {
        Name = "Search",
        Position = UDim2.new(0, 8, 0, 10),
        Size = UDim2.new(1, -16, 0, 30),
        BackgroundColor3 = Theme.Secondary[2],
        BackgroundTransparency = 0.5,
        Font = Theme.Font,
        PlaceholderText = "Search tabs...",
        Text = "",
        TextSize = 12,
        TextColor3 = Theme.Text,
        PlaceholderColor3 = Theme.SubText,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        BorderSizePixel = 0,
        Parent = Sidebar,
    })
    Search:SetAttribute("FancyBackground", "Secondary.2")
    Search:SetAttribute("FancyText", "Text")
    do
        Fancy.Modules.Instance:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Search })
        local searchStroke = Fancy.Modules.Instance:Create("UIStroke", {
            Color = Theme.Stroke,
            Transparency = 0.94,
            Parent = Search,
        })
        searchStroke:SetAttribute("FancyStroke", "Stroke")
        Fancy.Modules.Instance:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            Parent = Search,
        })
    end

    local NoResults = Fancy.Modules.Instance:Create("TextLabel", {
        Position = UDim2.new(0, 8, 0, 50),
        Size = UDim2.new(1, -16, 0, 16),
        BackgroundTransparency = 1,
        Font = Theme.Font,
        Text = "No matching tabs",
        TextSize = 11,
        TextColor3 = Theme.SubText,
        Visible = false,
        Parent = Sidebar,
    })
    NoResults:SetAttribute("FancyText", "SubText")

    Search:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(Search.Text)
        local visible = 0
        for _, tab in Fancy.Tabs do
            if tab.Button and tab.Button.Parent then
                local match = query == ""
                    or string.find(string.lower(tostring(tab.Settings.Name or "Tab")), query, 1, true) ~= nil
                tab.Button.Visible = match
                if match then visible += 1 end
            end
        end
        NoResults.Visible = query ~= "" and visible == 0
    end)

    local TabList = Fancy.Modules.Instance:Create("ScrollingFrame", {
        Name = "Tabs",
        Position = UDim2.new(0, 8, 0, 48),
        Size = UDim2.new(1, -16, 1, -116),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Parent = Sidebar,
    })
    TabList:SetAttribute("FancyScrollBar", "Accent")
    Fancy.Modules.Instance:Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabList,
    })

    local Footer = Fancy.Modules.Instance:Create("Frame", {
        Name = "User",
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 8, 1, -8),
        Size = UDim2.new(1, -16, 0, 54),
        BackgroundColor3 = Theme.Secondary[2],
        BorderSizePixel = 0,
        Parent = Sidebar,
    })
    Footer:SetAttribute("FancyBackground", "Secondary.2")
    Fancy.Modules.Instance:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Footer })

    local Avatar = Fancy.Modules.Instance:Create("ImageLabel", {
        Position = UDim2.new(0, 10, 0.5, -15),
        Size = UDim2.fromOffset(30, 30),
        BackgroundColor3 = Theme.Secondary[1],
        BorderSizePixel = 0,
        Parent = Footer,
    })
    Avatar:SetAttribute("FancyBackground", "Secondary.1")
    Fancy.Modules.Instance:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Avatar })
    do
        local ring = Fancy.Modules.Instance:Create("UIStroke", {
            Color = Theme.Accent,
            Transparency = 0.45,
            Thickness = 1,
            Parent = Avatar,
        })
        ring:SetAttribute("FancyStroke", "Accent")
    end

    local Pulse = Fancy.Modules.Instance:Create("Frame", {
        Position = UDim2.new(0, 31, 0, 33),
        Size = UDim2.fromOffset(12, 12),
        BackgroundColor3 = Theme.Success,
        BackgroundTransparency = 0.45,
        BorderSizePixel = 0,
        Parent = Footer,
    })
    Pulse:SetAttribute("FancyBackground", "Success")
    Fancy.Modules.Instance:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Pulse })

    local Dot = Fancy.Modules.Instance:Create("Frame", {
        Position = UDim2.new(0, 33, 0, 35),
        Size = UDim2.fromOffset(8, 8),
        BackgroundColor3 = Theme.Success,
        BorderSizePixel = 0,
        Parent = Footer,
    })
    Dot:SetAttribute("FancyBackground", "Success")
    Fancy.Modules.Instance:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Dot })

    task.spawn(function()
        while Dot.Parent do
            Utility.Tween(Pulse, 0.9, { BackgroundTransparency = 0.85 })
            task.wait(0.9)
            if not Dot.Parent then break end
            Utility.Tween(Pulse, 0.9, { BackgroundTransparency = 0.45 })
            task.wait(0.9)
        end
    end)

    local Username = Fancy.Modules.Instance:Create("TextLabel", {
        Position = UDim2.new(0, 50, 0, 12),
        Size = UDim2.new(1, -58, 0, 14),
        BackgroundTransparency = 1,
        Font = Theme.TitleFont,
        Text = "Guest",
        TextSize = 12,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = Footer,
    })
    Username:SetAttribute("FancyText", "Text")

    local Subname = Fancy.Modules.Instance:Create("TextLabel", {
        Position = UDim2.new(0, 50, 1, -24),
        Size = UDim2.new(1, -58, 0, 12),
        BackgroundTransparency = 1,
        Font = Theme.Font,
        Text = "@guest",
        TextSize = 10.5,
        TextColor3 = Theme.SubText,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = Footer,
    })
    Subname:SetAttribute("FancyText", "SubText")

    local LocalPlayer = Fancy.Services.Players.LocalPlayer
    if LocalPlayer then
        Username.Text = LocalPlayer.DisplayName
        Subname.Text = "@" .. LocalPlayer.Name
        task.spawn(function()
            local ok, content = pcall(
                Fancy.Services.Players.GetUserThumbnailAsync, Fancy.Services.Players,
                LocalPlayer.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size48x48
            )
            if ok and Avatar.Parent then
                Avatar.Image = content
            end
        end)
    end

    local Content = Fancy.Modules.Instance:Create("Frame", {
        Name = "Content",
        Position = UDim2.new(0, SidebarWidth, 0, 0),
        Size = UDim2.new(1, -SidebarWidth, 1, 0),
        BackgroundTransparency = 1,
        Parent = Body,
    })

    local PageHolder = Fancy.Modules.Instance:Create("Frame", {
        Name = "Pages",
        Position = UDim2.new(0, 6, 0, 6),
        Size = UDim2.new(1, -12, 1, -12),
        BackgroundTransparency = 1,
        Parent = Content,
    })

    Fancy.Refs = {
        Topbar = Topbar,
        Title = Title,
        PageTitle = PageTitle,
        TabList = TabList,
        PageHolder = PageHolder,
        Sidebar = Sidebar,
        Content = Content,
        Body = Body,
    }
    Fancy.Window = Main

    local VISIBLE = isMobile and 0 or 60

    local function keepInBounds()
        local vp = getViewport()
        local size = Main.AbsoluteSize
        local pos = Main.AbsolutePosition

        local minX, maxX
        if size.X >= vp.X then
            minX = (vp.X - size.X) / 2
            maxX = minX
        else
            minX = isMobile and 0 or -(size.X - VISIBLE)
            maxX = isMobile and (vp.X - size.X) or (vp.X - VISIBLE)
        end

        local minY, maxY
        if size.Y >= vp.Y then
            minY = (vp.Y - size.Y) / 2
            maxY = minY
        else
            minY = isMobile and 0 or -(size.Y - VISIBLE)
            maxY = isMobile and (vp.Y - size.Y) or (vp.Y - VISIBLE)
        end

        local ox = 0
        if pos.X < minX then
            ox = minX - pos.X
        elseif pos.X > maxX then
            ox = maxX - pos.X
        end

        local oy = 0
        if pos.Y < minY then
            oy = minY - pos.Y
        elseif pos.Y > maxY then
            oy = maxY - pos.Y
        end

        if ox ~= 0 or oy ~= 0 then
            Main.Position = Main.Position + UDim2.fromOffset(ox, oy)
        end
    end

    Utility.MakeDraggable(Topbar, Main, function()
        return not maximized
    end, keepInBounds)

    local restorePress = nil
    Topbar.InputBegan:Connect(function(input)
        if collapsed
            and (input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch) then
            restorePress = input.Position
        end
    end)

    Topbar.InputEnded:Connect(function(input)
        if restorePress
            and (input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - restorePress
            restorePress = nil
            if math.abs(delta.X) < 6 and math.abs(delta.Y) < 6 then
                Window:Collapse(false)
            end
        end
    end)

    Utility.Tween(Scale, 0.28, { Scale = 1 }, Enum.EasingStyle.Quart)
    if Shadow then
        Utility.Tween(Shadow, 0.35, { ImageTransparency = Theme.ShadowTransparency or 0.5 })
    end
    task.delay(0.3, keepInBounds)

    local COMPACT_START = 16
    local COMPACT_ICON_GAP = 26

    function Window:Collapse(state)
        local nextState = (state == nil) and not collapsed or state == true
        if nextState == collapsed then return end
        collapsed = nextState

        if collapsed then
            fullSize = Vector2.new(Main.AbsoluteSize.X, Main.AbsoluteSize.Y)
            setChromeVisible(false)

            local iconShown = Logo.Visible
            local contentStart = iconShown and (COMPACT_START + COMPACT_ICON_GAP) or COMPACT_START
            local barWidth = contentStart + measureTitle(Title.Text) + COMPACT_START

            barWidth = math.max(barWidth, 90)
            barWidth = math.min(barWidth, fullSize.X)

            Logo.Position = UDim2.new(0, COMPACT_START, 0.5, -9)
            Title.Position = UDim2.new(0, contentStart, 0.5, -9)

            Utility.Tween(Main, 0.32, {
                Size = UDim2.fromOffset(barWidth, 44),
            }, Enum.EasingStyle.Quart)
        else
            setChromeVisible(true)

            Logo.Position = UDim2.new(0, 78, 0.5, -9)
            Title.Position = UDim2.new(0, Logo.Visible and 104 or 78, 0.5, -9)

            Utility.Tween(Main, 0.32, {
                Size = UDim2.fromOffset(fullSize.X, fullSize.Y),
            }, Enum.EasingStyle.Quart)
            task.delay(0.33, keepInBounds)
        end

        if Grip then
            Grip.Visible = not collapsed and not maximized
        end
    end

    function Window:IsCollapsed()
        return collapsed
    end

    function Window:ToggleMaximize(state)
        local nextState = (state == nil) and not maximized or state == true
        if nextState == maximized then return end
        maximized = nextState

        local vp = getViewport()
        local margin = MARGIN

        if collapsed then
            Window:Collapse(false)
        end

        if nextState then
            savedBounds = {
                Position = Main.Position,
                Size = UDim2.fromOffset(fullSize.X, fullSize.Y),
            }
            Utility.Tween(Main, 0.32, {
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(vp.X - margin * 2, vp.Y - margin * 2),
            }, Enum.EasingStyle.Quart)
        elseif savedBounds then
            Utility.Tween(Main, 0.32, savedBounds, Enum.EasingStyle.Quart)
            task.delay(0.33, keepInBounds)
        end

        if Grip then
            Grip.Visible = not maximized and not collapsed
        end
    end

    function Window:SetTitle(text)
        if typeof(text) ~= "string" then
            warn("[Fancy] SetTitle requires a string")
            return
        end
        Title.Text = text
        if collapsed then
            local contentStart = Logo.Visible and (COMPACT_START + COMPACT_ICON_GAP) or COMPACT_START
            local barWidth = math.max(contentStart + measureTitle(text) + COMPACT_START, 90)
            Utility.Tween(Main, 0.2, {
                Size = UDim2.fromOffset(math.min(barWidth, fullSize.X), Main.AbsoluteSize.Y),
            }, Enum.EasingStyle.Quart)
        end
    end

    function Window:SetIcon(name)
        if typeof(name) == "string" and #name > 0 then
            Logo.Image = Icons.Get(name)
            Logo.Visible = true
        else
            Logo.Visible = false
        end

        if collapsed then
            local contentStart = Logo.Visible and (COMPACT_START + COMPACT_ICON_GAP) or COMPACT_START
            Logo.Position = UDim2.new(0, COMPACT_START, 0.5, -9)
            Title.Position = UDim2.new(0, contentStart, 0.5, -9)

            local barWidth = math.max(contentStart + measureTitle(Title.Text) + COMPACT_START, 90)
            Utility.Tween(Main, 0.2, {
                Size = UDim2.fromOffset(math.min(barWidth, fullSize.X), Main.AbsoluteSize.Y),
            }, Enum.EasingStyle.Quart)
        else
            Utility.Tween(Title, 0.15, {
                Position = UDim2.new(0, Logo.Visible and 104 or 78, 0.5, -9),
            })
        end
    end

    function Window:NewTab(settings)
        return Fancy.Elements.Tab:Create(Fancy, settings)
    end

    function Window:NewTopbar(settings)
        return Fancy.Elements.Topbar:Create(Fancy, settings)
    end

    function Window:SelectTab(reference)
        local target = nil
        if typeof(reference) == "number" then
            target = Fancy.Tabs[reference]
        else
            for _, tab in Fancy.Tabs do
                if tab == reference or tab.Settings.Name == tostring(reference) then
                    target = tab
                    break
                end
            end
        end
        if target then
            target:Select()
        else
            warn(("[Fancy] Tab '%s' was not found"):format(tostring(reference)))
        end
        return target
    end

    local forwardMethods = {
        NewSection = true,
        NewButton = true,
        NewToggle = true,
        NewSlider = true,
        NewInput = true,
        NewParagraph = true,
        NewKeybind = true,
        NewDropdown = true,
    }

    for methodName in forwardMethods do
        Window[methodName] = function(_, settings)
            local tab = Fancy.SelectedTab or Window:NewTab({ Name = "Main", Icon = "home" })
            return tab[methodName](tab, settings)
        end
    end

    function Window:Toggle(visible)
        if not Fancy.MainUI then return end
        if typeof(visible) == "boolean" then
            Fancy.MainUI.Enabled = visible
        else
            Fancy.MainUI.Enabled = not Fancy.MainUI.Enabled
        end
    end

    function Window:Notify(props)
        Fancy.Modules.Notifications.Send(Fancy, props)
    end

    function Window:SetTheme(name)
        local theme = typeof(name) == "string" and Fancy.Themes[name] or nil
        if not theme then
            warn(("[Fancy] Theme '%s' does not exist"):format(tostring(name)))
            return
        end
        Fancy.Theme = theme
        Fancy.ThemeName = name
        Utility.ApplyTheme(Main, theme)
    end

    local unloadHandlers = {}

    function Window:OnUnload(callback)
        if typeof(callback) ~= "function" then
            warn("[Fancy] OnUnload requires a function")
            return nil
        end
        table.insert(unloadHandlers, callback)
        return function()
            local index = table.find(unloadHandlers, callback)
            if index then
                table.remove(unloadHandlers, index)
            end
        end
    end

    local function fireUnload()
        if #unloadHandlers == 0 then return end
        local handlers = table.clone(unloadHandlers)
        table.clear(unloadHandlers)
        for _, handler in handlers do
            local ok, err = pcall(handler)
            if not ok then
                warn("[Fancy] OnUnload handler error: " .. tostring(err))
            end
        end
    end

    function Window:Destroy()
        fireUnload()

        for _, connection in connections do
            connection:Disconnect()
        end
        table.clear(connections)

        if Fancy.Topbars then
            for i = #Fancy.Topbars, 1, -1 do
                local bar = Fancy.Topbars[i]
                if bar.Persistent ~= true then
                    pcall(function()
                        bar:Destroy()
                    end)
                end
            end
        end

        Utility.Tween(Scale, 0.15, { Scale = 0.97 }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        if Shadow then
            Utility.Tween(Shadow, 0.15, { ImageTransparency = 1 })
        end

        task.delay(0.16, function()
            Main:Destroy()
        end)

        Fancy.Window = nil
        Fancy.WindowAPI = nil
        Fancy.Refs = nil
        Fancy.Tabs = {}
        Fancy.SelectedTab = nil
    end

    if Resizeable then
        Grip = Fancy.Modules.Instance:Create("TextButton", {
            Name = "ResizeGrip",
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -3, 1, -3),
            Size = UDim2.fromOffset(22, 22),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            Parent = Main,
        })

        local GripIcon = Fancy.Modules.Instance:Create("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(14, 14),
            BackgroundTransparency = 1,
            Image = Icons.Get("a-large-small"),
            ImageColor3 = Theme.SubText,
            ImageTransparency = 0.45,
            Rotation = 180,
            Parent = Grip,
        })
        GripIcon:SetAttribute("FancyImage", "SubText")

        Grip.MouseEnter:Connect(function()
            Utility.Tween(GripIcon, 0.15, { ImageTransparency = 0 })
        end)
        Grip.MouseLeave:Connect(function()
            Utility.Tween(GripIcon, 0.2, { ImageTransparency = 0.45 })
        end)

        local resizing = false
        local startInput, startSize

        Grip.InputBegan:Connect(function(input)
            if collapsed or maximized then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                resizing = true
                startInput = input.Position
                startSize = Vector2.new(Main.AbsoluteSize.X, Main.AbsoluteSize.Y)
            end
        end)

        table.insert(connections, UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                resizing = false
            end
        end))

        table.insert(connections, UserInputService.InputChanged:Connect(function(input)
            if not resizing or collapsed or maximized then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local vp = getViewport()
                local availW = math.max(vp.X - MARGIN * 2, effMinX)
                local availH = math.max(vp.Y - MARGIN * 2, effMinY)
                local delta = input.Position - startInput

                local newW, newH
                if isMobile then
                    local ratio = startSize.Y / math.max(startSize.X, 1)
                    local growth = math.max(delta.X, delta.Y / ratio)
                    newW = math.clamp(startSize.X + growth, effMinX, availW)
                    newH = math.clamp(newW * ratio, effMinY, availH)
                    newW = newH / ratio
                else
                    newW = math.clamp(startSize.X + delta.X, effMinX, availW)
                    newH = math.clamp(startSize.Y + delta.Y, effMinY, availH)
                end

                newW = math.floor(newW + 0.5)
                newH = math.floor(newH + 0.5)

                Main.Size = UDim2.fromOffset(newW, newH)
                fullSize = Vector2.new(newW, newH)
                keepInBounds()
            end
        end))

        do
            local camera = Fancy.Services.Workspace.CurrentCamera
            if camera then
                table.insert(connections, camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                    if collapsed then return end
                    local vp = getViewport()
                    local maxW = math.max(vp.X - MARGIN * 2, effMinX)
                    local maxH = math.max(vp.Y - MARGIN * 2, effMinY)
                    local newW = math.min(Main.AbsoluteSize.X, maxW)
                    local newH = math.min(Main.AbsoluteSize.Y, maxH)
                    if newW ~= Main.AbsoluteSize.X or newH ~= Main.AbsoluteSize.Y then
                        Main.Size = UDim2.fromOffset(newW, newH)
                        fullSize = Vector2.new(newW, newH)
                    end
                    keepInBounds()
                end))
            end
        end
    end

    if windowSettings.ToggleKey then
        table.insert(connections, UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == windowSettings.ToggleKey then
                Window:Toggle()
            end
        end))
    end

    return Window
end
return Window
