-- AYAM HUB v10 (Delta) + Key Harian
-- Dibuat oleh: Anjirr

-- ===== KEY SYSTEM =====
local VALID_KEYS_LIST = {
	"yZZuMuo1lug0Uwe", "L8k3katP9o5di1G", "n7FF8JuyfOmgIpo", "I0aWfvi6B5EjocW", "CyAsU2E1ij6buX9", "TVnfXPhSAFSITsP", "Y6Q7BafRZi0oX2x", "LlKwKo0EICbKiYM",
	"1f1GBJ2FzE8f3NU", "5n9pmMDIRNadOOs", "R8E1A6wY8rvB9Cz", "q1DuhalWduHGGFX", "eMR2rNqo0tIALUg", "4UZK82fKZcbVxPd", "72xrYYsEohlTZrL", "LhPohdVzUkkY091",
	"ZUfVGg9FvKHl6RW", "ATE8OgsU2IzCsGc", "ktD96JWw9OzD7BR", "vKCmplEPM4feSv1", "hHt6nqZTbykpEjc", "0tw1Mk19c1t6Tkn", "WyI1xqYDCjMrtgm", "AwRTgEWEFxBHQCg",
	"sL3gt3STBO4Rmiu", "N3Ip6jKn0xU0E6L", "J8vfZqrE5gDaMHI", "YtFI8630fmnaAxX", "yfPtRBJ9jVitcYF", "bcuUTePnUVmXnhi", "lpDReAerB4hEelz", "x44dqeZyWu6HFQO",
	"34Ymvr0z9ZuwM6l", "8XoYusbwCWa2CY8", "YuyPsqcBhguTrsY", "b4XaumQXvugWX1A", "iIcAhL5aWj57H2e", "7AwUtPM543faYaS", "gesMs3X1r5otRjI", "1zx5jDDKFsoIK8M",
	"DRkwJDfliN78aet", "uUWHrA0EKAVecG5", "5dHlvYw5Bfm3h8N", "JDKItDmsXvPYers", "YTDqNLgBLnNVQpz", "dv7jFs66Dfuyq4m", "rf3amWLBHu5P6xk", "RowfF80eTnZHjnL",
	"TLvWI3kcqGm0UFz", "bCHwF4s1cJeqrpg", "PrpvaqMV9TI9Vad", "K2KJnu5OctuBwaG", "0QGyAdn2P55q1Es", "BWzi5ZNFACMRnwi", "RBGtrASq0kHdjL6", "HNnZ5oh2IwpozdK",
	"qeiwPSVfUa9U4AW", "FBclDMoUACNAdat", "EbRM7pj0URhmT2K", "SjNqjxgCHgxmgoc", "p5jXzNPhUlGDkfz", "xGypZSnH8wlYyzh", "27E3AU7PCzXHw0A", "NdwycwU7kw6YdZz",
	"I1ys4CKifK1PHLw", "x8QjglJ71eVsVGT", "of8abDfVBU1ZXQC", "Se930A93sj2LgdD", "jabY8HnWB1qQJOF", "ZZjPIQV0eeI7Ow8", "skBw2WurZiyap6H", "OunOEwu4jq4W2T4",
	"5cSY9fmvJEPNSUI", "hcv4DFzgN5irOsT", "2VhnZQenb2mc4ep", "z42Q01EPmLPWsJb", "f1EjBjq1XyR06oZ", "UucOpeyPf5kiWaW", "vJ9y6Lzi5IExinX", "BJfH0Po73GPkZjk",
	"PgT0VGF0cddeZW8", "V0yzKPl2fkfWvDo", "8ObGf3UcYmxKXOT", "126n0qVK4ubqaef", "kw0IeJi3G9JULXh", "BeEi68KCOyqLcha", "kIbLBDVHPmMe9m6", "AY8NCtAp9bWnSJf",
	"myHLbxX6rqVhGWK", "YQVcYfcqFhyqMCv", "ntQ8c3k2iR2vwNm", "0k5jaCGK7DcrEQf", "qtkDAkoLMWgfVDm", "mT7mYKmiSGr36cJ", "zZke6YY1uhvjYkT", "xZU2EzxjWIwhSgg",
	"pQO3KkWHRI2HRfK", "jcSuBc2KfHj6qTs", "vRrfjPxa3efqhhw", "vcDDYLIKBy69iQ2", "SbDQbXSUwWf1OXL", "CjZWFAzpnU3KBg5", "sx60SeYfGjJOlc7", "6Xf56eKobu3Ih3X",
	"EPZA7tUTvOrCQ9V", "xbfuua8WQQa174w", "zXH3i1ZUvHXhtFz", "BRBroOItah8TZQf", "BoH0ZHgjNLQHAze", "eDWRkpxl7nHl05j", "JdiLsD2EFVjGWN7", "ZhQMz3pQCCADC0s",
	"VXfBAc5hRI8vPzb", "FKziNEhtxnPDeAY", "R9Rea5iM3KlBPBY", "spiVzANcMT9QoKR", "oianH05dLPhngG9", "TiPisKaiVZZkS1A", "qeHa5a13dCnKXEh", "aclkmcU975uTl39",
	"rm8cCMNzZ4Pt6DE", "v4ddAkQyAMI2bSK", "Q6lWh9kkgUjRN72", "ybRf3xnL1GCKepA", "uQJh9UxTmgQEIgd", "zPK2BQRNzShzBKP", "Eg8PvlV4SecGAId", "jIbzPmtmR6qGQwV",
	"m2sX1TeiX6AFtf3", "oupgJz3mo2Uh3nG", "C8fDUVxLbH6nKjS", "Xy4yN1N8TBqmQ19", "IXrGQZBfIQEmMzw", "24aXtQDluHLOmXj", "jT4Fr33aq1CErd9", "aGBX78tfv0gKsd5",
	"5RLCEupoENjsSca", "spz4wjwqKtspqqa", "O7dKfPAqhI7qLAk", "TlL88Jpz0HCaEWZ", "gEY6DgSGaT2QJS5", "WLAdLhDrCO1gOeE", "4NDhTgB3iOLo2OW", "3e72NUvBXOEWvI9",
	"vGl271f7UdD4XXd", "TPOgZIUWBso0IJP", "KTU0dYWk57fhIG6", "ZmTkoDqW0dFOu84", "tXBpLrfKOCDuDxW", "SJcL2t5ET4LbsVN", "IZ6Q5u0nf0Gdcbe", "PtvEUJnXLRp4J9R",
	"sZLp6eP3WUWmCr0", "R73TsSmgS4yMvfb", "7KqSRja7eO6UKDy", "gZ7zY0id9PZiQCn", "Lvx4JuybOQnNDLz", "WcL26XvGXcMH1Fr", "Lc5u3oXIGRv1cvH", "sur3yzwN9qkNTBZ",
	"j8XKMdUJ0qcw0TV", "IvPiIVqGqOu5a4M", "TbZUYIbqQO29hRL", "VZcfoIvEnE7IOYm", "Hp9Hp0yi2NQEH97", "DbmBVugiR28iGdg", "E1sAoPSEOhuXRSh", "dp2eHO79yU0wB2T",
	"rkwaG0BSdT16Uha", "Ydf3ObkUkoXIGil", "Z9qxGZ90pqsV2xV", "AALCcuGNwtB5JOF", "f60XxBUc5upsvlv", "CCAJRxAfYVy0Ulu", "UnQB1W3mumtOf0o", "9GpzUAfgbFE91K0",
	"CNShxpEEg1ZwaFD", "cBuDNHxvxJadt4I", "WCpqBQzhToMF2g0", "mnH231jqj8SxIsj", "PpXi37M5DG6Aubz", "NR7uPGEG1SmQf1g", "5yZ9jEfYvWEjPQT", "fyYCtvVfIdDxFk8",
	"hRuo9aE5UBUWj8a", "N5RNlBpuCzMHMKk", "zKXGb3Ngi0dSoWh", "u0AGUf1ngod9xj2", "SWoBXqE3JYBIRnu", "49ks2bbfyUQ12KH", "M6Lyq9jXE5sB7hr", "arPhGHJqSBfQ9Os",
	"DqBUsEzoLOBeZG7", "Wkgbm5TBdFR3hkt", "QNBBsaT4C1JOL8g", "MtfjBNGoJVV8gMs", "BfxKVbxKZMtmzoW", "ANY27563KsM6Ckl", "8ja0aiojshsfiGT", "fEoIG4VFm1uun3j",
}
local VALID = {}
for _, k in ipairs(VALID_KEYS_LIST) do VALID[k] = true end
local DURATION = 86400 -- key berlaku 1 hari (24 jam) sejak pertama dipakai
local FILE = "ayamhub_key2.txt"

