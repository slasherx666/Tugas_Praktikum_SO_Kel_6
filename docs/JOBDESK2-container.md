# Jobdesk 2: Container, Persistensi, Resource Limit, Pengujian

## Komponen
- Image: sysguard-backup:1.0 (debian:12-slim, user non-root backupuser uid 1000)
- Bind mount: ./dummy_assets/rekap_pesanan -> /data/source (read-only)
- Named volume: backup_data -> /data/backup, log_data -> /data/logs
- Network: sysguard-net (bridge), tanpa port yang dipublikasikan
- Limit: CPU 0.5, memori 256 MB, PID 100; tanpa privileged dan tanpa Docker socket

## Exit code
| Kode | Keterangan |
|------|------------|
| 0 | Backup berhasil |
| 1 | Jumlah parameter tidak sesuai |
| 2 | Folder sumber tidak ditemukan |
| 3 | Gagal membuat folder tujuan |
| 4 | Tidak memiliki izin menulis ke folder tujuan |
| 5 | Proses pembuatan arsip gagal |

## Tabel pengujian (hasil aktual)
| ID uji | Modul/fitur | Kondisi/input | Hasil yang diharapkan | Hasil aktual | Status | Lokasi bukti |
|--------|-------------|---------------|-----------------------|--------------|--------|--------------|
| T01 | Backup | Sumber dan tujuan valid | exit 0, arsip terbentuk | exit 0 | PASS | evidence/hasil_uji_final.log |
| T02 | Validasi input | Folder sumber tidak ada | exit 2 | exit 2 | PASS | evidence/hasil_uji_final.log |
| T03 | Validasi input | Tanpa argumen | exit 1 | exit 1 | PASS | evidence/hasil_uji_final.log |
| T04 | Akses/permission | Tujuan backup di mount read-only | exit 4 | exit 4 | PASS | evidence/hasil_uji_final.log |
| T05 | Akses ditolak | Tulis file ke /data/source (:ro) | perintah gagal | rc=1, ditolak | PASS | evidence/hasil_uji_final.log |
| T06 | Verifikasi arsip | tar -tzf pada arsip terbaru | exit 0 | exit 0 | PASS | evidence/hasil_uji_final.log |
| T07 | Persistensi | down lalu up, jumlah arsip dibandingkan | jumlah sama | sebelum=2, sesudah=2 | PASS | evidence/hasil_uji_final.log |
| T08 | Resource limit | docker inspect | CPU 0.5, mem 256 MB, PID 100, non-privileged | NanoCpus=500000000, Memory=268435456, PidsLimit=100, Privileged=false | PASS | evidence/hasil_uji_final.log, evidence/04_monitoring.log |
| T09 | Monitoring | docker stats dan log aktivitas | statistik dan log tampil | tampil | PASS | evidence/04_monitoring.log |
| T10 | Integrasi | Monitoring disk/layanan menentukan backup dilanjutkan atau ditolak | backup ditolak saat kondisi gagal | belum diuji (menunggu modul Jobdesk 1) | - | - |

## Cara menjalankan uji
