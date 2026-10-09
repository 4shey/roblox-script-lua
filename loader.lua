-- File: loader.lua (Panda Auth v3 + Rayfield UI)
-- Perbaikan: link kunci salah sambung, validasi tanpa pcall, anti-spam,
--             pemuatan remote aman, proteksi eksekusi ganda.

local Config = {
	API_KEY_PANDA = "45e1e8b3-f088-4a74-ae89-59fa6c0ea56d",
	IDENTIFIER_LAYANAN = "jmk48",
	KEY_PAGE_BASE = "https://pandauth.com/",
	MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/4shey/roblox-script-lua/refs/heads/main/fitur_aman.lua",
	DEBOUNCE = 1.5,
}

local G = (typeof(getgenv) == "function") and getgenv() or {}

if G.JMK48_LOADER_RUNNING then
	warn("[Jmk48] Loader sudah berjalan, dilewati.")
	return
end
G.JMK48_LOADER_RUNNING = true

local LINK_GET_KEY = Config.KEY_PAGE_BASE .. Config.IDENTIFIER_LAYANAN

local function bail(reason)
	G.JMK48_LOADER_RUNNING = nil
	warn("[Jmk48] " .. tostring(reason))
end

local function fetchRemote(url)
	local ok, result = pcall(function()
		return game:HttpGet(url)
	end)
	if not ok or type(result) ~= "string" or #result < 10 then
		return nil, tostring(result)
	end
	return result
end

local function loadModule(url, label)
	local source, err = fetchRemote(url)
	if not source then
		return nil, label .. " gagal diunduh: " .. tostring(err)
	end
	local ok, mod = pcall(loadstring, source)
	if not ok then
		return nil, label .. " gagal dikompilasi: " .. tostring(mod)
	end
	if type(mod) ~= "function" then
		return nil, label .. " tidak mengembalikan modul."
	end
	local okRun, value = pcall(mod)
	if not okRun or value == nil then
		return nil, label .. " gagal dijalankan: " .. tostring(value)
	end
	return value
end

local Rayfield, errRay = loadModule("https://sirius.menu", "Rayfield UI")
if not Rayfield then
	bail(errRay)
	return
end

local PandaAuth, errAuth = loadModule("https://pandauth.com", "Panda Auth v3")
if not PandaAuth then
	bail(errAuth)
	return
end

local function notify(title, content, duration)
	pcall(function()
		Rayfield:Notify({
			Title = title,
			Content = content,
			Duration = duration or 4,
		})
	end)
end

local function copyToClipboard(text)
	local ok = pcall(setclipboard, text)
	if not ok then
		ok = pcall(function()
			setclipboard(text)
		end)
	end
	return ok
end

local function normalizeKey(text)
	if type(text) ~= "string" then
		return ""
	end
	return text:match("^%s*(.-)%s*$") or ""
end

local function validateKey(key)
	key = normalizeKey(key)
	if key == "" then
		return false, "Kunci masih kosong."
	end

	local ok, result = pcall(function()
		return PandaAuth:ValidateKey(Config.API_KEY_PANDA, key)
	end)
	if not ok then
		return false, "Server verifikasi tidak merespons. Coba lagi."
	end

	if result == true then
		return true, key
	end
	if type(result) == "table" and (result.success == true or result.valid == true) then
		return true, key
	end
	if type(result) == "string" then
		return false, result
	end
	return false, "Kunci salah, expired, atau sudah terkunci di perangkat lain!"
end

local Window = Rayfield:CreateWindow({
	Name = "Jmk48 Hub | HWID Lock System",
	LoadingTitle = "Menghubungkan ke Server Panda...",
	LoadingSubtitle = "Verifikasi kunci untuk membuka menu.",
	Theme = "Default",
})

local KeyTab = Window:CreateTab("Verifikasi", 4483362458)

KeyTab:CreateButton({
	Name = "Ambil Kunci (Get Key)",
	Callback = function()
		if copyToClipboard(LINK_GET_KEY) then
			notify("Tautan Tersalin!", "Paste di browser Anda: " .. LINK_GET_KEY, 6)
		else
			notify("Salin Manual", LINK_GET_KEY, 8)
		end
	end,
})

local busy = false
local finished = false

local function runMainScript()
	if finished then
		return
	end
	finished = true

	notify("Akses Diterima!", "Membuka menu fitur...", 3)
	task.wait(1)

	pcall(function()
		Rayfield:Destroy()
	end)

	local source, err = fetchRemote(Config.MAIN_SCRIPT_URL)
	if not source then
		G.JMK48_LOADER_RUNNING = nil
		finished = false
		warn("[Jmk48] Gagal mengunduh skrip utama: " .. tostring(err))
		return
	end

	local ok, runErr = pcall(function()
		loadstring(source)()
	end)
	if not ok then
		G.JMK48_LOADER_RUNNING = nil
		finished = false
		warn("[Jmk48] Skrip utama error: " .. tostring(runErr))
	end
end

KeyTab:CreateInput({
	Name = "Masukkan Kunci",
	PlaceholderText = "Tempel kunci di sini...",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
		if busy or finished then
			return
		end

		local valid, message = validateKey(Text)
		if valid then
			G.JMK48_VALIDATED_KEY = message
			runMainScript()
			return
		end

		notify("Verifikasi Gagal!", message, 4)

		busy = true
		task.delay(Config.DEBOUNCE, function()
			busy = false
		end)
	end,
})

if type(G.JMK48_VALIDATED_KEY) == "string" and G.JMK48_VALIDATED_KEY ~= "" then
	notify("Kunci Tersimpan", "Memuat ulang menu fitur...", 3)
	task.delay(1, runMainScript)
end
