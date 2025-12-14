-- Gui to Lua
-- Version: 3.2

-- Instances:

local SyncME_V2 = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local ScrollingFrame = Instance.new("ScrollingFrame")
local UIGridLayout = Instance.new("UIGridLayout")
local select = Instance.new("TextLabel")

--Properties:

SyncME_V2.Name = "SyncME_V2"
SyncME_V2.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
SyncME_V2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SyncME_V2.DisplayOrder = 999999999
SyncME_V2.ResetOnSpawn = false

Main.Name = "Main"
Main.Parent = SyncME_V2
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Color3.fromRGB(39, 39, 39)
Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.Size = UDim2.new(0.585725963, 0, 0.557113528, 0)

UIAspectRatioConstraint.Parent = Main
UIAspectRatioConstraint.AspectRatio = 1.753

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Main

Title.Name = "Title"
Title.Parent = Main
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1.000
Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
Title.BorderSizePixel = 0
Title.Position = UDim2.new(0.0140056573, 0, 0.0184162073, 0)
Title.Size = UDim2.new(0.971988678, 0, 0.0607734472, 0)
Title.Font = Enum.Font.BuilderSansMedium
Title.Text = "<b>SyncMe!</b> <font size=\"10\">V3</font>"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.RichText = true
Title.TextSize = 14.000
Title.TextWrapped = true
Title.TextXAlignment = Enum.TextXAlignment.Left

ScrollingFrame.Parent = Main
ScrollingFrame.Active = true
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ScrollingFrame.BackgroundTransparency = 1.000
ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.Position = UDim2.new(0.148809597, 0, 0.205647647, 0)
ScrollingFrame.Size = UDim2.new(0.700630069, 0, 0.729895651, 0)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 3
ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.X
ScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.X

UIGridLayout.Parent = ScrollingFrame
UIGridLayout.FillDirection = Enum.FillDirection.Vertical
UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIGridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
UIGridLayout.CellSize = UDim2.new(0.347000003, 0, 0.109999999, 0)

select.Name = "select"
select.Parent = Main
select.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
select.BackgroundTransparency = 1.000
select.BorderColor3 = Color3.fromRGB(0, 0, 0)
select.BorderSizePixel = 0
select.Position = UDim2.new(0.0122549562, 0, 0.101289138, 0)
select.Size = UDim2.new(0.971988678, 0, 0.0607734472, 0)
select.Font = Enum.Font.BuilderSansBold
select.Text = "Select a Sync Module to decompile"
select.TextColor3 = Color3.fromRGB(255, 255, 255)
select.TextScaled = true
select.TextSize = 14.000
select.TextWrapped = true

-- Scripts:

local function VTFJZ_fake_script() -- SyncME_V2.LocalScript 
	local script = Instance.new('LocalScript', SyncME_V2)

	-- SyncMe! V2 for MM2 by IX_GP.

	script.Parent.Main.Active = true
	script.Parent.Main.Draggable = true
	local defaultSettings = {
		pretty = true;
		robloxFullName = false;
		robloxProperFullName = true;
		robloxClassName = true;
		tabs = true;
		semicolons = true;
		spaces = 1;
		sortKeys = true;
	}

	-- lua keywords
	local keywords = {["and"]=true, ["break"]=true, ["do"]=true, ["else"]=true,
		["elseif"]=true, ["end"]=true, ["false"]=true, ["for"]=true, ["function"]=true,
		["if"]=true, ["in"]=true, ["local"]=true, ["nil"]=true, ["not"]=true, ["or"]=true,
		["repeat"]=true, ["return"]=true, ["then"]=true, ["true"]=true, ["until"]=true, ["while"]=true}

	local function isLuaIdentifier(str)
		if type(str) ~= "string" then return false end
		-- must be nonempty
		if str:len() == 0 then return false end
		-- can only contain a-z, A-Z, 0-9 and underscore
		if str:find("[^%d%a_]") then return false end
		-- cannot begin with digit
		if tonumber(str:sub(1, 1)) then return false end
		-- cannot be keyword
		if keywords[str] then return false end
		return true
	end

	-- works like Instance:GetFullName(), but invalid Lua identifiers are fixed (e.g. workspace["The Dude"].Humanoid)
	local function properFullName(object, usePeriod)
		if object == nil or object == game then return "" end

		local s = object.Name
		local usePeriod = true
		if not isLuaIdentifier(s) then
			s = ("[%q]"):format(s)
			usePeriod = false
		end

		if not object.Parent or object.Parent == game then
			return s
		else
			return properFullName(object.Parent) .. (usePeriod and "." or "") .. s 
		end
	end

	local depth = 0
	local shown
	local INDENT
	local reprSettings

	local function repr(value, reprSettings)
		reprSettings = reprSettings or defaultSettings
		INDENT = (" "):rep(reprSettings.spaces or defaultSettings.spaces)
		if reprSettings.tabs then
			INDENT = "\t"
		end

		local v = value --args[1]
		local tabs = INDENT:rep(depth)

		if depth == 0 then
			shown = {}
		end
		if type(v) == "string" then
			return ("%q"):format(v)
		elseif type(v) == "number" then
			if v == math.huge then return "math.huge" end
			if v == -math.huge then return "-math.huge" end
			return tonumber(v)
		elseif type(v) == "boolean" then
			return tostring(v)
		elseif type(v) == "nil" then
			return "nil"
		elseif type(v) == "table" and type(v.__tostring) == "function" then
			return tostring(v.__tostring(v))
		elseif type(v) == "table" and getmetatable(v) and type(getmetatable(v).__tostring) == "function" then
			return tostring(getmetatable(v).__tostring(v))
		elseif type(v) == "table" then
			if shown[v] then return "{CYCLIC}" end
			shown[v] = true
			local str = "{" .. (reprSettings.pretty and ("\n" .. INDENT .. tabs) or "")
			local isArray = true
			for k, v in pairs(v) do
				if type(k) ~= "number" then
					isArray = false
					break
				end
			end
			if isArray then
				for i = 1, #v do
					if i ~= 1 then
						str = str .. (reprSettings.semicolons and ";" or ",") .. (reprSettings.pretty and ("\n" .. INDENT .. tabs) or " ")
					end
					depth = depth + 1
					str = str .. repr(v[i], reprSettings)
					depth = depth - 1
				end
			else
				local keyOrder = {}
				local keyValueStrings = {}
				for k, v in pairs(v) do
					depth = depth + 1
					local kStr = isLuaIdentifier(k) and k or ("[" .. repr(k, reprSettings) .. "]")
					local vStr = repr(v, reprSettings)
						--[[str = str .. ("%s = %s"):format(
							isLuaIdentifier(k) and k or ("[" .. repr(k, reprSettings) .. "]"),
							repr(v, reprSettings)
						)]]
					table.insert(keyOrder, kStr)
					keyValueStrings[kStr] = vStr
					depth = depth - 1
				end
				if reprSettings.sortKeys then table.sort(keyOrder) end
				local first = true
				for _, kStr in pairs(keyOrder) do
					if not first then
						str = str .. (reprSettings.semicolons and ";" or ",") .. (reprSettings.pretty and ("\n" .. INDENT .. tabs) or " ")
					end
					str = str .. ("%s = %s"):format(kStr, keyValueStrings[kStr])
					first = false
				end
			end
			shown[v] = false
			if reprSettings.pretty then
				str = str .. "\n" .. tabs
			end
			str = str .. "}"
			return str
		elseif typeof then
			-- Check Roblox types
			if typeof(v) == "Instance" then
				return  (reprSettings.robloxFullName
					and (reprSettings.robloxProperFullName and properFullName(v) or v:GetFullName())
					or v.Name) .. (reprSettings.robloxClassName and ((" (%s)"):format(v.ClassName)) or "")
			elseif typeof(v) == "Axes" then
				local s = {}
				if v.X then table.insert(s, repr(Enum.Axis.X, reprSettings)) end
				if v.Y then table.insert(s, repr(Enum.Axis.Y, reprSettings)) end
				if v.Z then table.insert(s, repr(Enum.Axis.Z, reprSettings)) end
				return ("Axes.new(%s)"):format(table.concat(s, ", "))
			elseif typeof(v) == "BrickColor" then
				return ("BrickColor.new(%q)"):format(v.Name)
			elseif typeof(v) == "CFrame" then
				return ("CFrame.new(%s)"):format(table.concat({v:GetComponents()}, ", "))
			elseif typeof(v) == "Color3" then
				return ("Color3.new(%d, %d, %d)"):format(v.r, v.g, v.b)
			elseif typeof(v) == "ColorSequence" then
				if #v.Keypoints > 2 then
					return ("ColorSequence.new(%s)"):format(repr(v.Keypoints, reprSettings))
				else
					if v.Keypoints[1].Value == v.Keypoints[2].Value then
						return ("ColorSequence.new(%s)"):format(repr(v.Keypoints[1].Value, reprSettings))
					else
						return ("ColorSequence.new(%s, %s)"):format(
							repr(v.Keypoints[1].Value, reprSettings),
							repr(v.Keypoints[2].Value, reprSettings)
						)
					end
				end
			elseif typeof(v) == "ColorSequenceKeypoint" then
				return ("ColorSequenceKeypoint.new(%d, %s)"):format(v.Time, repr(v.Value, reprSettings))
			elseif typeof(v) == "DockWidgetPluginGuiInfo" then
				return ("DockWidgetPluginGuiInfo.new(%s, %s, %s, %s, %s, %s, %s)"):format(
					repr(v.InitialDockState, reprSettings),
					repr(v.InitialEnabled, reprSettings),
					repr(v.InitialEnabledShouldOverrideRestore, reprSettings),
					repr(v.FloatingXSize, reprSettings),
					repr(v.FloatingYSize, reprSettings),
					repr(v.MinWidth, reprSettings),
					repr(v.MinHeight, reprSettings)
				)
			elseif typeof(v) == "Enums" then
				return "Enums"
			elseif typeof(v) == "Enum" then
				return ("Enum.%s"):format(tostring(v))
			elseif typeof(v) == "EnumItem" then
				return ("Enum.%s.%s"):format(tostring(v.EnumType), v.Name)
			elseif typeof(v) == "Faces" then
				local s = {}
				for _, enumItem in pairs(Enum.NormalId:GetEnumItems()) do
					if v[enumItem.Name] then
						table.insert(s, repr(enumItem, reprSettings))
					end
				end
				return ("Faces.new(%s)"):format(table.concat(s, ", "))
			elseif typeof(v) == "NumberRange" then
				if v.Min == v.Max then
					return ("NumberRange.new(%d)"):format(v.Min)
				else
					return ("NumberRange.new(%d, %d)"):format(v.Min, v.Max)
				end
			elseif typeof(v) == "NumberSequence" then
				if #v.Keypoints > 2 then
					return ("NumberSequence.new(%s)"):format(repr(v.Keypoints, reprSettings))
				else
					if v.Keypoints[1].Value == v.Keypoints[2].Value then
						return ("NumberSequence.new(%d)"):format(v.Keypoints[1].Value)
					else
						return ("NumberSequence.new(%d, %d)"):format(v.Keypoints[1].Value, v.Keypoints[2].Value)
					end
				end
			elseif typeof(v) == "NumberSequenceKeypoint" then
				if v.Envelope ~= 0 then
					return ("NumberSequenceKeypoint.new(%d, %d, %d)"):format(v.Time, v.Value, v.Envelope)
				else
					return ("NumberSequenceKeypoint.new(%d, %d)"):format(v.Time, v.Value)
				end
			elseif typeof(v) == "PathWaypoint" then
				return ("PathWaypoint.new(%s, %s)"):format(
					repr(v.Position, reprSettings),
					repr(v.Action, reprSettings)
				)
			elseif typeof(v) == "PhysicalProperties" then
				return ("PhysicalProperties.new(%d, %d, %d, %d, %d)"):format(
					v.Density, v.Friction, v.Elasticity, v.FrictionWeight, v.ElasticityWeight
				)
			elseif typeof(v) == "Random" then
				return "<Random>"
			elseif typeof(v) == "Ray" then
				return ("Ray.new(%s, %s)"):format(
					repr(v.Origin, reprSettings),
					repr(v.Direction, reprSettings)
				)
			elseif typeof(v) == "RBXScriptConnection" then
				return "<RBXScriptConnection>"
			elseif typeof(v) == "RBXScriptSignal" then
				return "<RBXScriptSignal>"
			elseif typeof(v) == "Rect" then
				return ("Rect.new(%d, %d, %d, %d)"):format(
					v.Min.X, v.Min.Y, v.Max.X, v.Max.Y
				)
			elseif typeof(v) == "Region3" then
				local min = v.CFrame.p + v.Size * -.5
				local max = v.CFrame.p + v.Size * .5
				return ("Region3.new(%s, %s)"):format(
					repr(min, reprSettings),
					repr(max, reprSettings)
				)
			elseif typeof(v) == "Region3int16" then
				return ("Region3int16.new(%s, %s)"):format(
					repr(v.Min, reprSettings),
					repr(v.Max, reprSettings)
				)
			elseif typeof(v) == "TweenInfo" then
				return ("TweenInfo.new(%d, %s, %s, %d, %s, %d)"):format(
					v.Time, repr(v.EasingStyle, reprSettings), repr(v.EasingDirection, reprSettings),
					v.RepeatCount, repr(v.Reverses, reprSettings), v.DelayTime
				)
			elseif typeof(v) == "UDim" then
				return ("UDim.new(%d, %d)"):format(
					v.Scale, v.Offset
				)
			elseif typeof(v) == "UDim2" then
				return ("UDim2.new(%d, %d, %d, %d)"):format(
					v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset
				)
			elseif typeof(v) == "Vector2" then
				return ("Vector2.new(%d, %d)"):format(v.X, v.Y)
			elseif typeof(v) == "Vector2int16" then
				return ("Vector2int16.new(%d, %d)"):format(v.X, v.Y)
			elseif typeof(v) == "Vector3" then
				return ("Vector3.new(%d, %d, %d)"):format(v.X, v.Y, v.Z)
			elseif typeof(v) == "Vector3int16" then
				return ("Vector3int16.new(%d, %d, %d)"):format(v.X, v.Y, v.Z)
			elseif typeof(v) == "DateTime" then
				return ("DateTime.fromIsoDate(%q)"):format(v:ToIsoDate())
			else
				return "<Roblox:" .. typeof(v) .. ">"
			end
		else
			return "<" .. type(v) .. ">"
		end
	end

	getsyncmodule = repr 

	for ModuleName, Module in pairs(game.ReplicatedStorage.Remotes.Events.GetEvents:InvokeServer()) do
		local ModuleFrame = Instance.new("Frame")
		local UICorner = Instance.new("UICorner")
		local TextLabel = Instance.new("TextLabel")
		local TextButton = Instance.new("TextButton")

		ModuleFrame.Name = "SyncModule"
		ModuleFrame.Parent = script.Parent.Main.ScrollingFrame
		ModuleFrame.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
		ModuleFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ModuleFrame.BorderSizePixel = 0
		ModuleFrame.Position = UDim2.new(0.323879629, 0, 0.441988975, 0)
		ModuleFrame.Size = UDim2.new(0.346988529, 0, 0.110497244, 0)

		UICorner.CornerRadius = UDim.new(0, 12)
		UICorner.Parent = ModuleFrame

		TextLabel.Parent = ModuleFrame
		TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel.BackgroundTransparency = 1.000
		TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TextLabel.BorderSizePixel = 0
		TextLabel.Position = UDim2.new(0.0313370675, 0, 0.245283023, 0)
		TextLabel.Size = UDim2.new(0.926880181, 0, 0.490566045, 0)
		TextLabel.Font = Enum.Font.BuilderSansBold
		TextLabel.Text = ModuleName
		TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel.TextScaled = true
		TextLabel.TextSize = 14.000
		TextLabel.TextWrapped = true

		TextButton.Parent = ModuleFrame
		TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TextButton.BackgroundTransparency = 1.000
		TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TextButton.BorderSizePixel = 0
		TextButton.Size = UDim2.new(1, 0, 1, 0)
		TextButton.Font = Enum.Font.SourceSans
		TextButton.Text = ""
		TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
		TextButton.TextSize = 14.000

		TextButton.MouseButton1Click:Connect(function()
			local v1, v2 = pcall(function()
				writefile(tostring("--[[ ModuleName: "..ModuleName.." ]] \n return "..getsyncmodule(Module)))
			end)
			if v1 then
				script.Parent.Main.select.Text = "Decompiled!"
				wait(1)
				script.Parent.Main.select.Text = "Select a Sync Module to decompile"
			else
				script.Parent.Main.select.Text = "Error in decompiling"
				wait(1)
				script.Parent.Main.select.Text = "Select a Sync Module to decompile"
			end
		end)
	end


end
coroutine.wrap(VTFJZ_fake_script)()
