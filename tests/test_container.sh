#!/usr/bin/env bash
C=sysguard-backup
EXE=/opt/sysguard/backup_ecommerce.sh
OUT=evidence/hasil_uji_$(date +%Y%m%d_%H%M%S).log
mkdir -p evidence

check() {
  local st=FAIL
  [ "$3" = "$4" ] && st=PASS
  printf '%s | %s | expected=%s actual=%s | %s\n' "$1" "$2" "$3" "$4" "$st" | tee -a "$OUT"
}

echo "== Uji dimulai $(date) ==" | tee "$OUT"

docker exec $C $EXE /data/source /data/backup
check T01 "Backup normal" 0 $?

docker exec $C $EXE /folder_ngasal /data/backup
check T02 "Sumber tidak ada" 2 $?

docker exec $C $EXE
check T03 "Tanpa argumen" 1 $?

docker exec $C $EXE /data/source /data/source
rc=$?
echo "T04 | Tujuan read-only | exit aktual=$rc (cocokkan dengan tabel exit status README)" | tee -a "$OUT"

docker exec $C sh -c 'touch /data/source/x' 2>>"$OUT"
rc=$?
if [ $rc -ne 0 ]; then s=PASS; else s=FAIL; fi
echo "T05 | Tulis ke mount read-only ditolak | rc=$rc | $s" | tee -a "$OUT"

LATEST=$(docker exec $C sh -c 'ls -t /data/backup/*.tar.gz | head -1')
docker exec $C tar -tzf "$LATEST" >>"$OUT" 2>&1
check T06 "Arsip dapat dibaca" 0 $?

BEFORE=$(docker exec $C sh -c 'ls /data/backup | wc -l')
docker compose down
docker compose up -d
sleep 2
AFTER=$(docker exec $C sh -c 'ls /data/backup | wc -l')
echo "T07 | Persistensi setelah down/up | sebelum=$BEFORE sesudah=$AFTER" | tee -a "$OUT"
if [ "$BEFORE" = "$AFTER" ]; then echo "T07 | PASS" | tee -a "$OUT"; else echo "T07 | FAIL" | tee -a "$OUT"; fi

docker inspect --format 'T08 | NanoCpus={{.HostConfig.NanoCpus}} Memory={{.HostConfig.Memory}} PidsLimit={{.HostConfig.PidsLimit}} Privileged={{.HostConfig.Privileged}}' $C | tee -a "$OUT"

docker stats --no-stream $C | tee -a "$OUT"
docker logs --tail 20 $C >>"$OUT" 2>&1
docker exec $C cat /data/logs/backup_activity.log | tail -20 | tee -a "$OUT"
