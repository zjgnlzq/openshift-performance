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

function create_app() {
    local app_name="$1"
    local cart_name="$2"
    local rhlogin="$3"
    local passwd="$4"
    shift 4
    local options="${@}"

    echo "Creating ${cart_name} app - ${app_name} ..."
    command="rm -rf ${app_name} && rhc app create ${app_name} ${cart_name} -p ${passwd} -l ${rhlogin} ${options}"
    run_command "${command}"
    return $?
}

function add_cart() {
    local app_name="$1"
    local cart_name="$2"
    local rhlogin="$3"
    local passwd="$4"
    shift 4
    local options="${@}"

    echo "Embedding ${cart_name} to ${app_name} app ..."
    command="rhc cartridge add ${cart_name} -a ${app_name} -l ${rhlogin} -p ${passwd} ${options}"
    run_command "${command}"
    return $?
}

function remove_cart() {
    local app_name="$1"
    local cart_name="$2"
    local rhlogin="$3"
    local passwd="$4"
    shift 4
    local options="${@}"

    echo "Removing ${cart_name} from ${app_name} app ..."
    command="rhc cartridge remove ${cart_name} -a ${app_name} -l ${rhlogin} -p ${passwd} ${options}"
    run_command "${command}"
    return $?
}

function destroy_app() {
    local app_name="$1"
    local rhlogin="$2"
    local passwd="$3"
    local options="$4"
    shift 4
    local options="${@}"

    echo "Destroying ${app_name} app ..."
    command="rhc app delete ${app_name} -l ${rhlogin} -p ${passwd} --confirm ${options}"
    run_command "${command}"
    return $?
}

get_date() {
    local date=$(date +"%Y-%m-%d-%H-%M-%S")
    echo "$date"
}

get_db_host() {
    local output="$1"
    echo "${output}" | grep 'Connection URL:' | grep -v 'MySQL gear-local' | awk -F'/' '{print $3}' | awk -F: '{print $1}'
    return $?
}

get_db_port() {
    local output="$1"
    echo "${output}" | grep 'Connection URL:' | grep -v 'MySQL gear-local' | awk -F'/' '{print $3}' | awk -F: '{print $2}'
    return $?
}

get_db_passwd() {
    local output="$1"
    echo "${output}" | grep 'Root Password:' | awk '{print $NF}'
    return $?
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