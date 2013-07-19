#!/bin/bash
. ./function.sh
ssh_auth_config
[ -f ./log ] || mkdir log
logfile=./log/sshkey_$(date +%Y%m%d-%H%M%S).log

cur_sshkey=`rhc sshkey list -l $user -p $passwd`

rhc sshkey remove $cur_sshkey
testname=test001
number=0
while ture;do 
    echo "# $number add test, date: $(date +%Y%m%d-%H%M%S)"
    rhc sshkey add $testname ~/.ssh/id_rsa.pub -l $user -p $passwd
    rhc sshkey remove $testname -l $user -p $passwd
    number=$((number + 1))
done