local function readStore()
	local store = {}
	local ok, data = pcall(function() return isfile and isfile(FILE) and readfile(FILE) end)
	if ok and data then
		for k, t in data:gmatch("([^|\n]+)|(%d+)") do store[k] = tonumber(t) end
	end
	return store
end
local function writeStore(store)
	local lines = {}
	for k, t in pairs(store) do table.insert(lines, k .. "|" .. t) end
	pcall(function() writefile(FILE, table.concat(lines, "\n")) end)
end
local function savedOk()
	for k, t in pairs(readStore()) do
		if VALID[k] and os.time() - t < DURATION then return true end
	end
	return false
end
local function checkKey(input)
	input = input:gsub("%s", "")
	if not VALID[input] then return false, "Key salah" end
	local store = readStore()
	local t = store[input]
	if t then
		if os.time() - t < DURATION then return true end
		return false, "Key sudah kedaluwarsa"
	end
	store[input] = os.time() -- mulai hitung 1 hari dari sekarang
	writeStore(store)
	return true
end

local function StartHub()
-- ====== SCRIPT AYAM HUB ======
local CREATOR = "Anjirr"

local CODES = {
	"LacilBlueBerry", "Zhien", "IronReaper", "EJ(YURU)",
	"Ascart", "Sweetiee24", "Aetherix", "Monarch",
	"SUB2MULTIST789", "Heso", "Skywinter86", "Ghelayyy",
	"Aimyoungs", "GRAYWOLF", "Rujika", "RAGNAROK",
	"Giovanni_GG", "BERLINHERE23", "reiley", "ERIKSM",
	"Heartguard", "RaykorBR", "ZARGAKSTONE", "WerNate",
	"FRanime_OFFICIEL", "Ewaa", "Astral", "Lifauzi",
	"Shiroo00312_IRONSOUL", "PepCalcot", "Kiota2", "TT_oratttt",
	"Staysmoovey", "NisardHelpOnlyWoman", "LZZ_019BEST", "Les",
	"SEYUnever", "Bebek", "Shan", "Freca",
	"ReyPomuchi", "tony_vt", "ARKANGHEL", "Gryffin",
	"DEI_Yumeko", "Ryokenn", "Chrisss", "Ryu",
	"DrekathSenpai", "Lulzsec", "PaPaX", "omjiwa",
	"Clipz7112", "DanoNano", "MADUNN", "WettySNK",
	"Taalonely", "Darren", "obe", "Dekday",
	"PapiJoy", "Qyuu", "Gwynne", "Maniaco_666",
	"GT_HANNI", "smiley", "Sine", "Marcell",
	"Markbhatra", "Darkfeniks", "Sneptuno", "Dism",
	"FannTzy", "ProfGab", "Nothing", "Nyxaria",
	"ARES", "Deco", "Laplace", "LezoCr",
	"Maple", "TT_Mentally_ill_K.N", "VeeruChan", "Uzi",
	"Zeny", "Fujiesane", "Luthador2121", "AAM",
	"Iuknojo", "RIKUSOULS", "runekify", "Ahjughh",
	"T3nsei", "Ghifa",
}

