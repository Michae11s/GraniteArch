#!/bin/bash

bash 00-setupvars.sh
read -p "00 Finished. Continue?" con
bash 0-preinstall.sh
read -p "0 Finished. Continue?" con
source ./settings
arch-chroot /mnt /root/GraniteArch/1-setup.sh
read -p "1 Finished. Continue?" con
arch-chroot /mnt /usr/bin/runuser -u $USER -- /home/$USER/build/GraniteArch/2-user.sh
read -p "2 Finished. Continue?" con
arch-chroot /mnt /root/GraniteArch/3-post-setup.sh
