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
	"CA2", "SIGURIH",	"SamudraSelatan", "Joy_Blox", "minamee", "Vinxies",
	"DEYMMM", "ChakGIM", "fantasmo", "Airkub",
	"Leyyy", "HaruU4you", "EvLCrys", "AbuelaCalcot",
	"SUB2MARKX4G",
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
			rec[
