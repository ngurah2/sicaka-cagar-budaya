# 🌟 Panduan Lengkap SI-CAKA (Sistem Informasi Kalender Cagar Budaya) 🌟

Selamat datang di kode sumber **SI-CAKA**! 

Aplikasi ini adalah sistem informasi digital yang dibuat khusus untuk **Bidang Cagar Budaya, Dinas Kebudayaan Kabupaten Badung**. Tujuannya sangat sederhana: **Memastikan semua jadwal kegiatan tersimpan dengan rapi, aman, dan bisa diakses oleh pimpinan maupun staf tanpa ada jadwal yang terlewat.**

Aplikasi ini terbagi menjadi 2 bagian utama yang saling bekerja sama:
1. **Mesin & Database (Backend - Python):** Tempat di mana semua data jadwal, gambar, dan kata sandi disimpan secara aman.
2. **Layar Aplikasi (Frontend - Flutter):** Tampilan visual (tombol, kalender, warna) yang dilihat dan ditekan oleh pengguna di HP atau Laptop.

---

## ✨ Apa Saja yang Bisa Dilakukan Aplikasi Ini?

### 🔒 1. Mode Admin (Khusus Kepala Bidang/Petugas)
- **Login Terpusat:** Harus memasukkan Username dan Password untuk bisa masuk ke mode ini.
- **Kelola Jadwal:** Petugas bisa Menambah, Mengubah, atau Menghapus jadwal kegiatan.
- **Upload Poster:** Bisa langsung memasukkan foto/poster kegiatan dari galeri laptop atau HP.

### 👥 2. Mode Publik (Untuk Staf / Tamu)
- Jika tidak login, aplikasi otomatis berubah menjadi mode "Buku Tamu".
- Tombol Tambah, Edit, dan Hapus akan otomatis disembunyikan agar data tidak bisa dirusak oleh sembarang orang.

### 📊 3. Dashboard Cerdas & Alarm Otomatis
- **Grafik Otomatis:** Menampilkan gambar diagram bulat (*Pie Chart*) untuk melihat berapa persen kegiatan yang sudah "Terlaksana" dan masih "Segera".
- **Alarm Pengingat:** Saat admin login, jika ada jadwal kegiatan untuk **HARI INI** atau **BESOK**, akan muncul *Pop-Up* peringatan besar berwarna oranye di layar.

---

## 🚀 PANDUAN INSTALASI PERTAMA KALI (HANYA DILAKUKAN SEKALI)

*Lakukan langkah ini **hanya** jika Anda baru pertama kali memindahkan folder proyek ini ke laptop baru.*
*(Kabar Baik: Anda **TIDAK PERLU** menginstal XAMPP. Database sudah otomatis menyatu di dalam kode ini).*

### Tahap 1: Mempersiapkan Mesin Data (Backend Python)
1. Buka aplikasi **Visual Studio Code (VS Code)**.
2. Buka folder utama proyek ini di VS Code (Pilih menu `File` > `Open Folder`).
3. Buka **Terminal** di VS Code (Klik menu `Terminal` di bagian paling atas > pilih `New Terminal`).
4. Di terminal yang muncul di bawah, pastikan Anda masuk ke dalam folder mesin (backend). Ketik perintah ini dan tekan Enter:
   `cd backend` *(Catatan: sesuaikan nama folder jika namanya berbeda, contoh: `cd sicaka_backend`)*
5. **Buat "Ruang Kedap Suara" (Virtual Environment):** Ini agar pengaturan aplikasi tidak bentrok dengan aplikasi lain di laptop. Ketik dan Enter:
   `python -m venv venv`
6. **Nyalakan Ruang Tersebut:** Ketik dan Enter:
   `.\venv\Scripts\activate` *(Jika berhasil, akan muncul tulisan `(venv)` warna hijau di sebelah kiri tempat Anda mengetik).*
7. **Download Alat-alat yang Dibutuhkan:** Ketik dan Enter:
   `pip install -r requirements.txt`
