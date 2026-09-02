local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EnemyServiceUtils = require(ReplicatedStorage.Shared.Services.EnemyService.EnemyServiceUtils)
local RealmServiceUtils = require(ReplicatedStorage.Shared.Services.RealmService.RealmServiceUtils)

local Data = require(ReplicatedStorage.Shared.Data).client
local EnemiesFolder = workspace:WaitForChild("Enemies") :: Folder
local Networker = require(ReplicatedStorage.Packages.Networker).client

local networker = nil
local EnemyServiceClient = {}

function EnemyServiceClient.init(self)
	networker = Networker.new("EnemyService", EnemyServiceClient)

	self:SetupEnemyListeners()

	Data.realm.Changed(function()
		self:RefreshAllEnemyLabels()
	end)
end

function EnemyServiceClient.UpdateEnemyGui(self, enemyId, enemyModel, currentHealth, maxHealth)
	local enemyData = EnemyServiceUtils.Data[enemyId]
	if not enemyData then
		return
	end

	local billboardGui = enemyModel:FindFirstChild("BillboardGui", true) :: BillboardGui?
	if not billboardGui then
		return
	end

	local healthFrame = billboardGui:FindFirstChild("Health") :: Frame?
	if healthFrame then
		local healthLabel = healthFrame:FindFirstChild("HealthLabel") :: TextLabel?
		local healthBar = healthFrame:FindFirstChild("currentHealth") :: Frame?

		if healthLabel then
			healthLabel.Text = string.format("%.1f/%d", currentHealth, maxHealth)
		end
		if healthBar then
			healthBar.Size = UDim2.fromScale(currentHealth / maxHealth, 1)
		end
	end

	-- Only reason why i migrate ui to client
	local dataFrame = billboardGui:FindFirstChild("Data") :: Frame?
	if dataFrame then
		local nameLabel = dataFrame:FindFirstChild("Name") :: TextLabel?
		if nameLabel then
			nameLabel.Text = enemyData.name .. " - " .. RealmServiceUtils.RealmName(enemyData.realm)

			local playerRealm = Data.realm() or 1
			if playerRealm < enemyData.realm then
				nameLabel.TextColor3 = Color3.fromRGB(255, 107, 109)
			else
				nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
		end
	end
end

function EnemyServiceClient.OnEnemyAdded(self, enemyFolder: Folder, enemyModel: Model)
	local enemyData = EnemyServiceUtils.Data[enemyFolder.Name]
	if not enemyData then
		return
	end

	local currentHealth = enemyModel:GetAttribute("health") :: number? or enemyData.maxHealth
	self:UpdateEnemyGui(enemyFolder.Name, enemyModel, currentHealth, enemyData.maxHealth)

	enemyModel:GetAttributeChangedSignal("health"):Connect(function()
		local updatedHealth = enemyModel:GetAttribute("health") :: number? or enemyData.maxHealth
		self:UpdateEnemyGui(enemyFolder.Name, enemyModel, updatedHealth, enemyData.maxHealth)
	end)
end

function EnemyServiceClient.SetupEnemyListeners(self)
	for _, folder in EnemiesFolder:GetChildren() do
		if folder:IsA("Folder") then
			for _, model in folder:GetChildren() do
				if model:IsA("Model") then
					self:OnEnemyAdded(folder, model)
				end
			end
			folder.ChildAdded:Connect(function(child)
				if child:IsA("Model") then
					self:OnEnemyAdded(folder, child)
				end
			end)
		end
	end
end

function EnemyServiceClient.RefreshAllEnemyLabels(self)
	for _, folder in EnemiesFolder:GetChildren() do
		if folder:IsA("Folder") then
			for _, model in folder:GetChildren() do
				if model:IsA("Model") then
					local enemyData = EnemyServiceUtils.Data[folder.name]
					if enemyData then
						local currentHealth = model:GetAttribute("health") :: number? or enemyData.maxHealth
						self:UpdateEnemyGui(folder.name, model, currentHealth, enemyData.maxHealth)
					end
				end
			end
		end
	end
end

return EnemyServiceClient
