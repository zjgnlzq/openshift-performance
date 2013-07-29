#!/bin/sh
#!/bin/bash
script_dir=$(dirname $0)
pushd $script_dir >/dev/null && script_real_dir=$(pwd) && popd >/dev/null
LIB_DIR="${script_real_dir}/../lib"

source ${LIB_DIR}/openshift.sh
source ${LIB_DIR}/util.sh

########################################
###             Main                 ###
########################################

rhlogin="jialiu@redhat.com"
namespace="jialiu"
password="redhat"

rest_api_force_clean_domain  $namespace $rhlogin $password
