local clref = (typeof(cloneref) == "function" and cloneref or typeof(clonereference) == "function" and clonereference) or function(...)
	return ...
end

local function GetService(service)
	local instance = game:GetService(service) or game:FindService(service)
	if instance and clref then
		return clref(instance)
	end
	return instance
end

local TweenService = GetService("TweenService")
local UserInputService = GetService("UserInputService")
local Workspace = GetService("Workspace")

local dasdadawdaw = nil

local Utility = {}

function Utility.Init(s)
	if dasdadawdaw then return end
	dasdadawdaw = s
end

function Utility.Tween(object, time, properties, style, direction)
	if not object or typeof(properties) ~= "table" then return nil end
	local tween = TweenService:Create(object, TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out), properties)
	tween:Play()
	return tween
end

function Utility.SafeCallback(callback, ...)
	if typeof(callback) ~= "function" then return end

	local ok, err = pcall(callback, ...)
	if not ok then
		warn("[Fancy] Callback error: " .. tostring(err))
	end

	local SM = dasdadawdaw and dasdadawdaw.Modules and dasdadawdaw.Modules.SaveManager
	if SM and typeof(SM.QueueSave) == "function"
		and dasdadawdaw.WindowSettings
		and typeof(dasdadawdaw.WindowSettings.Configuration) == "table"
		and dasdadawdaw.WindowSettings.Configuration.AutoSave then
		SM.QueueSave()
	end
end

function Utility.Round(number, decimals)
	local factor = 10 ^ (decimals or 0)
	return math.floor(number * factor + 0.5) / factor
end

function Utility.Comma(number)
	local formatted = tostring(math.floor(number))
	while true do
		local replaced
		formatted, replaced = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		if replaced == 0 then
			break
		end
	end
	return formatted
end

function Utility.ResolveSize(size, fallbackWidth, fallbackHeight)
	if typeof(size) ~= "UDim2" then
		return UDim2.fromOffset(fallbackWidth or 691, fallbackHeight or 457)
	end
	local camera = Workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
	local x = size.X.Scale > 0 and math.floor(size.X.Scale * viewport.X + 0.5) or size.X.Offset
	local y = size.Y.Scale > 0 and math.floor(size.Y.Scale * viewport.Y + 0.5) or size.Y.Offset
	if x <= 0 then
		x = fallbackWidth or 691
	end
	if y <= 0 then
		y = fallbackHeight or 457
	end
	return UDim2.fromOffset(x, y)
end

local function resolveThemeKey(theme, key)
	local value = theme
	for part in string.gmatch(tostring(key), "[^.]+") do
		if typeof(value) ~= "table" then return nil end
		value = value[tonumber(part) or part]
		if value == nil then return nil end
	end
	return value
end

function Utility.ApplyTheme(root, theme)
	if not root or typeof(theme) ~= "table" then return end

	local function apply(object)
		local bindings = {
			{ object:GetAttribute("FancyBackground"), "BackgroundColor3" },
			{ object:GetAttribute("FancyText"), "TextColor3" },
			{ object:GetAttribute("FancyStroke"), "Color" },
			{ object:GetAttribute("FancyImage"), "ImageColor3" },
			{ object:GetAttribute("FancyScrollBar"), "ScrollBarImageColor3" },
		}
		for _, binding in bindings do
			if binding[1] then
				local color = resolveThemeKey(theme, binding[1])
				if typeof(color) == "Color3" then
					pcall(function()
						object[binding[2]] = color
					end)
				end
			end
		end
	end

	apply(root)
	for _, object in root:GetDescendants() do
		apply(object)
	end
end

