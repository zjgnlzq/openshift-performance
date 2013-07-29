#!/bin/bash
#jbosseap https://github.com/openshift/spring-eap6-quickstart
#php https://github.com/openshift/cakephp-example
pwd=$(pwd)

. function.sh
app_types="jbosseap-6.0 php-5.3 diy-0.1 python-2.6 ruby-1.9 ruby-1.8 perl-5.10"

app_config()
{
app=$1
case $app in
	"jbosseap-6.0")
		git_repo="git://github.com/openshift/spring-eap6-quickstart.git" 
		check_pattern="Spring MVC Starter Application"
		app_name=spring
	;;
	"php-5.3")
		git_repo="git://github.com/openshift/cakephp-example.git" 
		check_pattern="CakePHP: the rapid development php framework"
		app_name=cake
	;;
	"diy-0.1")
		git_repo="git://github.com/openshift/weinre-quickstart.git" 
		check_pattern="debug client user interface"
		app_name=weinre
	;;
	"python-2.6")
		git_repo="git://github.com/openshift/openshiftwebpy.git" 
		check_pattern="OpenShift"
		app_name=openshiftwebpy
	;;
	"ruby-1.9")
		git_repo="git://github.com/openshift/sinatra-example.git" 
		check_pattern="the time where this server lives is"
		app_name=sinatra
	;;
	"ruby-1.8")
		git_repo="git://github.com/openshift/gollum-openshifted.git" 
		check_pattern="Create New Page"
		app_name=gollum
	;;
	"perl-5.10")
		git_repo="git://github.com/openshift/dancer-example.git" 
		check_pattern="Perl is dancing"
		app_name=dancer
	;;
esac 
}

####################
# $0 $app_type
####################
quickstart()
{
app=$1
#app_create $app
run rhc app create $app_name $app -p${passwd} --timeout 360
cd $app_name
git remote add upstream -m master git://github.com/openshift/spring-eap6-quickstart.git
git pull -s recursive -X theirs upstream master
if [ "$app" = "jbosseap-6.0" ];then
	git rm src/main/webapp/index.html &&
	git commit -m 'Removed default index.html'
fi
git push
value1=$?
url_check $app_name $check_pattern
value2=$?
return $value1 && $value2
}

run ssh_auth_config

for app in $app_types;do
	[ -d $pwd/testdir ] && rm -rf $pwd/testdir/* || mkdir testdir
        cd testdir
	run app_config $app
	run quickstart $app
	cd -
done
