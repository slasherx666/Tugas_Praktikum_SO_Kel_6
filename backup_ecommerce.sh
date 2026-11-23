#!/bin/bash

# ==============================================================================
# Script Name: backup_ecommerce.sh
# Description: Otomasi Monitoring Sistem/Layanan, Backup, dan Restore Terverifikasi
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${LOG_FILE:-${SCRIPT_DIR}/backup_activity.log}"
MAX_DISK_USAGE="${MAX_DISK_USAGE:-85}"
REQUIRED_SERVICE="${REQUIRED_SERVICE:-cron}"

log_message() {
    local LOG_LEVEL=$1
    local MESSAGE=$2
    local CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[${CURRENT_TIME}] [${LOG_LEVEL}] ${MESSAGE}" | tee -a "${LOG_FILE}"
}

monitor_system_and_service() {
    local TARGET_PATH=$1

    log_message "INFO" "Memulai monitoring kondisi sistem & layanan (batas disk: ${MAX_DISK_USAGE}%, layanan: ${REQUIRED_SERVICE})..."

    if ! df -P "$TARGET_PATH" >/dev/null 2>&1; then
        log_message "ERROR" "Gagal memeriksa kapasitas penyimpanan pada '$TARGET_PATH'."
        exit 6
    fi

    local DISK_USAGE
    DISK_USAGE=$(df -P "$TARGET_PATH" | awk 'NR==2 {gsub(/%/,""); print $5}')

    if [ -z "$DISK_USAGE" ] || [ "$DISK_USAGE" -gt "$MAX_DISK_USAGE" ]; then
        log_message "ERROR" "Backup DITOLAK: Penggunaan disk (${DISK_USAGE:-N/A}%) melebihi ambang batas (${MAX_DISK_USAGE}%)."
        exit 6
    fi

    if pgrep -x "$REQUIRED_SERVICE" >/dev/null 2>&1 || [ -f "/tmp/service_${REQUIRED_SERVICE}.ok" ]; then
        log_message "INFO" "Monitoring lolos: Disk ${DISK_USAGE}% (<= ${MAX_DISK_USAGE}%) dan layanan '$REQUIRED_SERVICE' aktif."
    else
        log_message "ERROR" "Backup DITOLAK: Layanan '$REQUIRED_SERVICE' tidak aktif atau tidak terdeteksi."
        exit 7
    fi
}

validate_backup_input() {
    if [ "$#" -ne 2 ]; then
        log_message "ERROR" "Jumlah parameter backup tidak sesuai. Cara pakai: $0 backup <folder_sumber> <folder_tujuan>"
        exit 1
    fi

    SRC_DIR=$1
    DEST_DIR=$2

    if [ ! -d "$SRC_DIR" ]; then
        log_message "ERROR" "Folder sumber '$SRC_DIR' tidak ditemukan!"
        exit 2
    fi

    if [ ! -d "$DEST_DIR" ]; then
        log_message "INFO" "Folder tujuan '$DEST_DIR' belum ada, membuat folder baru..."
        mkdir -p "$DEST_DIR" || { log_message "ERROR" "Gagal membuat folder tujuan '$DEST_DIR'."; exit 3; }
    fi

    if [ ! -w "$DEST_DIR" ]; then
        log_message "ERROR" "Permission Denied. Tidak memiliki izin menulis di folder '$DEST_DIR'."
        exit 4
    fi
}

perform_backup() {
    validate_backup_input "$@"
    monitor_system_and_service "$DEST_DIR"

    local TIMESTAMP
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    local BACKUP_NAME="backup_assets_${TIMESTAMP}.tar.gz"
    local BACKUP_PATH="${DEST_DIR}/${BACKUP_NAME}"

    log_message "INFO" "Memulai proses backup dari '$SRC_DIR' ke '$BACKUP_PATH'..."
    if tar -czf "$BACKUP_PATH" -C "$SRC_DIR" . 2>> "${LOG_FILE}"; then
        local ABS_ARCHIVE_DIR
        ABS_ARCHIVE_DIR=$(cd "$(dirname "$BACKUP_PATH")" && pwd)
        local ARCHIVE_BASENAME
        ARCHIVE_BASENAME=$(basename "$BACKUP_PATH")
        (cd "$ABS_ARCHIVE_DIR" && sha256sum "$ARCHIVE_BASENAME") > "${BACKUP_PATH}.sha256"
        log_message "SUCCESS" "Backup berhasil disimpan di '$BACKUP_PATH' beserta checksum SHA256."
        exit 0
    else
        rm -f "$BACKUP_PATH"
        log_message "ERROR" "Proses kompresi gagal! Periksa file log untuk detail."
        exit 5
    fi
}

perform_restore() {
    if [ "$#" -ne 2 ]; then
        log_message "ERROR" "Jumlah parameter restore tidak sesuai. Cara pakai: $0 restore <file_arsip.tar.gz> <folder_restore>"
        exit 1
    fi

    local ARCHIVE_PATH=$1
    local RESTORE_DIR=$2

    if [ ! -f "$ARCHIVE_PATH" ]; then
        log_message "ERROR" "File arsip '$ARCHIVE_PATH' tidak ditemukan!"
        exit 2
    fi

    if [ -f "${ARCHIVE_PATH}.sha256" ]; then
        log_message "INFO" "Memverifikasi checksum arsip sebelum restore..."
        local ABS_ARCHIVE_DIR
        ABS_ARCHIVE_DIR=$(cd "$(dirname "$ARCHIVE_PATH")" && pwd)
        local SHA_BASENAME
        SHA_BASENAME=$(basename "${ARCHIVE_PATH}.sha256")
        if ! (cd "$ABS_ARCHIVE_DIR" && sha256sum -c "$SHA_BASENAME" >> "${LOG_FILE}" 2>&1); then
            log_message "ERROR" "Verifikasi checksum gagal! Arsip mungkin rusak atau berubah."
            exit 8
        fi
    fi

    mkdir -p "$RESTORE_DIR" || {
        log_message "ERROR" "Gagal membuat folder restore '$RESTORE_DIR'."
        exit 3
    }

    log_message "INFO" "Memulai proses restore dari '$ARCHIVE_PATH' ke '$RESTORE_DIR'..."
    if ! tar -xzf "$ARCHIVE_PATH" -C "$RESTORE_DIR" 2>> "${LOG_FILE}"; then
        log_message "ERROR" "Proses ekstraksi restore gagal!"
        exit 5
    fi

    if [ -z "$(ls -A "$RESTORE_DIR" 2>/dev/null)" ]; then
        log_message "ERROR" "Verifikasi restore gagal: folder '$RESTORE_DIR' kosong setelah ekstraksi."
        exit 9
    fi

    log_message "SUCCESS" "Restore berhasil dan terverifikasi di folder '$RESTORE_DIR'."
    exit 0
}

main() {
    if [ "$#" -lt 1 ]; then
        log_message "ERROR" "Mode tidak diberikan. Gunakan: $0 {backup|restore} [argumen...]"
        exit 1
    fi

    local MODE=$1
    shift

    case "$MODE" in
        backup)
            perform_backup "$@"
            ;;
        restore)
            perform_restore "$@"
            ;;
        *)
            log_message "ERROR" "Mode '$MODE' tidak dikenali. Gunakan 'backup' atau 'restore'."
            exit 1
            ;;
    esac
}

main "$@"