function Utility.ElementBase(Fancy, container, settings)
    local Theme = Fancy.Theme
    settings = typeof(settings) == "table" and settings or {}

    local hasDescription = typeof(settings.Description) == "string" and settings.Description ~= ""
    local height = settings.Height or (hasDescription and 50 or 32)

    local Card = Fancy.Modules.Instance:Create("Frame", {
        Name = tostring(settings.Name or settings.Title or "Element"),
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = Theme.Secondary[2],
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = container,
    })
    Card:SetAttribute("FancyBackground", "Secondary.2")
    Fancy.Modules.Instance:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Card })

    local stroke = Fancy.Modules.Instance:Create("UIStroke", {
        Color = Theme.Stroke,
        Transparency = math.min((Theme.StrokeTransparency or 0.92) + 0.02, 1),
        Parent = Card,
    })
    stroke:SetAttribute("FancyStroke", "Stroke")

    local Hover = Fancy.Modules.Instance:Create("Frame", {
        Name = "HoverWash",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.Stroke,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = Card,
    })
    Hover:SetAttribute("FancyBackground", "Stroke")
    Fancy.Modules.Instance:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Hover })

    Card.MouseEnter:Connect(function()
        Utility.Tween(Hover, 0.12, { BackgroundTransparency = 0.965 })
    end)
    Card.MouseLeave:Connect(function()
        Utility.Tween(Hover, 0.18, { BackgroundTransparency = 1 })
    end)

    local Label = Fancy.Modules.Instance:Create("TextLabel", {
        Position = UDim2.new(0, 10, 0, hasDescription and 8 or 0),
        Size = UDim2.new(1, -20, 0, hasDescription and 14 or height),
        BackgroundTransparency = 1,
        Font = Theme.Font,
        Text = tostring(settings.Name or settings.Title or "Element"),
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = Card,
    })
    Label:SetAttribute("FancyText", "Text")

    local Description
    if hasDescription then
        Description = Fancy.Modules.Instance:Create("TextLabel", {
            Position = UDim2.new(0, 10, 0, 26),
            Size = UDim2.new(1, -20, 0, 13),
            BackgroundTransparency = 1,
            Font = Theme.Font,
            Text = settings.Description,
            TextSize = 11,
            TextColor3 = Theme.SubText,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = Card,
        })
        Description:SetAttribute("FancyText", "SubText")
    end

    return Card, Label, Description, settings, Hover
end

function Utility.MakeDraggable(handle, target, canDrag, onMoved)
    if not handle or not target then return end
	
    local DRAG_DEADZONE = 4

    local dragging = false
    local dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if target.Parent == nil then return end
        if canDrag and not canDrag() then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
        end
    end)

    local endedConnection
    local changedConnection

    local function disconnect()
        endedConnection:Disconnect()
        changedConnection:Disconnect()
    end

    endedConnection = UserInputService.InputEnded:Connect(function(input)
        if target.Parent == nil then
            disconnect()
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.TouchEnded:Connect(function(touch)
        if dragging and touch.UserInputState == Enum.UserInputState.Cancel then
            dragging = false
        end
    end)

    changedConnection = UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if target.Parent == nil then
            disconnect()
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            if math.abs(delta.X) < DRAG_DEADZONE and math.abs(delta.Y) < DRAG_DEADZONE then
                return
            end

            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)

            if typeof(onMoved) == "function" then
                onMoved(target)
            end
        end
    end)
end

local ENCODE_CHARS = buffer.fromstring("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/")
local ENCODE_URL_CHARS = buffer.fromstring("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_")

local DECODE_LUT = buffer.create(256)
buffer.fill(DECODE_LUT, 0, 0xFF, 256)

for i = 0, 63 do
	local charCode = buffer.readu8(ENCODE_CHARS, i)
	buffer.writeu8(DECODE_LUT, charCode, i)
end

buffer.writeu8(DECODE_LUT, 45, 62)
buffer.writeu8(DECODE_LUT, 95, 63)

local function toBuffer(input)
	if type(input) == "string" then
		return buffer.fromstring(input)
	end
	return input
end

