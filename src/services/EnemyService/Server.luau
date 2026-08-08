--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Networker = require(ReplicatedStorage.Packages.Networker)
local BigNum = require(ReplicatedStorage.Shared.BigNum)
local EnemyServiceUtils = require(ReplicatedStorage.Shared.Services.EnemyService.EnemyServiceUtils)
local ItemServiceUtils = require(ReplicatedStorage.Shared.Services.ItemService.ItemServiceUtils)
local RealmServiceUtils = require(ReplicatedStorage.Shared.Services.RealmService.RealmServiceUtils)
local WeaponServiceUtils = require(ReplicatedStorage.Shared.Services.WeaponService.WeaponServiceUtils)
local ZoneServiceUtils = require(ReplicatedStorage.Shared.Services.ZoneService.ZoneServiceUtils)
local Data = require(ReplicatedStorage.Shared.Data).server
local EnemiesFolder = workspace:WaitForChild("Enemies") :: Folder

type State = {
	isTouching: { [Player]: { [string]: { [string]: boolean } } },
	attackThreads: { [Player]: { [string]: { [string]: thread } } },
}

export type EnemyServiceServer = typeof(setmetatable({} :: State, { __index = {} })) & {
	init: (self: EnemyServiceServer) -> (),
	start: (self: EnemyServiceServer) -> (),
	OnPlayerAdded: (self: EnemyServiceServer, player: Player) -> (),
	OnPlayerRemoving: (self: EnemyServiceServer, player: Player) -> (),

	SetEnemyState: (self: EnemyServiceServer, player: Player, enemyMode: Model, isAlive: boolean) -> (),
	AttackEnemy: (self: EnemyServiceServer, player: Player, enemyIdModel: { string }) -> (),
	UpdateEnemyGui: (self: EnemyServiceServer, player: Player, enemyIdModel: { string }) -> (),
	SetupEnemyListener: (self: EnemyServiceServer) -> (),
	-- ... Add More Functions Here

	-- Networker
	networker: any,
}

local EnemyServiceServer = {} :: EnemyServiceServer

-- Setup
function EnemyServiceServer.init(self: EnemyServiceServer)
	self.isTouching = {}
	self.attackThreads = {}
	-- Networker --> Replacement for RemoteEvents/RemoteFunctions
	self.networker = Networker.server.new(
		"EnemyService",
		self,
		{
			-- Add public network
		} :: any
	)

	Players.PlayerAdded:Connect(function(player: Player)
		self:OnPlayerAdded(player)
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		self:OnPlayerRemoving(player)
	end)
end

function EnemyServiceServer.OnPlayerAdded(self: EnemyServiceServer, player: Player)
	self.isTouching[player] = {}
	self.attackThreads[player] = {}
end

function EnemyServiceServer.OnPlayerRemoving(self: EnemyServiceServer, player: Player)
	if self.attackThreads and self.attackThreads[player] then
		for _, models in self.attackThreads[player] do
			for _, threadHandle in models do
				if threadHandle and coroutine.status(threadHandle) ~= "dead" then
					task.cancel(threadHandle)
				end
			end
		end
	end
	self.isTouching[player] = nil
	self.attackThreads[player] = nil
end

function EnemyServiceServer.start(self: EnemyServiceServer)
	self:SetupEnemyListener()
end

function EnemyServiceServer.SetEnemyState(self, player, enemyModel, isAlive)
	local billboardGui = enemyModel:WaitForChild("BillboardGui") :: BillboardGui
	if billboardGui then
		billboardGui.Enabled = isAlive
	end

	local visualsFolder = enemyModel:FindFirstChild("Visuals")
	if visualsFolder then
		for _, part in visualsFolder:GetDescendants() do
			if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("Texture") then
				if isAlive then
					local defaultTransparency = part:GetAttribute("DefaultTransparency") :: number
					part.Transparency = defaultTransparency
				else
					part.Transparency = 1
				end
			end
		end
	end
end

function EnemyServiceServer.AttackEnemy(self, player, enemyIdModel)
	local enemyId, enemyModelName = enemyIdModel[1], enemyIdModel[2]
	local EnemyFolder = EnemiesFolder:FindFirstChild(enemyId) :: Folder
	if not EnemyFolder then
		return
	end
	local EnemyModel = EnemyFolder:WaitForChild(enemyModelName, 3) :: Model
	if not EnemyModel then
		return
	end
	local enemyData = EnemyServiceUtils.Data[EnemyFolder.Name]
	if not enemyData then
		return
	end
	local isTouching = self.isTouching[player]
		and self.isTouching[player][enemyId]
		and self.isTouching[player][enemyId][enemyModelName]
	if not isTouching then
		return
	end

	local playerRealm = Data[player].realm()
	if not playerRealm or playerRealm < enemyData.realm then
		warn("[EnemyServiceServer][AttackEnemy] Player Realm is Not High Enough.")
		return
	end

	local playerWeapon = Data[player].inventory.weaponEquipped()
	if not playerWeapon then
		return
	end
	local weaponData = WeaponServiceUtils.Data[playerWeapon]
	if not weaponData then
		return
	end
	local dmg = weaponData.atk
	local playerItem = Data[player].inventory.itemEquipped()
	local itemData = ItemServiceUtils.Data[playerItem]
	if itemData then
		dmg = dmg * (itemData.dmgMultiplier or 1)
	end

	local currentHealth = EnemyModel:GetAttribute("health") :: number? or enemyData.maxHealth
	if currentHealth <= 0 then
		return
	end

	local newHealth = math.max(0, currentHealth - dmg)
	EnemyModel:SetAttribute("health", newHealth)
	self:UpdateEnemyGui(player, enemyIdModel)

	if newHealth <= 0 then
		Data[player].totalEnemyKilled[enemyId](function(currentNumber: number)
			local updated = (currentNumber or 0) + 1
			return updated
		end)

		self:SetEnemyState(player, EnemyModel, false)
		local drops = EnemyServiceUtils.GiveDrops(enemyId)
		Data[player].spiritualStones(function(currentStone)
			local updated = BigNum.add(currentStone, drops.spiritualStone)
			return updated
		end)

		-- respawn
		task.delay(enemyData.respawnTime, function()
			EnemyModel:SetAttribute("health", enemyData.maxHealth)
			self:UpdateEnemyGui(player, enemyIdModel)

			self:SetEnemyState(player, EnemyModel, true)
		end)

		return
	end
