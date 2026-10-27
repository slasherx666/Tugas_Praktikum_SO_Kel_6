# Tugas Praktikum SO Kelompok 6: Otomasi Backup E-Commerce

## 1. Use Case dan Tujuan
**Use case:** Data aset e-commerce, seperti rekap pesanan dan file pendukung toko online, perlu dicadangkan untuk mengurangi risiko kehilangan data akibat kesalahan penghapusan atau kerusakan file.

**Tujuan otomasi:** Membuat proses backup lebih mudah menggunakan shell script yang mengarsipkan folder sumber menjadi file .tar.gz, memberikan nama file berdasarkan waktu pembuatan, dan mencatat aktivitas backup ke dalam log.

## 2. Struktur Repository
| Path | Fungsi |
|---|---|
| `backup_folder/` | Folder penyimpanan arsip backup |
| `dummy_assets/rekap_pesanan/` | Folder data dummy untuk pengujian |
| `README.md` | Dokumentasi penggunaan dan pengujian |
| `backup_activity.log` | Log file pencatatan aktivitas dan kesalahan |
| `backup_ecommerce.sh` | Script utama untuk melakukan backup |

## 3. Cara Menjalankan
**Persyaratan**
- Linux atau lingkungan yang mendukung Bash.
- Perintah tar tersedia.
- Memiliki izin membaca folder sumber dan menulis ke folder tujuan.

**Langkah-langkah**
1. Buka terminal pada direktori repository yang berisi file backup_ecommerce.sh.
2. Berikan izin eksekusi agar script dapat dijalankan dengan perintah berikut:
```bash
chmod +x backup_ecommerce.sh
```
3. Siapkan folder sumber berisi data yang akan di-backup dan folder tujuan untuk menyimpan hasil backup:
```bash
mkdir -p dummy_assets/rekap_pesanan
mkdir -p backup_folder
```
Untuk pengujian, tambahkan satu file data dummy ke folder sumber:
```bash
echo "Data pesanan dummy" > dummy_assets/rekap_pesanan/pesanan.txt
```
4. Jalankan script dengan memasukkan lokasi folder sumber dan folder tujuan:
```bash
./backup_ecommerce.sh dummy_assets/rekap_pesanan backup_folder
```
Pada perintah tersebut, **dummy_assets/rekap_pesanan** merupakan parameter pertama, yaitu folder yang datanya akan dicadangkan. Sementara itu, **backup_folder** merupakan parameter kedua, yaitu folder tempat menyimpan hasil backup.

5. Periksa hasil backup dengan melihat isi folder tujuan:
```bash
ls -lh backup_folder/
```
Jika proses berhasil, akan muncul file arsip dengan format **.tar.gz.** Nama file dilengkapi timestamp agar setiap hasil backup dapat dibedakan berdasarkan waktu pembuatannya.

6. Periksa log aktivitas untuk mengetahui informasi proses backup, termasuk pesan keberhasilan atau kesalahan:
```bash
cat backup_activity.log
```

## 4. Exit Status
| Kode | Keterangan |
|---|---|
| 0 | Backup berhasil |
| 1 | Jumlah parameter tidak sesuai |
| 2 | Folder sumber tidak ditemukan |
| 3 | Gagal membuat folder tujuan |
| 4 | Tidak memiliki izin menulis ke folder tujuan |
| 5 | Proses pembuatan arsip gagal |

Kode exit digunakan untuk mengetahui hasil eksekusi script. Kode dapat diperiksa menggunakan echo $? segera setelah script selesai dijalankan.

## 5. Cara Verifikasi

Verifikasi dilakukan dengan cara memeriksa isi arsip menggunakan perintah tar -tzf dan melihat log aktivitas pada file backup_activity.log. Hasil pemeriksaan menunjukkan bahwa arsip dapat dibaca dan berisi folder resi/, folder rekap_pesanan/, serta file rekap_pesanan/oktober.csv. Log mencatat bahwa file backup berhasil disimpan, tetapi terdapat pesan kesalahan karena folder sumber dari folder_ngasal tidak ditemukan. Pemeriksaan checksum belum dilakukan karena belum tersedia nilai checksum pembanding. 

## 6. Cleanup dan Rollback
### Cleanup 
Cleanup dilakukan untuk menghapus direktori dan file sementara yang digunakan selama proses pengujian agar tidak meninggalkan file yang tidak diperlukan di dalam repository.

Langkah-langkah cleanup:
1. Menghapus direktori pengujian menggunakan perintah `rm -r test_cleanup`.
2. Memastikan direktori sudah terhapus menggunakan perintah `ls -ld test_cleanup`.
3. Memeriksa kondisi repository menggunakan perintah `git status`.

