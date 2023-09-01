#!/bin/bash

bash 00-setupvars.sh |& tee install.log
#read -p "00 Finished. Continue?" con
bash 0-preinstall.sh |& tee -a install.log
#read -p "0 Finished. Continue?" con
source ./settings
arch-chroot /mnt /root/GraniteArch/1-setup.sh |& tee -a install.log
#read -p "1 Finished. Continue?" con
arch-chroot /mnt /usr/bin/runuser -u $USER -- /home/$USER/build/GraniteArch/2-user.sh |& tee -a install.log
#read -p "2 Finished. Continue?" con
arch-chroot /mnt /root/GraniteArch/3-post-setup.sh |& tee -a install.log
rm -r /mnt/root/GraniteArch/
read -p "Install finished. Reboot? [Y/n]:" Ans
case $Ans in
   y|Y|yes|Yes|YES|"") reboot ;;
esac
