# This is how I set up my Message Of The Day (MOTD)

```
grep -n pam_motd /etc/pam.d/sshd || true
>>> 33:session    optional     pam_motd.so  motd=/run/motd.dynamic
>>> 34:session    optional     pam_motd.so noupdate
```

```
sudo install -d -m 0755 /var/lib/boot-metrics
sudo tee /usr/local/sbin/boot-metrics >/dev/null <<'EOF'
#!/bin/sh
set -eu


OUTDIR=/var/lib/boot-metrics
LOG=/var/log/boot-metrics.log

now_iso="$(date -Is)"
boot_since="$(uptime -s 2>/dev/null || echo unknown)"

boot_time="$(systemd-analyze time 2>/dev/null | tr -d '\n' || echo 'systemd-analyze unavailable')"

# Downtime estimate based on previous boot's last journal entry vs this boot's first journal entry
downtime_sec=""
if command -v journalctl >/dev/null 2>&1; then
  prev_last="$(journalctl -b -1 -n 1 --no-pager -o short-iso 2>/dev/null | head -n1 | cut -c1-19 || true)"
  curr_first="$(journalctl -b 0 -n 1 --no-pager -o short-iso --reverse 2>/dev/null | head -n1 | cut -c1-19 || true)"

  if [ -n "$prev_last" ] && [ -n "$curr_first" ]; then
    prev_epoch="$(date -d "$prev_last" +%s 2>/dev/null || true)"
    curr_epoch="$(date -d "$curr_first" +%s 2>/dev/null || true)"
    if [ -n "${prev_epoch:-}" ] && [ -n "${curr_epoch:-}" ] && [ "$curr_epoch" -ge "$prev_epoch" ]; then
      downtime_sec="$((curr_epoch - prev_epoch))"
    fi
  fi
fi

# Human-ish formatting for downtime
downtime_human="unknown"
if [ -n "${downtime_sec:-}" ]; then
  s="$downtime_sec"
  h=$((s/3600)); m=$(((s%3600)/60)); ss=$((s%60))
  downtime_human="${h}h ${m}m ${ss}s"
fi

summary="Boot summary: ${boot_time}
Booted since: ${boot_since}
Estimated downtime: ${downtime_human}
Recorded at: ${now_iso}
"

printf "%s\n" "$summary" > "${OUTDIR}/last.txt"
printf "%s | boot_since=%s | downtime=%s | %s\n" "$now_iso" "$boot_since" "$downtime_human" "$boot_time" >> "$LOG"
EOF
sudo chmod 0755 /usr/local/sbin/boot-metrics

sudo tee /etc/systemd/system/boot-metrics.service >/dev/null <<'EOF'
[Unit]
Description=Record boot metrics (boot time + downtime estimate)
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/boot-metrics

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now boot-metrics.service

sudo tee /etc/update-motd.d/20-boot-metrics >/dev/null <<'EOF'
#!/bin/sh
echo
echo "=== System status ==="
echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
if [ -r /var/lib/boot-metrics/last.txt ]; then
  cat /var/lib/boot-metrics/last.txt
fi
echo
EOF
sudo chmod 0755 /etc/update-motd.d/20-boot-metrics
```

