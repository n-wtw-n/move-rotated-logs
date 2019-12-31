# move-rotated-logs

A script on a timer that backs up rotated logsto the desired destination.

## Getting Started

$ git clone https://github.com/n-wtw-n/move-rotated-logs.git

### Prerequisites
```
tar, find, bash
```
### Installing

```
After cloning, 
$ cd move-rotated-logs
$ chmod +x install.sh
$ sudo ./install.sh "/path/to/logs.tar.gz"
```
This will create /etc/systemd/system/move-rotated-logs.timer, /etc/systemd/system/move-rotated-logs.service, 
and /usr/local/bin/moverotatedlogs. Every 24 hours and 5 minutes rotated logs will be zipped up and moved to /path/to/logs.tar.gz.
