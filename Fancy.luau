--[[
    Fancy UI Library

    10/7/2026
    7:25 AM
    GMT+7
]]

local Fancy = {
	Elements = {},
	Modules = {},
	Themes = {},
	Tabs = {},
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
Fancy.Services.RunService = GetService("RunService")
Fancy.Services.Workspace = GetService("Workspace")
Fancy.Services.CoreGui = GetService("CoreGui")
Fancy.Services.Players = GetService("Players")

local LP = Fancy.Services.Players.LocalPlayer
local HiddenUI = typeof(gethui) == "function" and gethui() or CoreGui or (LP and clref(LP.PlayerGui))

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
		for _, v in Files.Elements do
			local ok, res = pcall(loadstring, game:HttpGet(url .. "/Elements/" .. v .. ".luau"))
			if not ok then
				warn("[Fancy] Failed to load " .. v .. ":", res)
				continue
			end
			
			Fancy.Elements[v] = res
		end
		
		for _, v in Files.Modules do
			local ok, res = pcall(loadstring, game:HttpGet(url .. "/Modules/" .. v .. ".luau"))
			if not ok then
				warn("[Fancy] Failed to load " .. v .. ":", res)
				continue
			end
			
			if v == "Themes" then
				for name, theme in res do
					Fancy.Themes[name] = theme
				end
			else
				Fancy.Modules[v] = res
			end
		end
	else
		return nil
	end
	
	Fancy.MainUI = Fancy.Modules.Instance:Create("ScreenGui", {
		Name = "FancyUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 999,
		Parent = HiddenUI
	})

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

		local window = Fancy.Elements.Window:Create(Fancy, merged, WindowDefaults.Window)
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
		if Fancy.MainUI then
			pcall(function()
				Fancy.MainUI:Destroy()
			end)
		end
		Fancy.MainUI = nil
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