local COOLDOWN = 6 -- detik antar kode (game minta jeda 15 detik)
local MAX_RETRY = 2 -- ulangi kode yang sama kalau kena "Tindakan terlalu sering"

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local VIM = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")
local lp = Players.LocalPlayer

local function getGuiParent()
	local ok, h = pcall(function() return gethui and gethui() end)
	if ok and h then return h end
	local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
	if ok2 and cg then return cg end
	return lp:WaitForChild("PlayerGui")
end

local parent = getGuiParent()
local old = parent:FindFirstChild("AyamHub")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "AyamHub"
gui.ResetOnSpawn = false
gui.Parent = parent

-- ===== Desain baru =====
local ACCENT = Color3.fromRGB(255, 170, 40)
local ACCENT2 = Color3.fromRGB(255, 85, 60)
local BG = Color3.fromRGB(18, 18, 24)
local BTN = Color3.fromRGB(34, 34, 44)
local W, H = 240, 214

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, W, 0, H)
frame.Position = UDim2.new(0.5, -W / 2, 0.15, 0)
frame.BackgroundColor3 = BG
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

local frameStroke = Instance.new("UIStroke", frame)
frameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
frameStroke.Color = ACCENT
frameStroke.Transparency = 0.45
frameStroke.Thickness = 1.5

