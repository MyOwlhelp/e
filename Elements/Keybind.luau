local Keybind = {}
function Keybind:Create(Fancy, container, settings)
    local Utility = Fancy.Modules.Utility
    local UserInputService = Fancy.Services.UserInputService

    local Card, Label, Description, settings = Utility.ElementBase(Fancy, container, settings)
    if Description then
        Description.Size = UDim2.new(1, -80, 0, 14)
    end

    local key = settings.Default
    if typeof(key) == "string" then
        key = Enum.KeyCode[key]
    end

    local Chip = Fancy.Modules.Instance:Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(64, 24),
        BackgroundColor3 = Fancy.Theme.Secondary[1],
        BackgroundTransparency = 0.2,
        Font = Fancy.Theme.Font,
        Text = key and key.Name or "None",
        TextSize = 12,
        TextColor3 = Fancy.Theme.SubText,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        Parent = Card,
    })
    Chip:SetAttribute("FancyBackground", "Secondary.1")
    Chip:SetAttribute("FancyText", "SubText")
    Fancy.Modules.Instance:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Chip })

    local Keybind = {}
    local listening = false
    local held = {} -- KeyCode -> true while physically held down

    local function setListening(state)
        listening = state
        if state then
            Chip.Text = "..."
            Chip.TextColor3 = Fancy.Theme.Accent
        else
            Chip.Text = key and key.Name or "None"
            Chip.TextColor3 = Fancy.Theme.SubText
        end
    end

    local beganConnection
    local endedConnection

    local function disconnect()
        beganConnection:Disconnect()
        endedConnection:Disconnect()
    end

    beganConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if not Card.Parent then
            disconnect()
            return
        end

        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode ~= Enum.KeyCode.Escape then
                    Keybind:Set(input.KeyCode)
                end
                setListening(false)
            end
            return
        end

        if input.UserInputType == Enum.UserInputType.Keyboard then
            if held[input.KeyCode] then
                return
            end
            held[input.KeyCode] = true
        end

        if processed then return end
        if key and input.KeyCode == key then
            Utility.SafeCallback(settings.OnPressed, key)
        end
    end)

    endedConnection = UserInputService.InputEnded:Connect(function(input)
        if not Card.Parent then
            disconnect()
            return
        end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            held[input.KeyCode] = nil
        end
    end)

    Chip.MouseButton1Click:Connect(function()
        setListening(not listening)
    end)

    function Keybind:Set(keyCode, silent)
        if typeof(keyCode) == "string" then
            keyCode = Enum.KeyCode[keyCode]
        end
        if keyCode ~= nil and (typeof(keyCode) ~= "EnumItem" or keyCode.EnumType ~= Enum.KeyCode) then
            warn("[Fancy] Keybind:Set expects an Enum.KeyCode (or its name)")
            return
        end
        key = keyCode
        if not listening then
            Chip.Text = key and key.Name or "None"
        end
        if not silent then
            Utility.SafeCallback(settings.Callback, key)
        end
    end

    function Keybind:Get()
        return key
    end

    function Keybind:SetCallback(callback)
        settings.Callback = callback
    end

    function Keybind:SetOnPressed(callback)
        settings.OnPressed = callback
    end

    if settings.Flag then
        Fancy.Modules.SaveManager.Register(settings.Flag, {
            Instance = Card,
            Get = function()
                local bound = Keybind:Get()
                return bound and bound.Name or nil
            end,
            Set = function(value, silent)
                Keybind:Set(value, silent)
            end
        })
    end

    Keybind.Instance = Card
    return Keybind
end
return Keybind
