#!/bin/bash
#jbosseap https://github.com/openshift/spring-eap6-quickstart
#php https://github.com/openshift/cakephp-example

. function.sh
app_types="jbosseap-6.0"

app_config()
{
app=$1
case $app in
	"jbosseap-6.0")
		git_repo="git://github.com/openshift/spring-eap6-quickstart.git" 
		check_pattern="Spring MVC Starter Application"
	;;
	"php-5.3")
		git_repo="git://github.com/openshift/cakephp-example.git" 
		check_pattern="CakePHP: the rapid development php framework"
	;;
esac 
}

quickstart()
{
app=$1
app_create $app
cd $app_name
git remote add upstream -m master git://github.com/openshift/spring-eap6-quickstart.git
git pull -s recursive -X theirs upstream master
if [ "$app" = "jbosseap-6.0" ];then
	git rm src/main/webapp/index.html
	git commit -m 'Removed default index.html'
fi
git push
url_check $app_name $check_pattern
}

run app_config php-5.3
run quickstart php-5.3