-- Banner atas (gradasi)
local banner = Instance.new("Frame")
banner.Size = UDim2.new(1, 0, 0, 54)
banner.BackgroundColor3 = Color3.new(1, 1, 1)
banner.BorderSizePixel = 0
banner.Parent = frame
Instance.new("UICorner", banner).CornerRadius = UDim.new(0, 14)

local grad = Instance.new("UIGradient", banner)
grad.Color = ColorSequence.new(ACCENT, ACCENT2)
grad.Rotation = 0

-- Penutup sudut bawah banner (supaya hanya sudut atas yang melengkung)
local filler = Instance.new("Frame")
filler.Size = UDim2.new(1, 0, 0, 24)
filler.Position = UDim2.new(0, 0, 0, 30)
filler.BackgroundColor3 = Color3.new(1, 1, 1)
filler.BorderSizePixel = 0
filler.Parent = banner

local grad2 = Instance.new("UIGradient", filler)
grad2.Color = ColorSequence.new(ACCENT, ACCENT2)
grad2.Rotation = 0

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 0, 28)
title.Position = UDim2.new(0, 16, 0, 6)
title.BackgroundTransparency = 1
title.Text = "AYAM HUB"
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBlack
title.TextSize = 21
title.Parent = banner

local titleStroke = Instance.new("UIStroke", title)
titleStroke.Color = Color3.fromRGB(90, 30, 10)
titleStroke.Transparency = 0.6
titleStroke.Thickness = 1

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -90, 0, 16)
subtitle.Position = UDim2.new(0, 16, 0, 33)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Auto Redeem Hub | by " .. CREATOR
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.TextColor3 = Color3.fromRGB(255, 244, 225)
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextSize = 11
subtitle.Parent = banner

-- Isi menu
local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -54)
body.Position = UDim2.new(0, 0, 0, 54)
body.BackgroundTransparency = 1
body.Parent = frame

local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, -20, 0, 48)
statusBar.Position = UDim2.new(0, 10, 1, -58)
statusBar.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
statusBar.BorderSizePixel = 0
statusBar.Parent = body
Instance.new("UICorner", statusBar).CornerRadius = UDim.new(0, 10)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -16, 1, -8)
status.Position = UDim2.new(0, 8, 0, 4)
status.BackgroundTransparency = 1
status.Text = "Siap"
status.TextColor3 = Color3.fromRGB(190, 190, 200)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextWrapped = true
status.Parent = statusBar

local function setStatus(t)
	status.Text = tostring(t)
end

local function makeButton(text, y, callback)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -20, 0, 40)
	b.Position = UDim2.new(0, 10, 0, y)
	b.BackgroundColor3 = BTN
	b.TextColor3 = Color3.fromRGB(235, 235, 240)
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 14
	b.Text = text
	b.BorderSizePixel = 0
	b.Parent = body
	Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
	local st = Instance.new("UIStroke", b)
	st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	st.Color = ACCENT
	st.Transparency = 0.7
	st.Thickness = 1
	b.Activated:Connect(function() callback(b) end)
	return b
end

-- Warna tombol aktif / tidak aktif
local function paint(b, on)
	b.BackgroundColor3 = on and ACCENT or BTN
	b.TextColor3 = on and Color3.fromRGB(30, 20, 8) or Color3.fromRGB(235, 235, 240)
end

-- Anti DC (cegah ter-kick karena idle / error 278)
local afkConn
local dcOn = false
makeButton("Anti DC: OFF", 12, function(b)
	if dcOn then
		dcOn = false
		if afkConn then
			afkConn:Disconnect()
			afkConn = nil
		end
		b.Text = "Anti DC: OFF"; paint(b, false)
		setStatus("Anti DC dimatikan")
	else
		dcOn = true
		afkConn = lp.Idled:Connect(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end)
		task.spawn(function()
			while dcOn do
				task.wait(50)
				if not dcOn then break end
				pcall(function()
					VirtualUser:CaptureController()
					VirtualUser:ClickButton2(Vector2.new())
				end)
			end
		end)
		b.Text = "Anti DC: ON"; paint(b, true)
		setStatus("Anti DC aktif")
	end
end)

