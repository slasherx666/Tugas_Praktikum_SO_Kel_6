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
1. Berikan izin eksekusi:
```bash
chmod +x backup_ecommerce.sh
```
2. Siapkan folder sumber berisi data dummy dan folder tujuan untuk pengujian:
```bash
mkdir -p dummy_assets/rekap_pesanan
mkdir -p backup_folder
echo "Data pesanan dummy" > dummy_assets/rekap_pesanan/pesanan.txt
```
3. Jalankan script dengan dua parameter:
```bash
./backup_ecommerce.sh dummy_assets/rekap_pesanan backup_folder
```
Parameter pertama adalah folder sumber yang akan dicadangkan. Parameter kedua adalah folder tujuan untuk menyimpan arsip backup.

Arsip yang dihasilkan menggunakan format nama **backup_assets_TIMESTAMP.tar.gz**, dengan timestamp sesuai waktu eksekusi.

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
[contoh: cek file arsip di backup_folder, jalankan `tar -tzf <arsip>`, bandingkan checksum, lihat baris INFO di log]

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
- [fitur yang belum selesai, jika ada]

## 9. Kontribusi Anggota
| Nama | NIM | Kontribusi |
|---|---|---|
| Marsha Indriani | 2510501049 | [..] |
| Indah Aura Nathania | 2510501058 | [..] |
| Nafizza Azzahra | 2510501061 | [..] |
| Muhamad Rasya Alfajri | 2510501062 | [..] |
| Feisha Azalia | 2510501063 | [..] |

## 10. Informasi Repository dan Rilis
- **Nama kelompok:** Kelompok 6
- **Repository:** [Isi URL repository kelompok]
- **Branch:** [Isi nama branch]
- **Commit ID atau tag:** [Isi setelah commit atau tag dibuat]
- **Tag yang disarankan:** P2-CHECKPOINT-P11-v01
