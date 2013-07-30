#!/bin/bash
which dstat > /dev/null
[ $? -ne 0 ] && yum install dstat -y
dstat -lasmt 1 3
pstree |egrep 'http|java|mongo'
free -m
