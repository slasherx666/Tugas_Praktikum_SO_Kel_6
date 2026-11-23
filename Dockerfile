FROM debian:12-slim

LABEL project="SysGuard" group="Kelompok-6" module="backup-monitoring"

RUN apt-get update \
    && apt-get install -y --no-install-recommends tar gzip coreutils procps \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 backupuser \
    && mkdir -p /opt/sysguard /data/source /data/backup /data/logs \
    && chown -R backupuser:backupuser /data

COPY backup_ecommerce.sh /opt/sysguard/backup_ecommerce.sh
RUN chmod 755 /opt/sysguard/backup_ecommerce.sh

USER backupuser
WORKDIR /data/logs

CMD ["sleep", "infinity"]
