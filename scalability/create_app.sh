#!/bin/sh
script_dir=$(dirname $0)
pushd $script_dir >/dev/null && script_real_dir=$(pwd) && popd >/dev/null
LIB_DIR="${script_real_dir}/../lib"

source ${LIB_DIR}/openshift.sh
source ${LIB_DIR}/util.sh

########################################
###             Main                 ###
########################################
APP_TYPE="jbosseap-6.0"
RHLOGIN="jialiu@redhat.com"
PASSWD="redhat"
APP_PREFIX="app"
SCALING="True"
STOPPED="True"
START=1
END=4


log_file=$(initial_log)


i=$START
while [ $i -le $END ]; do
    if [ X"$SCALING" == X"True" ]; then
        create_app ${APP_PREFIX}${i} ${APP_TYPE} ${RHLOGIN} ${PASSWD} -s || break
    else
        create_app ${APP_PREFIX}${i} ${APP_TYPE} ${RHLOGIN} ${PASSWD} || break
    fi
    if [ X"$STOPPED" == X"True" ]; then
        control_app ${APP_PREFIX}${i} ${RHLOGIN} ${PASSWD} stop || break
    fi

    i=$(expr $i + 1)
    echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' | tee -a ${log_file}
done


