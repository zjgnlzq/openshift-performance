#!/bin/bash
. ./function.sh
ssh_auth_config
[ -f ./log ] || mkdir log
logfile=./log/sshkey_$(date +%Y%m%d-%H%M%S).log
rhc sshkey list -l $user -p $passwd > /dev/null
if [ $? -eq 0 ];then
    cur_sshkey=`rhc sshkey list -l $user -p $passwd|grep type |awk '{print $1}'`
    rhc sshkey remove $cur_sshkey
fi
testname=test001
number=0
while true;do 
    echo "# The $number times add/remove test, date: $(date +%Y%m%d-%H%M%S)" |tee -a $logfile
    rhc sshkey add $testname ~/.ssh/id_rsa.pub -l $user -p $passwd
    rhc sshkey remove $testname -l $user -p $passwd
    number=$((number + 1))
done