**Hasil pengujian:** Direktori `test_cleanup` berhasil dihapus. Perintah `ls` menampilkan pesan bahwa direktori tidak ditemukan, sedangkan `git status` menunjukkan `nothing to commit, working tree clean`. Hal ini menunjukkan bahwa file pengujian telah dibersihkan dan tidak ada perubahan lokal yang tertinggal di repository.

### Rollback
Rollback diuji untuk memastikan data dapat dipulihkan dari arsip backup ketika file sumber mengalami perubahan.

Langkah-langkah pengujian:
1. Membuat file sumber `pesanan.txt` yang berisi `Data sebelum perubahan`.
2. Membuat arsip backup bernama `rollback_test.tar.gz`.
3. Mengubah isi file sumber menjadi `Data setelah perubahan`.
4. Memulihkan data dari arsip backup ke direktori `restore` menggunakan perintah `tar -xzf test_cleanup/backup/rollback_test.tar.gz -C test_cleanup/restore`.
5. Memeriksa isi file hasil pemulihan menggunakan perintah `cat` dan memverifikasi isinya menggunakan `grep -Fx`.

**Hasil pengujian:** Proses pemulihan berhasil mengembalikan isi file pada direktori `restore` menjadi `Data sebelum perubahan`. Perintah verifikasi menghasilkan *exit code* `0`, yang menandakan bahwa teks yang dicari ditemukan. Sementara itu, file sumber tetap berisi `Data setelah perubahan`, sehingga dapat dipastikan bahwa pemulihan dilakukan ke direktori terpisah dan tidak menimpa file sumber.

## 7. Test Case dan Hasil Aktual
| No | Skenario | Perintah | Hasil yang diharapkan | Hasil aktual | Interpretasi |
|---|---|---|---|---|---|
| 1 | Sukses | ./backup_ecommerce.sh dummy_assets/rekap_pesanan backup_folder | exit 0, arsip .tar.gz terbentuk, log SUCCESS | Exit 0. Log: [INFO] Folder tujuan 'backup_folder' belum ada, membuat folder baru..., [INFO] Memulai proses backup ..., [SUCCESS] Backup berhasil disimpan di 'backup_folder/backup_assets_20261027_212248.tar.gz'. Arsip terbentuk (165 byte) dan tar -tzf menampilkan ./ dan ./oktober.csv. | Backup berhasil. Folder tujuan dibuat otomatis, nama arsip memuat timestamp, dan isi arsip sesuai folder sumber. |
| 2 | Gagal: sumber tidak ada | ./backup_ecommerce.sh folder_ngasal backup_folder | exit 2, pesan error di log, tidak ada arsip baru | Exit 2. Log: [ERROR] Folder sumber 'folder_ngasal' tidak ditemukan! | Validasi parameter pertama bekerja. Script berhenti sebelum membuat arsip dan kegagalan tercatat di log. |
| 3 | Gagal: argumen kosong | ./backup_ecommerce.sh | 	exit 1, pesan cara pakai di log | Exit 1. Log: [ERROR] Jumlah parameter tidak sesuai. Cara pakai: ./backup_ecommerce.sh <folder_sumber> <folder_tujuan> | Validasi jumlah parameter bekerja dan memberi petunjuk penggunaan yang jelas kepada pengguna. |

## 8. Batasan
- Belum ada fitur verifikasi checksum otomatis untuk memastikan integritas file backup.
- Belum ada fitur pemulihan (restore) otomatis untuk mengembalikan data dari arsip backup.
- Script hanya dapat melakukan backup terhadap folder sumber yang tersedia. Jika folder sumber tidak ditemukan, maka proses backup akan dihentikan dan pesan kesalahan dicatat ke log.

## 9. Kontribusi Anggota
| *Nama* | *NIM* | *Kontribusi* |
| ----- | ----- | ----- |
| Marsha Indriani | 2510501049 | Merancang skenario uji coba (1 berhasil, 2 gagal) dan Menyusun dokumentasi teknis README.md |
| Indah Aura Nathania | 2510501058 | Menyusun dokumentasi teknis README.md dan mempublikasikan Release Tag ke portal e-learning kampus. |
| Nafizza Azzahra | 2510501061 | Merancang arsitektur script modular, logika error handling, dan implementasi validasi parameter. |
| Muhamad Rasya Alfajri | 2510501062 | Melakukan setup repository GitHub, cloning, dan manajemen branch. |
| Feisha Azalia | 2510501063 | Menyusun dokumentasi teknis README.md dan Mengecek error pada source code. |

## 10. Informasi Repository dan Rilis
- **Nama kelompok:** Kelompok 6
- **Repository:** Tugas_Praktikum_SO_Kel_6
- **Branch:** Main
