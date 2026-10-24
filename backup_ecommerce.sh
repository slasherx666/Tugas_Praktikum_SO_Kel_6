#!/bin/bash

# ==============================================================================
# Script Name: backup_ecommerce.sh
# Description: Otomasi backup folder aset e-commerce menjadi file arsip (.tar.gz)
# ==============================================================================

LOG_FILE="backup_activity.log"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

log_message() {
    local LOG_LEVEL=$1
    local MESSAGE=$2
    local CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[${CURRENT_TIME}] [${LOG_LEVEL}] ${MESSAGE}" | tee -a "${LOG_FILE}"
}

validate_input() {
    if [ "$#" -ne 2 ]; then
        log_message "ERROR" "Jumlah parameter tidak sesuai. Cara pakai: $0 <folder_sumber> <folder_tujuan>"
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
        mkdir -p "$DEST_DIR" || { log_message "ERROR" "Gagal membuat folder tujuan."; exit 3; }
    fi

    if [ ! -w "$DEST_DIR" ]; then
        log_message "ERROR" "Permission Denied. Tidak memiliki izin menulis di folder '$DEST_DIR'."
        exit 4
    fi
}

perform_backup() {
    local BACKUP_NAME="backup_assets_${TIMESTAMP}.tar.gz"
    local BACKUP_PATH="${DEST_DIR}/${BACKUP_NAME}"

    log_message "INFO" "Memulai proses backup dari '$SRC_DIR' ke '$BACKUP_PATH'..."
    tar -czf "$BACKUP_PATH" -C "$SRC_DIR" . 2>> "${LOG_FILE}"

    if [ $? -eq 0 ]; then
        log_message "SUCCESS" "Backup berhasil disimpan di '$BACKUP_PATH'."
        exit 0
    else
        log_message "ERROR" "Proses kompresi gagal! Periksa file log untuk detail."
        exit 5
    fi
}

validate_input "$@"
perform_backup