local function encodeInternal(src)
	local srcLen = buffer.len(src)
	if srcLen == 0 then
		return buffer.create(0)
	end

	local rem = srcLen % 3
	local mainLen = srcLen - rem

	local dstLen = (mainLen // 3 + 1) * 4
	if rem == 0 then
		dstLen = (mainLen // 3) * 4
	end
	
	local dst = buffer.create(dstLen)
	local srcIdx = 0
	local dstIdx = 0
	
	while srcIdx < mainLen do
		local b0 = buffer.readu8(src, srcIdx)
		local b1 = buffer.readu8(src, srcIdx + 1)
		local b2 = buffer.readu8(src, srcIdx + 2)
		srcIdx += 3

		local n = bit32.bor(bit32.lshift(b0, 16), bit32.lshift(b1, 8), b2)
		buffer.writeu8(dst, dstIdx, buffer.readu8(ENCODE_CHARS, bit32.rshift(n, 18)))
		buffer.writeu8(dst, dstIdx + 1, buffer.readu8(ENCODE_CHARS, bit32.band(bit32.rshift(n, 12), 0x3F)))
		buffer.writeu8(dst, dstIdx + 2, buffer.readu8(ENCODE_CHARS, bit32.band(bit32.rshift(n, 6), 0x3F)))
		buffer.writeu8(dst, dstIdx + 3, buffer.readu8(ENCODE_CHARS, bit32.band(n, 0x3F)))
		dstIdx += 4
	end

	if rem == 1 then
		local b0 = buffer.readu8(src, srcIdx)
		buffer.writeu8(dst, dstIdx, buffer.readu8(ENCODE_CHARS, bit32.rshift(b0, 2)))
		buffer.writeu8(dst, dstIdx + 1, buffer.readu8(ENCODE_CHARS, bit32.lshift(bit32.band(b0, 0x03), 4)))
		buffer.writeu8(dst, dstIdx + 2, 61)
		buffer.writeu8(dst, dstIdx + 3, 61)
	elseif rem == 2 then
		local b0 = buffer.readu8(src, srcIdx)
		local b1 = buffer.readu8(src, srcIdx + 1)
		local n = bit32.bor(bit32.lshift(b0, 8), b1)
		buffer.writeu8(dst, dstIdx, buffer.readu8(ENCODE_CHARS, bit32.rshift(n, 10)))
		buffer.writeu8(dst, dstIdx + 1, buffer.readu8(ENCODE_CHARS, bit32.band(bit32.rshift(n, 4), 0x3F)))
		buffer.writeu8(dst, dstIdx + 2, buffer.readu8(ENCODE_CHARS, bit32.lshift(bit32.band(n, 0x0F), 2)))
		buffer.writeu8(dst, dstIdx + 3, 61)
	end

	return dst
end

local function decodeInternal(src)
	local srcLen = buffer.len(src)
	if srcLen == 0 then
		return buffer.create(0)
	end

	while srcLen > 0 do
		local last = buffer.readu8(src, srcLen - 1)
		if last == 10 or last == 13 or last == 32 or last == 9 then
			srcLen -= 1
		else
			break
		end
	end

	if srcLen == 0 then
		return buffer.create(0)
	end

	local pad = 0
	if srcLen >= 2 and buffer.readu8(src, srcLen - 1) == 61 then
		pad = 1
		if buffer.readu8(src, srcLen - 2) == 61 then
			pad = 2
		end
	end

	local outputLen
	if pad > 0 then
		if srcLen % 4 ~= 0 then
			error("Invalid Base64 input: padded length must be a multiple of 4")
		end
		if srcLen >= 3 and buffer.readu8(src, srcLen - 3) == 61 then
			error("Invalid Base64 input: too many padding characters")
		end
		outputLen = (srcLen // 4) * 3 - pad
	else
		local rem = srcLen % 4
		if rem == 0 then
			outputLen = (srcLen // 4) * 3
		elseif rem == 2 then
			outputLen = (srcLen // 4) * 3 + 1
		elseif rem == 3 then
			outputLen = (srcLen // 4) * 3 + 2
		else
			error("Invalid Base64 input: invalid unpadded string length")
		end
	end

	if outputLen < 0 then
		error("Invalid Base64 input: invalid length")
	end

	local dst = buffer.create(outputLen)
	local fullEnd = pad > 0 and srcLen - 4 or srcLen - (srcLen % 4)
	local srcIdx = 0
	local dstIdx = 0

	while srcIdx < fullEnd do
		local c0 = buffer.readu8(src, srcIdx)
		local c1 = buffer.readu8(src, srcIdx + 1)
		local c2 = buffer.readu8(src, srcIdx + 2)
		local c3 = buffer.readu8(src, srcIdx + 3)
		srcIdx += 4

		local v0 = buffer.readu8(DECODE_LUT, c0)
		local v1 = buffer.readu8(DECODE_LUT, c1)
		local v2 = buffer.readu8(DECODE_LUT, c2)
		local v3 = buffer.readu8(DECODE_LUT, c3)

		if bit32.bor(v0, v1, v2, v3) >= 64 then
			error("Invalid Base64 character encountered")
		end

		local n = bit32.bor(bit32.lshift(v0, 18), bit32.lshift(v1, 12), bit32.lshift(v2, 6), v3)
		buffer.writeu8(dst, dstIdx, bit32.rshift(n, 16))
		buffer.writeu8(dst, dstIdx + 1, bit32.band(bit32.rshift(n, 8), 0xFF))
		buffer.writeu8(dst, dstIdx + 2, bit32.band(n, 0xFF))
		dstIdx += 3
	end

	local remaining = outputLen - dstIdx
	if remaining == 1 then
		local c0 = buffer.readu8(src, srcIdx)
		local c1 = buffer.readu8(src, srcIdx + 1)
		local v0 = buffer.readu8(DECODE_LUT, c0)
		local v1 = buffer.readu8(DECODE_LUT, c1)

		if bit32.bor(v0, v1) >= 64 then
			error("Invalid Base64 character encountered")
		end

		buffer.writeu8(dst, dstIdx, bit32.bor(bit32.lshift(v0, 2), bit32.rshift(v1, 4)))
	elseif remaining == 2 then
		local c0 = buffer.readu8(src, srcIdx)
		local c1 = buffer.readu8(src, srcIdx + 1)
		local c2 = buffer.readu8(src, srcIdx + 2)
		local v0 = buffer.readu8(DECODE_LUT, c0)
		local v1 = buffer.readu8(DECODE_LUT, c1)
		local v2 = buffer.readu8(DECODE_LUT, c2)

		if bit32.bor(v0, v1, v2) >= 64 then
			error("Invalid Base64 character encountered")
		end

		local n = bit32.bor(bit32.lshift(v0, 10), bit32.lshift(v1, 4), bit32.rshift(v2, 2))
		buffer.writeu8(dst, dstIdx, bit32.rshift(n, 8))
		buffer.writeu8(dst, dstIdx + 1, bit32.band(n, 0xFF))
	end

	return dst
end

Utility.Base64 = {
	Encode = function(str)
		if typeof(str) ~= "string" then
			return ""
		end
		
		if typeof(crypt) == "table" and typeof(crypt.base64) == "table" and typeof(crypt.base64.encode) == "function" then
			return crypt.base64.encode(str)
		end
		
		return buffer.tostring(encodeInternal(toBuffer(str), false))
	end,
	Decode = function(str)
		if typeof(str) ~= "string" then
			return ""
		end
		
		if typeof(crypt) == "table" and typeof(crypt.base64) == "table" and typeof(crypt.base64.decode) == "function" then
			return crypt.base64.decode(str)
		end
		
		return buffer.tostring(decodeInternal(toBuffer(str)))
	end
}

local Signal = {}
Signal.__index = Signal

function Utility.Signal()
	return setmetatable({ _bindable = Instance.new("BindableEvent") }, Signal)
end

function Signal:Connect(callback)
	return self._bindable.Event:Connect(callback)
end

function Signal:Fire(...)
	self._bindable:Fire(...)
end

function Signal:Wait()
	return self._bindable.Event:Wait()
end

function Signal:Destroy()
	self._bindable:Destroy()
end

return Utility
