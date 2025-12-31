SHELL := /bin/bash
.RECIPEPREFIX := >

SNAP_DIR := snapshots/latest

.PHONY: help snapshot apt-update apt-upgrade apt-clean boot net dns ports services failed journal-warn pihole-status

help:
>@echo "Custom commands:"
>@echo "  snapshot      Write current system snapshots to $(SNAP_DIR)"
>@echo "  apt-update    apt update"
>@echo "  apt-upgrade   full upgrade (careful on testing)"
>@echo "  apt-clean     autoremove + clean"
>@echo "  boot          systemd boot timing + blame (top 20)"
>@echo "  net           ip + routes"
>@echo "  dns           resolver status + test lookups"
>@echo "  ports         listening sockets"
>@echo "  services      enabled services"
>@echo "  failed        failed units"
>@echo "  journal-warn  last 200 warnings/errors this boot"
>@echo "  pihole-status pihole status (if installed)"

snapshot:
>@mkdir -p "$(SNAP_DIR)"
>@echo "Writing snapshots to: $(SNAP_DIR)"
>@dpkg-query -W -f='$${binary:Package}\n' | sort > "$(SNAP_DIR)/packages.txt"
>@systemctl list-unit-files --state=enabled > "$(SNAP_DIR)/services-enabled.txt"
>@systemd-analyze time > "$(SNAP_DIR)/systemd-analyze.txt"
>@systemd-analyze blame > "$(SNAP_DIR)/systemd-blame.txt"
>@echo "Done."

apt-update:
>sudo apt update

apt-upgrade:
>sudo apt full-upgrade -y

apt-clean:
>sudo apt autoremove -y
>sudo apt clean

boot:
>@echo "== systemd-analyze time =="
>@systemd-analyze time
>@echo
>@echo "== systemd-analyze blame (top 20) =="
>@systemd-analyze blame | head -n 20
>@echo
>@echo "== critical chain =="
>@systemd-analyze critical-chain || true

net:
>@echo "== ip addr =="
>@ip -br a
>@echo
>@echo "== ipv4 routes =="
>@ip route
>@echo
>@echo "== ipv6 routes =="
>@ip -6 route || true

dns:
>@echo "== resolver status =="
>@{ command -v resolvectl >/dev/null && resolvectl status || cat /etc/resolv.conf; }
>@echo
>@echo "== DNS tests =="
>@echo "resolving deb.debian.org..."
>@getent hosts deb.debian.org || true
>@echo "resolving archive.raspberrypi.com..."
>@getent hosts archive.raspberrypi.com || true

ports:
>@sudo ss -tulpn

services:
>@systemctl list-unit-files --state=enabled

failed:
>@systemctl --failed || true

journal-warn:
>@sudo journalctl -b -p warning --no-pager | tail -n 200 || true

pihole-status:
>@command -v pihole >/dev/null && sudo pihole status || echo "pihole not installed"

.PHONY: tree
tree:
>python3 scripts/tree.py

