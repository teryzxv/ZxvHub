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

local enemies = { "Kanao", "Nezuko", "Tanjiro", "Zenitsu" }
local selectedEnemy = enemies[1]
local isFarming = false

-- 🔽 Dropdown เลือกมอนสเตอร์
Farm.Main:AddDropdown("SelectEnemy", {
    Title = "เลือกมอนสเตอร์",
    Values = enemies,
    Multi = false,
    Default = enemies[1],
    Callback = function(value)
        selectedEnemy = value
        print("🎯 เป้าหมายเปลี่ยนเป็น:", selectedEnemy)
    end
})

-- ⚔️ ฟังก์ชันโจมตี
local function Attack(mon)
    print("🗡️ โจมตีมอน:", mon.Name)
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
            local enemyFolder = workspace:FindFirstChild("Worlds")
            if enemyFolder then
                for _, world in ipairs(enemyFolder:GetChildren()) do
                    if world:FindFirstChild("Enemies") then
                        for _, mon in ipairs(world.Enemies:GetChildren()) do
                            if mon.Name == selectedEnemy and mon:FindFirstChild("HumanoidRootPart") then
                                TP(mon.HumanoidRootPart.CFrame + Vector3.new(0, 0, 2))
                                Attack(mon)
                                break
                            end
                        end
                        break -- ออกจากลูป world ทันทีเมื่อเจอ enemies
                    end
                end
            end
            task.wait(1)
        end
    end)
end

-- ✅ Toggle ฟาร์ม
Farm.Main:AddToggle("ToggleAutoFarm", {
    Title = "เปิด/ปิด AutoFarm",
    Default = false,
    Callback = function(value)
        isFarming = value
        if isFarming then
            print("✅ เริ่มฟาร์ม:", selectedEnemy)
            StartFarm()
        else
            print("⛔ หยุดฟาร์ม")
        end
    end
})

-- 🔍 หา enemies จาก world ปัจจุบัน
local function GetEnemiesFromCurrentWorld()
    local foundEnemies = {}
    local worlds = workspace:FindFirstChild("Worlds")
    if not worlds then return foundEnemies end

    for _, world in ipairs(worlds:GetChildren()) do
        if world:FindFirstChild("Enemies") then
            for _, enemy in ipairs(world.Enemies:GetChildren()) do
                if enemy:IsA("Model") then
                    table.insert(foundEnemies, enemy.Name)
                end
            end
            break
        end
    end
    return foundEnemies
end

-- 🔁 ฟังก์ชัน Refresh รายชื่อมอนสเตอร์
local function RefreshEnemies()
    local newEnemies = GetEnemiesFromCurrentWorld()
    if #newEnemies > 0 then
        enemies = newEnemies
        selectedEnemy = enemies[1]
        local dropdown = Fluent:GetDropdown("SelectEnemy")
        if dropdown then
            dropdown:SetValues(enemies)
            dropdown:SetValue(selectedEnemy)
        else
            warn("❌ ไม่พบ Dropdown: SelectEnemy")
        end
        print("🔄 รีเฟรชมอนเสร็จแล้ว:", table.concat(enemies, ", "))
    else
        print("⚠️ ไม่พบมอนใน World ปัจจุบัน")
    end
end

-- 🔘 ปุ่ม Refresh
Farm.Main:AddButton("RefreshEnemies", {
    Title = "🔄 รีเฟรชมอนสเตอร์",
    Description = "โหลดมอนจากด่านปัจจุบันใหม่",
    Callback = function()
        RefreshEnemies()
    end
})
