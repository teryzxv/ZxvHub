local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Zxv HUB",
    SubTitle = "by teryzxv",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Farm = {
    Main = Window:AddTab({ Title = "Auto Farm", Icon = "swords" }),
    Dungeons = Window:AddTab({ Title = "Dungeons", Icon = "skull" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- 🗺️ รายชื่อด่านและมอนในแต่ละด่าน
local stageEnemies = {
    Solo = { "Cha", "Park", "Sung", "Yung" },
    OnePiece = { "Luffy", "Nami", "Sanji", "Zoro" },
    DBZ = { "Piccolo", "Roshi", "SSJGoku", "Vegeta" },
    DemonSlayer = { "Kanao", "Nezuko", "Tanjiro", "Zenitsu" }
}

local selectedStage = "Solo"
local selectedEnemy = stageEnemies[selectedStage][1]
local isFarming = false

-- 🔽 Dropdown เลือกด่าน
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
        print("🌍 เปลี่ยนด่านเป็น:", selectedStage)
    end
})

-- 🔽 Dropdown เลือกมอนสเตอร์ (จะเปลี่ยนตามด่าน)
Farm.Main:AddDropdown("SelectEnemy", {
    Title = "เลือกมอนสเตอร์",
    Values = stageEnemies[selectedStage],
    Multi = false,
    Default = selectedEnemy,
    Callback = function(value)
        selectedEnemy = value
        print("🎯 เป้าหมายเปลี่ยนเป็น:", selectedEnemy)
    end
})

-- ⚔️ ฟังก์ชันโจมตี
local function Attack(mon)
    print("🗡️ โจมตีมอน:", mon.Name)
    -- ที่นี่ใส่คำสั่งโจมตีจริง เช่น firetouchinterest หรือ remote
end

-- 🚀 ฟังก์ชันเทเลพอร์ต
local function TP(pos)
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = pos
    end
end

-- 🔁 ฟังก์ชันฟาร์ม
local function StartFarm()
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

-- ✅ Toggle เริ่ม/หยุด AutoFarm
Farm.Main:AddToggle("ToggleAutoFarm", {
    Title = "เปิด/ปิด AutoFarm",
    Default = false,
    Callback = function(value)
        isFarming = value
        if isFarming then
            print("✅ เริ่มฟาร์ม:", selectedEnemy, "ที่ด่าน", selectedStage)
            StartFarm()
        else
            print("⛔ หยุดฟาร์ม")
        end
    end
})
