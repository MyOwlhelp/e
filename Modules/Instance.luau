local NewInstance = Instance.new

local clref = (typeof(cloneref) == "function" and cloneref or typeof(clonereference) == "function" and clonereference) or function(...)
	return ...
end

local InstanceModule = {}
function InstanceModule:Create(className, properties)
	if typeof(className) ~= "string" then return nil end

	local ok, new = pcall(NewInstance, className)
	if not ok or not new then return nil end

	local parent
	if typeof(properties) == "table" then
		parent = properties.Parent
		for name, value in properties do
			if name ~= "Parent" then
				pcall(function()
					new[name] = value
				end)
			end
		end
	end

	if parent ~= nil then
		pcall(function()
			new.Parent = parent
		end)
	end

	return clref(new)
end

InstanceModule.New = InstanceModule.Create
return InstanceModule