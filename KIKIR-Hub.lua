-- AYAM HUB v14w (Delta) - Anti DC + Auto Redeem + Auto Spin x10 (+ x1 buat sisa tiket) + hitung Tiket Keberuntungan + Shard (Pecahan Asal) otomatis
-- Dibuat oleh: Anjirr
local CREATOR = "Anjirr"

local CODES = {
	"BOWANDSKILLTREE",
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
	"BaraWell", "qzq", "Horrortoki", "TRADEISLANDUPDATE",
	"CA2", "SIGURIH",
}

-- ===== Pengaturan kecepatan =====
-- Jeda antar kode dicari otomatis (bagi dua), hanya dari percobaan PERTAMA tiap kode
-- (kirim ulang tidak dipakai untuk mengukur, supaya hasilnya tidak ikut membengkak).
--  gagal ("mohon tunggu") = batas bawah, berhasil = batas atas.
-- Kalau sudah dekat, jeda DIKUNCI di batas atas + SAFETY, dan tiap PROBE_EVERY kode
-- dites sedikit lebih pendek untuk memastikan tidak kelamaan.
local START_CD = 3        -- tebakan awal jeda antar kode (detik)
local MIN_CD = 0.3        -- jeda terkecil yang boleh dipakai
local MAX_CD = 20         -- jeda terbesar yang boleh dipakai
local CD_TOL = 0.2        -- selisih batas atas dan bawah yang dianggap cukup presisi
local SAFETY = 0.15       -- tambahan aman di atas batas atas saat dikunci
local PROBE_EVERY = 8     -- tiap berapa kode, tes jeda yang lebih pendek saat terkunci
local RETRY_DELAY = 1.0   -- jarak minimum antar kirim ulang
local EST_START = 6       -- perkiraan awal waktu per kode (untuk sisa waktu, lalu menyesuaikan)
local AUTO_START = true   -- mulai redeem semua kode otomatis begitu jendela Kode terbuka
local HIDE_NOTICE = false -- sembunyikan notif "mohon tunggu" dan "tidak ditemukan" (ubah ke true kalau sudah aman)
local MAX_TRIES = 100    -- batas coba ulang per kode (tombol Stop selalu bisa dipakai)
local POLL = 0.1         -- cek hasil tiap 0.1 detik (ringan, hanya baca variabel)
local RESULT_TIMEOUT = 4 -- tunggu pesan hasil maksimal (detik)

-- ===== Pengaturan Auto Spin x10 =====
local SPIN_LIMIT = 0           -- jumlah maksimal "Putar x10" (0 = terus sampai tiket habis)
local SPIN_REWARD_TIMEOUT = 8  -- tunggu pesan "Received" setelah menekan tombol (detik)
local SPIN_QUIET = 1.5         -- dianggap selesai kalau tidak ada hadiah baru selama ini (detik)
local SPIN_MAX_ANIM = 15       -- batas tunggu animasi spin per putaran (detik)
local SPIN_GAP = 0.5           -- jeda sebelum menekan Putar x10 berikutnya (detik)
local SPIN_MISS_STOP = 3       -- x10: segini kali berturut-turut tanpa hadiah dianggap tiket kurang dari 10
local SPIN_REMAINDER = true    -- setelah tiket kurang dari 10, lanjut Putar x1 sampai tiket habis
local SPIN_X1_MISS_STOP = 2    -- x1: berhenti kalau segini kali berturut-turut tanpa hadiah (tiket habis)

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local VIM = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local lp = Players.LocalPlayer

-- Ingatan bertahan selama game belum ditutup (juga kalau script dijalankan ulang)
local state = (getgenv and getgenv()) or _G

-- ===== Penyimpanan permanen per akun (berdasarkan UserId, nama ikut dicatat) =====
local SAVE_FILE = "AyamHub_data.json"
local ACC_KEY = tostring(lp.UserId)
local canFile = type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"

local function readDb()
	local db = {}
	if canFile then
		pcall(function()
			if isfile(SAVE_FILE) then
				local d = HttpService:JSONDecode(readfile(SAVE_FILE))
				if type(d) == "table" then db = d end
			end
		end)
	end
	return db
end

local db = readDb()
local acc = db[ACC_KEY]
if type(acc) ~= "table" or type(acc.codes) ~= "table" then
	acc = { name = lp.Name, codes = {} }
end
acc.name = lp.Name

-- Pindahkan data dari versi lama (file per akun) kalau ada
if canFile and next(acc.codes) == nil then
	pcall(function()
		local old = "AyamHub_" .. ACC_KEY .. ".json"
		if isfile(old) then
			local d = HttpService:JSONDecode(readfile(old))
			if type(d) == "table" then acc.codes = d end
		end
	end)
end

local saved = acc.codes
local isNewAccount = next(saved) == nil

-- Ingatan sesi juga dipisah per akun
state.AyamDoneBy = state.AyamDoneBy or {}
state.AyamDoneBy[ACC_KEY] = state.AyamDoneBy[ACC_KEY] or {}
local sessionDone = state.AyamDoneBy[ACC_KEY]
for c in pairs(saved) do sessionDone[c] = true end

local fileOk = false
local function saveToFile()
	if not canFile then return false end
	local ok = pcall(function()
		local fresh = readDb() -- baca ulang supaya data akun lain tidak tertimpa
		fresh[ACC_KEY] = acc
		writefile(SAVE_FILE, HttpService:JSONEncode(fresh))
	end)
	fileOk = ok
	return ok
end
saveToFile() -- uji tulis sekarang, sekaligus mencatat akun ini di file
local function fileInfo()
	if fileOk then return "tersimpan di file" end
	return "FILE TIDAK BISA DITULIS: ingatan hanya sesi ini"
end

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

-- ===== Desain =====
local ACCENT = Color3.fromRGB(255, 170, 40)
local ACCENT2 = Color3.fromRGB(255, 85, 60)
local BG = Color3.fromRGB(18, 18, 24)
local BTN = Color3.fromRGB(34, 34, 44)
local W, H = 240, 318

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

local banner = Instance.new("Frame")
banner.Size = UDim2.new(1, 0, 0, 54)
banner.BackgroundColor3 = Color3.new(1, 1, 1)
banner.BorderSizePixel = 0
banner.Parent = frame
Instance.new("UICorner", banner).CornerRadius = UDim.new(0, 14)
local grad = Instance.new("UIGradient", banner)
grad.Color = ColorSequence.new(ACCENT, ACCENT2)

