#! /bin/bash

(( $EUID != 0 )) && { printf '%s!\n' "This script must be run as root"; exit 1; }
if [[ -z "$1" ]]; then
	printf '%s\n' "USAGE: $0 \"/path/to/logs.tar.gz\""
	exit 1
elif [[ ! -d "${1%/*}" ]]; then
	printf '%s\n' "USAGE: $0 \"/path/to/logs.tar.gz\""
	exit 1
elif [[ ! "$1" =~ ^.*'.tar.gz'$ ]]; then
	file="$1.tar.gz"
fi
timer="/etc/systemd/system/move-rotated-logs.timer"
service="/etc/systemd/system/move-rotated-logs.service"
execf="/usr/local/bin/moverotatedlogs"
if [[ ! -f "$execf" ]]; then
	cp -f "${0%/*}/moverotatedlogs.sh" "$execf" >/dev/null 2>&1 || { printf '%s\n' "Could not copy move-rotated-logs.sh to ${execf%/*}."; exit 1; }
	chmod +x "$execf" >/dev/null 2>&1 || { printf '%s\n' "Could not make move-rotated-logs.sh to executable."; exit 1; }
fi
if [[ ! -f "$timer" ]]; then
	cat >"$timer" <<EOF
[Unit]
Description=Run post-logrotate script every 24 hours and 5 minutes

[Timer]
OnCalendar=*-*-* 00:05:00
Persistent=true

[Install]
WantedBy=timers.target
EOF
fi
if [[ ! -f "$service" ]]; then
	cat >"$service" <<EOF
[Unit]
Description=Backup rotated files to NAS

[Service]
Type=oneshot
ExecStart=/usr/local/bin/moverotatedlogs -f "${file-$1}"
User=root
EOF
fi
systemctl is-enabled "${timer##*/}" >/dev/null 2>&1 || systemctl enable "${timer##*/}"
systemctl start "${timer##*/}" >/dev/null 2>&1 
exit 0
