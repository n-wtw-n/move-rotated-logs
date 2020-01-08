#! /bin/bash

(( $EUID == 0 )) || 
{ 
	printf '%s!\n' "This script must be run as root"
	exit 1
}
function usage () {
		printf '%s\n' "USAGE: $0 -f /path/to/tarfile"
		exit 0
}
if (( $# >= 1 )); then
	while (( $# )); do
		if [[ "$1" == '-'[a-zA-Z] ]]; then
			case "${1#-}" in
				f)
                                  	count=0
                                  	touch "$2" 2>/dev/null &
                                  	while ps -p "$!" >/dev/null 2>&1; do
                                  		if [[ "$count" == "6" ]]; then
                                       	 		logger "${2%/*} is unresponsive. Exiting."
                                                	exit 1
						else
                                        		sleep 1 && let count=count+1
                                        	fi
                                  	done
				  	if [[ -d "${2%/*}" ]]; then
				  		if [[ ! -d "$2" ]]; then
							unset 'count'
							tarfile="${2%/*}/$(date '+%Y-%m-%d').${2##*/}"; 
                                		else
							logger "$2 is a directory. Exiting"
						fi
					else
                                  		logger "${2%/*} is not a directory. Exiting."
                                  		exit 1
					fi
					;;
				h)
					usage
					;;
				*)
					printf '%s\n' "Unknown option: $1"
					usage
			esac
		else
			printf '%s\n' "Unknown option: $1"
			usage
		fi
		shift 2
	done
else
	usage
fi
mapfile -t logs < <(find /var/log -type f -regextype egrep -regex '.*([1-9]|[1-9].gz)')
[[ -z "${logs[@]}" ]] && 
{ 
	logger "There are no rotated logs to backup to $tarfile."
	exit 1
}
[[ -f "$tarfile" ]] && 
{ 
	gunzip "$tarfile" && tar --remove-files -rf "${tarfile%.gz}" "${logs[@]}" && gzip -9 "${tarfile%.gz}"
	result=$? 
} || 
{ 
	tar --remove-files -czf "$tarfile" "${logs[@]}"
	result=$?
}
(( "$result" == 0 )) && 
{
	logger "Backed up rotated logs from /var/log to $tarfile."
	exit 0
} ||
{
	logger "Failed to Backup rotated logs from /var/log to $tarfile."
	exit $result
}
