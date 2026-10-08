local Notifications = {}

local TweenService = game:GetService("TweenService")

local function tween(object, time, properties, style)
	local t = TweenService:Create(object, TweenInfo.new(time, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), properties)
	t:Play()
	return t
end

function Notifications.Send(Fancy, props)
	if not Fancy or not Fancy.MainUI then return end
	props = typeof(props) == "table" and props or {}

	local host = Fancy.NotifyLayer or Fancy.MainUI
    if not host then return end

	local Theme = Fancy.Theme or (Fancy.Themes and Fancy.Themes.Default)
	if not Theme then return end
	
	local Icons = Fancy.Modules and Fancy.Modules.Icons

	local typeIcons = { Success = "circle-check", Warning = "circle-alert", Danger = "circle-x", Info = "info" }
	local kind = props.Type and typeIcons[props.Type] and props.Type or "Info"
	local color = props.Color or Theme[kind] or Theme.Accent
	
	local notificationOrder = 0
	
	local duration = tonumber(props.Duration)
	if duration == nil then
		duration = 4
	end

	local function resolveIcon(name)
		if typeof(name) ~= "string" then
			return nil
		end
		if string.find(name, "rbxassetid", 1, true) then
			return name
		end
		if Icons then
			return Icons.Get(name)
		end
		return nil
	end

    local holder = host:FindFirstChild("FancyNotifications")
    if not holder then
        holder = Instance.new("Frame")
        holder.Name = "FancyNotifications"
        holder.AnchorPoint = Vector2.new(1, 0)
        holder.Position = UDim2.new(1, -16, 0, 16)
        holder.Size = UDim2.new(0, 300, 1, -32)
        holder.BackgroundTransparency = 1
        holder.ClipsDescendants = true
        holder.ZIndex = 50
        holder.Parent = host

		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 8)
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = holder
	end
	
	notificationOrder -= 1
	
	local Toast = Instance.new("Frame")
	Toast.Name = "Toast"
	Toast.Size = UDim2.new(1, 0, 0, 58)
	Toast.LayoutOrder = notificationOrder
	Toast.BackgroundTransparency = 1
	Toast.Parent = holder

	local Card = Instance.new("Frame")
	Card.Name = "Card"
	Card.Size = UDim2.new(1, 0, 1, 0)
	Card.Position = UDim2.fromOffset(320, 0)
	Card.BackgroundColor3 = props.BackgroundColor or Theme.Primary
	Card.BorderSizePixel = 0
	Card.Parent = Toast

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = Card

	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Stroke
	stroke.Transparency = Theme.StrokeTransparency or 0.92
	stroke.Parent = Card

	local bar = Instance.new("Frame")
	bar.AnchorPoint = Vector2.new(0, 0.5)
	bar.Position = UDim2.new(0, 8, 0.5, 0)
	bar.Size = UDim2.new(0, 3, 1, -16)
	bar.BackgroundColor3 = color
	bar.BorderSizePixel = 0
	bar.Parent = Card

	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(1, 0)
	barCorner.Parent = bar

	local icon = Instance.new("ImageLabel")
	icon.Position = UDim2.new(0, 20, 0, 21)
	icon.Size = UDim2.fromOffset(16, 16)
	icon.BackgroundTransparency = 1
	icon.Image = resolveIcon(props.Icon) or resolveIcon(typeIcons[kind]) or "rbxassetid://124560466474914"
	icon.ImageColor3 = color
	icon.Parent = Card

	local title = Instance.new("TextLabel")
	title.Position = UDim2.new(0, 44, 0, 12)
	title.Size = UDim2.new(1, -54, 0, 14)
	title.BackgroundTransparency = 1
	title.Font = Theme.TitleFont
	title.Text = props.Title or "Notification"
	title.TextSize = 12
	title.TextColor3 = Theme.Text
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.Parent = Card

	local text = Instance.new("TextLabel")
	text.Position = UDim2.new(0, 44, 0, 28)
	text.Size = UDim2.new(1, -54, 0, 24)
	text.BackgroundTransparency = 1
	text.Font = Theme.Font
	text.Text = props.Text or props.Content or ""
	text.TextSize = 11
	text.TextColor3 = Theme.SubText
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.TextYAlignment = Enum.TextYAlignment.Top
	text.TextWrapped = true
	text.Parent = Card

	local closed = false
	local progressTween

	local function close()
		if closed then return end
		closed = true
		if progressTween then
			progressTween:Cancel()
		end
		tween(Card, 0.3, { Position = UDim2.fromOffset(320, 0) })
		task.delay(0.35, function()
			Toast:Destroy()
		end)
	end

	local click = Instance.new("TextButton")
	click.Size = UDim2.new(1, 0, 1, 0)
	click.BackgroundTransparency = 1
	click.Text = ""
	click.Parent = Card
	click.Activated:Connect(close)

	tween(Card, 0.4, { Position = UDim2.fromOffset(0, 0) })

	if duration > 0 then
		local progress = Instance.new("Frame")
		progress.AnchorPoint = Vector2.new(0, 1)
		progress.Position = UDim2.new(0, 0, 1, 0)
		progress.Size = UDim2.new(1, 0, 0, 2)
		progress.BackgroundColor3 = color
		progress.BackgroundTransparency = 0.45
		progress.BorderSizePixel = 0
		progress.ZIndex = 2
		progress.Parent = Card

		progressTween = tween(progress, duration, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)
		task.delay(duration, close)
	end
end

return Notifications
