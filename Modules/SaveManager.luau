--[[
    Fancy SaveManager

    10/7/2026
    7:22 AM
    GMT+7
]]

local HttpService = game:GetService("HttpService")

local SaveManager = {}
SaveManager.Folder = "FancyUI/Configs"
SaveManager.DefaultName = "FancyConfig"
SaveManager.AutoSaveInterval = 60
SaveManager.DebounceDelay = 2

local Fancy = nil
local Initialized = false
local FileApi = false
local Registry = {}
local Pending = {}
local MemoryConfigs = {}
local AutoSaveToken = 0
local DebounceToken = 0

local function notify(props)
	if Fancy and Fancy.MainUI and Fancy.Modules and Fancy.Modules.Notifications then
		Fancy.Modules.Notifications.Send(Fancy, props)
	end
end

local function encode(data)
	if typeof(data) ~= "table" then return nil end
	local ok, json = pcall(HttpService.JSONEncode, HttpService, data)
	if not ok or typeof(json) ~= "string" then return nil end
	local okB64, encoded = pcall(Fancy.Modules.Utility.Base64.Encode, json)
	if okB64 and typeof(encoded) == "string" then
		return encoded
	end
	return nil
end

local function decode(content)
	if typeof(content) ~= "string" or #content == 0 then return nil end
	local ok, json = pcall(Fancy.Modules.Utility.Base64.Decode, content)
	if not ok or typeof(json) ~= "string" then return nil end
	local okJson, data = pcall(HttpService.JSONDecode, HttpService, json)
	if okJson and typeof(data) == "table" then
		return data
	end
	return nil
end

local function sanitize(name)
	name = tostring(name or "")
	name = name:gsub("^%s+", ""):gsub("%s+$", "")
	name = name:gsub("[^%w%s%-_]", "")
	return name
end

local function configPath(name)
	return SaveManager.Folder .. "/" .. name .. ".json"
end

local function ensureFolder()
	if not FileApi then
		return true
	end
	local built = ""
	for segment in string.gmatch(SaveManager.Folder, "[^/\\]+") do
		built = built == "" and segment or built .. "/" .. segment
		if not isfolder(built) then
			pcall(makefolder, built)
		end
	end
	return isfolder(SaveManager.Folder)
end

local function writeConfig(path, json)
	if FileApi then
		return (pcall(writefile, path, json))
	end
	MemoryConfigs[path] = json
	return true
end

local function readConfig(path)
	if FileApi then
		if not isfile(path) then return nil end
		local ok, content = pcall(readfile, path)
		if ok and typeof(content) == "string" then
			return content
		end
		return nil
	end
	return MemoryConfigs[path]
end

local function deleteConfig(path)
	if FileApi then
		if isfile(path) then
			return (pcall(delfile, path))
		end
		return true
	end
	MemoryConfigs[path] = nil
	return true
end

local function checkReady()
	if Initialized and Fancy then
		return true
	end
	notify({ Title = "SaveManager", Text = "Not initialized", Type = "Warning", Duration = 6 })
	return false
end

function SaveManager:Initialize(RealFancy)
	Fancy = RealFancy or Fancy
	FileApi = typeof(writefile) == "function"
		and typeof(readfile) == "function"
		and typeof(isfile) == "function"
		and typeof(isfolder) == "function"
		and typeof(makefolder) == "function"

	local config = {}
	if Fancy and typeof(Fancy.WindowSettings) == "table"
		and typeof(Fancy.WindowSettings.Configuration) == "table" then
		config = Fancy.WindowSettings.Configuration
	end

	if not Initialized then
		if typeof(config.CustomFolder) == "string" and #sanitize(config.CustomFolder) > 0 then
			SaveManager.Folder = sanitize(config.CustomFolder) .. "/Configs"
		end
		if typeof(config.FileName) == "string" and #sanitize(config.FileName) > 0 then
			SaveManager.DefaultName = sanitize(config.FileName)
		end

		if not FileApi then
			notify({
				Title = "SaveManager",
				Text = "File system API unavailable configs are in-memory for this session",
				Type = "Warning",
				Duration = 7,
			})
		end
	end

	Initialized = true

	if config.AutoLoad ~= false then
		task.defer(function()
			if not (Fancy and Fancy.MainUI) then return end
			if not SaveManager:Get(SaveManager.DefaultName) then return end
			local ok, applied, deferred = SaveManager:Load(SaveManager.DefaultName, true)
			if ok then
				local total = (applied or 0) + (deferred or 0)
				if total > 0 then
					notify({
						Title = "SaveManager",
						Text = ("Auto-loaded '%s' %d flags"):format(SaveManager.DefaultName, total),
						Type = "Success",
						Duration = 4,
					})
				end
			end
		end)
	end

	if config.AutoSave then
		SaveManager:EnableAutoSave(tonumber(config.AutoSaveInterval) or SaveManager.AutoSaveInterval)
	end
