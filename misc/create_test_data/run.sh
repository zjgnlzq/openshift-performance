#!/bin/bash
script_dir=$(dirname $0)
pushd $script_dir >/dev/null && script_real_dir=$(pwd) && popd >/dev/null
LIB_DIR="${script_real_dir}/../../lib"

source ${LIB_DIR}/openshift.sh
source ${LIB_DIR}/util.sh

########################################
###             Main                 ###
########################################

rhlogin="jialiu@redhat.com"
namespace="jialiu"
password="redhat"

#jbossas_app="jbossastest"
python_app="reviewboard"
php_app="drupal"
perl_app="perlapp"
ruby18_app="redmine"
diy_app="diytest"
jbosseap_app="jbeapapp"
ruby19_app="railsapp"
jbossews_app="jbewsapp"
jbossews2_app="jbews2app"
#nodejs_app="etherpad"

scalable_python_app="pythonscal"
scalable_php_app="mediawiki"
scalable_perl_app="perlscal"
scalable_ruby18_app="ruby18scal"
scalable_jbosseap_app="jbeapscal"
scalable_ruby19_app="ruby19scal"
scalable_jbossews_app="jbewsscal"
scalable_jbossews2_app="jbews2scal"


#scalable_nodejs_app="nodejsscal"

# initial log
date=$(get_date)
log_file="log/my.${date}.log"
user_info_file="user_info.${date}"

if [ ! -d log ]; then
    mkdir log
fi

touch ${log_file}

#set -x

# create domains and keys
#echo -e "Create domains and keys ...\n"
#command="rhc-create-domain -n ${namespace1} -l ${rhlogin} -p ${password}"
#run_command "${command}"
#ret1=$?
#command="rhc-create-domain -n ${namespace2} -l ${rhlogin} -p ${password}"
#run_command "${command}"
#ret2=$?
#if [ X"$ret1" != X"0" ] || [ X"$ret2" != X"0" ]; then 
#    echo "Please destroy already existing domains or using non-exisiting domains"
#    exit 1
#fi

#key_name="mykey"
#dsa_key_file="~/.ssh/mykey"
#if [ ! -f ${dsa_key_file} ]; then
#    echo -e "Generating ssh-dsa key\n"
#    command="ssh-keygen -N '' -y -t dsa -f ${dsa_key_file}"
#    run_command "${command}"
#fi
#command="rhc-ctl-domain -n ${namespace1} -l ${rhlogin} -a ${key_name} -k ${dsa_key_file}.pub -p ${password}"
#run_command "${command}"

echo -e "Please input your choice\n 0: all data \n Specified app: python_app|perl_app|ruby18_app|diy_app|php_app|ruby19_app|jbossews_app|jbossews2_app|jbosseap_app|scalable_jbosseap_app|scalable_perl_app|scalable_ruby18_app|scalable_php_app|scalable_python_app|scalable_ruby19_app|scalable_jbossews_app|scalable_jbossews2_app"
read choice
# create app and embedding cartridge

echo -e "Creating test data ... \n"
echo '---------------------------------' | tee -a ${log_file}
create_app jenkins "jenkins" ${rhlogin} ${password}


echo '---------------------------------' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || [ X"$choice" == X"python_app" ]; then
    create_app ${python_app} "python" ${rhlogin} ${password} &&
    add_cart ${python_app} "mysql" "${rhlogin}" "${password}" &&
    run_command "cd ${python_app} && git remote add upstream -m master git://github.com/openshift/reviewboard-example.git && git pull -s recursive -X theirs upstream master && git push && cd -"
fi

echo '---------------------------------' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || [ X"$choice" == X"perl_app" ]; then 
    create_app ${perl_app} "perl-5.10" ${rhlogin} ${password} &&
    output=$(add_cart ${perl_app} "mysql" "${rhlogin}" "${password}") &&
    echo "${output}" &&
    db_passwd=$(get_db_passwd "${output}") &&
    db_user=$(get_db_user "${output}") &&
    run_command "cp -rf data/test.pl ${perl_app}/perl/ && cd ${perl_app} && sed -i -e 's/changeme_db/${perl_app}/g' -e 's/changeme_username/${db_user}/g' -e 's/changeme_password/${db_passwd}/g' perl/test.pl && git add . && git commit -a -mx && git push && cd -"
    run_command "rhc app stop ${perl_app} -l ${rhlogin} -p ${password}"
fi

echo '---------------------------------' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || [ X"$choice" == X"ruby18_app" ]; then 
    create_app ${ruby18_app} "ruby-1.8" ${rhlogin} ${password} &&
    add_cart ${ruby18_app} "mysql-5.1" "${rhlogin}" "${password}" &&
    run_command "rhc alias add ${ruby18_app} -l ${rhlogin} -p ${password} bar.${namespace}.com" &&
    run_command "cd ${ruby18_app} && rm -rf * && git remote add upstream -m master git://github.com/openshift/redmine-2.0-openshift-quickstart.git && git pull -s recursive -X theirs upstream master && git push && cd -"