end

function EnemyServiceServer.UpdateEnemyGui(self, player, enemyIdModel)
	local enemyId, enemyModelName = enemyIdModel[1], enemyIdModel[2]
	local EnemyFolder = EnemiesFolder:FindFirstChild(enemyId) :: Folder
	if not EnemyFolder then
		return
	end
	local EnemyModel = EnemyFolder:WaitForChild(enemyModelName, 3)
	if not EnemyModel then
		return
	end
	local enemyData = EnemyServiceUtils.Data[EnemyFolder.Name]
	if not enemyData then
		return
	end

	local billboardGui = EnemyModel:WaitForChild("BillboardGui") :: BillboardGui
	if not billboardGui then
		return
	end

	-- HEALTH BAR & TEXT
	local HealthFrame = billboardGui:WaitForChild("Health") :: Frame
	if not HealthFrame then
		return
	end
	local HealthLabel = HealthFrame:WaitForChild("HealthLabel") :: TextLabel
	if not HealthLabel then
		return
	end
	local currentHealth = EnemyModel:GetAttribute("health") :: number? or enemyData.maxHealth
	HealthLabel.Text = string.format("%.1f", currentHealth) .. "/" .. enemyData.maxHealth

	local HealthBar = HealthFrame:WaitForChild("currentHealth") :: Frame
	if not HealthBar then
		return
	end
	HealthBar.Size = UDim2.fromScale(currentHealth / enemyData.maxHealth, 1)
end

function EnemyServiceServer.SetupEnemyListener(self)
	for _, EnemyFolder: Folder in EnemiesFolder:GetChildren() do
		if not EnemyFolder:IsA("Folder") then
			continue
		end

		local enemyData = EnemyServiceUtils.Data[EnemyFolder.Name]
		if not enemyData then
			continue
		end

		for _, EnemyModel in EnemyFolder:GetChildren() do
			local billboardGui = EnemyModel:WaitForChild("BillboardGui") :: BillboardGui
			if not billboardGui then
				continue
			end

			local collisionPart = EnemyModel:WaitForChild("Collision") :: Part
			if not collisionPart then
				continue
			end

			-- HEALTH TEXT
			local HealthFrame = billboardGui:WaitForChild("Health") :: Frame
			if not HealthFrame then
				continue
			end
			local HealthLabel = HealthFrame:WaitForChild("HealthLabel") :: TextLabel
			if not HealthLabel then
				continue
			end
			local Health = EnemyModel:GetAttribute("health") :: number? or enemyData.maxHealth
			HealthLabel.Text = Health .. "/" .. enemyData.maxHealth

			-- NAME & REALM LABEL
			local NameLabel = billboardGui:WaitForChild("Data"):WaitForChild("Name") :: TextLabel
			if not NameLabel then
				continue
			end
			NameLabel.Text = enemyData.name .. " - " .. RealmServiceUtils.RealmName(enemyData.realm)

			local visualsFolder = EnemyModel:FindFirstChild("Visuals")
			if visualsFolder then
				for _, part in visualsFolder:GetDescendants() do
					if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("Texture") then
						part:SetAttribute("DefaultTransparency", part.Transparency)
					end
				end
			end

			ZoneServiceUtils.CalculateDist(collisionPart, function(player, isInside)
				if not self.isTouching[player] then
					return
				end

				self.isTouching[player][enemyData.id] = self.isTouching[player][enemyData.id] or {}
				self.attackThreads[player][enemyData.id] = self.attackThreads[player][enemyData.id] or {}

				local wasTouching = self.isTouching[player][enemyData.id][EnemyModel.Name] or false
				if wasTouching == isInside then
					return
				end

				self.isTouching[player][enemyData.id][EnemyModel.Name] = isInside

				local enemyIdModel = { enemyData.id, EnemyModel.Name }

				local existingThread = self.attackThreads[player][enemyData.id][EnemyModel.Name]
				if existingThread then
					task.cancel(existingThread)
					self.attackThreads[player][enemyData.id][EnemyModel.Name] = nil
				end

				if isInside and wasTouching ~= isInside then
					self.attackThreads[player][enemyData.id][EnemyModel.Name] = task.spawn(function()
						while
							self.isTouching[player]
							and self.isTouching[player][enemyData.id]
							and self.isTouching[player][enemyData.id][EnemyModel.Name] == true
						do
							local playerWeapon = Data[player].inventory.weaponEquipped()
							local weaponData = WeaponServiceUtils.Data[playerWeapon]

							if weaponData then
								self:AttackEnemy(player, enemyIdModel)
							end

							local waitTime = (weaponData and weaponData.atkSpd) or 1
							task.wait(waitTime)
						end

						if self.attackThreads[player] and self.attackThreads[player][enemyData.id] then
							self.attackThreads[player][enemyData.id][EnemyModel.Name] = nil
						end
					end)
				end
			end)
		end
	end
end

return EnemyServiceServer
