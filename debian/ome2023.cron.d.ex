#
# Regular cron jobs for the ome2023 package
#
0 4	* * *	root	[ -x /usr/bin/ome2023_maintenance ] && /usr/bin/ome2023_maintenance
