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

	local Size = Utility.ResolveSize(windowSettings.Size or default.Size, 691, 457)
	local MinSize = windowSettings.MinSize or default.MinSize or Vector2.new(540, 350)

	local Main = Fancy.Modules.Instance:Create("Frame", {
		Name = "Window",
		AnchorPoint = Center and Vector2.new(0.5, 0.5) or Vector2.zero,
		Position = Center and UDim2.fromScale(0.5, 0.5) or (windowSettings.Position or default.Position or UDim2.fromOffset(60, 60)),
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

	local Topbar = Fancy.Modules.Instance:Create("Frame", {
		Name = "Topbar",
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
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

    -- traffic lights end at LIGHTS_X + 2 * LIGHT_PITCH + LIGHT_SIZE = 66,
    -- so content starts at 78
    local hasIcon = typeof(windowSettings.Icon) == "string" and #windowSettings.Icon > 0

    local Logo = Fancy.Modules.Instance:Create("ImageLabel", {
        Name = "Logo",
        Position = UDim2.new(0, 78, 0.5, -9),
        Size = UDim2.fromOffset(18, 18),
        BackgroundTransparency = 1,
        Image = Icons.Get(windowSettings.Icon or "sparkles"),
        ImageColor3 = Theme.Accent,
        Visible = hasIcon,
        Parent = Topbar
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
        Parent = Topbar
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
		Size = UDim2.new(0, 178, 1, 0),
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

	local TabList = Fancy.Modules.Instance:Create("ScrollingFrame", {
		Name = "Tabs",
		Position = UDim2.new(0, 8, 0, 10),
		Size = UDim2.new(1, -16, 1, -72),
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
		Size = UDim2.new(1, -16, 0, 46),
		BackgroundColor3 = Theme.Secondary[2],
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		Parent = Sidebar,
	})
	Footer:SetAttribute("FancyBackground", "Secondary.2")
	Fancy.Modules.Instance:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Footer })

	local Avatar = Fancy.Modules.Instance:Create("ImageLabel", {
		Position = UDim2.new(0, 8, 0.5, -14),
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = Theme.Secondary[1],
		BorderSizePixel = 0,
		Parent = Footer,
	})
	Avatar:SetAttribute("FancyBackground", "Secondary.1")
	Fancy.Modules.Instance:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Avatar })

	local Username = Fancy.Modules.Instance:Create("TextLabel", {
		Position = UDim2.new(0, 44, 0, 9),
		Size = UDim2.new(1, -52, 0, 13),
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
		Position = UDim2.new(0, 44, 1, -22),
		Size = UDim2.new(1, -52, 0, 12),
		BackgroundTransparency = 1,
		Font = Theme.Font,
		Text = "@guest",
		TextSize = 11,
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
		Position = UDim2.new(0, 178, 0, 0),
		Size = UDim2.new(1, -178, 1, 0),
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

	Utility.MakeDraggable(Topbar, Main, function()
		return not maximized
	end)
	Utility.Tween(Scale, 0.28, { Scale = 1 }, Enum.EasingStyle.Quart)
	if Shadow then
		Utility.Tween(Shadow, 0.35, { ImageTransparency = Theme.ShadowTransparency or 0.5 })
	end

	function Window:Collapse(state)
		local nextState = (state == nil) and not collapsed or state == true
		if nextState == collapsed then return end
		collapsed = nextState

		if collapsed then
			fullSize = Vector2.new(Main.AbsoluteSize.X, Main.AbsoluteSize.Y)
			Utility.Tween(Main, 0.32, { Size = UDim2.fromOffset(fullSize.X, 44) }, Enum.EasingStyle.Quart)
		else
			Utility.Tween(Main, 0.32, { Size = UDim2.fromOffset(fullSize.X, fullSize.Y) }, Enum.EasingStyle.Quart)
		end

		if Grip then
			Grip.Visible = not collapsed and not maximized
		end
	end

	function Window:ToggleMaximize(state)
		local nextState = (state == nil) and not maximized or state == true
		if nextState == maximized then return end
		maximized = nextState

		local camera = Fancy.Services.Workspace.CurrentCamera
		local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
		local margin = 24

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
				Size = UDim2.fromOffset(viewport.X - margin * 2, viewport.Y - margin * 2),
			}, Enum.EasingStyle.Quart)
		elseif savedBounds then
			Utility.Tween(Main, 0.32, savedBounds, Enum.EasingStyle.Quart)
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
	end

    function Window:SetIcon(name)
        if typeof(name) == "string" and #name > 0 then
            Logo.Image = Icons.Get(name)
            Logo.Visible = true
        else
            Logo.Visible = false -- nil removes the icon
        end
        Utility.Tween(Title, 0.15, {
            Position = UDim2.new(0, Logo.Visible and 104 or 78, 0.5, -9),
        })
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

	function Window:Destroy()
		for _, connection in connections do
			connection:Disconnect()
		end
		table.clear(connections)

        if Fancy.Topbars then
            for i = #Fancy.Topbars, 1, -1 do
                local bar = Fancy.Topbars[i]
                if bar.Persistent == false then
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

		table.insert(connections, Fancy.Services.UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				resizing = false
			end
		end))

		table.insert(connections, Fancy.Services.UserInputService.InputChanged:Connect(function(input)
			if not resizing or collapsed or maximized then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local camera = Fancy.Services.Workspace.CurrentCamera
				local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
				local delta = input.Position - startInput
				local width = math.clamp(startSize.X + delta.X, MinSize.X, viewport.X - 24)
				local height = math.clamp(startSize.Y + delta.Y, MinSize.Y, viewport.Y - 24)
				Main.Size = UDim2.fromOffset(width, height)
				fullSize = Vector2.new(width, height)
			end
		end))
	end

	if windowSettings.ToggleKey then
		table.insert(connections, Fancy.Services.UserInputService.InputBegan:Connect(function(input, processed)
			if processed then return end
			if input.KeyCode == windowSettings.ToggleKey then
				Window:Toggle()
			end
		end))
	end

	return Window
end
return Window
