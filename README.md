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
**Cleanup:** [contoh: hapus arsip di backup_folder dan file log hasil uji]

**Rollback:** [contoh: ekstrak arsip ke lokasi semula, atau hapus arsip yang baru dibuat agar kembali ke kondisi sebelum script dijalankan]

## 7. Test Case dan Hasil Aktual
| No | Skenario | Perintah | Hasil yang diharapkan | Hasil aktual | Interpretasi |
|---|---|---|---|---|---|
| 1 | Sukses | [..] | exit 0 | [isi dari eksekusi nyata] | [..] |
| 2 | Gagal: sumber tidak ada | [..] | exit [..] | [isi dari eksekusi nyata] | [..] |
| 3 | Gagal: argumen kosong | [..] | exit [..] | [isi dari eksekusi nyata] | [..] |

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
