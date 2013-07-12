#!/bin/bash

run_command() {
    local command="$1"
    echo "Command: ${command}" 2>&1 | tee -a ${log_file}
    #Method 1
    #output=$(eval "${command}" 2>&1)
    #ret=$?
    #echo -e "$output\n" | tee -a ${log_file}

    #Method 2
    #(eval "${command}"; echo "ret=$?" >/tmp/ret) 2>&1 | tee -a ${log_file}
    #source /tmp/ret
    #rm -rf /tmp/ret
    #echo ""

    #Method 3
    eval "${command}" 2>&1 | tee -a ${log_file}
    ret=${PIPESTATUS[0]}
    return $ret
}


initial_log() {
    local date=$(get_date)
    local file_name=$(basename $0 | awk -F. '{print $1}')
    local logfile="log/${file_name}.${date}.log"
    if [ ! -d log ]; then
        mkdir log
    fi
    > ${logfile}
    echo ${logfile}
}

