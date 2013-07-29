#!/bin/bash
source "${LIB_DIR}/util.sh"

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

function control_app() {
    local app_name="$1"
    local rhlogin="$2"
    local passwd="$3"
    local action="$4"
    shift 4
    local options="${@}"

    echo "${action}ing ${app_name} app ..."
    command="rhc app ${action} ${app_name} -l ${rhlogin} -p ${passwd} ${options}"
    run_command "${command}"
    return $?
}


function destroy_app() {
    local app_name="$1"
    local rhlogin="$2"
    local passwd="$3"
    shift 3
    local options="${@}"

    echo "Destroying ${app_name} app ..."
    command="rhc app delete ${app_name} -l ${rhlogin} -p ${passwd} --confirm ${options}"
    run_command "${command}"
    return $?
}

function get_date() {
    local date=$(date +"%Y-%m-%d-%H-%M-%S")
    echo "$date"
}

function get_db_host() {
    local output="$1"
    echo "${output}" | grep 'Connection URL:' | grep -v 'MySQL gear-local' | awk -F'/' '{print $3}' | awk -F: '{print $1}'
    return $?
}

function get_db_port() {
    local output="$1"
    echo "${output}" | grep 'Connection URL:' | grep -v 'MySQL gear-local' | awk -F'/' '{print $3}' | awk -F: '{print $2}'
    return $?
}

function get_db_passwd() {
    local output="$1"
    echo "${output}" | grep 'Root Password:' | awk '{print $NF}'
    return $?
}

function get_db_user() {
    local output="$1"
    echo "${output}" | grep 'Root User:' | awk '{print $NF}'
    return $?
}

function get_libra_server() {
    if [ -f ~/.openshift/express.conf ]; then
        local config_file="${HOME}/.openshift/express.conf"
        grep "^libra_server" $config_file | cut -d= -f2 | tr -d " " | tr -d "'"
    elif [ -f /etc/openshift/express.conf ]; then
        config_file='/etc/openshift/express.conf'
        grep "^libra_server" $config_file | cut -d= -f2 | tr -d " " | tr -d "'"
    else
        echo "No found express config file !!!"
        return 1
    fi
}

function rest_api_force_clean_domain() {
    local domain_name="$1"
    local rhlogin="$2"
    local passwd="$3"
    command="curl -k -X DELETE -H 'Accept: application/xml' -d force=true --user ${rhlogin}:${passwd} https://$(get_libra_server)/broker/rest/domains/$domain_name"
    run_command "${command}"
}
