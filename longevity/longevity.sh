#!/bin/bash
. ./function.sh

[ -d log ] || mkdir log
app_type=$1
pwd=$(pwd)
time=$(date +%Y%m%d-%H%M%S)

#log define
log="$pwd/log/${0%.*}_${time}.log"
cycle_log="$pwd/log/cycle_$time.log"
#monitor_script="monitor-localhost.sh"
monitor_script="system_monitor.sh"

#no parameter
app_create_all()
{
	for scale in on off;do
		for app in $app_types;do
			if [ "$app" = "diy-0.1" ] && [ "$scale" = "on" ];then
				echo "Diy is cann't support scalable !"
				continue
			fi
			for cartridge_type in $cartridges;do
				if [ "$scale" = "on" ] && [ "$cartridge_type" = "cron-1.4" ];then
					echo "Cron-1.4 is can not embedded to scalable application!"
				elif [ "$app" = "jbosseap-6.0" ] && [ "$cartridge_type" = "cron-1.4" ];then
					echo "Cron-1.4 is not support jbosseap-6.0"
				elif [ "$scale" = "off" ];then
					run app_create $app
					#run url_check $app_name
					run cartridge_add $cartridge_type $app_name
					#run url_check $app_name
					echo "$app_name			$cartridge_type				nonscalable		$(date +%Y%m%d-%H%M%S)" >> $log
				else
					run app_create $app -s
					#run url_check $app_name
					run cartridge_add $cartridge_type $app_name
					#run url_check $app_name
					echo "$app_name			$cartridge_type				scalable		$(date +%Y%m%d-%H%M%S)" >> $log
				fi
			done
		done
	done
	echo_yellow "Already have $(($app_number+1)) applications"
}

#node and borker config for monitor
server_config()
{
if [ -f server.conf ];then
	echo "Will read config from server.conf"
else
	echo -n "Please input the server location: 1(BeiJing), 2(US):"
	read location
	if [ "$location" = "1" ];then
		passwd=redhat
	elif [ "$location" = "2" ];then
		passwd=dog8code
	else
		echo "Please setup the server's password!"
		exit 1
	fi
	nodes=`mco ping|grep time|awk '{print $1}'`	
	
	echo "$(hostname) $(hostname) $passwd" >>server.conf
	for node in $nodes;do
		echo "$node $node $passwd" >>server.conf	
	done
fi
}

#confirm broker and node config ,and deployment script to it
confirm_and_deployment()
{
while read server_alias server_ip server_passwd;do
	echo_yellow "Confirm your $server_alias:"
	echo "HOST: $server_alias,		IP: $server_ip,			Password: $server_passwd"
done < server.conf
echo_blue  "If these info is all right, please input 'yes' to continue: (yes/no)"
read confirm
if [ "$confirm" = "yes" ];then
	while read server_alias server_ip server_passwd;do
		scp_task "$monitor_script" $server_ip $server_passwd "/opt"
	done < server.conf
else 
	echo "Please run it again!"
    exit 1
fi
}
start_monitor()
{
	cd monitor
	server_config
	confirm_and_deployment
	./performance_monitor.sh ../log/${0%.*}_${time}.log  2>&1 > /dev/null &
	cd -
}

#monitor process start
>$log
start_monitor

run set_running_parameter
cycle=1
while true;do
	[ -d $pwd/testdir ] && rm -rf $pwd/testdir/* || mkdir testdir
	cd testdir
	echo "### Cycle $cycle start, time : $(date +%Y%m%d-%H%M%S)" |tee -a $cycle_log
	rhc domain show -predhat|grep jenkins-1.4 > /dev/null
	[ $? -ne 0 ] && run app_create jenkins-1.4
	echo "$app_name			jenkins-1.4				nonscalable		$(date +%Y%m%d-%H%M%S)" >> $log
	run app_create_all
	echo "### Cycle $cycle end,time : $(date +%Y%m%d-%H%M%S), have $(($app_number+1)) apps created." |tee -a $cycle_log
	run app_delete_all
	((cycle+=1))
	cd -
done
