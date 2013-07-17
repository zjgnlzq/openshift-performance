#!/bin/bash
. ../common_func.sh
pwd=`pwd`
#monitor_script="monitor-localhost.sh"
monitor_script="system_monitor.sh"
time_str=`echo $1|cut -d'_' -f2|cut -d'.' -f1`
monitor_log="../log/monitor_server_${time_str}.log"

tail -f $1|while read app_info;do
	echo_blue "New app created, app info: $app_info"
	echo -e "\n### New app info: $app_info" >> $monitor_log
	while read server_alias server_ip server_passwd;do
	echo "####################### $server_alias INFO #######################" |tee -a $monitor_log
	task_ssh_root $server_ip $server_passwd "/opt/$monitor_script" |tee -a $monitor_log
	sed -i  "/spawn/,/root/d" $monitor_log
	done < server.conf
done
