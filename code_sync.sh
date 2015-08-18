#!/bin/sh
#desc:rsync code to product server and backup server
#version:1.0
#os: centos
#common variables
std_log=/var/log/code_sync.sh   #script normal stdout
code_version_server="192.168.1.200"  #code server
code_path="hencai"      #code rsync module
expires_days=7  #log expirese
pro_tmp="/data/shell/tmp/`date +%F`"          #script runtime tmp
rsync_bin="/usr/bin/rsync"  #rsync path
#rsync_exclude=".svn|*.gz|*.cache|*.txt|_tmp|temp|pma|dsn.php|gem*|global_config.php"    #rsync exclude file. example:tmp|*.cache
OLD_IFS="$IFS"  #backup IFS
local_product_dir="/www/releases/product/"         #local code deploy dir
#
##
trap "rm -rf $pro_tmp" 0          #trap exit singal and rm exec pro_tmp
##
#log script running log.
exec_log()
{
if [ "$1" ]
then
echo "`date +%Y%m%d:%H%M%s` $1"  >>$std_log
fi
}
##
#code rsync
sync_code()
{
exec_log "sync_code process running."
if [ "$rsync_exclude" ]
then
IFS='|'
exclude_arr=($rsync_exclude)
for e_arr in ${exclude_arr[@]}
do
echo $e_arr >>$pro_tmp/code_exclude_list
done
$rsync_bin -avz --delete  --exclude-from="$pro_tmp/code_exclude_list"  $code_version_server::$code_path/* $local_product_dir  >>$std_log
else
$rsync_bin -avz --delete $code_version_server::$code_path/ $local_product_dir  >>$std_log
fi
IFS="$OLD_IFS"
}
#
#archive this script exec log 
archive_gz()
{
#
exec_log "archive_gz log process running."
if [ -f $std_log ] && [ ! -f $std_log.`date +%Y%m%d`.tar.gz ]
then
cd `dirname  $std_log` && mv `basename $std_log` `basename $std_log`.`date +%Y%m%d` && tar -czf `basename $std_log`.`date +%Y%m%d`.tar.gz `basename $std_log`.`date +%Y%m%d`
rm -f $std_log.`date +%Y%m%d --date "$expires_days days ago"`.tar.gz
rm -f $std_log.`date +%Y%m%d`
fi
}
##
##main process
#
#
if [ "$expires_days" ]
then
archive_gz
fi
#check script tmp dir
if [ ! -d $pro_tmp ]
then
mkdir -p $pro_tmp
fi
#
if [  -x  $rsync_bin ] && [ "$code_version_server" ] && [ "$code_path" ] && [ -d $local_product_dir ]
then
exec_log "sync_code main process start running."
sync_code
exec_log "sync_code main process finsh running."
fi
##
exit