fi

echo '---------------------------------' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || [ X"$choice" == X"diy_app" ]; then
    create_app ${diy_app} "diy-0.1" ${rhlogin} ${password} &&
    run_command "cd data && tar -xvzf django-1.3.1.tar.gz && cd - && mv data/Django-1.3.1/django ${diy_app}/diy/ && cd ${diy_app}/diy/ && unzip ../../data/myrawapp.zip && cd -" &&
    run_command "cp data/diyapp_start ${diy_app}/.openshift/action_hooks/start && cp data/diyapp_stop ${diy_app}/.openshift/action_hooks/stop" &&
    run_command "cd ${diy_app} && git add . && git commit -a -mx && git push && cd -"
fi

echo '---------------------------------' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || [ X"$choice" == X"php_app" ]; then
    create_app ${php_app} "php" ${rhlogin} ${password} &&
    add_cart ${php_app} "mysql" "${rhlogin}" "${password}" &&
    add_cart ${php_app} "cron" "${rhlogin}" "${password}" &&
    run_command "cd ${php_app} && git remote add upstream -m master git://github.com/openshift/drupal-example.git && git pull -s recursive -X theirs upstream master && git push && cd -"
    run_command "cd ${php_app} && echo 'date >> \${OPENSHIFT_REPO_DIR}php/date.txt' >.openshift/cron/minutely/date.sh && chmod +x .openshift/cron/minutely/date.sh && git add . && git commit -a -mx && git push && cd -"
fi


echo '---------------------------------' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || [ X"$choice" == X"ruby19_app" ]; then
    create_app ${ruby19_app} "ruby-1.9" ${rhlogin} ${password} &&
    add_cart ${ruby19_app} "mysql" "${rhlogin}" "${password}" &&
    run_command "cd ${ruby19_app} && git remote add upstream -m master git://github.com/openshift/rails-example.git && git pull -s recursive -X theirs upstream master && git push && cd -"
fi


echo '---------------------------------' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || [ X"$choice" == X"jbossews_app" ]; then
    create_app ${jbossews_app} "jbossews-1.0" ${rhlogin} ${password} &&
    add_cart ${jbossews_app} "mysql" "${rhlogin}" "${password}" &&
    run_command "cp -rf data/mysql.jsp ${jbossews_app}/src/main/webapp/ && mkdir -p ${jbossews_app}/src/main/webapp/WEB-INF/lib && cp -rf data/mysql-connector-java-5.1.20-bin.jar ${jbossews_app}/src/main/webapp/WEB-INF/lib && cd ${jbossews_app} && git add . && git commit -amt && git push && cd -"
fi


echo '---------------------------------' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || [ X"$choice" == X"jbossews2_app" ]; then
    create_app ${jbossews2_app} "jbossews-2.0" ${rhlogin} ${password} &&
    add_cart ${jbossews2_app} "mysql" "${rhlogin}" "${password}" &&
    run_command "cp -rf data/mysql.jsp ${jbossews2_app}/src/main/webapp/ && mkdir -p ${jbossews2_app}/src/main/webapp/WEB-INF/lib && cp -rf data/mysql-connector-java-5.1.20-bin.jar ${jbossews2_app}/src/main/webapp/WEB-INF/lib && cd ${jbossews2_app} && git add . && git commit -amt && git push && cd -"
fi


echo '---------------------------------' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || [ X"$choice" == X"jbosseap_app" ]; then
    create_app ${jbosseap_app} "jbosseap" ${rhlogin} ${password} &&
    add_cart ${jbosseap_app} "jenkins-client" "${rhlogin}" "${password}" &&
    add_cart ${jbosseap_app} "postgresql-8.4" "${rhlogin}" "${password}" &&
    run_command "cp -rf data/test.jsp ${jbosseap_app}/src/main/webapp/test.jsp && cd ${jbosseap_app} && git add . && git commit -a -mx && git push && cd -"
fi


echo '---------------------------------' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || [ X"$choice" == X"scalable_jbosseap_app" ]; then
    create_app ${scalable_jbosseap_app} "jbosseap-6.0" ${rhlogin} ${password} '--scaling' &&
    add_cart ${scalable_jbosseap_app} "mysql" ${rhlogin} ${password} &&
    run_command "cp -rf data/test1.jsp ${scalable_jbosseap_app}/src/main/webapp/test.jsp && cd ${scalable_jbosseap_app} && git add . && git commit -a -mx && git push && cd -"
fi

