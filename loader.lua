-- File: loader.lua (Panda Auth v3 + Rayfield UI)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu'))()

-- 1. Memuat Pustaka API Resmi Panda Auth v3
local PandaAuth = loadstring(game:HttpGet("https://pandauth.com"))()

-- 2. KONFIGURASI TAUTAN & API
-- Tempelkan API Key yang Anda salin dari Langkah 1 ke dalam tanda petik di bawah ini:
local API_KEY_PANDA = "45e1e8b3-f088-4a74-ae89-59fa6c0ea56d"
local IDENTIFIER_LAYANAN = "jmk48"
local LINK_GITHUB_SKRIP_UTAMA = "https://raw.githubusercontent.com/4shey/roblox-script-lua/refs/heads/main/fitur_aman.lua"

-- Tautan resmi halaman pencarian kunci untuk pemain Anda
local LINK_GET_KEY = "https://pandauth.com" .. IDENTIFIER_LAYANAN

local Window = Rayfield:CreateWindow({
   Name = "Jmk48 Hub | HWID Lock System",
   LoadingTitle = "Menghubungkan ke Server Panda...",
   Theme = "Default",
})

local KeyTab = Window:CreateTab("Verifikasi", 4483362458)

-- 3. Tombol untuk Menyalin Link Kunci
KeyTab:CreateButton({
   Name = "Ambil Kunci (Get Key)",
   Callback = function()
       setclipboard(LINK_GET_KEY)
       Rayfield:Notify({ 
          Title = "Tautan Tersalin!", 
          Content = "Tautan kunci berhasil disalin. Silakan paste di Google Chrome Anda.", 
          Duration = 5 
       })
   end,
})

-- 4. Kotak Input untuk Memasukkan Kunci Hasil Iklan
KeyTab:CreateInput({
   Name = "Masukkan Kunci",
   PlaceholderText = "Tempel kunci di sini...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       -- Sistem memvalidasi kunci secara online ke server menggunakan API Key Anda
       local status = PandaAuth:ValidateKey(API_KEY_PANDA, Text)
       
       if status == true then
           Rayfield:Notify({ 
              Title = "Akses Diterima!", 
              Content = "Membuka menu fitur dari GitHub...", 
              Duration = 3 
           })
           task.wait(1)
           Rayfield:Destroy()
           
           -- EKSEKUSI FITUR UTAMA TERENKRIPSI
           loadstring(game:HttpGet(LINK_GITHUB_SKRIP_UTAMA))()
       else
           Rayfield:Notify({ 
              Title = "Verifikasi Gagal!", 
              Content = "Kunci salah, expired, atau sudah terkunci di HP lain!", 
              Duration = 4 
           })
       end
   end,
})