end

function SaveManager.Register(flag, api)
	if typeof(flag) ~= "string" or #flag == 0 then
		warn("[Fancy] SaveManager.Register: flag must be a non-empty string")
		return
	end
	if typeof(api) ~= "table" or typeof(api.Get) ~= "function" or typeof(api.Set) ~= "function" then
		warn(("[Fancy] SaveManager.Register('%s'): api needs Get and Set functions"):format(flag))
		return
	end

	if Registry[flag] then
		warn(("[Fancy] SaveManager: flag '%s' registered twice keeping the newest element"):format(flag))
		SaveManager.Unregister(flag)
	end

	local entry = {
		Get = api.Get,
		Set = api.Set,
		Connection = nil,
	}

	if typeof(api.Instance) == "Instance" then
		entry.Connection = api.Instance.Destroying:Connect(function()
			SaveManager.Unregister(flag)
		end)
	end

	Registry[flag] = entry
	
	local pendingValue = Pending[flag]
	if pendingValue ~= nil then
		Pending[flag] = nil
		task.spawn(function()
			pcall(entry.Set, pendingValue)
		end)
	end
end

function SaveManager.Unregister(flag)
	local entry = Registry[flag]
	if not entry then return end
	if entry.Connection then
		pcall(function()
			entry.Connection:Disconnect()
		end)
	end
	Registry[flag] = nil
end

function SaveManager:GetFlag(flag)
	local entry = Registry[flag]
	if not entry then return nil end
	local ok, value = pcall(entry.Get)
	return ok and value or nil
end

function SaveManager:SetFlag(flag, value, silent)
	local entry = Registry[flag]
	if not entry then
		warn(("[Fancy] SaveManager: no element registered with flag '%s'"):format(tostring(flag)))
		return false
	end
	return (pcall(entry.Set, value, silent))
end

function SaveManager:GetFlags()
	local flags = {}
	for flag in Registry do
		flags[flag] = SaveManager:GetFlag(flag)
	end
	return flags
end

function SaveManager:Get(name)
	if not checkReady() then return nil end
	name = sanitize(name)
	if name == "" then return nil end
	local content = readConfig(configPath(name))
	if not content then return nil end
	return decode(content)
end

SaveManager.GetSave = SaveManager.Get

function SaveManager:Save(name, silent)
	if not checkReady() then return false end
	name = sanitize(name ~= nil and name or SaveManager.DefaultName)
	if name == "" then
		notify({ Title = "SaveManager", Text = "Invalid config name", Type = "Warning" })
		return false
	end
	if not ensureFolder() then
		notify({ Title = "SaveManager", Text = "Couldn't create the config folder", Type = "Danger" })
		return false
	end

	local flags = {}
	for flag, entry in Registry do
		local ok, value = pcall(entry.Get)
		if ok then
			flags[flag] = value
		end
	end
	local count = 0
	for _ in flags do
		count += 1
	end

	local payload = encode({
		Theme = Fancy.ThemeName,
		SavedAt = os.time(),
		Flags = flags,
	})
	if not payload then
		notify({ Title = "SaveManager", Text = "Failed to encode the config (flags must be string/number/boolean)", Type = "Danger" })
		return false
	end

	if not writeConfig(configPath(name), payload) then
		notify({ Title = "SaveManager", Text = "Failed to write '" .. name .. "'", Type = "Danger" })
		return false
	end

	if not silent then
		notify({
			Title = "SaveManager",
			Text = ("Saved '%s' %d flags"):format(name, count),
			Type = "Success",
		})
	end
	return true
end

function SaveManager:Load(name, silent)
	if not checkReady() then return false end
	name = sanitize(name ~= nil and name or SaveManager.DefaultName)

	local data = SaveManager:Get(name)
	if not data then
		if not silent then
			notify({ Title = "SaveManager", Text = "Config '" .. name .. "' not found", Type = "Warning" })
		end
		return false
	end

	local flagsTable = typeof(data.Flags) == "table" and data.Flags or {}
	local applied, deferred = 0, 0
	local nextPending = {}

	for flag, value in flagsTable do
		local entry = Registry[flag]
		if entry then
			if pcall(entry.Set, value) then
				applied += 1
			end
		else
			nextPending[flag] = value
			deferred += 1
		end
	end
	Pending = nextPending

	if typeof(data.Theme) == "string" and Fancy.Themes[data.Theme] and Fancy.MainUI then
		Fancy.Theme = Fancy.Themes[data.Theme]
		Fancy.ThemeName = data.Theme
		pcall(Fancy.Modules.Utility.ApplyTheme, Fancy.MainUI, Fancy.Theme)
	end

	if not silent then
		notify({
			Title = "SaveManager",
			Text = ("Loaded '%s' %d flags%s"):format(
				name,
				applied,
				deferred > 0 and (" + " .. deferred .. " deferred") or ""),
			Type = "Success",
		})
	end

	return true, applied, deferred
