--[[
    Fancy UI Library

    10/9/2026
    10:32 PM
    GMT+7
]]

local Fancy = {
    Elements = {},
    Modules = {},
    Themes = {},
    Tabs = {},
    Topbars = {},
    Services = {},
    SelectedTab = nil,
    MainUI = nil,
    WindowSettings = nil,
    Window = nil,
    WindowAPI = nil,
    Refs = nil,
    Theme = nil,
    ThemeName = "Default"
}

local WindowDefaults = {
    Title = "Fancy UI",
    Center = true,
    Resizeable = true,
    Shadow = false,
    Position = UDim2.fromOffset(323, 34),
    Size = UDim2.fromOffset(691, 457),
    MinSize = Vector2.new(540, 350),
    Theme = "Default",
    ToggleKey = Enum.KeyCode.K,
    Configuration = {
        AutoSave = true,
        AutoLoad = true,
        FileName = "FancyConfig",
        CustomFolder = "FancyUI"
    }
}

local Files = {
    Elements = {
        "Button",
        "Keybind",
        "Dropdown",
        "Topbar",
        "Section",
        "Tab",
        "Window",
        "Paragraph",
        "Toggle",
        "Slider",
        "Input"
    },
    Modules = {
        "Icons",
        "Instance",
        "SaveManager",
        "Notifications",
        "Themes",
        "Utility"
    }
}

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

Fancy.Services.UserInputService = GetService("UserInputService")
Fancy.Services.TweenService = GetService("TweenService")
Fancy.Services.TextService = GetService("TextService")
Fancy.Services.RunService = GetService("RunService")
Fancy.Services.Workspace = GetService("Workspace")
Fancy.Services.CoreGui = GetService("CoreGui")
Fancy.Services.Players = GetService("Players")

local LP = Fancy.Services.Players.LocalPlayer
local HiddenUI = (typeof(gethui) == "function" and gethui()) or (LP and clref(LP.PlayerGui)) or Fancy.Services.CoreGui