-- ===== Helper UI =====
local function isVisible(o)
	local cur = o
	while cur and cur ~= game do
		if cur:IsA("GuiObject") and not cur.Visible then return false end
		if cur:IsA("ScreenGui") and not cur.Enabled then return false end
		cur = cur.Parent
	end
	return true
end

local function clickAt(obj)
	local inset = GuiService:GetGuiInset()
	local p = obj.AbsolutePosition + obj.AbsoluteSize / 2
	VIM:SendMouseButtonEvent(p.X, p.Y + inset.Y, 0, true, game, 1)
	task.wait(0.05)
	VIM:SendMouseButtonEvent(p.X, p.Y + inset.Y, 0, false, game, 1)
end

local function press(obj)
	local fired = false
	if obj:IsA("GuiButton") then
		for _, sig in ipairs({ "Activated", "MouseButton1Click", "MouseButton1Down", "MouseButton1Up" }) do
			pcall(function()
				if getconnections then
					for _, c in ipairs(getconnections(obj[sig])) do
						c:Fire()
						fired = true
					end
				end
			end)
		end
		if not fired and firesignal then
			pcall(function() firesignal(obj.Activated) fired = true end)
		end
	end
	if not fired then
		fired = pcall(clickAt, obj) -- cadangan: klik layar di posisi tombol
	end
	return fired
end

local KEYS = { "masukkan", "redeem", "klaim", "claim", "submit" }

-- Cari tombol "Masukkan Kode" (bisa TextButton, atau tulisan di dalam tombol/gambar)
local function findUi()
	local pg = lp.PlayerGui
	for _, k in ipairs(KEYS) do
		for _, v in ipairs(pg:GetDescendants()) do
			if not v:IsDescendantOf(gui) and (v:IsA("TextButton") or v:IsA("TextLabel")) and isVisible(v) then
				local t = v.Text:lower()
				if #t < 30 and t:find(k) then
					local target = v
					local cur = v
					while cur and cur ~= pg do
						if cur:IsA("GuiButton") then
							target = cur
							break
						end
						cur = cur.Parent
					end
					local root = target:FindFirstAncestorOfClass("ScreenGui") or pg
					local box
					for _, d in ipairs(root:GetDescendants()) do
						if d:IsA("TextBox") and isVisible(d) then
							box = d
							break
						end
					end
					return box, target
				end
			end
		end
	end
end

-- Jalur UI sebenarnya (dari hasil Scan UI):
-- MainGui.ScreenDiscordCode.BtnFrmae -> TypeBnt.TextBox (kolom kode) + Confirm (tombol)
local function findUiDirect()
	local pg = lp.PlayerGui
	local main = pg:FindFirstChild("MainGui")
	local scr = main and main:FindFirstChild("ScreenDiscordCode")
	local frm = scr and scr:FindFirstChild("BtnFrmae")
	if not frm then
		return nil, nil, "Jendela Kode tidak ditemukan di game ini"
	end
	if not isVisible(scr) then
		return nil, nil, "Buka dulu jendela 'Kode!', lalu tekan lagi"
	end
	local box = frm:FindFirstChild("TextBox", true)
	local confirm = frm:FindFirstChild("Confirm")
	return box, confirm, nil
end

-- Baca pesan hasil dari layar game
local function readResult()
	for _, v in ipairs(lp.PlayerGui:GetDescendants()) do
		if v:IsA("TextLabel") and not v:IsDescendantOf(gui) and v.TextTransparency < 0.9 and isVisible(v) then
			local t = v.Text:lower()
			if t:find("ditebus") then return "ok" end
			if t:find("tidak ditemukan") then return "notfound" end
			if t:find("terlalu sering") then return "cooldown" end
		end
	end
end

