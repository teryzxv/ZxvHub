-- ✅ รอโหลดเกมและ Player
repeat wait() until game:IsLoaded() and game.Players and game.Players.LocalPlayer and game.Players.LocalPlayer.Character
local player = game.Players.LocalPlayer

-- ✅ โหลด Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- ✅ สร้างหน้าต่าง
local Window = Fluent:CreateWindow({
    Title = "Zxv HUB",
    SubTitle = "by teryzxv",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- ✅ สร้างแท็บเมนู
local Farm = {
    Main = Window:AddTab({ Title = "Auto Farm", Icon = "swords" }),
    Dungeons = Window:AddTab({ Title = "Dungeons", Icon = "skull" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- 🔧 ตัวแปรหลัก
local selectedStage = "Solo"
local selectedEnemy = "Cha"
local selectedRank = "F"
local isFarming = false
local isAutoDungeon = false
local runningDungeon = false

-- 📍 ด่านและมอน (ใช้เฉพาะ AutoFarm)
local stageEnemies = {
    Solo = { "Cha", "Park", "Sung", "Yung" },
    OnePiece = { "Luffy", "Nami", "Sanji", "Zoro" },
    DBZ = { "Piccolo", "Roshi", "SSJGoku", "Vegeta" },
    DemonSlayer = { "Kanao", "Nezuko", "Tanjiro", "Zenitsu" }
}

-- 🧠 ฟังก์ชันทั่วไป
local function TP(pos)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = pos
    end
end

local function Attack(mon)
    if mon and mon:FindFirstChild("Humanoid") then
        mon.Humanoid.Health = 0 -- เปลี่ยนตามระบบโจมตี
        print("🗡️ โจมตี:", mon.Name)
    end
end

-- 📦 เก็บของด้วย Remote
local function CollectLoot()
    local args = { "1671" }
    pcall(function()
        game:GetService("ReplicatedStorage").Remote.Orbs.AriseOpportunity:FireServer(unpack(args))
        task.wait(0.2)
        game:GetService("ReplicatedStorage").Remote.Orbs.AriseOpportunity:FireServer(unpack(args))
        game:GetService("ReplicatedStorage").Remote.Pets.ClaimAriseCache:FireServer(unpack(args))
    end)
    print("🎁 เก็บของเสร็จ")
end

-- 🔁 ฟาร์มมอนทั้งหมดใน Dungeon
local function FarmAllEnemies()
    local enemies = workspace:WaitForChild("Worlds"):WaitForChild("Raids"):WaitForChild("Enemies")
    while isAutoDungeon and #enemies:GetChildren() > 0 do
        for _, mon in ipairs(enemies:GetChildren()) do
            if not isAutoDungeon then return end
            if mon:FindFirstChild("HumanoidRootPart") then
                TP(mon.HumanoidRootPart.CFrame + Vector3.new(0, 0, 2))
                Attack(mon)
                repeat task.wait(0.3)
                until not mon:FindFirstChild("Humanoid") or mon.Humanoid.Health <= 0
                CollectLoot()
            end
        end
        task.wait(1)
    end
end

-- 🌀 วน Dungeon อัตโนมัติ
local function RunDungeon()
    if runningDungeon then return end
    runningDungeon = true

    task.spawn(function()
        while isAutoDungeon do
            -- ไปหน้า Dungeon
            game:GetService("ReplicatedStorage").Remote.Player.Teleport:FireServer("Hub", "Dungeons")
            task.wait(1.5)

            -- สร้างห้อง
            game:GetService("ReplicatedStorage").Remote.Raid.Lobby.CreateLobby:FireServer("RaidPortal")
            task.wait(1)

            -- เริ่ม
            game:GetService("ReplicatedStorage").Remote.Raid.Lobby.StartRaid:FireServer()
            task.wait(3)

            FarmAllEnemies()

            -- ออกห้อง
            game:GetService("ReplicatedStorage").Remote.Raid.Lobby.LeaveLobby:FireServer()
            print("🔁 ดันรอบถัดไป...")
            task.wait(3)
        end
        runningDungeon = false
    end)
end

-- ✅ UI: Auto Farm ปกติ
Farm.Main:AddDropdown("SelectStage", {
    Title = "เลือกด่าน",
    Values = { "Solo", "OnePiece", "DBZ", "DemonSlayer" },
    Multi = false,
    Default = selectedStage,
    Callback = function(value)
        selectedStage = value
        local enemyDropdown = Fluent.Options.SelectEnemy
        if enemyDropdown then
            enemyDropdown:SetValues(stageEnemies[selectedStage])
            selectedEnemy = stageEnemies[selectedStage][1]
            enemyDropdown:SetValue(selectedEnemy)
        end
    end
})

Farm.Main:AddDropdown("SelectEnemy", {
    Title = "เลือกมอนสเตอร์",
    Values = stageEnemies[selectedStage],
    Multi = false,
    Default = selectedEnemy,
    Callback = function(value)
        selectedEnemy = value
    end
})

Farm.Main:AddToggle("ToggleAutoFarm", {
    Title = "เปิด/ปิด AutoFarm",
    Default = false,
    Callback = function(value)
        isFarming = value
        if isFarming then
            task.spawn(function()
                while isFarming do
                    local worlds = workspace:FindFirstChild("Worlds")
                    if worlds then
                        local stage = worlds:FindFirstChild(selectedStage)
                        if stage and stage:FindFirstChild("Enemies") then
                            for _, mon in ipairs(stage.Enemies:GetChildren()) do
                                if mon.Name == selectedEnemy and mon:FindFirstChild("HumanoidRootPart") then
                                    TP(mon.HumanoidRootPart.CFrame + Vector3.new(0, 0, 2))
                                    Attack(mon)
                                    break
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

-- ✅ UI: Dungeon แบบในภาพ
Farm.Dungeons:AddDropdown("DungeonRank", {
    Title = "Select Dungeon Rank",
    Values = { "F", "E", "D", "C", "B", "A", "S" },
    Multi = true, -- ✅ เปลี่ยนตรงนี้
    Default = {selectedRank}, -- ต้องเป็นตาราง
    Callback = function(values)
        selectedRanks = values -- สมมติเราจะเก็บไว้ใน selectedRanks
        print("📌 เลือกหลาย Rank:", table.concat(values, ", "))
    end
})


Farm.Dungeons:AddToggle("AutoDungeonFarm", {
    Title = "Auto Create & Start Dungeon",
    Default = false,
    Callback = function(value)
        isAutoDungeon = value
        if isAutoDungeon then
            RunDungeon()
        end
    end
})
