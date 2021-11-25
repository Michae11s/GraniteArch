#!/bin/bash

    bash 0-preinstall.sh
    arch-chroot /mnt /root/GraniteArch/1-setup.sh
    source /mnt/root/GraniteArch/install.conf
    arch-chroot /mnt /usr/bin/runuser -u $username -- /home/$username/GraniteArch/2-user.sh
    arch-chroot /mnt /root/GraniteArch/3-post-setup.sh
