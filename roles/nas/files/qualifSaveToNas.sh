#!/bin/sh
#sudo mount -t nfs 10.185.110.178:/volume1/NetBackup/ /mnt/nas
#check /etc/fstab for mount point details

######################################
# Clean previous logs
rm /var/log/saveToNas/*.bak
cd /var/log/saveToNas/
rename s/.log/.bak/ *.log

######################################
# Save to the NAS via rsync
dpkg -l > /home/qualif/Bureau/SAVE_TO_NAS/installed_packages
crontab -u qualif -l > /home/qualif/Bureau/SAVE_TO_NAS/crontab_qualif
crontab -l > /home/qualif/Bureau/SAVE_TO_NAS/crontab_root
mysqldump --user=test --password=univers MyTVTools > /home/qualif/Bureau/SAVE_TO_NAS/MyTVTools_dump.SQL
mysqldump --user=test --password=univers JUnitHistoryTools > /home/qualif/Bureau/SAVE_TO_NAS/JUnitHistoryTools_dump.SQL

rsync -av --force --del --exclude 'ZNE' /home/qualif/ /mnt/nas/banc_qualif/home/qualif/  --log-file /var/log/saveToNas/job1.log 
rc1=$?

rsync -av --force --del /etc/ /mnt/nas/banc_qualif/etc/  --log-file /var/log/saveToNas/job2.log
rc2=$?

rsync -av --force --del --exclude 'builds'  /var/lib/jenkins/ /mnt/nas/banc_qualif/var/lib/jenkins/  --log-file /var/log/saveToNas/job3.log
rc3=$?

rsync -av --force --del /home/standalone/ /mnt/nas/banc_qualif/home/standalone/  --log-file /var/log/saveToNas/job4.log
rc4=$?

rsync -av --force --del /var/www/ /mnt/nas/banc_qualif/var/www/  --log-file /var/log/saveToNas/job5.log
rc5=$?

rsync -av --force --del /usr/local/multicat-tools/videos/ /mnt/nas/banc_qualif/usr/local/multicat-tools/videos/  --log-file /var/log/saveToNas/job6.log
rc6=$?

sudo rsync -av --force --del /var/lib/tomcat8/ /mnt/nas/banc_qualif/var/lib/tomcat8/  --log-file /var/log/saveToNas/job6.log
rc7=$?

sudo rsync -av --force --del /usr/local/gwtjunithistory/ /mnt/nas/banc_qualif/usr/local/gwtjunithistory/  --log-file /var/log/saveToNas/job7.log
rc8=$?

rc=$(($rc1 + $rc2 + $rc3 + $rc4 + $rc5 + $rc6 + $rc7 + $rc8))
if [ $rc != 0 ] ; then
   echo "Erreur pendant le backup du banc de qualif. Plus de details dans /var/log/saveToNas/jobs*.log" > /var/log/saveToNas/status.log

   if [ $rc1 != 0 ] ; then
       echo "\nstatus = $rc1" >> /var/log/saveToNas/job1.log
       cat /var/log/saveToNas/job1.log | mail -s 'BACKUP QUALIF WARNING' archilog.newtv@orange.com
   fi
   if [ $rc2 != 0 ] ; then
       echo "\nstatus = $rc2" >> /var/log/saveToNas/job2.log
       cat /var/log/saveToNas/job2.log | mail -s 'BACKUP QUALIF WARNING' archilog.newtv@orange.com
   fi
   if [ $rc3 != 0 ] ; then
       echo "\nstatus = $rc3" >> /var/log/saveToNas/job3.log
       cat /var/log/saveToNas/job3.log | mail -s 'BACKUP QUALIF WARNING' archilog.newtv@orange.com
   fi
   if [ $rc4 != 0 ] ; then
       echo "\nstatus = $rc4" >> /var/log/saveToNas/job4.log
       cat /var/log/saveToNas/job4.log | mail -s 'BACKUP QUALIF WARNING' archilog.newtv@orange.com
   fi
   if [ $rc5 != 0 ] ; then
       echo "\nstatus = $rc5" >> /var/log/saveToNas/job5.log
       cat /var/log/saveToNas/job5.log | mail -s 'BACKUP QUALIF WARNING' archilog.newtv@orange.com
   fi
   if [ $rc6 != 0 ] ; then
       echo "\nstatus = $rc6" >> /var/log/saveToNas/job6.log
       cat /var/log/saveToNas/job6.log | mail -s 'BACKUP QUALIF WARNING' archilog.newtv@orange.com
   fi
   if [ $rc7 != 0 ] ; then
       echo "\nstatus = $rc7" >> /var/log/saveToNas/job7.log
       cat /var/log/saveToNas/job7.log | mail -s 'BACKUP QUALIF WARNING' archilog.newtv@orange.com
   fi
   if [ $rc8 != 0 ] ; then
       echo "\nstatus = $rc8" >> /var/log/saveToNas/job8.log
       cat /var/log/saveToNas/job8.log | mail -s 'BACKUP QUALIF WARNING' archilog.newtv@orange.com
   fi
else
   echo "Success" > /var/log/saveToNas/status.log
fi
