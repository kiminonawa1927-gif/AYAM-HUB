local VIM     = game:GetService("VirtualInputManager")
local RS      = game:GetService("RunService")
local Players = game:GetService("Players")
local player  = Players.LocalPlayer

-- ====== SETTING ======
local UNDER        = 12
local MAX_DIST     = 600
local IGNORE_NAMES = {}
local STEP_DIST    = 12      -- jarak maju kalau nggak ada monster
local STEP_EVERY   = 1.5
local SKILLS = {
    { key = Enum.KeyCode.Q, cd = 0.25, last = 0 },
    { key = Enum.KeyCode.E, cd = 0.25, last = 0 },
    { key = Enum.KeyCode.R, cd = 0.25, last = 0 },
    { key = Enum.KeyCode.G, cd = 0.25, last = 0 },
}
local SWITCH_KEY, SWITCH_EVERY, lastSwitch = Enum.KeyCode.C, 6, 0
-- =====================

if getgenv().AF_conn then getgenv().AF_conn:Disconnect() end
getgenv().AutoFarm = true

local function press(key)
    VIM:SendKeyEvent(true, key, false, game)
    task.wait(0.03)
    VIM:SendKeyEvent(false, key, false, game)
end

local enemies = {}
local function refresh()
    local list = {}
    for _, h in ipairs(workspace:GetDescendants()) do
        if h:IsA("Humanoid") and h.Health > 0 then
            local m = h.Parent
            if m ~= player.Character and not Players:GetPlayerFromCharacter(m)
               and not m:FindFirstAncestor("Pets")
               and not table.find(IGNORE_NAMES, m.Name) then
                local r = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
                if r then list[#list+1] = { h = h, r = r } end
            end
        end
    end
    enemies = list
end

local function nearest(from)
    local best, bd = nil, MAX_DIST
    for _, e in ipairs(enemies) do
        if e.r.Parent and e.h.Health > 0 then
            local d = (e.r.Position - from).Magnitude
            if d < bd then best, bd = e, d end
        end
    end
    return best
end

local lastStep = 0
getgenv().AF_conn = RS.Heartbeat:Connect(function()
    if not getgenv().AutoFarm then return end
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum or hum.Health <= 0 then return end
    local t = nearest(root.Position)
    if not t then
        if os.clock() - lastStep > STEP_EVERY then
            lastStep = os.clock()
            root.CFrame = root.CFrame + root.CFrame.LookVector * STEP_DIST
        end
        return
    end
    local pos = t.r.Position + Vector3.new(0, -UNDER, 0)
    root.CFrame = CFrame.new(pos) * (root.CFrame - root.CFrame.Position)
    root.AssemblyLinearVelocity = Vector3.zero
end)

local parent = (gethui and gethui()) or game:GetService("CoreGui")
local old = parent:FindFirstChild("AutoSkillGui"); if old then old:Destroy() end
local gui = Instance.new("ScreenGui"); gui.Name = "AutoSkillGui"; gui.ResetOnSpawn = false; gui.Parent = parent
local btn = Instance.new("TextButton", gui)
btn.Size, btn.Position = UDim2.new(0, 90, 0, 36), UDim2.new(0, 10, 0.45, 0)
btn.Text, btn.BackgroundColor3 = "AUTO: ON", Color3.fromRGB(40,140,60)
btn.TextColor3, btn.TextSize = Color3.new(1,1,1), 14
btn.MouseButton1Click:Connect(function()
    getgenv().AutoFarm = not getgenv().AutoFarm
    btn.Text = getgenv().AutoFarm and "AUTO: ON" or "AUTO: OFF"
    btn.BackgroundColor3 = getgenv().AutoFarm and Color3.fromRGB(40,140,60) or Color3.fromRGB(160,40,40)
end)

task.spawn(function()
    local lastRefresh = 0
    while gui.Parent do
        if os.clock() - lastRefresh > 0.5 then refresh(); lastRefresh = os.clock() end
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if getgenv().AutoFarm and root and nearest(root.Position) then
            for _, s in ipairs(SKILLS) do
                if not getgenv().AutoFarm then break end
                if os.clock() - s.last >= s.cd then
                    pcall(press, s.key); s.last = os.clock(); task.wait(0.03)
                end
            end
            if os.clock() - lastSwitch >= SWITCH_EVERY then
                pcall(press, SWITCH_KEY); lastSwitch = os.clock()
            end
        end
        task.wait(0.03)
    end
end)
print("[AutoFarm v6.5] jalan")
