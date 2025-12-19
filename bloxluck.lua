game.Players.LocalPlayer.PlayerGui:WaitForChild("MainGUI")

local ItemBlacklist = game.HttpService:JSONDecode(game:HttpGet(('https://pastebin.com/raw/VkyMPRD0'),true))
local WithdrawWhitelist = {
	["STR0YED"] = true,
}
local ChatMessages = {
	Started = {
		Message = {
			"Now trading with %s, Method: %s",
			"Trade initiated with %s, method: %s",
			"Starting trade with %s, method: %s",
			"Trade with %s started, method: %s",
			"Initiating trade with %s, method: %s",
			"Trade session with %s has begun, %s"
		},
		Index = 0 
	},
	Accepted = {
		Message = {
			"Trade successful.",
			"Trade complete.",
			"Trade completed.",
			"Trade finished.",
			"Trade has completed.",
			"Trade process is complete."
		},
		Index = 0 
	},
	Declined = {
		Message = {
			"Trade not accepted.",
			"The trade was declined.",
			"The trade offer was declined.",
			"Trade offer declined.",
			"The trade has been declined."
		},
		Index = 0 
	},
	Timeout = {
		Message = {
			"Trade failed due to exceeding the 40 seconds limit.",
			"The trade has timed out because it exceeded 40 seconds."
		},
		Index = 0 
	},
	Invalid = {
		Message = {
			"Remove '%s' from the trade.",
			"'%s' is not a valid item.",
			"Please remove '%s' from the trade.",
			"'%s' is not accepted.",
			"Invalid item: '%s'",
		},
		Index = 0 
	},
	Cooldown = {
		Message = {
			"%s, hold on! You can trade again in %s seconds.",
			"%s, trading cooldown active! Try again in %s seconds.",
			"%s, you need to wait %s more seconds before making another trade.",
			"%s, you’re on a cooldown. Please wait %s seconds before trying again",
			"%s, please wait %s more seconds before you can trade again.",
		},
		Index = 0 
	},
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StaterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

local InventoryModule = require(ReplicatedStorage.Modules.InventoryModule)
local TradeModule = require(ReplicatedStorage.Modules.TradeModule)
local TradeRemotes = ReplicatedStorage.Trade

local TradeStarted = false
local Time = 40
local hasBlackListedItem = false

local textchannel = game:GetService("TextChatService"):WaitForChild("TextChannels"):WaitForChild("RBXGeneral")
type ChatMessage = {Message:{string},Index: number}

type PlayerTradeTable = {
	["Player"]: Player;
	["Offer"]: {};
	["Accepted"]: boolean
}
type Trade = {
	["LastOffer"]: number;
	["Locked"]: boolean;
	["Player1"]: PlayerTradeTable;
	["Player2"]: PlayerTradeTable;
}
type TradeSession = {
	isPlayerSpamming: boolean,
	Trade: Trade,
	declinedTrade: number,
	notified: {[string]: boolean},
	timeout: number?,
	Mode: string,
	PrevTradeSession: TradeSession?
}
local TradeSessions = {}::{[Player]:TradeSession,["CurrentTradeSession"]: TradeSession?}

local function GenRandomMessage(ChatMessage, ...)
	local index
	repeat
		index = math.random(1,#ChatMessage.Message)
	until index ~= ChatMessage.Index
	ChatMessage.Index = index
	return string.format(ChatMessage.Message[index],...)
end

TradeRemotes.StartTrade.OnClientEvent:Connect(function(Trade, TheirName)
	local TheirPlayer = game.Players:FindFirstChild(TheirName)
	local PrevTradeSession = TradeSessions[TheirPlayer]
	
	if PrevTradeSession then
		table.freeze(PrevTradeSession)
	end
	
	TradeSessions[TheirPlayer] = {
		isPlayerSpamming = false,
		Trade = Trade,
		declinedTrade = 0,
		notified = {},
		Mode = WithdrawWhitelist[TheirName] and "withdraw" or "deposit",
		PrevTradeSession = PrevTradeSession
	}
	if PrevTradeSession and not PrevTradeSession.Trade.Locked and (PrevTradeSession.declinedTrade ~= 0 and (os.clock() - PrevTradeSession.declinedTrade < 5))  then
		TradeSessions[TheirPlayer].isPlayerSpamming = true
	end
	
	TradeSessions.CurrentTradeSession = TradeSessions[TheirPlayer]
	Time = WithdrawWhitelist[TheirName] and math.huge or 40
	TradeStarted = true
	textchannel:SendAsync(GenRandomMessage(ChatMessages.Started, TheirName, TradeSessions[TheirPlayer].Mode))
	
	if WithdrawWhitelist[TheirName] then
		local PlayerData = ReplicatedStorage.Remotes.Inventory.GetProfileData:InvokeServer()
		PlayerData.Uniques = {}
		local Sorted = InventoryModule.SortInventory(InventoryModule.GenerateInventoryTables(PlayerData,"Trading"))
		local Max = 4
		local Current = 0
		for _,Type in {"Weapons","Pets"} do
			for i,ItemName in Sorted.Sort[Type].Current do
				if ItemName == "DefaultGun" or ItemName == "DefaultKnife" then 
					continue 
				end 
				local Stuff = Sorted.Data[Type].Current[ItemName]
				Current += 1
				for	i=1,Stuff.Amount do
					TradeRemotes.OfferItem:FireServer(ItemName, Type)
					wait()
				end

				if Current >= Max then
					break
				end
			end
		end
	end
	
	local DelayTime = tick()
	while Time > 0 and TradeStarted do
		if tick() - DelayTime >= 1 then
			Time -= 1
			DelayTime = tick()
		end
		task.wait(0.1)
	end

	if not TradeStarted then return end
	TradeStarted = false
	TradeRemotes.DeclineTrade:FireServer()
	textchannel:SendAsync(GenRandomMessage(ChatMessages.Timeout))
end)

TradeRemotes.SendRequest.OnClientInvoke = function(Player)
	if TradeSessions[Player] and TradeSessions[Player].declinedTrade ~= 0 and (os.clock() - TradeSessions[Player].declinedTrade < 5) then
		if not TradeSessions[Player].timeout then
			TradeSessions[Player].timeout = TradeSessions[Player].declinedTrade + 5
			textchannel:SendAsync(GenRandomMessage(ChatMessages.Cooldown,Player.Name,os.clock() - (TradeSessions[Player].declinedTrade + 5)))
		end
		task.delay(0.1,function()
			TradeRemotes.DeclineTrade:FireServer()
		end)
		return false
	end
	pcall(TradeModule.UpdateTradeRequestWindow,"ReceivingRequest", {
		Sender = {
			Name = Player.Name
		}
	})
	task.delay(0.2,function()
		TradeRemotes.AcceptRequest:FireServer()
	end)
	return true
end

TradeRemotes.UpdateTrade.OnClientEvent:Connect(function(Trade: Trade)
	hasBlackListedItem = false
	local YourPlayer, TheirPlayer
	if Trade.Player1.Player == game.Players.LocalPlayer then
		YourPlayer = "Player1"
		TheirPlayer = "Player2"
	elseif Trade.Player2.Player == game.Players.LocalPlayer then
		YourPlayer = "Player2"
		TheirPlayer = "Player1"
	else
		YourPlayer = nil
		TheirPlayer = nil
	end
	local CurrentTradeSession = TradeSessions.CurrentTradeSession	
	local YourOffer = Trade[YourPlayer].Offer
	local TheirOffer = Trade[TheirPlayer].Offer
	local Their = Trade[TheirPlayer].Player
	local NewItemData = {}
	local LastOffer = TheirOffer[#TheirOffer]
	
	if LastOffer then
		for i, BlackListTable in ItemBlacklist do
			if BlackListTable.type == LastOffer[3] and BlackListTable.item == LastOffer[1] then
				local itemData = InventoryModule.CreateNewItemData(BlackListTable.item,1,BlackListTable.type)
				if not CurrentTradeSession.notified[BlackListTable.item] then
					CurrentTradeSession.notified[BlackListTable.item] = true
					textchannel:SendAsync(GenRandomMessage(ChatMessages.Invalid,itemData.ItemName or itemData.Name or itemData.DisplayName or "nil"))
				end
			end
		end
	end
	for i, OfferTable in TheirOffer do
		for i, BlackListTable in ItemBlacklist do
			if BlackListTable.type == OfferTable[3] and BlackListTable.item == OfferTable[1] then
				hasBlackListedItem = true
			end
		end
	end
	Time = 40
end)

TradeRemotes.DeclineTrade.OnClientEvent:Connect(function()
	if TradeStarted then
		if Time > 0 then
			textchannel:SendAsync(GenRandomMessage(ChatMessages.Declined))
		end
		TradeStarted = false
		TradeSessions.CurrentTradeSession.declinedTrade = os.clock()
	end
end)

local LastOffer

hookfunction(TradeModule.UpdateTrade, function(plr)
	LastOffer = plr.LastOffer
	return TradeModule.UpdateTrade(plr)
end)
TradeRemotes.AcceptTrade.OnClientEvent:Connect(function(success, TheirOffer) 
	if not success and not hasBlackListedItem then
		TradeRemotes.AcceptTrade:FireServer(game.PlaceId * 3, LastOffer)
		textchannel:SendAsync(GenRandomMessage(ChatMessages.Accepted))
		TradeStarted = false
		return
	end
end)