end

function SaveManager:Delete(name, silent)
	if not checkReady() then return false end
	name = sanitize(name)
	if name == "" then
		notify({ Title = "SaveManager", Text = "Invalid config name", Type = "Warning" })
		return false
	end

	local path = configPath(name)
	if FileApi and not isfile(path) then
		if not silent then
			notify({ Title = "SaveManager", Text = "Config '" .. name .. "' not found", Type = "Warning" })
		end
		return false
	end

	if not deleteConfig(path) then
		notify({ Title = "SaveManager", Text = "Failed to delete '" .. name .. "' (is delfile supported?)", Type = "Danger" })
		return false
	end

	if not silent then
		notify({ Title = "SaveManager", Text = "Deleted '" .. name .. "'", Type = "Info" })
	end
	return true
end

function SaveManager:GetConfigs()
	local names = {}

	if FileApi and typeof(listfiles) == "function" then
		local ok, files = pcall(listfiles, SaveManager.Folder)
		if ok and typeof(files) == "table" then
			for _, path in files do
				local name = string.match(tostring(path), "([^/\\]+)%.json$")
				if name then
					table.insert(names, name)
				end
			end
		end
	else
		for path in MemoryConfigs do
			local name = string.match(path, "([^/\\]+)%.json$")
			if name then
				table.insert(names, name)
			end
		end
	end

	table.sort(names)
	return names
end

function SaveManager:SetFolder(path)
	if typeof(path) ~= "string" then return end
	path = path:gsub("\\", "/"):gsub("/+", "/"):gsub("^%s+", ""):gsub("%s+$", "")
	if path == "" then return end
	SaveManager.Folder = path
end

function SaveManager:GetStorage()
	return FileApi and "Files" or "Memory"
end

function SaveManager.QueueSave()
	if not Initialized then return end
	DebounceToken += 1
	local token = DebounceToken

	task.delay(SaveManager.DebounceDelay, function()
		if token ~= DebounceToken then return end
		if not (Fancy and Fancy.MainUI and Fancy.MainUI.Parent) then return end
		if next(Registry) == nil then return end
		SaveManager:Save(SaveManager.DefaultName, true)
	end)
end

function SaveManager:EnableAutoSave(interval)
	SaveManager:DisableAutoSave()
	interval = math.max(tonumber(interval) or SaveManager.AutoSaveInterval, 10)
	AutoSaveToken += 1
	local token = AutoSaveToken

	task.spawn(function()
		while token == AutoSaveToken do
			task.wait(interval)
			if token ~= AutoSaveToken then break end
			if not (Fancy and Fancy.MainUI and Fancy.MainUI.Parent) then break end
			if next(Registry) ~= nil then
				SaveManager:Save(SaveManager.DefaultName, true)
			end
		end
	end)
end

function SaveManager:DisableAutoSave()
	AutoSaveToken += 1
end

function SaveManager:CreateConfigSection(container)
	local host = nil
	if typeof(container) == "table" then
		if container.Container then
			host = container
		elseif typeof(container.NewSection) == "function" then
			host = container:NewSection({ Name = "Configs" })
		end
	end
	if not host or not Fancy then
		warn("[Fancy] SaveManager:CreateConfigSection expects a Tab or Section")
		return nil
	end

	host:NewParagraph({
		Title = "Storage",
		Text = ("Mode: %s\nFolder: %s\nDefault slot: %s"):format(
			SaveManager:GetStorage(), SaveManager.Folder, SaveManager.DefaultName),
	})

	local nameInput = host:NewInput({
		Name = "Config name",
		Description = "Empty = the default slot ('" .. SaveManager.DefaultName .. "')",
		Placeholder = "my-config",
	})

	local configDropdown = host:NewDropdown({
		Name = "Saved configs",
		Description = "Picking one fills the name box",
		Options = SaveManager:GetConfigs(),
		Callback = function(name)
			nameInput:Set(name)
		end,
	})

	local function currentName()
		local text = nameInput:Get():gsub("^%s+", ""):gsub("%s+$", "")
		return text ~= "" and text or nil
	end

	local function refresh()
		configDropdown:SetOptions(SaveManager:GetConfigs())
	end

	host:NewButton({
		Name = "Save config",
		Description = "Writes every flagged element + the active theme",
		Callback = function()
			if SaveManager:Save(currentName()) then
				refresh()
			end
		end,
	})

	host:NewButton({
		Name = "Load config",
		Callback = function()
			SaveManager:Load(currentName())
		end,
	})

	host:NewButton({
		Name = "Delete config",
		Callback = function()
			if SaveManager:Delete(currentName()) then
				refresh()
			end
		end,
	})

	host:NewButton({
		Name = "Refresh list",
		Callback = refresh,
	})

	return host
end

return SaveManager