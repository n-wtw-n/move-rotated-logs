# description
Sets up a systemd service and timer that backs up rotated logs from /var/log to desired destination. 
### installation
After cloning, 
$ cd move-rotated-logs
$ chmod +x install.sh
$ sudo ./install.sh "/path/to/logs.tar.gz"
This will create /etc/systemd/system/move-rotated-logs.timer, /etc/systemd/system/move-rotated-logs.service, 
and /usr/local/bin/moverotatedlogs. Every 24 hours and 5 minutes rotated logs will be zipped up and moved to /path/to/logs.tar.gz.
