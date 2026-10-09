-- File: fitur_asli.lua
-- Menu utama setelah kunci terverifikasi.
-- Perbaikan: akses Humanoid aman (tidak error saat respawn), toggle + slider,
--             auto-apply saat karakter baru spawn, tombol reset.

local G = (typeof(getgenv) == "function") and getgenv() or {}

if G.JMK48_MAIN_RUNNING then
	warn("[Jmk48] Menu utama sudah berjalan, dilewati.")
	return
end
G.JMK48_MAIN_RUNNING = true

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

local Rayfield
do
	local ok, mod = pcall(function()
		return loadstring(game:HttpGet("https://sirius.menu"))()
	end)
	if not ok or type(mod) ~= "table" then
		G.JMK48_MAIN_RUNNING = nil
		warn("[Jmk48] Gagal memuat Rayfield UI: " .. tostring(mod))
		return
	end
	Rayfield = mod
end

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

local Window = Rayfield:CreateWindow({
	Name = "Nasi Rendang Hub | Menu Utama",
	LoadingTitle = "Memuat Fitur...",
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
	Min = 50,
	Max = 500,
	Step = 10,
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
	Min = 16,
	Max = 200,
	Step = 5,
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

-- Terapkan ulang otomatis saat karakter baru muncul
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