8. **Siapkan Kunci Rahasia:** Aplikasi membutuhkan kunci rahasia agar aman. Buat file baru bernama `.env` (wajib isi titik di depannya) di dalam folder utama. Buka file tersebut, lalu ketik teks berikut dan simpan (Ctrl+S):
   ```env
   SECRET_KEY=KunciRahasiaPuspemBadung123!
   ADMIN_USERNAME=admin.cagarbudaya
   ADMIN_PASSWORD=password123

Tunggu proses download sampai selesai 100%. Persiapan pertama kali sudah selesai! 🎉

⚡ PANDUAN SEHARI-HARI (CARA MENYALAKAN APLIKASI DI LAPTOP)
SANGAT PENTING: Ikuti langkah di bawah ini secara berurutan setiap kali Anda baru menghidupkan laptop dan ingin membuka aplikasi. Anda harus membuka 2 Terminal (Terminal 1 untuk Mesin, Terminal 2 untuk Layar).

🖥️ TERMINAL 1: Menyalakan Mesin Data (Backend)
Buka VS Code dan buka folder proyek.

Buka Terminal Baru (Terminal > New Terminal).

Masuk ke folder mesin: Ketik cd backend lalu Enter.

Nyalakan ruang khusus: Ketik .\venv\Scripts\activate lalu Enter.

Nyalakan Mesinnya: Ketik perintah sakti ini lalu Enter:

Bash
uvicorn main:app --reload
Tunggu sampai muncul tulisan Application startup complete.

JANGAN TUTUP TERMINAL INI! Biarkan mesin menyala di latar belakang. Lanjut ke Terminal 2.

📱 TERMINAL 2: Menyalakan Layar Aplikasi (Frontend Flutter)
Buat layar terminal baru dengan menekan tombol tanda tambah (+) di bagian kanan atas kotak Terminal VS Code Anda. (Sekarang Anda punya 2 terminal yang bisa di-klik bergantian).

Di terminal baru ini, masuk ke folder layar aplikasi:
Ketik cd sicaka_mobile lalu Enter.

Nyalakan Aplikasinya (Contoh di Google Chrome): Ketik perintah ini lalu Enter:

Bash
flutter run -d chrome
Tunggu beberapa saat, dan Google Chrome akan otomatis terbuka menampilkan aplikasi SI-CAKA!

🔑 KUNCI RAHASIA LOGIN ADMIN
Jika Anda ingin masuk sebagai Admin/Kepala Bidang untuk menambah jadwal, gunakan kunci ini di halaman Login:

Username: admin.cagarbudaya

Password: password123

🌍 PANDUAN DEPLOYMENT (RILIS KE SERVER & DOMAIN KOMINFO)
Langkah ini dilakukan jika aplikasi SI-CAKA sudah siap dipublikasikan ke internet, sehingga semua pegawai bisa mengaksesnya melalui domain resmi pemerintah (contoh: sicaka.badungkab.go.id).

Tahap 1: Membungkus Layar Aplikasi (Build Frontend)
Buka Terminal di VS Code dan pastikan Anda berada di dalam folder sicaka_mobile.

Ketik perintah ini untuk mengubah kode Flutter menjadi file website yang ringan:

Bash
flutter build web --release
Tunggu hingga proses selesai. Jika berhasil, sistem akan membuat folder baru di sicaka_mobile/build/web.

Catatan Penting: Seluruh file dan folder yang ada di dalam folder web inilah yang nantinya akan kita unggah ke server Kominfo.

Tahap 2: Mempersiapkan Server Kominfo (Cpanel / VPS)
Hubungi tim IT Dinas Kominfo Badung untuk meminta akses ke Server (cPanel atau VPS) dan sebuah Subdomain.

Mengunggah Layar Aplikasi:

Masuk ke pengelola file (File Manager) di cPanel Kominfo.

Buka folder public_html (atau folder direktori subdomain yang diberikan).

Unggah (Upload) seluruh isi dari folder build/web (dari Tahap 1) ke dalam folder tersebut.

Mengunggah Mesin Data (Backend):

Buat folder baru di luar public_html untuk keamanan (misalnya beri nama sicaka_backend).

Unggah semua file Python Anda (main.py), file requirements.txt, dan file rahasia .env ke dalam folder baru ini.

Tahap 3: Menyalakan Mesin Data di Server (Hidup 24 Jam)
Masuk ke terminal server Kominfo (melalui fitur Terminal di cPanel atau menggunakan SSH).

Pindah ke folder mesin data: cd sicaka_backend (sesuaikan dengan nama folder yang Anda buat).

Instal perlengkapan mesin di server:

Bash
pip install -r requirements.txt
Nyalakan mesin agar tidak mati meskipun Anda menutup laptop/terminal, menggunakan perintah:

Bash
nohup uvicorn main:app --host 0.0.0.0 --port 8000 &
Tahap 4: Pengaturan Akhir dengan Tim IT Kominfo
Laporkan kepada tim IT Kominfo bahwa aplikasi sudah berjalan di port 8000.

Minta bantuan tim IT untuk mengatur Reverse Proxy agar subdomain (misal: sicaka.badungkab.go.id) mengarah secara otomatis ke mesin data Anda di port 8000.

Selesai! SI-CAKA kini sudah resmi online dan siap digunakan oleh seluruh staf.

❓ SOLUSI JIKA TERJADI ERROR (Troubleshooting Lengkap)
Aplikasi macet atau berputar (loading) terus saat menambah jadwal?
Penyebab: Mesin backend (Terminal 1) kemungkinan mati atau terhenti ("sleep").
Solusi: Buka VS Code, lihat Terminal 1. Tekan tombol Enter beberapa kali untuk membangunkannya. Jika masih diam, matikan paksa dengan tombol Ctrl + C, lalu ketik ulang perintah uvicorn main:app --reload dan tekan Enter.

Error "File Not Found" atau "No such file or directory" di Terminal?
Penyebab: Anda membuka terminal di folder yang salah.
Solusi: Pastikan Anda menggunakan perintah cd untuk masuk ke folder yang benar terlebih dahulu. Ketik dir (di Windows) atau ls (di Mac) untuk melihat apakah Anda sudah berada di folder yang tepat.

Layar Abu-abu atau Blank Screen saat aplikasi dibuka di Google Chrome?
Penyebab: Ada kesalahan saat Flutter membaca memori cache komputer Anda.
Solusi: Matikan Terminal 2 (tekan Ctrl + C). Ketik flutter clean lalu Enter. Tunggu sampai selesai, lalu ketik ulang flutter run -d chrome.

Error "Port is already in use" di Terminal 1?
Penyebab: Mesin data sebelumnya belum dimatikan dengan sempurna sehingga menumpuk.
Solusi: Tutup seluruh aplikasi VS Code, buka ulang, dan nyalakan dari awal.

Aplikasi jalan di laptop, tapi Error (CORS) saat sudah di-Upload ke Kominfo?
Penyebab: Aplikasi layar belum tahu alamat mesin data yang baru di server.
Solusi: Buka file api_service.dart. Ubah alamat tulisan http://127.0.0.1:8000 menjadi nama domain resmi dari Kominfo. Setelah diubah, jalankan ulang langkah flutter build web --release dan unggah ulang file terbarunya ke cPanel.

Developed with ☕️ in Mengwi, Bali.