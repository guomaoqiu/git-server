#!/bin/sh
#
#deploy_project.sh
#version: 0.1.0
#desc:deploy update version to online servers
#
#
update_dir="/root/webprojects/var" #every time upload code main dir
bak_dir="/codedata/bak/deploy" #backup file main dir
gibin="/usr/bin/git" #git bin path
projects="hencai" #如有多个项目名称  逗号分割
#
#pull code
#$1 - project name
pullcode()
{
 if [[ $projects == *${1}* ]] ; then
     if cd $update_dir/$1 && $gibin pull ;then
		echo "create pull flag lock."
		touch /deploy/$1/${1}.lock 
		echo "`date` git pull code success"
	 else
		echo "`date` git pull code error" && exit 1
	 fi
 else
     echo "`date` $1 project name is invalid." && exit 1
 fi
}
#
#git push code to localremote center
#$1 - project name
#$2 - commit version nubmer string,eg: version1.2.3
updatecode()
{
 if [ ! -f "/deploy/$1/${1}.lock" ] ;then
 	echo "please before you upload file or update,run pull fisrt." && exit 1
 fi
 if [[ $projects == *${1}* ]] && [ ! -z "$2" ] ; then
     if cd $update_dir/$1 && $gibin add . -A && $gibin commit -m "$2" -a && git push origin master ;then
		echo "`date` git update code success"
		echo "unlock flag"
 		rm -f /deploy/$1/${1}.lock
	 else
		rm -f /deploy/$1/${1}.lock
		echo "`date` git update code error" && exit 1
	 fi
 else
     rm -f /deploy/$1/${1}.lock
     echo "`date` $1 project name is invalid or version string is null." && exit 1
 fi
}
#
#use git revert restore last commit version
#$1 - project name
#$2 - last commit version nubmer string,eg: version1.2.3
restoreversion()
{
 if [[ $projects == *${1}* ]] && [ ! -z "$2" ] ; then
     if cd $update_dir/$1 &&  $gibin revert -n HEAD && $gibin add . -A && $gibin commit -m "$2" -a && git push origin master ;then
		echo "`date` git restoreversion code success"
	 else
		echo "`date` git restoreversion code error" && exit 1
	 fi
 else
     echo "`date` $1 project name is invalid or restore version string is null." && exit 1
 fi
}
#restore single file from backup dir,only for last modify
#$1 - project name
#$2 - file path and name
#please check output command,and run that
#
restorefile()
{
 if [[ $projects == *${1}* ]] && [ -f "${bak_dir}/$1/`date +%Y%m%d`/releases/product_v1/$2" ] ; then
	echo "cp ${bak_dir}/$1/`date +%Y%m%d`/releases/product_v1/$2 $update_dir/$1/${2%/*}/"
	echo "cd ${update_dir}"
	echo "git add . -A"
	echo "git add -m \"$1 restore `date +%Y%m%d` \" -a"
	echo "git push origin master"
 else
	echo "project name error or file is not exist in backup" && exit 1
 fi
}
##
#
#main run 
#
#variables check
if [ ! -d "$update_dir" ] || [ ! -d "$bak_dir" ]  || [ ! -f "$gibin" ] || [   -z "$projects"  ] ;
then
	echo " some main dir or bin set error" && exit 1
fi
#
case $1 in
	pull)
		pullcode $2
	;;
	update)
		updatecode $2 $3
	;;
	rollversion)
		restoreversion $2 $3 
	;;	
	rollfile)
		restorefile $2 $3
	;;
	*)
		echo "usage: $0 pull hencai"  
		echo "usage: $0 update hencai"
		echo "usage: $0 rollversion hencai"
		echo "usage: $0 restorefile hencai"
	;;
	esac
	exit 0
#
