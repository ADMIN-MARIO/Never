local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local clientId = RbxAnalyticsService:GetClientId()
local Playerlist = {"613712AD-33E4-465F-AEC8-75444B547E9C"}

if not table.find(PlayerData, clientId) then
	setclipboard(clientId)
	game.Players.LocalPlayer:Kick("มึงใครมาใช้ code กู")
  return 
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Taka.Ace",
    SubTitle = "by Taka",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.PageUp
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
}

_G.Head100 = false
_G.HeadChance = 100

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if _G.Head100 and not checkcaller() and method == "FireServer" and self.Name == "Damage" then
        if math.random(1, 100) <= _G.HeadChance then
            args[2] = "Head"
        end
        return oldNamecall(self, table.unpack(args))
    end

    return oldNamecall(self, ...)
end))

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local HITBOX_SIZE = Vector3.new(20, 20, 20)
local HITBOX_TRANSPARENCY = 0.5
local MAX_DISTANCE = 100

_G.Enabled = false
_G.A = false

local lastUpdate = 0
local UPDATE_INTERVAL = 0.1

local function applyHitbox(char, myPos)
    local human = char:FindFirstChildOfClass("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")

    if not (human and rootPart and human.Health > 0) then return end
    
    if (rootPart.Position - myPos).Magnitude <= MAX_DISTANCE then
        if not rootPart:FindFirstChild("OriginalSize") then
            local origSize = Instance.new("Vector3Value")
            origSize.Name = "OriginalSize"
            origSize.Value = rootPart.Size
            origSize.Parent = rootPart
        end

        rootPart.Size = HITBOX_SIZE
        rootPart.Transparency = HITBOX_TRANSPARENCY
        rootPart.CanCollide = false
    else
        if rootPart:FindFirstChild("OriginalSize") then
            rootPart.Size = rootPart.OriginalSize.Value
            rootPart.OriginalSize:Destroy()
        end
        rootPart.Transparency = 1
        rootPart.CanCollide = true
    end
end

local function resetAllHitboxes()
    local function cleanCharacter(char)
        if not char then return end
        
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if rootPart then
            if rootPart:FindFirstChild("OriginalSize") then
                rootPart.Size = rootPart.OriginalSize.Value
                rootPart.OriginalSize:Destroy()
            end
            rootPart.Transparency = 1
            rootPart.CanCollide = true
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            cleanCharacter(player.Character)
        end
    end

    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj ~= localPlayer.Character and not Players:GetPlayerFromCharacter(obj) then
            cleanCharacter(obj)
        end
    end
end

local function expandEnemyHitboxes()
    if not _G.Enabled then return end

    local myChar = localPlayer.Character
    if not myChar then return end
    local root = myChar:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local myPos = root.Position

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            applyHitbox(player.Character, myPos)
        end
    end
    
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj ~= myChar and not Players:GetPlayerFromCharacter(obj) then
            applyHitbox(obj, myPos)
        end
    end
end

RunService.Heartbeat:Connect(function()
    local currentTime = os.clock()
    if currentTime - lastUpdate >= UPDATE_INTERVAL then
        lastUpdate = currentTime
        pcall(expandEnemyHitboxes)
    end
end)

local ToggleHead100 = Tabs.Main:AddToggle("ToggleHead100", { Title = "Headshot Override", Default = false })

local HeadChanceSlider = Tabs.Main:AddSlider("HeadChanceSlider", {
    Title = "Headshot Rate (%)",
    Description = "ปรับโอกาสติด Headshot (0% = โจมตีปกติ, 100% = ติดหัวทุกครั้ง)",
    Default = 100,
    Min = 0,
    Max = 100,
    Rounding = 0
})

local ToggleHitBox = Tabs.Main:AddToggle("ToggleHitBox", { Title = "Toggle HitBox", Default = false })
local ToggleKillaura = Tabs.Main:AddToggle("ToggleKillaura", { Title = "Toggle Killaura", Default = false })

local HeadSizeSlider = Tabs.Main:AddSlider("HeadSizeSlider", {
    Title = "Adjust Hitbox Size",
    Description = "ปรับขนาด Hitbox (HumanoidRootPart) ของศัตรู",
    Default = 20,
    Min = 2,
    Max = 50,
    Rounding = 0
})

local HeadTransSlider = Tabs.Main:AddSlider("HeadTransSlider", {
    Title = "Hitbox Transparency",
    Description = "ความโปร่งใสของ Hitbox (0 = เห็นชัด, 1 = ล่องหน)",
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2
})

ToggleHead100:OnChanged(function(Value)
    _G.Head100 = Value
end)

HeadChanceSlider:OnChanged(function(Value)
    _G.HeadChance = Value
end)

HeadSizeSlider:OnChanged(function(Value)
    HITBOX_SIZE = Vector3.new(Value, Value, Value)
end)

HeadTransSlider:OnChanged(function(Value)
    HITBOX_TRANSPARENCY = Value
end)

ToggleHitBox:OnChanged(function(Value)
    _G.Enabled = Value
    if not Value then
        resetAllHitboxes()
    end
end)

ToggleKillaura:OnChanged(function(Value)
    _G.A = Value
    
    if Value then
        task.spawn(function()
            while _G.A do
                task.wait(0.2)
                pcall(function()
                    local myChar = localPlayer.Character
                    if myChar and myChar:FindFirstChild("BaseballBat") then
                        local damageRemote = myChar.BaseballBat.LocalScript.Damage
                        
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= localPlayer then
                                local enemyChar = workspace:FindFirstChild(player.Name)
                                if enemyChar and enemyChar:FindFirstChild("HumanoidRootPart") then
                                    local args = {
                                        [1] = enemyChar,
                                        [2] = "Head"
                                    }
                                    damageRemote:FireServer(unpack(args))
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end
end)
