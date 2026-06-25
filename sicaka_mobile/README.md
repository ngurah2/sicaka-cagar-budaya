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
8. Tunggu proses *download* sampai selesai 100%. Persiapan pertama kali sudah selesai! 🎉

---

## ⚡ PANDUAN SEHARI-HARI (CARA MENYALAKAN APLIKASI)

**SANGAT PENTING:** Ikuti langkah di bawah ini **secara berurutan** setiap kali Anda baru menghidupkan laptop dan ingin membuka aplikasi. Anda harus membuka 2 Terminal (Terminal 1 untuk Mesin, Terminal 2 untuk Layar).

### 🖥️ TERMINAL 1: Menyalakan Mesin Data (Backend)
1. Buka **VS Code** dan buka folder proyek.
2. Buka Terminal Baru (`Terminal` > `New Terminal`).
3. Masuk ke folder mesin: Ketik `cd backend` lalu Enter.
4. Nyalakan ruang khusus: Ketik `.\venv\Scripts\activate` lalu Enter.
5. **Nyalakan Mesinnya:** Ketik perintah sakti ini lalu Enter:
   `uvicorn main:app --reload`
6. Tunggu sampai muncul tulisan `Application startup complete`. 
7. **JANGAN TUTUP TERMINAL INI!** Biarkan mesin menyala di latar belakang. Lanjut ke Terminal 2.

### 📱 TERMINAL 2: Menyalakan Layar Aplikasi (Frontend Flutter)
1. Buat layar terminal baru dengan menekan tombol tanda tambah **(+)** di bagian kanan atas kotak Terminal VS Code Anda. (Sekarang Anda punya 2 terminal yang bisa di-klik bergantian).
2. Di terminal baru ini, masuk ke folder layar aplikasi:
   Ketik `cd sicaka_mobile` lalu Enter.
3. **Nyalakan Aplikasinya (Contoh di Google Chrome):** Ketik perintah ini lalu Enter:
   `flutter run -d chrome`
4. Tunggu beberapa saat, dan Google Chrome akan otomatis terbuka menampilkan aplikasi SI-CAKA!

---

## 🔑 KUNCI RAHASIA LOGIN ADMIN

Jika Anda ingin masuk sebagai Admin/Kepala Bidang untuk menambah jadwal, gunakan kunci ini di halaman Login:

- **Username:** `admin.cagarbudaya`
- **Password:** `password123`

---

## ❓ SOLUSI JIKA TERJADI ERROR (Troubleshooting)

* **Aplikasi macet/loading terus saat menambah jadwal?**
  *Cek Terminal 1 Anda. Mesin (Backend) kemungkinan mati atau terhenti. Tekan tombol `Enter` beberapa kali di Terminal 1 untuk membangunkannya, atau matikan dengan `Ctrl+C` lalu ketik ulang `uvicorn main:app --reload`.*
* **Error "File Not Found" saat mencoba menjalankan Terminal?**
  *Pastikan Anda sudah mengetik `cd` (Change Directory) ke folder yang benar. Gunakan perintah `ls` atau `dir` untuk melihat isi folder saat ini.*

---
*Developed with ☕️ in Mengwi, Bali.*