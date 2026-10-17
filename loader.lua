-- File: loader.lua (Tanpa Panda Auth + Rayfield UI)
-- Perbaikan: Sistem kunci dihapus, langsung memuat Rayfield UI dan fitur utama.

local Config = {
    MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/4shey/roblox-script-lua/refs/heads/main/fitur_aman.lua",
}

local G = (typeof(getgenv) == "function") and getgenv() or {}

if G.JMK48_LOADER_RUNNING then
    warn("[Jmk48] Loader sudah berjalan, dilewati.")
    return
end
G.JMK48_LOADER_RUNNING = true

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

local function notify(title, content, duration)
    pcall(function()
        Rayfield:Notify({
            Title = title,
            Content = content,
            Duration = duration or 4,
        })
    end)
end

local Window = Rayfield:CreateWindow({
    Name = "Jmk48 Hub | No-Key System",
    LoadingTitle = "Memuat Jmk48 Hub...",
    LoadingSubtitle = "Menyiapkan fitur aman...",
    Theme = "Default",
})

local MainTab = Window:CreateTab("Beranda", 4483362458)

MainTab:CreateParagraph({
    Title = "Status Loader",
    Content = "Sistem verifikasi kunci telah dinonaktifkan. Anda dapat langsung meluncurkan menu fitur utama.",
})

MainTab:CreateButton({
    Name = "Muat Fitur Utama",
    Callback = function()
        notify("Memuat...", "Mengunduh skrip fitur aman...", 3)
        task.wait(0.5)

        pcall(function()
            Rayfield:Destroy()
        end)

        local source, err = fetchRemote(Config.MAIN_SCRIPT_URL)
        if not source then
            G.JMK48_LOADER_RUNNING = nil
            warn("[Jmk48] Gagal mengunduh skrip utama: " .. tostring(err))
            return
        end

        local ok, runErr = pcall(function()
            loadstring(source)()
        end)
        if not ok then
            G.JMK48_LOADER_RUNNING = nil
            warn("[Jmk48] Skrip utama error: " .. tostring(runErr))
        end
    end,
})

notify("Berhasil Dimuat!", "Silakan klik tombol Muat Fitur Utama di menu.", 4)