local filler = Instance.new("Frame")
filler.Size = UDim2.new(1, 0, 0, 24)
filler.Position = UDim2.new(0, 0, 0, 30)
filler.BackgroundColor3 = Color3.new(1, 1, 1)
filler.BorderSizePixel = 0
filler.Parent = banner
local grad2 = Instance.new("UIGradient", filler)
grad2.Color = ColorSequence.new(ACCENT, ACCENT2)

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

local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -54)
body.Position = UDim2.new(0, 0, 0, 54)
body.BackgroundTransparency = 1
body.Parent = frame

local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, -20, 0, 60)
statusBar.Position = UDim2.new(0, 10, 1, -70)
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

local function paint(b, on)
	b.BackgroundColor3 = on and ACCENT or BTN
	b.TextColor3 = on and Color3.fromRGB(30, 20, 8) or Color3.fromRGB(235, 235, 240)
end

-- ===== Anti DC =====
local afkConn
local dcOn = false
local pulseCount = 0

local function pulse()
	pulseCount += 1
	pcall(function()
		local cam = workspace.CurrentCamera
		local cf = cam and cam.CFrame or CFrame.new()
		VirtualUser:CaptureController()
		VirtualUser:Button2Down(Vector2.new(0, 0), cf)
		task.wait(0.1)
		VirtualUser:Button2Up(Vector2.new(0, 0), cf)
	end)
	pcall(function()
		VIM:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
		task.wait(0.05)
		VIM:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
	end)
	pcall(function()
		local cam = workspace.CurrentCamera
		if cam then
			cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(0.1), 0)
		end
	end)
end

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
		pulseCount = 0
		pcall(function()
			if getconnections then
				for _, c in ipairs(getconnections(lp.Idled)) do
					c:Disable()
				end
			end
		end)
		afkConn = lp.Idled:Connect(pulse)
		task.spawn(function()
			while dcOn do
				pulse()
				if status.Text:find("Anti DC") or status.Text == "Siap" then
					setStatus(("Anti DC aktif (ping ke-%d)"):format(pulseCount))
				end
				for _ = 1, 25 do
					if not dcOn then break end
					task.wait(1)
				end
			end
		end)
		b.Text = "Anti DC: ON"; paint(b, true)
		setStatus("Anti DC aktif")
	end
end)

-- ===== Tombol Auto Redeem: dibuat di sini supaya SELALU muncul =====
-- Isinya (redeemHandler) didefinisikan di bawah; kalau belum siap, tombol memberi tahu.
local redeemHandler
local redeemBtn = makeButton("Auto Redeem", 58, function(b)
	if redeemHandler then
		redeemHandler(b)
	else
		setStatus("Belum siap, script masih dimuat / ada error di bawah")
	end
end)

-- Tombol Auto Spin: isinya (spinHandler) didefinisikan di bawah
local spinHandler
local spinBtn = makeButton("Auto Spin x10", 104, function(b)
	if spinHandler then
		spinHandler(b)
	else
		setStatus("Belum siap, script masih dimuat / ada error di bawah")
	end
end)

-- Label jumlah Tiket Keberuntungan + tombol "Set" (memilih angka tiket dengan mengetuk layar)
local ticketLabel = Instance.new("TextLabel")
ticketLabel.Size = UDim2.new(1, -66, 0, 20)
ticketLabel.Position = UDim2.new(0, 12, 0, 148)
ticketLabel.BackgroundTransparency = 1
ticketLabel.Text = "Tiket didapat: +0"
ticketLabel.TextXAlignment = Enum.TextXAlignment.Left
ticketLabel.TextColor3 = ACCENT
ticketLabel.Font = Enum.Font.GothamMedium
ticketLabel.TextSize = 12
ticketLabel.Parent = body

-- Label total Shard (Potongan Asal) yang didapat
local shardLabel = Instance.new("TextLabel")
shardLabel.Size = UDim2.new(1, -24, 0, 20)
shardLabel.Position = UDim2.new(0, 12, 0, 168)
shardLabel.BackgroundTransparency = 1
shardLabel.Text = "Shard: +0"
shardLabel.TextXAlignment = Enum.TextXAlignment.Left
shardLabel.TextColor3 = Color3.fromRGB(110, 190, 255)
shardLabel.Font = Enum.Font.GothamMedium
shardLabel.TextSize = 12
shardLabel.Parent = body

