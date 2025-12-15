local TextChatService = game:GetService("TextChatService")
local CollectionService = game:GetService("CollectionService")
local RBXSystem = TextChatService.TextChannels.RBXSystem

local Items = Instance.new("Folder", game.ReplicatedStorage)
Items.Name = "Items"

local Item = Instance.new("Folder", Items)
Item.Name = "Item"

local function onToolAdded(obj)
	if obj:HasTag("Weapon") and not Item:FindFirstChild(obj:GetAttribute("ItemID")) then
		pcall(function()
			task.wait(0.5)
			obj = obj:Clone()
			for i, v in obj:GetDescendants() do
				if (v:IsA("Sound") and v.Name == "Reload" or v.Name == "Gunshot" or v.Name == "Kill" or v.Name == "Throw") 
					or (v:IsA("LuaSourceContainer") and v.Name == "KnifeServer" or v.Name == "KnifeClient" or v.Name == "KnifeVisuals" or v.Name == "GunServer" or v.Name == "GunClient")
					or (v:IsA("Folder") and v.Name == "Animations" or v.Name == "Sounds" or v.Name == "Events")
					or (v:IsA("RemoteEvent") and v.Name == "End" or v.Name == "Stab" or v.Name == "Throw")
					or (v:IsA("BoolValue") and v.Name == "IsGun" or v.Name == "DualEffect")
					or v:IsA("TouchTransmitter")
					or v:IsA("ParticleEmitter") then
					v:Destroy()
				end
			end

			obj:RemoveTag("Weapon")
			obj:RemoveTag(`Weapon_{obj:GetAttribute("ItemType")}`)
			obj.Name = obj:GetAttribute("ItemID")
			obj.Parent = Item
			task.wait(0.1)

			for i, v in obj:GetAttributes() do
				obj:SetAttribute(i)
			end
			RBXSystem:DisplaySystemMessage(`<font color="#00FF00">(Weapon) {obj.Name} saved successfully.</font>`)
		end)
	end
end

local Radios = Instance.new("Folder", Items)
Radios.Name = "Radios"

local Effects = Instance.new("Folder", Items)
Effects.Name = "Effects"

local Perks = Instance.new("Folder", Items)
Perks.Name = "Perks"

local function checkItems(Player)
	local EffectName = Player:GetAttribute("EquippedEffect")

	if EffectName and EffectName ~= "Dual" and EffectName ~= "None" and not Effects:FindFirstChild(EffectName) then
		pcall(function()
			task.wait(0.5)
			local EffectFolder = Instance.new("Folder")
			EffectFolder.Name = EffectName
			EffectFolder.Parent = Effects

			for _, v in Player.Character.DisplayRefKnife.Value:GetDescendants() do
				if v:IsA("ParticleEmitter") or v:IsA("Fire") then
					v:Clone().Parent = EffectFolder
				end
			end

			RBXSystem:DisplaySystemMessage(`<font color="#00FF00">(Effect) {EffectFolder.Name} saved successfully.</font>`)
		end)
	end

	local character = Player.Character or Player.CharacterAdded:Wait()
	local Radio = character:FindFirstChild("Radio")
	local RadioName = Player:GetAttribute("EquippedRadio")

	if Radio and RadioName and not Radios:FindFirstChild(RadioName) then
		pcall(function()
			task.wait(0.5)
			local obj = Radio:Clone()

			if obj:FindFirstChild("OriginalSize") then
				obj.Size = obj:FindFirstChild("OriginalSize").Value
			end

			for i, v in obj:GetDescendants() do
				if v:IsA("Sound") or v:IsA("Vector3Value") then
					v:Destroy()
				end
			end

			obj.Name = RadioName
			obj.CFrame = CFrame.new(0, 0, 0)
			obj.Parent = Radios

			RBXSystem:DisplaySystemMessage(`<font color="#00FF00">(Radio) {obj.Name} saved successfully.</font>`)
		end)
	end

	local folder = Player.Character:FindFirstChild("Folder")
	local Perk = folder and CollectionService:HasTag(folder, "Perk")


	if Perk and not Perks:FindFirstChild(Perk.Name) then
		task.wait(0.5)
		pcall(function()
			local obj = Perk:Clone()
			obj.Parent = Perks
			RBXSystem:DisplaySystemMessage(`<font color="#00FF00">(Perk) {obj.Name} saved successfully.</font>`)
		end)
	end
end

local function checkBackpack(Player)
	pcall(function()
		Player.Backpack.ChildAdded:Connect(onToolAdded)
		Player.ChildAdded:Connect(function(obj)
			if obj:IsA("Backpack") then
				obj.ChildAdded:Connect(onToolAdded)
			end
		end)
	end)
end

for i, Player in game.Players:GetPlayers() do
	Player:GetAttributeChangedSignal("EquippedRadio"):Connect(function()
		checkItems(Player)
	end)
	Player:GetAttributeChangedSignal("EquippedEffect"):Connect(function()
		checkItems(Player)
	end)
	checkItems(Player)
	checkBackpack(Player)
end

game.Players.PlayerAdded:Connect(function(player)
	checkItems(player)
	checkBackpack(player)

	player:GetAttributeChangedSignal("EquippedRadio"):Connect(function()
		checkItems(player)
	end)
	player:GetAttributeChangedSignal("EquippedEffect"):Connect(function()
		checkItems(player)
	end)
end)

local Maps = Instance.new("Folder", Items)
Maps.Name = "Maps"

workspace.ChildAdded:Connect(function(child)
	if child:HasTag("CurrentMap") then
		pcall(function()
			if not Maps:FindFirstChild(child.Name) then
				task.wait(5)
				child:Clone().Parent = Maps
				child:RemoveTag("CurrentMap")
				if CollectionService:HasTag(child, "PerkWorldParts") then
					child:RemoveTag("WorldParts")
				end
				RBXSystem:DisplaySystemMessage(`<font color="#00FF00">(Map) {child.Name} saved successfully.</font>`)
			end
		end)
	end
end)
