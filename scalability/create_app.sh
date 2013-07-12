#!/bin/sh
source $(pwd)/lib.sh

source $(pwd)/create_app.conf

log_file=$(initial_log)

start=210
end=6000


i=$start
while [ $i -le $end ]; do
    create_app ${APP_PREFIX}${i} ${APP_TYPE} ${RHLOGIN} ${PASSWD}
    ret=$?
    if [ X"$ret" != X"0"  ]; then
        break
    fi
    i=$(expr $i + 1)
    echo '---------------------------------' | tee -a ${log_file}
done


