local VIM = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- ====== SETTING ======
local SKILLS = {
    { key = Enum.KeyCode.Q, cd = 0.25, last = 0 },
    { key = Enum.KeyCode.E, cd = 0.25, last = 0 },
    { key = Enum.KeyCode.R, cd = 0.25, last = 0 },
    { key = Enum.KeyCode.G, cd = 0.25, last = 0 },
}
local SWITCH_KEY, SWITCH_EVERY, lastSwitch = Enum.KeyCode.C, 6, 0
local OFFSET = CFrame.new(0, 0, 0)    -- tepat di posisi monster (0,0,0)
local SCAN_EVERY = 0.25               -- jeda cari monster (detik)
-- =====================

getgenv().AutoFarm = true

local function press(key)
    VIM:SendKeyEvent(true, key, false, game)
    task.wait(0.03)
    VIM:SendKeyEvent(false, key, false, game)
end

-- cari monster hidup terdekat (punya Humanoid, bukan pemain)
local function getTarget()
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local best, bestDist
    for _, h in ipairs(workspace:GetDescendants()) do
        if h:IsA("Humanoid") and h.Health > 0 then
            local model = h.Parent
            if model and model ~= char and not Players:GetPlayerFromCharacter(model) then
                local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
                if root then
                    local d = (root.Position - hrp.Position).Magnitude
                    if not bestDist or d < bestDist then
                        best, bestDist = root, d
                    end
                end
            end
        end
    end
    return best
end

-- ====== GUI ======
local parent = (gethui and gethui()) or game:GetService("CoreGui")
local old = parent:FindFirstChild("AutoSkillGui"); if old then old:Destroy() end
local gui = Instance.new("ScreenGui"); gui.Name = "AutoSkillGui"; gui.ResetOnSpawn = false; gui.Parent = parent

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 130, 0, 66)
frame.Position = UDim2.new(0, 10, 0.45, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -56, 0, 26)
title.BackgroundTransparency = 1
title.Text = " AutoSkill"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton", frame)
minBtn.Size, minBtn.Position = UDim2.new(0, 26, 0, 26), UDim2.new(1, -52, 0, 0)
minBtn.Text, minBtn.TextSize = "-", 18
minBtn.BackgroundColor3, minBtn.TextColor3 = Color3.fromRGB(70, 70, 70), Color3.new(1, 1, 1)
minBtn.BorderSizePixel = 0

local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size, closeBtn.Position = UDim2.new(0, 26, 0, 26), UDim2.new(1, -26, 0, 0)
closeBtn.Text, closeBtn.TextSize = "X", 14
closeBtn.BackgroundColor3, closeBtn.TextColor3 = Color3.fromRGB(170, 40, 40), Color3.new(1, 1, 1)
closeBtn.BorderSizePixel = 0

local btn = Instance.new("TextButton", frame)
btn.Size, btn.Position = UDim2.new(1, -12, 0, 30), UDim2.new(0, 6, 0, 31)
btn.Text, btn.TextSize = "AUTO: ON", 14
btn.BackgroundColor3, btn.TextColor3 = Color3.fromRGB(40, 140, 60), Color3.new(1, 1, 1)
btn.BorderSizePixel = 0

local function refreshBtn(status)
    if getgenv().AutoFarm then
        btn.Text = status or "AUTO: ON"
        btn.BackgroundColor3 = Color3.fromRGB(40, 140, 60)
    else
        btn.Text = "AUTO: OFF"
        btn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
    end
end

btn.MouseButton1Click:Connect(function()
    getgenv().AutoFarm = not getgenv().AutoFarm
    refreshBtn()
end)

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    btn.Visible = not minimized
    frame.Size = minimized and UDim2.new(0, 130, 0, 26) or UDim2.new(0, 130, 0, 66)
    minBtn.Text = minimized and "+" or "-"
end)

closeBtn.MouseButton1Click:Connect(function()
    getgenv().AutoFarm = false
    gui:Destroy()
end)

-- ====== LOOP UTAMA ======
local target, lastScan = nil, 0

task.spawn(function()
    while gui.Parent do
        if getgenv().AutoFarm then
            -- cari target baru kalau belum ada / sudah mati / sudah waktunya scan
            local valid = target and target.Parent
                and target.Parent:FindFirstChildOfClass("Humanoid")
                and target.Parent:FindFirstChildOfClass("Humanoid").Health > 0
            if not valid or os.clock() - lastScan >= SCAN_EVERY then
                lastScan = os.clock()
                if not valid then target = nil end
                local t = getTarget()
                if t then target = t end
            end

            local char = lp.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if target and hrp then
                -- ada monster: teleport + skill
                refreshBtn("FARMING")
                pcall(function()
                    hrp.CFrame = target.CFrame * OFFSET
                    hrp.AssemblyLinearVelocity = Vector3.zero
                end)
                for _, s in ipairs(SKILLS) do
                    if not getgenv().AutoFarm then break end
                    if os.clock() - s.last >= s.cd then
                        pcall(press, s.key); s.last = os.clock(); task.wait(0.03)
                    end
                end
                if os.clock() - lastSwitch >= SWITCH_EVERY then
                    pcall(press, SWITCH_KEY); lastSwitch = os.clock()
                end
            else
                -- tidak ada monster: berhenti, menunggu spawn
                refreshBtn("MENUNGGU...")
            end
        end
        task.wait(0.03)
    end
end)
print("[AutoSkill] jalan")
