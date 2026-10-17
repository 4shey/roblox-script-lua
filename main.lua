-- File: main.lua (All-in-One Loader & Features)
-- Dapat dijalankan langsung via: loadstring(game:HttpGet("https://raw.githubusercontent.com/4shey/roblox-script-lua/refs/heads/main/main.lua"))()

local G = (typeof(getgenv) == "function") and getgenv() or {}

if G.JMK48_HUB_RUNNING then
    warn("[Jmk48 Hub] Skrip sudah berjalan, dilewati.")
    return
end
G.JMK48_HUB_RUNNING = true

-- Load Rayfield UI dengan aman
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu"))()
end)

if not success or not Rayfield then
    warn("[Jmk48 Hub] Gagal memuat Rayfield UI!")
    G.JMK48_HUB_RUNNING = nil
    return
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local DEFAULT_JUMP = 50
local DEFAULT_SPEED = 16

local State = {
    JumpOn = false,
    SpeedOn = false,
    JumpPower = 100,
    WalkSpeed = 50,
}

local function getHumanoid()
    local character = LocalPlayer and LocalPlayer.Character
    if not character then
        return nil
    end
    return character:FindFirstChildOfClass("Humanoid")
end

local function applyState()
    local humanoid = getHumanoid()
    if not humanoid then
        return false
    end

    if State.JumpOn then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = State.JumpPower
    else
        humanoid.JumpPower = DEFAULT_JUMP
    end

    if State.SpeedOn then
        humanoid.WalkSpeed = State.WalkSpeed
    else
        humanoid.WalkSpeed = DEFAULT_SPEED
    end

    return true
end

-- Membuat Window UI
local Window = Rayfield:CreateWindow({
    Name = "Jmk48 Hub | No-Key Menu",
    LoadingTitle = "Memuat Jmk48 Hub...",
    LoadingSubtitle = "Selamat Bermain!",
    Theme = "Default",
})

local MainTab = Window:CreateTab("Fitur Utama", 4483362458)
MainTab:CreateSection("Karakter")

MainTab:CreateToggle({
    Name = "Lompatan Tinggi (Super Jump)",
    CurrentValue = State.JumpOn,
    Callback = function(value)
        State.JumpOn = value == true
        applyState()
    end,
})

MainTab:CreateSlider({
    Name = "Tinggi Lompatan",
    Range = { 50, 500 },
    Increment = 10,
    CurrentValue = State.JumpPower,
    Callback = function(value)
        State.JumpPower = tonumber(value) or State.JumpPower
        if State.JumpOn then
            applyState()
        end
    end,
})

MainTab:CreateToggle({
    Name = "Lari Cepat (Speed Hack)",
    CurrentValue = State.SpeedOn,
    Callback = function(value)
        State.SpeedOn = value == true
        applyState()
    end,
})

MainTab:CreateSlider({
    Name = "Kecepatan Lari",
    Range = { 16, 200 },
    Increment = 5,
    CurrentValue = State.WalkSpeed,
    Callback = function(value)
        State.WalkSpeed = tonumber(value) or State.WalkSpeed
        if State.SpeedOn then
            applyState()
        end
    end,
})

MainTab:CreateButton({
    Name = "Reset ke Normal",
    Callback = function()
        State.JumpOn = false
        State.SpeedOn = false
        State.JumpPower = 100
        State.WalkSpeed = 50
        applyState()
        Rayfield:Notify({
            Title = "Direset",
            Content = "Kecepatan & lompatan kembali normal.",
            Duration = 3,
        })
    end,
})

MainTab:CreateParagraph({
    Title = "Status",
    Content = "Fitur tetap aktif setelah respawn. Nonaktifkan toggle untuk kembali normal.",
})

-- Event saat karakter mati/respawn agar fitur tidak hilang
LocalPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if humanoid then
        task.wait(0.2)
        applyState()
    end
end)

if LocalPlayer.Character then
    applyState()
end

Rayfield:Notify({
    Title = "Berhasil Dimuat!",
    Content = "Jmk48 Hub siap digunakan.",
    Duration = 4,
})