-- ===== Auto Redeem =====
local running = false
makeButton("Auto Redeem", 58, function(b)
	if running then
		running = false
		b.Text = "Auto Redeem"; paint(b, false)
		setStatus("Dihentikan")
		return
	end

	local box, btn, err = findUiDirect()
	if err then
		setStatus(err)
		return
	end
	if not box or not btn then
		setStatus("Kolom atau tombol Confirm tidak ketemu")
		return
	end

	running = true
	b.Text = "Stop"; paint(b, true)

	task.spawn(function()
		for i, code in ipairs(CODES) do
			if not running then break end
			local attempt = 0
			while running do
				attempt += 1
				box.Text = code
				task.wait(0.5)
				if not press(btn) then
					setStatus("Gagal menekan tombol")
					running = false
					break
				end

				local res
				for _ = 1, 8 do
					task.wait(0.5)
					res = readResult()
					if res then break end
				end

				if res == "ok" then
					setStatus(("%d/%d %s: Ditebus!"):format(i, #CODES, code))
				elseif res == "notfound" then
					setStatus(("%d/%d %s: Tidak ditemukan"):format(i, #CODES, code))
				elseif res == "cooldown" and attempt <= MAX_RETRY then
					setStatus(("%s: kena cooldown, ulangi..."):format(code))
					task.wait(COOLDOWN)
					continue
				else
					setStatus(("%d/%d %s: terkirim (hasil tidak terbaca)"):format(i, #CODES, code))
				end
				break
			end

			if running and i < #CODES then
				for s = COOLDOWN, 1, -1 do
					if not running then break end
					setStatus(("Jeda %ds sebelum kode berikutnya"):format(s))
					task.wait(1)
				end
			end
		end
		if running then setStatus("Semua kode selesai") end
		running = false
		b.Text = "Auto Redeem"; paint(b, false)
	end)
end)

-- Tombol minimize dan tutup (di banner)
local function bannerButton(text, xOffset)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 26, 0, 26)
	b.Position = UDim2.new(1, xOffset, 0, 8)
	b.BackgroundColor3 = Color3.fromRGB(20, 12, 8)
	b.BackgroundTransparency = 0.45
	b.Text = text
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 15
	b.BorderSizePixel = 0
	b.Parent = banner
	Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
	return b
end

local mini = bannerButton("-", -64)
local close = bannerButton("X", -34)

-- Bubble kecil "AH" (muncul saat menu diminimize)
local bubble = Instance.new("TextButton")
bubble.Size = UDim2.new(0, 52, 0, 52)
bubble.BackgroundTransparency = 1
bubble.Text = ""
bubble.AutoButtonColor = false
bubble.Active = true
bubble.Visible = false
bubble.Parent = gui

local bubbleBg = Instance.new("Frame")
bubbleBg.Size = UDim2.new(1, 0, 1, 0)
bubbleBg.BackgroundColor3 = Color3.new(1, 1, 1)
bubbleBg.BorderSizePixel = 0
bubbleBg.Parent = bubble
Instance.new("UICorner", bubbleBg).CornerRadius = UDim.new(1, 0)

local bubbleGrad = Instance.new("UIGradient", bubbleBg)
bubbleGrad.Color = ColorSequence.new(ACCENT, ACCENT2)
bubbleGrad.Rotation = 45

local ring = Instance.new("UIStroke", bubbleBg)
ring.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ring.Color = Color3.new(1, 1, 1)
ring.Transparency = 0.5
ring.Thickness = 2

local bubbleText = Instance.new("TextLabel")
bubbleText.Size = UDim2.new(1, 0, 1, 0)
bubbleText.BackgroundTransparency = 1
bubbleText.Text = "AH"
bubbleText.TextColor3 = Color3.new(1, 1, 1)
bubbleText.Font = Enum.Font.GothamBlack
bubbleText.TextSize = 20
bubbleText.ZIndex = 2
bubbleText.Parent = bubble

local bubbleStroke = Instance.new("UIStroke", bubbleText)
bubbleStroke.Color = Color3.fromRGB(90, 30, 10)
bubbleStroke.Transparency = 0.5
bubbleStroke.Thickness = 1

-- Minimize: menu hilang, muncul bubble di posisi yang sama
mini.Activated:Connect(function()
	bubble.Position = frame.Position
	frame.Visible = false
	bubble.Visible = true
end)

-- Geser dan ketuk bubble (dibuat manual supaya ketukan tidak tertelan)
local UIS = game:GetService("UserInputService")
local dragging = false
local moved = false
local dragStart, startPos

local function expand()
	frame.Position = bubble.Position
	bubble.Visible = false
	frame.Visible = true
end

local function isPointer(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

bubble.InputBegan:Connect(function(input)
	if isPointer(input) then
		dragging = true
		moved = false
		dragStart = input.Position
		startPos = bubble.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				if not moved then
					expand() -- ketukan biasa = buka menu
				end
			end
		end)
	end
end)

UIS.InputChanged:Connect(function(input)
	if not dragging then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then
		local d = input.Position - dragStart
		if d.Magnitude > 8 then moved = true end
		if moved then
			bubble.Position = UDim2.new(
				s