echo '---------------------------------' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || [ X"$choice" == X"scalable_perl_app" ]; then
    create_app ${scalable_perl_app} "perl-5.10" ${rhlogin} ${password} '--scaling' &&
    add_cart ${scalable_perl_app} "jenkins-client" "${rhlogin}" "${password}" &&
    output=$(add_cart ${scalable_perl_app} "mysql" "${rhlogin}" "${password}") &&
    echo "${output}" &&
    db_passwd=$(get_db_passwd "${output}") &&
    db_user=$(get_db_user "${output}") &&
    run_command "cp -rf data/test.pl ${scalable_perl_app}/perl/ && cd ${scalable_perl_app} && sed -i -e 's/changeme_db/${scalable_perl_app}/g' -e 's/changeme_username/${db_user}/g' -e 's/changeme_password/${db_passwd}/g' perl/test.pl && git add . && git commit -a -mx && git push && cd -"
fi

echo '---------------------------------' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || [ X"$choice" == X"scalable_ruby18_app" ]; then
    create_app ${scalable_ruby18_app} "ruby-1.8" ${rhlogin} ${password} '--scaling' &&
    output=$(add_cart ${scalable_ruby18_app} "mysql" "${rhlogin}" "${password}") &&
    echo "${output}" &&
    db_passwd=$(get_db_passwd "${output}") &&
    db_user=$(get_db_user "${output}") &&
    run_command "cp -r data/{config.ru,Gemfile} ${scalable_ruby18_app}/ && cd ${scalable_ruby18_app} && bundle install && sed -i -e 's/#dbname/${scalable_ruby18_app}/g' config.ru -e 's/#user/${db_user}/g' config.ru -e 's/#passwd/${db_passwd}/g' config.ru && git add . && git commit -amt && git push && cd -"
fi


echo '---------------------------------' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || [ X"$choice" == X"scalable_php_app" ]; then
    create_app ${scalable_php_app} "php" ${rhlogin} ${password} '--scaling' &&
    add_cart ${scalable_php_app} "mysql" "${rhlogin}" "${password}" &&
    run_command "cd ${scalable_php_app} && git remote add upstream -m master git://github.com/openshift/mediawiki-example.git && git pull -s recursive -X theirs upstream master && git push && cd -"
fi

echo '---------------------------------' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || [ X"$choice" == X"scalable_python_app" ]; then
    create_app ${scalable_python_app} "python" ${rhlogin} ${password} '--scaling' &&
    output=$(add_cart ${scalable_python_app} "mysql" "${rhlogin}" "${password}") &&
    echo "${output}" &&
    db_passwd=$(get_db_passwd "${output}") &&
    db_user=$(get_db_user "${output}") &&
    run_command "cp -r data/application ${scalable_python_app}/wsgi/ && cd ${scalable_python_app} && sed -i -e 's/#dbname/${scalable_python_app}/g' -e 's/#user/${db_user}/g' -e 's/#passwd/${db_passwd}/g' wsgi/application && git add . && git commit -amt && git push && cd -"
fi

echo '---------------------------------' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || [ X"$choice" == X"scalable_ruby19_app" ]; then
    create_app ${scalable_ruby19_app} "ruby-1.9" ${rhlogin} ${password} '--scaling' &&
    add_cart ${scalable_ruby19_app} "mysql" "${rhlogin}" "${password}" &&
    run_command "cd ${scalable_ruby19_app} && git remote add upstream -m master git://github.com/openshift/rails-example.git && git pull -s recursive -X theirs upstream master && git push && cd -"
fi


echo '---------------------------------' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || [ X"$choice" == X"scalable_jbossews_app" ]; then
    create_app ${scalable_jbossews_app} "jbossews-1.0" ${rhlogin} ${password} '--scaling' &&
    add_cart ${scalable_jbossews_app} "mysql" "${rhlogin}" "${password}" &&
    run_command "cp -rf data/mysql.jsp ${scalable_jbossews_app}/src/main/webapp/ && mkdir -p ${scalable_jbossews_app}/src/main/webapp/WEB-INF/lib && cp -rf data/mysql-connector-java-5.1.20-bin.jar ${scalable_jbossews_app}/src/main/webapp/WEB-INF/lib && cd ${scalable_jbossews_app} && git add . && git commit -amt && git push && cd -"
fi

echo '---------------------------------' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || [ X"$choice" == X"scalable_jbossews2_app" ]; then
    create_app ${scalable_jbossews2_app} "jbossews-2.0" ${rhlogin} ${password} '--scaling' &&
    add_cart ${scalable_jbossews2_app} "postgresql" "${rhlogin}" "${password}" &&
    run_command "cd ${scalable_jbossews2_app} && sed -i 's/Welcome to OpenShift/Welcome t1o OpenShift/g' src/main/webapp/index.html && git commit -a -m'modify title' && git push && cd -"
fi


echo '---------------------------------' | tee -a ${log_file}
# Save user info into file
#echo "Saving user info for ${namespace}"
#rhc domain show -l ${rhlogin} -p ${password} | tee ${user_info_file}.${namespace}

