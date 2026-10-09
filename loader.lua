-- File: loader.lua
-- Script ini yang nantinya Anda bagikan ke orang-orang

local Rayfield = loadstring(game:HttpGet('https://sirius.menu'))()

-- KONSFIGURASI UTAMA
local KUNCI_BENAR = "JMK48" 
local LINK_IKLAN = "https://lootlabs.com" 
-- Link di bawah ini nanti wajib diganti dengan link RAW GitHub dari berkas terenkripsi Anda
local LINK_GITHUB_SKRIP_UTAMA = "https://raw.githubusercontent.com/4shey/roblox-script-lua/refs/heads/main/fitur_aman.lua"

local Window = Rayfield:CreateWindow({
   Name = "JMK48 Hub | Security System",
   LoadingTitle = "Memeriksa Otorisasi...",
   LoadingSubtitle = "Sistem Keamanan Aktif",
   Theme = "Default",
})

local KeyTab = Window:CreateTab("Sistem Kunci", 4483362458)

KeyTab:CreateButton({
   Name = "Dapatkan Kunci Disini (Get Key)",
   Callback = function()
       setclipboard(LINK_IKLAN)
       Rayfield:Notify({
          Title = "Berhasil Disalin!",
          Content = "Link iklan berhasil disalin ke clipboard laptop Anda. Silakan tempel (paste) di browser.",
          Duration = 5,
          Image = 4483362458,
       })
   end,
})

KeyTab:CreateInput({
   Name = "Masukkan Kunci Anda",
   PlaceholderText = "Ketik kunci di sini...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       if Text == KUNCI_BENAR then
           Rayfield:Notify({
              Title = "Kunci Valid!",
              Content = "Akses diterima. Memuat menu utama...",
              Duration = 3,
              Image = 4483362458,
           })
           task.wait(1)
           Rayfield:Destroy()
           
           -- Menarik skrip utama dari server GitHub
           loadstring(game:HttpGet(LINK_GITHUB_SKRIP_UTAMA))()
       else
           Rayfield:Notify({
              Title = "Kunci Salah!",
              Content = "Silakan periksa kembali atau ambil kunci baru melalui tombol Get Key.",
              Duration = 3,
              Image = 4483362458,
           })
       end
   end,
})
