local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local TextChatService = game:GetService("TextChatService")
local RBXSystem = TextChatService.TextChannels.RBXSystem

local ProfileData = ReplicatedStorage.Remotes.Inventory.GetProfileData:InvokeServer()
local ItemDB = require(ReplicatedStorage.Database.Sync.Item)

local WeaponModels = Instance.new("Folder",ReplicatedStorage)
WeaponModels.Name = "WeaponModels"

local function SaveWeapon(Tool)
	if not CollectionService:HasTag(Tool,"Weapon") then return end
	local ItemID = Tool:GetAttribute("ItemID")
	local ItemType = ItemDB[ItemID].ItemType

	if not WeaponModels:FindFirstChild(ItemID) then
		task.wait(3)
		local Clone = Tool:Clone()

		for _, v in pairs(Clone:GetDescendants()) do
			if (v:IsA("LuaSourceContainer") and (v.Name == "KnifeServer" or v.Name == "KnifeClient" or v.Name == "KnifeVisuals" or v.Name == "GunServer" or v.Name == "GunClient"))
				or (v:IsA("BoolValue") and (v.Name == "IsGun" or v.Name == "DualEffect")) or (v:IsA("BasePart") and (v.Name == "Dual"))
				or v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("BillboardGui") or (v:IsA("RemoteEvent") and v.Name == "Shoot")
				or (v:IsA("Sound") and (v.Name == "Reload" or v.Name == "Gunshot" or v.Name == "Kill" or v.Name == "Throw"))
				or (v:IsA("Folder") and (v.Name == "Animations" or v.Name == "Sounds" or v.Name == "Events")) then
				v:Destroy()
			elseif v:IsA("Decal") and v.Name == "Chroma" then
				v:SetAttribute("ChromaLayer")
			end
		end

		for _, v in ipairs({
			"RadioAngles","RadioOffset","Angles","EvoBaseID","ItemType",
			"Image","IsGun","IsKnife","IsWeapon","ItemID","ItemName",
			"Rarity","Season","ThrowSpeed","EquippedPerk","Event",
			"EvoIndex","Evo","Chroma","FX","RadioAngles","Year"}) do
			Clone:SetAttribute(v)
		end

		CollectionService:RemoveTag(Clone,"Weapon")
		CollectionService:RemoveTag(Clone,"Weapon_"..ItemType)

		for _, v in pairs(Clone:GetDescendants()) do
			if v:IsA("WeldConstraint") or v:IsA("ManualWeld") then
				local Part0 = Instance.new("ObjectValue",v)
				Part0.Name = "Part0Object"
				Part0.Value = v.Part0
				local Part1 = Instance.new("ObjectValue",v)
				Part1.Value = v.Part1
				Part1.Name = "Part1Object"
			end
			if v:IsA("BasePart") then
				pcall(function()
					v:SetAttribute("CollisionFidelity",v.CollisionFidelity.Name)
				end)
			end
		end

		Clone.Name = ItemID
		Clone.TextureId = ""
		Clone.Parent = WeaponModels
	end

	WeaponModels:WaitForChild(ItemID,5)
	RBXSystem:DisplaySystemMessage(
		`<font color="{ItemType == "Knife" and "#ff2e46" or "#0071e3"}">({ItemType}) {ItemID} saved successfully.</font>`
	)
end

local RadioModels = Instance.new("Folder",ReplicatedStorage)
RadioModels.Name = "RadioModels"

local function SaveRadio(Player, Radio)
	pcall(function()
		task.wait(3)
		if RadioModels:FindFirstChild(Radio) then return end
		local Clone = (Player.Character:FindFirstChild("Radio") and Player.Character.Radio:Clone())
		
		if not Clone then return end
		
		if Clone:FindFirstChild("OriginalSize") then
			Clone.Size = Clone:FindFirstChild("OriginalSize").Value
		end
		
		for _, v in pairs(Clone:GetDescendants()) do
			if v:IsA("WeldConstraint") or v:IsA("ManualWeld") then
				local Part0 = Instance.new("ObjectValue",v)
				Part0.Name = "Part0Object"
				Part0.Value = v.Part0
				local Part1 = Instance.new("ObjectValue",v)
				Part1.Value = v.Part1
				Part1.Name = "Part1Object"
			end
			if v:IsA("BasePart") then
				pcall(function()
					v:SetAttribute("CollisionFidelity",v.CollisionFidelity.Name)
				end)
			end
			if v:IsA("Sound") or v:IsA("Vector3Value") then
				v:Destroy()
			end
		end

		Clone.Name = Radio
		Clone.CFrame = CFrame.new(0, 0, 0)
		Clone.Parent = RadioModels
		
		RadioModels:WaitForChild(Radio,5)
		RBXSystem:DisplaySystemMessage(`<font color="#00FF00">(Radio) {Radio} saved successfully.</font>`)
	end)
end

local Effects = Instance.new("Folder",ReplicatedStorage)
Effects.Name = "Effects"

local function SaveEffect(Player, Effect)
	if Effect and Effect ~= "Dual" and Effect ~= "None" and not Effects:FindFirstChild(Effect) then
		pcall(function()
			task.wait(1.5)
			local EffectFolder = Instance.new("Folder")
			EffectFolder.Name = Effect
			EffectFolder.Parent = Effects

			for _, v in Player.Character.DisplayRefKnife.Value:GetDescendants() do
				if v:IsA("ParticleEmitter") or v:IsA("Fire") then
					v:Clone().Parent = EffectFolder
				end
			end

			RBXSystem:DisplaySystemMessage(`<font color="#00FF00">(Effect) {EffectFolder.Name} saved successfully.</font>`)
		end)
	end
end

local function CheckBackpack(Player)
	pcall(function()
		Player.Backpack.ChildAdded:Connect(SaveWeapon)
		Player.ChildAdded:Connect(function(obj)
			if obj:IsA("Backpack") then
				obj.ChildAdded:Connect(SaveWeapon)
			end
		end)
	end)
end

local function SetupPlayer(Player)
	CheckBackpack(Player)

	local function UpdateRadio()
		SaveRadio(Player, Player:GetAttribute("EquippedRadio"))
	end

	local function UpdateEffect()
		SaveEffect(Player, Player:GetAttribute("EquippedEffect"))
	end

	Player:GetAttributeChangedSignal("EquippedRadio"):Connect(UpdateRadio)
	Player:GetAttributeChangedSignal("EquippedEffect"):Connect(UpdateEffect)

	UpdateRadio()
	UpdateEffect()
end

for i, Player in Players:GetPlayers() do
	SetupPlayer(Player)
end
Players.PlayerAdded:Connect(SetupPlayer)

while task.wait(5) do
	ReplicatedStorage.Remotes.CustomGames.SubmitDuel:FireServer({
		Team1 = {[Players.LocalPlayer.Name] = {Knife = true, Gun = true}},
		Team2 = (function()
			local Table = {}
			for _, Player in pairs(Players:GetPlayers()) do
				if Player ~= Players.LocalPlayer then
					Table[Player.Name] = {Knife = true, Gun = true}
				end
			end
			return Table
		end)()
	})
end
