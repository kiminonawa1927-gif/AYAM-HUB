local Players = game:GetService("Players")

local TARGET_NAME = "Leviartcst"
local JARAK = 4 -- jarak di depan target (stud)

-- Isi UserId yang boleh pakai (ganti dengan UserId kamu)
local ADMIN = { [12345678] = true }

local function teleportKeDepan(pemain)
	local target = Players:FindFirstChild(TARGET_NAME)
	if not target then return end

	local a, b = pemain.Character, target.Character
	if not (a and b) then return end

	local hrpB = b:FindFirstChild("HumanoidRootPart")
	if not (a:FindFirstChild("HumanoidRootPart") and hrpB) then return end

	local posisi = hrpB.CFrame * CFrame.new(0, 0, -JARAK) -- depan target
	a:PivotTo(CFrame.lookAt(posisi.Position, hrpB.Position))
end

Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(msg)
		if not ADMIN[player.UserId] then return end
		if msg:lower() == "/tp" then
			teleportKeDepan(player)
		end
	end)
end)