local tkCalibrate
local tkSetBtn = Instance.new("TextButton")
tkSetBtn.Size = UDim2.new(0, 40, 0, 20)
tkSetBtn.Position = UDim2.new(1, -50, 0, 148)
tkSetBtn.BackgroundColor3 = BTN
tkSetBtn.Text = "Set"
tkSetBtn.TextColor3 = Color3.fromRGB(235, 235, 240)
tkSetBtn.Font = Enum.Font.GothamMedium
tkSetBtn.TextSize = 11
tkSetBtn.BorderSizePixel = 0
tkSetBtn.Parent = body
Instance.new("UICorner", tkSetBtn).CornerRadius = UDim.new(1, 0)
tkSetBtn.Activated:Connect(function()
	if tkCalibrate then tkCalibrate() end
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
	task.wait(0.03)
	VIM:SendMouseButtonEvent(p.X, p.Y + inset.Y, 0, false, game, 1)
end

-- Ingat cara menekan yang berhasil supaya tidak mencoba semuanya tiap kali
local pressMode
local function press(obj)
	if pressMode == "fire" or pressMode == nil then
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
		if fired then
			pressMode = "fire"
			return true
		end
	end
	local ok = pcall(clickAt, obj)
	if ok then pressMode = "click" end
	return ok
end

-- Jalur UI sebenarnya: MainGui.ScreenDiscordCode.BtnFrmae -> TextBox + Confirm
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
	return frm:FindFirstChild("TextBox", true), frm:FindFirstChild("Confirm"), nil
end

-- ===== Deteksi hasil =====
local function classify(text)
	local t = text:lower()
	if t:find("ditebus") then return "ok" end
	if t:find("digunakan") or t:find("dipakai") or t:find("already") then return "used" end
	if t:find("tidak ditemukan") then return "notfound" end
	if t:find("terlalu sering") or t:find("mohon tunggu") then return "cooldown" end
end

-- Deteksi berbasis event (tanpa scan berat): pantau perubahan teks label
local lastMsg = { kind = nil, t = 0, text = "" }
local hooked = setmetatable({}, { __mode = "k" })
local conns = {}
local hookedAll = false

-- Sembunyikan notifikasi gagal (hanya tampilan; hasilnya tetap dibaca script)
local hiddenBy = setmetatable({}, { __mode = "k" })

local function hasLayout(o)
	for _, c in ipairs(o:GetChildren()) do
		if c:IsA("UIListLayout") or c:IsA("UIGridLayout") or c:IsA("UITableLayout") or c:IsA("UIPageLayout") then
			return true
		end
	end
	return false
end

local function countTexts(o)
	local n = 0
	for _, d in ipairs(o:GetDescendants()) do
		if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then n += 1 end
	end
	return n
end

local noticeHolders = setmetatable({}, { __mode = "k" })

local function textCount(o)
	return ((o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox")) and 1 or 0) + countTexts(o)
end

-- Wadah notifikasi: induk dari beberapa kotak sejenis yang masing-masing berisi satu teks
local function siblingsLike(par, cur)
	if cur:IsA("TextLabel") or cur:IsA("TextButton") then return false end
	local n = 0
	for _, c in ipairs(par:GetChildren()) do
		if c:IsA("GuiObject") and c.ClassName == cur.ClassName and textCount(c) == 1 then n += 1 end
	end
	return n >= 2
end

local function hideNotice(v)
	if hiddenBy[v] then
		v:SetAttribute("AH_t", os.clock())
		return
	end
	local list = { v }
	-- Cari entri notifikasi: leluhur yang induknya adalah wadah berdaftar (UIListLayout dsb.)
	local entry
	local cur = v
	for _ = 1, 5 do
		local par = cur.Parent
		if not par or not cur:IsA("GuiObject") then break end
		if hasLayout(par) or siblingsLike(par, cur) then
			entry = cur
			noticeHolders[par] = true
			break
		end
		cur = par
	end
	if entry and entry ~= v then
		table.insert(list, entry)
	elseif not entry then
		-- Cadangan: kotak pembungkus yang hanya berisi teks ini
		local p = v.Parent
		for _ = 1, 2 do
			if p and p:IsA("GuiObject") and not hasLayout(p) and countTexts(p) <= 1 then
				table.insert(list, p)
				p = p.Parent
			else
				break
			end
		end
	end
	hiddenBy[v] = list
	v:SetAttribute("AH_t", os.clock())
	for _, o in ipairs(list) do
		pcall(function() o.Visible = false end)
		-- Game memakai ulang kotak notifikasi dan bisa menyalakannya lagi: matikan lagi
		-- selama label ini masih dalam keadaan disembunyikan
		table.insert(conns, o:GetPropertyChangedSignal("Visible"):Connect(function()
			if hiddenBy[v] == list and o.Visible then
				o.Visible = false
			end
		end))
	end
end

local function restoreNotice(v)
	local list = hiddenBy[v]
	if list then
		hiddenBy[v] = nil
		for _, o in ipairs(list) do
			pcall(function() o.Visible = true end)
		end
	end
end

local function entryInfo(e)
	local has, fail = false, false
	local function look(o)
		if (o:IsA("TextLabel") or o:IsA("TextButton")) and o.Text ~= "" then
			has = true
			local k = classify(o.Text)
			if k and k ~= "ok" then fail = true end
		end
	end
	look(e)
	for _, d in ipairs(e:GetDescendants()) do look(d) end
	return has, fail
end

-- Penyapu kotak hitam kosong: cari kotak tipis-lebar tanpa tulisan di bagian atas layar
-- yang berdampingan dengan kotak sejenis, lalu buat transparan (tidak mengubah Visible)
local candidates = setmetatable({}, { __mode = "k" })
local origProps = setmetatable({}, { __mode = "k" })

local function consider(o)
	if (o:IsA("Frame") or o:IsA("ImageLabel")) and not o:IsDescendantOf(gui) then
		candidates[o] = true
	end
end

local function lumaOf(c) return 0.299 * c.R + 0.587 * c.G + 0.114 * c.B end

local function makeClear(o)
	if origProps[o] then return end
	local rec = {}
	local function grab(x)
		if x:IsA("GuiObject") then
			rec[#rec + 1] = { x, "BackgroundTransparency", x.BackgroundTransparency }
			x.BackgroundTransparency = 1
			if x:IsA("ImageLabel") or x:IsA("ImageButton") then
				rec[#rec + 1] = { x, "ImageTransparency", x.ImageTransparency }
				x.ImageTransparency = 1
			end
		elseif x:IsA("UIStroke") then
			rec[#rec + 1] = { x, "Enabled", x.Enabled }
			x.Enabled = false
		end
	end
	grab(o)
	for _, d in ipairs(o:GetDescendants()) do grab(d) end
	origProps[o] = rec
end

-- Game bisa menyalakan lagi transparansinya: tegakkan ulang
local function reapplyClear(o)
	local rec = origProps[o]
	for _, r in ipairs(rec) do
		local x, prop = r[1], r[2]
		if prop == "Enabled" then
			if x.Enabled then x.Enabled = false end
		elseif x[prop] ~= 1 then
			x[prop] = 1
		end
	end
end

local function undoClear(o)
	local rec = origProps[o]
	origProps[o] = nil
	if rec then
		for _, r in ipairs(rec) do pcall(function() r[1][r[2]] = r[3] end) end
	end
end

local function sweepHolders()
	local cam = workspace.CurrentCamera
	local screenH = cam and cam.ViewportSize.Y or 720
	local sameCount = {}
	local hits = {}
	for o in pairs(candidates) do
		if not o.Parent then
			candidates[o] = nil
			if origProps[o] then origProps[o] = nil end
		elseif origProps[o] then
			sameCount[o.Parent] = (sameCount[o.Parent] or 0) + 1
			local has, fail = entryInfo(o)
			if has and not fail then
				undoClear(o) -- notif biasa (mis. "Ditebus"): kembalikan tampilan
			else
				reapplyClear(o)
			end
		else
			local sz, pos = o.AbsoluteSize, o.AbsolutePosition
			if sz.Y >= 16 and sz.Y <= 70 and sz.X >= 100 and sz.X / sz.Y >= 3 and pos.Y < screenH * 0.4 then
				local bg = o:IsA("Frame") and o.BackgroundColor3 or Color3.new(0, 0, 0)
				if o.BackgroundTransparency < 0.95 and lumaOf(bg) < 0.3 and isVisible(o) then
					local has, fail = entryInfo(o)
					if (not has) or fail then
						hits[#hits + 1] = o
						sameCount[o.Parent] = (sameCount[o.Parent] or 0) + 1
					end
				end
			end
		end
	end
	for _, o in ipairs(hits) do
		-- hanya kalau ada kotak sejenis di induk yang sama (daftar notifikasi), supaya bar HUD aman
		if (sameCount[o.Parent] or 0) >= 2 then
			makeClear(o)
		end
	end
end

local function check(v, fromText)
	if v.Text == "" then return end
	local kind = classify(v.Text)
	if not kind then return end

	if kind == "ok" then
		restoreNotice(v) -- kalau label ini pernah disembunyikan lalu dipakai untuk "ditebus"
	end

	-- Catat hasil dulu (sebelum disembunyikan) supaya tetap terbaca script.
	if fromText or (v.Visible and isVisible(v)) then
		lastMsg.kind = kind
		lastMsg.t = os.clock()
		lastMsg.text = v.Text
	end

	if HIDE_NOTICE and kind ~= "ok" then
		hideNotice(v)
	end
end

local function hook(v)
	if hooked[v] or not v:IsA("TextLabel") or v:IsDescendantOf(gui) then return false end
	hooked[v] = true
	table.insert(conns, v:GetPropertyChangedSignal("Text"):Connect(function() check(v, true) end))
	table.insert(conns, v:GetPropertyChangedSignal("Visible"):Connect(function() if v.Visible then check(v, false) end end))
	return true
end

local function hookAll()
	if hookedAll then return end
	hookedAll = true
	if HIDE_NOTICE then
		task.spawn(function()
			while gui.Parent do
				pcall(sweepHolders)
				task.wait(0.25)
			end
		end)
	end
	for _, v in ipairs(lp.PlayerGui:GetDescendants()) do
		hook(v)
		consider(v)
	end
	table.insert(conns, lp.PlayerGui.DescendantAdded:Connect(function(v)
		consider(v)
		if hook(v) then check(v, true) end
	end))
end

-- Cadangan ringan: satu kali scan (dipanggil jarang, bukan tiap 0.1 detik)
local function scanOnce(since)
	for _, v in ipairs(lp.PlayerGui:GetDescendants()) do
		if v:IsA("TextLabel") and not v:IsDescendantOf(gui) and v.Text ~= "" then
			local kind = classify(v.Text)
			if kind then
				local ht = v:GetAttribute("AH_t")
				if ht and ht >= since then
					return kind, v.Text -- notifikasi yang kita sembunyikan setelah tombol ditekan
				end
				if v.TextTransparency < 0.9 and isVisible(v) then return kind, v.Text end
			end
		end
	end
end

-- Tunggu pesan yang muncul SETELAH tombol ditekan
local function waitResult(pressedAt)
	local t0 = os.clock()
	local scanned = false
	while os.clock() - t0 < RESULT_TIMEOUT do
		task.wait(POLL)
		if lastMsg.kind and lastMsg.t >= pressedAt then
			return lastMsg.kind, lastMsg.text
		end
		if not scanned and os.clock() - t0 > 0.6 then
			scanned = true
			local k, tx = scanOnce(pressedAt)
			if k then return k, tx end
		end
	end
	return nil
end

local function fmtTime(s)
	s = math.max(0, math.ceil(s))
	if s >= 3600 then
		return ("%d:%02d:%02d"):format(s // 3600, (s % 3600) // 60, s % 60)
	end
	return ("%d:%02d"):format(s // 60, s % 60)
end

-- Angka dengan pemisah ribuan (mis. 12500 jadi 12,500)
local function fmtNum(n)
	local s = tostring(math.floor(n))
	local r = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	return (r:gsub("^,", ""))
end

-- Sisa waktu dan jam selesai (jam lokal perangkat)
local function etaLine(remaining)
	remaining = math.max(0, remaining)
	return ("sisa %s | selesai %s"):format(
		fmtTime(remaining), os.date("%H:%M:%S", os.time() + math.ceil(remaining)))
end

-- ===== Auto Redeem =====
local running = false
local runId = 0

-- Tiket Keberuntungan (merah) yang didapat sejak script dijalankan; dihitung dari pesan "+N Tiket Keberuntungan"
local tkGained = 0
-- Shard (Potongan Asal) yang didapat sejak script dijalankan; dihitung dari pesan hadiah "Received ... Potongan Asal"
local shardGained = 0

function redeemHandler(b)
	if running then
		running = false
		b.Text = "Auto Redeem"; paint(b, false)
		setStatus("Dihentikan (kemajuan tersimpan)")
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

	local okHook, errHook = pcall(hookAll)
	if not okHook then
		setStatus("hookAll error: " .. tostring(errHook))
	end
	runId += 1
	local myId = runId
	running = true
	b.Text = "Stop"; paint(b, true)

	local function alive()
		return running and runId == myId
	end

	task.spawn(function()
		local done = sessionDone
		local pending = {}
		for _, code in ipairs(CODES) do
			if not done[code] then table.insert(pending, code) end
		end
		local skipped = #CODES - #pending
		if #pending == 0 then
			setStatus(("Semua %d kode sudah dipakai atau tidak valid. Tidak ada yang perlu ditebus."):format(#CODES))
			if runId == myId then
				running = false
				b.Text = "Auto Redeem"; paint(b, false)
			end
			return
		end

		setStatus(("Akun %s: %d sudah, %d lanjut\n%s"):format(lp.Name, skipped, #pending, fileInfo()))
		task.wait(1.5)

		local nOk, nBad, nFail = 0, 0, 0
		local tk0 = tkGained
		local sh0 = shardGained
		local lastAccepted = -1e9
		local learnedCd = START_CD -- jeda antar kode yang sedang dipakai
		local cdLo, cdHi = 0, nil  -- lo: jeda yang gagal (percobaan pertama), hi: jeda yang berhasil
		local locked = false
		local safety = SAFETY
		local acceptedCount = 0
		local function nextCd()
			local v
			if cdHi then
				if (cdHi - cdLo) <= CD_TOL then
					locked = true
					v = cdHi + safety
				else
					locked = false
					v = (cdLo + cdHi) / 2
				end
			else
				locked = false
				v = math.max(learnedCd, cdLo) * 1.5
			end
			return math.min(MAX_CD, math.max(MIN_CD, v))
		end
		local function bracketText()
			return ("[%.1f-%s]"):format(cdLo, cdHi and ("%.1f"):format(cdHi) or "?")
		end
		local total = #pending
		local runStart = os.clock()
		local cycles = {} -- waktu nyata antar kode yang diterima (rata-rata 6 terakhir)

		local codeStart = os.clock()
		local function avgCycle()
			if #cycles == 0 then return EST_START end
			local sum = 0
			for _, c in ipairs(cycles) do sum += c end
			return sum / #cycles
		end

		local function remainingFrom(idx)
			local cur = math.max(1, avgCycle() - (os.clock() - codeStart))
			return cur + (total - idx) * avgCycle()
		end

		for idx, code in ipairs(pending) do
			if not alive() then break end
			codeStart = os.clock()

			-- Tunggu jeda sampai boleh kirim (dihitung dari kode terakhir yang diterima)
			while alive() do
				local left = learnedCd - (os.clock() - lastAccepted)
				if left <= 0 then break end
				setStatus(("%d/%d jeda %.1fs %s %s\n%s"):format(
					idx, total, left, locked and "stabil" or "mencari", bracketText(),
					etaLine(left + remainingFrom(idx))))
				task.wait(math.min(left, 0.25))
			end

			local result
			local tries = 0
			while alive() do
				tries += 1
				if not box.Parent or not btn.Parent then
					box, btn = findUiDirect()
					if not box or not btn then
						setStatus("Jendela Kode tertutup, dihentikan")
						running = false
						break
					end
				end
				box.Text = code
				task.wait()
				local pressedAt = os.clock()
				if not press(btn) then
					setStatus("Gagal menekan tombol")
					running = false
					break
				end
				local res, resText = waitResult(pressedAt)

				if res == "cooldown" then
					if tries >= MAX_TRIES then
						result = "fail"
						break
					end
					local sentAfter = (lastAccepted > 0) and (pressedAt - lastAccepted) or nil
					-- Hanya percobaan pertama yang dipakai mengukur batas bawah
					if sentAfter and tries == 1 then
						cdLo = math.max(cdLo, sentAfter)
					end
					-- Batas atas lama ternyata tidak cukup (server lebih ketat): buang, longgarkan, cari ulang
					if cdHi and sentAfter and sentAfter >= cdHi then
						cdHi = nil
						cdLo = math.max(cdLo, sentAfter)
						safety = math.min(0.6, safety + 0.1)
					end
					-- Target kirim ulang (sejak kode terakhir diterima): batas atas kalau ada, kalau belum naik 1.5x
					local target
					local secs = resText and tonumber(resText:match("(%d+%.?%d*)"))
					if secs and secs > 0 and secs <= MAX_CD and sentAfter then
						target = sentAfter + secs + 0.1
					elseif cdHi then
						target = cdHi + safety
					else
						target = math.min(MAX_CD, math.max(learnedCd, sentAfter or 0) * 1.5)
						learnedCd = target
					end
					local elapsed = sentAfter and (os.clock() - lastAccepted) or 0
					local waitFor = math.max(RETRY_DELAY, target - elapsed)
					setStatus(("%d/%d %s: mohon tunggu, ulangi %.1fs %s\n%s"):format(
						idx, total, code, waitFor, bracketText(), etaLine(remainingFrom(idx))))
					task.wait(waitFor)
				else
					-- Diterima server
					if lastAccepted > 0 then
						local sent = pressedAt - lastAccepted
						if tries == 1 then
							-- percobaan pertama berhasil = jeda ini terbukti cukup (batas atas bersih)
							if not cdHi or sent < cdHi then cdHi = sent end
							if cdLo >= cdHi then
								cdLo = math.max(0, cdHi - 2 * CD_TOL) -- batas bawah lama tidak cocok, longgarkan
							end
						elseif not cdHi then
							-- belum punya batas atas: pakai waktu berhasil setelah kirim ulang sebagai batas kasar
							cdHi = sent
							if cdLo >= cdHi then cdLo = 0 end
						end
						acceptedCount += 1
						learnedCd = nextCd()
						-- Terkunci: tiap beberapa kode, tes jeda sedikit lebih pendek supaya tidak kelamaan
						if locked and cdHi and acceptedCount % PROBE_EVERY == 0 then
							learnedCd = math.max(MIN_CD, cdHi - math.max(0.3, cdHi * 0.1))
						end
						table.insert(cycles, sent)
						if #cycles > 6 then table.remove(cycles, 1) end
					end
					lastAccepted = pressedAt
					result = res or "unknown"
					break
				end
			end

			if not alive() and not result then break end

			local nextEta = etaLine((total - idx) * avgCycle())
			if result == "ok" then
				nOk += 1; done[code] = true
				saved[code] = "ok"; saveToFile()
				setStatus(("%d/%d %s: Ditebus!\n%s"):format(idx, total, code, nextEta))
			elseif result == "used" then
				nBad += 1; done[code] = true
				saved[code] = "used"; saveToFile()
				setStatus(("%d/%d %s: Sudah digunakan\n%s"):format(idx, total, code, nextEta))
			elseif result == "notfound" then
				nBad += 1; done[code] = true
				saved[code] = "notfound"; saveToFile()
				setStatus(("%d/%d %s: Tidak valid\n%s"):format(idx, total, code, nextEta))
			elseif result == "unknown" then
				nFail += 1; done[code] = true
				saved[code] = "sent"; saveToFile()
				setStatus(("%d/%d %s: terkirim (tak terbaca)\n%s"):format(idx, total, code, nextEta))
			else
				nFail += 1 -- gagal karena cooldown terus, tidak diingat supaya dicoba lagi nanti
				setStatus(("%d/%d %s: gagal (cooldown)\n%s"):format(idx, total, code, nextEta))
			end
		end

		if alive() then
			setStatus(("Selesai %s (durasi %s)\nDitebus %d | Invalid %d | Gagal %d | Lewat %d\nTiket +%d | Shard +%s"):format(
				os.date("%H:%M:%S"), fmtTime(os.clock() - runStart), nOk, nBad, nFail, skipped,
				tkGained - tk0, fmtNum(shardGained - sh0)))
		end
		if runId == myId then
			running = false
			b.Text = "Auto Redeem"; paint(b, false)
		end
	end)
end

-- ===== Tiket Keberuntungan =====
-- Sumber angka dicari berurutan:
--  1) jalur label yang pernah dipilih lewat tombol "Set" (tersimpan di file per akun)
--  2) data pemain (IntValue/NumberValue/atribut) yang namanya memuat "ticket/tiket" DAN "luck"
-- Kalau dua-duanya tidak ada, tekan "Set" lalu ketuk angka tiket di layar game.
local tkGet
local tkPicking = false

local function numOf(t)
	if type(t) ~= "string" then return nil end
	if not t:match("^[%d,%.%s]+$") or not t:match("%d") then return nil end
	return tonumber((t:gsub("[,%.%s]", "")))
end

local function pathNames(o)
	local names = {}
	local cur = o
	local pg = lp.PlayerGui
	while cur and cur ~= pg do
		table.insert(names, 1, cur.Name)
		cur = cur.Parent
	end
	if cur ~= pg then return nil end
	return names
end

local function resolvePath(names)
	local cur = lp.PlayerGui
	for _, n in ipairs(names) do
		cur = cur and cur:FindFirstChild(n)
		if not cur then return nil end
	end
	return cur
end

local function labelGetter(lbl, names)
	local cur = lbl
	return function()
		if not cur or not cur.Parent then
			cur = names and resolvePath(names) or nil
		end
		if not cur then return nil end
		local ok, t = pcall(function() return cur.Text end)
		if ok then return numOf(t) end
		return nil
	end
end

local function tkMatchName(str)
	local l = str:lower()
	return (l:find("ticket", 1, true) ~= nil or l:find("tiket", 1, true) ~= nil)
		and l:find("luck", 1, true) ~= nil
end

local function scanData()
	for k, v in pairs(lp:GetAttributes()) do
		if type(v) == "number" and tkMatchName(k) then
			return function() return lp:GetAttribute(k) end
		end
	end
	for _, d in ipairs(lp:GetDescendants()) do
		if d:IsA("IntValue") or d:IsA("NumberValue") then
			if tkMatchName(d.Name .. " " .. (d.Parent and d.Parent.Name or "")) then
				return function() return d.Value end
			end
		elseif d:IsA("Folder") or d:IsA("Configuration") then
			for k, v in pairs(d:GetAttributes()) do
				if type(v) == "number" and tkMatchName(k) then
					return function() return d:GetAttribute(k) end
				end
			end
		end
	end
	return nil
end

-- Pilih angka tiket dengan mengetuk layar: ambil label berangka paling atas di titik ketukan
local function pickAt(x, y)
	local ok, objs = pcall(function() return lp.PlayerGui:GetGuiObjectsAtPosition(x, y) end)
	if not ok then return nil end
	for _, o in ipairs(objs) do
		if (o:IsA("TextLabel") or o:IsA("TextButton")) and numOf(o.Text) then return o end
	end
end

function tkCalibrate()
	if tkPicking then
		tkPicking = false
		setStatus("Pilih tiket dibatalkan")
		return
	end
	tkPicking = true
	setStatus("Buka Season > Roda Keberuntungan, lalu ketuk ANGKA tiket keberuntungan di layar. Tekan Set lagi untuk batal")
end

table.insert(conns, UIS.InputBegan:Connect(function(input)
	if not tkPicking then return end
	if input.UserInputType ~= Enum.UserInputType.Touch
		and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
		return
	end
	local pos = input.Position
	-- abaikan ketukan di dalam jendela hub sendiri
	local fp, fs = frame.AbsolutePosition, frame.AbsoluteSize
	local inset = GuiService:GetGuiInset()
	if frame.Visible and pos.X >= fp.X and pos.X <= fp.X + fs.X
		and pos.Y >= fp.Y - 2 and pos.Y <= fp.Y + fs.Y + inset.Y + 2 then
		return
	end
	local lbl = pickAt(pos.X, pos.Y) or pickAt(pos.X, pos.Y + inset.Y) or pickAt(pos.X, pos.Y - inset.Y)
	if not lbl then
		setStatus("Tidak ada angka di titik itu, ketuk tepat di angka tiketnya")
		return
	end
	local names = pathNames(lbl)
	if not names then
		setStatus("Label itu di luar PlayerGui, coba angka lain")
		return
	end
	tkPicking = false
	acc.tk = names
	saveToFile()
	tkGet = labelGetter(lbl, names)
	local shown = table.concat(names, ".")
	if #shown > 48 then shown = "..." .. shown:sub(-45) end
	setStatus(("Tiket terpasang: %s\nIsi sekarang: %s"):format(shown, lbl.Text))
end))

-- Muat pilihan lama kalau ada, kalau tidak coba cari otomatis di data pemain
do
	if type(acc.tk) == "table" and #acc.tk > 0 then
		tkGet = labelGetter(resolvePath(acc.tk), acc.tk)
	else
		local ok, g = pcall(scanData)
		if ok and g then tkGet = g end
	end
end

-- Pantau pesan hadiah "+N Tiket Keberuntungan" dan "+N Potongan Asal" (muncul saat redeem kode atau spin) lalu jumlahkan
local tkSeen = setmetatable({}, { __mode = "k" })
local shSeen = setmetatable({}, { __mode = "k" })
local tkWatched = setmetatable({}, { __mode = "k" })

local function rewardWord(t)
	local tl = t:lower()
	return tl:find("received", 1, true) ~= nil
		or tl:find("diterima", 1, true) ~= nil
		or tl:find("menerima", 1, true) ~= nil
end

-- Hanya hitung kalau label ada di notifikasi hadiah (ada kata "Received" di kotak yang sama)
local function inToast(v)
	if rewardWord(v.Text) then return true end
	local cur = v.Parent
	for _ = 1, 3 do
		if not cur or cur == lp.PlayerGui then break end
		for _, d in ipairs(cur:GetDescendants()) do
			if d:IsA("TextLabel") and d ~= v and d.Text ~= "" and rewardWord(d.Text) then return true end
		end
		cur = cur.Parent
	end
	return false
end

local function tkCommit(v, txt, n)
	local rec = tkSeen[v]
	local now = os.clock()
	-- Text dan Visible bisa menyala berurutan untuk notif yang sama: hitung sekali
	if rec and rec.text == txt and now - rec.t < 0.6 then
		rec.t = now
		return
	end
	tkSeen[v] = { text = txt, t = now }
	tkGained += n
end

local function tkCount(v)
	local txt = v.Text
	if txt == "" then return end
	local tl = txt:lower()
	local at = tl:find("tiket keberuntungan", 1, true) or tl:find("lucky ticket", 1, true)
	if not at then return end
	local n = tonumber(tl:sub(1, at - 1):match("(%d+)[^%d]*$"))
	if not n or n <= 0 then return end
	if inToast(v) then
		tkCommit(v, txt, n)
	else
		-- kotak notifikasi kadang belum lengkap saat teks pertama muncul: cek ulang sebentar lagi
		task.delay(0.4, function()
			if v.Parent and v.Text == txt and inToast(v) then
				tkCommit(v, txt, n)
			end
		end)
	end
end

-- Shard (Potongan Asal): sama seperti tiket, hanya notifikasi hadiah ("Received") yang dihitung,
-- jadi tulisan "Potongan Asal x250" di roda atau menu tidak ikut terhitung
local SHARD_NAMES = { "pecahan asal", "potongan asal", "origin shard" }

local function shCommit(v, txt, n)
	local rec = shSeen[v]
	local now = os.clock()
	if rec and rec.text == txt and now - rec.t < 0.6 then
		rec.t = now
		return
	end
	shSeen[v] = { text = txt, t = now }
	shardGained += n
end

local function shCount(v)
	local txt = v.Text
	if txt == "" then return end
	local tl = (txt:lower():gsub("(%d),(%d)", "%1%2")) -- 1,250 jadi 1250
	local at, len
	for _, name in ipairs(SHARD_NAMES) do
		local a = tl:find(name, 1, true)
		if a and (not at or a < at) then at, len = a, #name end
	end
	if not at then return end
	-- angka bisa di depan ("+250 Potongan Asal") atau di belakang ("Potongan Asal x250")
	local n = tonumber(tl:sub(1, at - 1):match("(%d+)[^%d]*$"))
		or tonumber(tl:sub(at + len):match("^[^%d]*(%d+)"))
	if not n or n <= 0 then return end
	if inToast(v) then
		shCommit(v, txt, n)
	else
		task.delay(0.4, function()
			if v.Parent and v.Text == txt and inToast(v) then
				shCommit(v, txt, n)
			end
		end)
	end
end

local function rewardCount(v)
	tkCount(v)
	shCount(v)
end

local function tkWatch(v, fresh)
	if not v:IsA("TextLabel") or tkWatched[v] or v:IsDescendantOf(gui) then return end
	tkWatched[v] = true
	table.insert(conns, v:GetPropertyChangedSignal("Text"):Connect(function() rewardCount(v) end))
	table.insert(conns, v:GetPropertyChangedSignal("Visible"):Connect(function()
		if v.Visible then
			tkCount(v)
			-- kotak notifikasi dipakai ulang: tunggu sebentar supaya teks lama tidak ikut terhitung
			task.delay(0.15, function()
				if v.Parent and v.Visible then shCount(v) end
			end)
		end
	end))
	if fresh then rewardCount(v) end
end

for _, v in ipairs(lp.PlayerGui:GetDescendants()) do tkWatch(v, false) end
table.insert(conns, lp.PlayerGui.DescendantAdded:Connect(function(v) tkWatch(v, true) end))

task.spawn(function()
	while gui.Parent do
		local v
		if tkGet then
			local ok, val = pcall(tkGet)
			if ok then v = val end
		end
		if v then
			ticketLabel.Text = ("Tiket %s (+%d didapat)"):format(tostring(v), tkGained)
		else
			ticketLabel.Text = ("Tiket didapat: +%d"):format(tkGained)
		end
		shardLabel.Text = ("Shard: +%s"):format(fmtNum(shardGained))
		task.wait(0.5)
	end
end)

-- ===== Auto Spin x10 (Season > Roda Keberuntungan) =====
-- Tombol dicari lewat tulisannya ("Putar x10"), jadi menu harus terbuka dan tombolnya terlihat.
-- Hasil putaran dideteksi dari pesan "Received ..." yang muncul setelah tombol ditekan.
local spinning = false
local spinRunId = 0
local lastReward = { t = 0, n = 0 }
local spinHookedSet = setmetatable({}, { __mode = "k" })
local spinHookDone = false

local function isRewardText(t)
	local tl = t:lower()
	return tl:find("received", 1, true) ~= nil
		or tl:find("diterima", 1, true) ~= nil
		or tl:find("menerima", 1, true) ~= nil
end

local function spinHook(v)
	if not v:IsA("TextLabel") or spinHookedSet[v] or v:IsDescendantOf(gui) then return end
	spinHookedSet[v] = true
	local function chk()
		if v.Text ~= "" and isRewardText(v.Text) then
			lastReward.t = os.clock()
			lastReward.n += 1
		end
	end
	table.insert(conns, v:GetPropertyChangedSignal("Text"):Connect(chk))
	table.insert(conns, v:GetPropertyChangedSignal("Visible"):Connect(function()
		if v.Visible then chk() end
	end))
	chk()
end

local function spinHookAll()
	if spinHookDone then return end
	spinHookDone = true
	for _, v in ipairs(lp.PlayerGui:GetDescendants()) do spinHook(v) end
	table.insert(conns, lp.PlayerGui.DescendantAdded:Connect(spinHook))
end

local function findSpinButton(want)
	want = want or 10
	local pg = lp.PlayerGui
	for _, d in ipairs(pg:GetDescendants()) do
		if (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Text ~= "" and not d:IsDescendantOf(gui) then
			local tl = d.Text:lower()
			local n = tl:match("putar%D*(%d+)") or tl:match("spin%D*(%d+)")
			if n and tonumber(n) == want and isVisible(d) then
				local obj = d
				while obj and obj ~= pg and not obj:IsA("GuiButton") do obj = obj.Parent end
				if not obj or obj == pg then obj = d end
				return obj
			end
		end
	end
end

local function shortPath(o)
	local full = o:GetFullName()
	local cut = full:find("PlayerGui.", 1, true)
	if cut then full = full:sub(cut + 10) end
	if #full > 48 then full = "..." .. full:sub(-45) end
	return full
end

function spinHandler(b)
	if spinning then
		spinning = false
		b.Text = "Auto Spin x10"; paint(b, false)
		setStatus("Auto Spin dihentikan")
		return
	end

	local target = findSpinButton(10)
	if not target then
		setStatus("Buka Season > Roda Keberuntungan sampai tombol 'Putar x10' terlihat, lalu tekan lagi")
		return
	end

	local okH, errH = pcall(spinHookAll)
	if not okH then setStatus("spinHook error: " .. tostring(errH)) end
	spinRunId += 1
	local myId = spinRunId
	spinning = true
	b.Text = "Stop Spin"; paint(b, true)
	setStatus("Tombol ketemu:\n" .. shortPath(target))
	task.wait(1)

	task.spawn(function()
		local function alive()
			return spinning and spinRunId == myId
		end
		local sh0 = shardGained -- shard yang didapat selama Auto Spin ini
		local n, n1, misses = 0, 0, 0
		local reason = "Selesai"

		local function shardTxt()
			return ("Shard +%s"):format(fmtNum(shardGained - sh0))
		end
		-- "Sisa tiket N | " kalau jumlah tiket terbaca (lewat tombol Set)
		local function leftInfo()
			if tkGet then
				local okT, tkv = pcall(tkGet)
				if okT and tkv then return ("Sisa tiket %d | "):format(math.floor(tkv)) end
			end
			return ""
		end

		-- Tekan satu tombol putar, tunggu pesan hadiah, lalu tunggu animasi selesai.
		-- Hasil: ada hadiah atau tidak, dan apakah penekanan tombol gagal.
		local function spinOnce(btnObj)
			local pressedAt = os.clock()
			if not press(btnObj) then return false, true end
			local got = false
			local t0 = os.clock()
			while alive() and os.clock() - t0 < SPIN_REWARD_TIMEOUT do
				task.wait(0.1)
				if lastReward.t >= pressedAt then got = true; break end
			end
			if got then
				-- Tunggu animasi selesai: tidak ada hadiah baru selama SPIN_QUIET
				local t1 = os.clock()
				while alive() and os.clock() - lastReward.t < SPIN_QUIET and os.clock() - t1 < SPIN_MAX_ANIM do
					task.wait(0.1)
				end
			end
			return got, false
		end

		-- Tahap 1: Putar x10 terus sampai tiket kurang dari 10
		local goX1 = false
		while alive() do
			if SPIN_LIMIT > 0 and n >= SPIN_LIMIT then
				reason = ("Selesai: batas %d x Putar x10"):format(SPIN_LIMIT)
				break
			end
			-- Kalau jumlah tiket terbaca dan kurang dari 10, lanjut ke tahap Putar x1
			if tkGet then
				local okT, tkv = pcall(tkGet)
				if okT and tkv and tkv < 10 then
					goX1 = true
					break
				end
			end
			if not target.Parent or not isVisible(target) then
				target = findSpinButton(10)
				if not target then
					reason = "Menu spin tertutup, dihentikan"
					break
				end
			end

			local got, pressFail = spinOnce(target)
			if pressFail then
				reason = "Gagal menekan tombol spin"
				break
			end
			if not alive() then break end

			if got then
				n += 1
				misses = 0
				setStatus(("Putar x10 ke-%d selesai (%d putaran)\n%s%s"):format(n, n * 10, leftInfo(), shardTxt()))
				task.wait(SPIN_GAP)
			else
				misses += 1
				if misses >= SPIN_MISS_STOP then
					-- Tiket tidak terbaca dan x10 tidak jalan lagi: anggap sisa tiket kurang dari 10
					goX1 = true
					break
				end
				setStatus(("Tidak ada hadiah terdeteksi (%d/%d), coba lagi\n%s"):format(misses, SPIN_MISS_STOP, shardTxt()))
				task.wait(1.5)
			end
		end

		-- Tahap 2: sisa tiket (kurang dari 10) dihabiskan dengan Putar x1
		if goX1 and SPIN_REMAINDER and alive() then
			local t1 = findSpinButton(1)
			if not t1 then
				reason = "Tombol 'Putar x1' tidak ketemu, sisa tiket belum terpakai"
			else
				reason = "Selesai, tiket sudah habis dipakai"
				local m1 = 0
				while alive() do
					if tkGet then
						local okT, tkv = pcall(tkGet)
						if okT and tkv and tkv < 1 then break end
					end
					if not t1.Parent or not isVisible(t1) then
						t1 = findSpinButton(1)
						if not t1 then
							reason = "Menu spin tertutup, dihentikan"
							break
						end
					end

					local got, pressFail = spinOnce(t1)
					if pressFail then
						reason = "Gagal menekan tombol Putar x1"
						break
					end
					if not alive() then break end

					if got then
						n1 += 1
						m1 = 0
						setStatus(("Putar x1 ke-%d selesai\n%s%s"):format(n1, leftInfo(), shardTxt()))
						task.wait(SPIN_GAP)
					else
						m1 += 1
						if m1 >= SPIN_X1_MISS_STOP then break end
						setStatus(("Putar x1: tidak ada hadiah (%d/%d)\n%s"):format(m1, SPIN_X1_MISS_STOP, shardTxt()))
						task.wait(1.5)
					end
				end
			end
		elseif goX1 and alive() then
			reason = "Selesai (tiket kurang dari 10)"
		end

		if alive() then
			setStatus(("%s\nx10: %d | x1: %d | %s"):format(reason, n, n1, shardTxt()))
		end
		if spinRunId == myId then
			spinning = false
			b.Text = "Auto Spin x10"; paint(b, false)
		end
	end)
end

-- Status awal: tampilkan akun dan kemajuan
do
	local doneCount = 0
	for _, c in ipairs(CODES) do
		if sessionDone[c] then doneCount += 1 end
	end
	if isNewAccount and doneCount == 0 then
		setStatus(("Akun %s: baru, %d kode\n%s"):format(lp.Name, #CODES, fileInfo()))
	else
		setStatus(("Akun %s: %d sudah, %d lanjut\n%s"):format(lp.Name, doneCount, #CODES - doneCount, fileInfo()))
	end
end

-- Mulai otomatis: begitu jendela Kode terbuka, semua kode yang belum ditebus langsung diproses
if AUTO_START then
	task.spawn(function()
		while gui.Parent and not running do
			local box, btn, err = findUiDirect()
			if not err and box and btn then
				redeemHandler(redeemBtn)
				return
			end
			task.wait(1)
		end
	end)
end

-- ===== Minimize dan tutup =====
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

mini.Activated:Connect(function()
	bubble.Position = frame.Position
	frame.Visible = false
	bubble.Visible = true
end)

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
					expand()
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
				startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y
			)
		end
	end
end)

close.Activated:Connect(function()
	running = false
	spinning = false
	dcOn = false
	if afkConn then afkConn:Disconnect() end
	for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
	gui:Destroy()
end)
