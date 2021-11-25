#!/bin/bash

bash 00-setupvars.sh
bash 0-preinstall.sh
source settings
arch-chroot /mnt /root/GraniteArch/1-setup.sh
arch-chroot /mnt /usr/bin/runuser -u $USER -- /home/$USER/GraniteArch/2-user.sh
arch-chroot /mnt /root/GraniteArch/3-post-setup.sh