return function(url)
    if typeof(url) ~= "string" or #url == 0 then
        url = nil
    end

    if Fancy.Services.RunService:IsStudio() and script then
        for _, v in script.Parent.Elements:GetChildren() do
            if v:IsA("ModuleScript") then
                Fancy.Elements[v.Name] = require(v)
            end
        end

        for _, v in script.Parent.Modules:GetChildren() do
            if v:IsA("ModuleScript") then
                if v.Name == "Themes" then
                    for name, theme in require(v) do
                        Fancy.Themes[name] = theme
                    end
                else
                    Fancy.Modules[v.Name] = require(v)
                end
            end
        end
    elseif url then
        if typeof(game.HttpGet) ~= "function" or typeof(loadstring) ~= "function" then
            warn("[Fancy] Remote loading needs game:HttpGet and loadstring (executor only)")
            return nil
        end

        local failures = 0
        local function LoadRemote(path)
            local okFetch, source = pcall(game.HttpGet, game, url .. "/" .. path)
            if not okFetch or typeof(source) ~= "string" or #source == 0 then
                warn("[Fancy] Failed to fetch " .. path)
                return nil
            end

            local chunk = loadstring(source)
            if not chunk then
                warn("[Fancy] Syntax error in " .. path)
                return nil
            end

            local okRun, result = pcall(chunk)
            if not okRun then
                warn("[Fancy] Error while running " .. path .. ":", result)
                return nil
            end
            if result == nil then
                warn("[Fancy] " .. path .. " returned nothing")
                return nil
            end
            return result
        end

        for _, v in Files.Elements do
            local module = LoadRemote("Elements/" .. v .. ".luau")
            if module then
                Fancy.Elements[v] = module
            else
                failures += 1
            end
        end

        for _, v in Files.Modules do
            local module = LoadRemote("Modules/" .. v .. ".luau")
            if module then
                if v == "Themes" then
                    for name, theme in module do
                        Fancy.Themes[name] = theme
                    end
                else
                    Fancy.Modules[v] = module
                end
            else
                failures += 1
            end
        end

        local missing = {}
        for _, v in { "Instance", "Utility", "Icons", "Notifications", "SaveManager" } do
            if not Fancy.Modules[v] then
                table.insert(missing, "Modules/" .. v .. ".luau")
            end
        end
        if not Fancy.Elements.Window then
            table.insert(missing, "Elements/Window.luau")
        end
        if #missing > 0 then
            warn("[Fancy] Core files failed to load: " .. table.concat(missing, ", "))
            return nil
        end
        if failures > 0 then
            warn(("[Fancy] Loaded with %d non-core file failure(s)"):format(failures))
        end
    else
        return nil
    end

    if HiddenUI then
        if HiddenUI:FindFirstChild("FancyUI") then
            pcall(function()
                HiddenUI.FancyUI:Destroy()
            end)
        end
        if HiddenUI:FindFirstChild("FancyTopbars") then
            pcall(function()
                HiddenUI.FancyTopbars:Destroy()
            end)
        end
    end

    Fancy.Window = nil
    Fancy.WindowAPI = nil
    Fancy.Refs = nil
    Fancy.Tabs = {}
    Fancy.SelectedTab = nil
    Fancy.Topbars = {}

    Fancy.MainUI = Fancy.Modules.Instance:Create("ScreenGui", {
        Name = "FancyUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
        Parent = HiddenUI
    })

    Fancy.TopbarUI = Fancy.Modules.Instance:Create("ScreenGui", {
        Name = "FancyTopbars",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 1000,
        Parent = HiddenUI
    })

    Fancy.NotifyLayer = Fancy.TopbarUI or Fancy.MainUI

    if not Fancy.MainUI then
        warn("[Fancy] Failed to create the ScreenGui")
    end

    local Main = {}
    function Main:CreateWindow(properties)
        if not Fancy.MainUI then
            warn("[Fancy] CreateWindow failed: MainUI is nil")
            return nil
        end

        if Fancy.Window then
            warn("[Fancy] CreateWindow failed: a window already exists")
            return Fancy.WindowAPI
        end

        if typeof(properties) ~= "table" then properties = {} end

        local merged = {}
        for key, value in properties do
            merged[key] = value
        end

        if typeof(properties.Window) == "table" then
            for key, value in properties.Window do
                merged[key] = value
            end
        end

        local window = Fancy.Elements.Window:Create(Fancy, merged, WindowDefaults)
        if not window then
            warn("[Fancy] Elements/Window.lua returned nil")
            return nil
        end

        Fancy.WindowSettings = merged
        Fancy.Modules.Utility.Init(Fancy)
        Fancy.Modules.SaveManager:Initialize(Fancy)
        Fancy.WindowAPI = window
        return window
    end

    function Main:Destroy()
        if Fancy.WindowAPI then
            pcall(function()
                Fancy.WindowAPI:Destroy()
            end)
        end
        for _, gui in { Fancy.MainUI, Fancy.TopbarUI } do
            if gui then
                pcall(function()
                    gui:Destroy()
                end)
            end
        end
        Fancy.MainUI = nil
        Fancy.TopbarUI = nil
        Fancy.Window = nil
        Fancy.WindowAPI = nil
        Fancy.Refs = nil
        Fancy.Tabs = {}
        Fancy.SelectedTab = nil
        Fancy.Topbars = {}
    end

    function Main:Toggle(visible)
        if not Fancy.MainUI then return end
        if typeof(visible) == "boolean" then
            Fancy.MainUI.Enabled = visible
        else
            Fancy.MainUI.Enabled = not Fancy.MainUI.Enabled
        end
    end

    function Main:SetTheme(name)
        if typeof(name) ~= "string" or not Fancy.Themes[name] then
            warn(("[Fancy] Theme '%s' does not exist"):format(tostring(name)))
            return
        end
        Fancy.Theme = Fancy.Themes[name]
        Fancy.ThemeName = name
        if Fancy.MainUI then
            Fancy.Modules.Utility.ApplyTheme(Fancy.MainUI, Fancy.Theme)
        end
    end

    function Main:Notify(props)
        if not Fancy.MainUI then return end
        Fancy.Modules.Notifications.Send(Fancy, props)
    end

    Main.Themes = Fancy.Themes
    Main.Icons = Fancy.Modules.Icons
    Main.Utility = Fancy.Modules.Utility
    Main.SaveManager = Fancy.Modules.SaveManager
    return Main
end
