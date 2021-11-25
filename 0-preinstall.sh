#!/usr/bin/env bash
#-------------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗████████╗██╗████████╗██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║╚══██╔══╝██║╚══██╔══╝██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║   ██║   ██║   ██║   ██║   ██║███████╗
#  ██╔══██║██╔══██╗██║     ██╔══██║   ██║   ██║   ██║   ██║   ██║╚════██║
#  ██║  ██║██║  ██║╚██████╗██║  ██║   ██║   ██║   ██║   ╚██████╔╝███████║
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝   ╚═╝    ╚═════╝ ╚══════╝
#-------------------------------------------------------------------------
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "-------------------------------------------------"
echo "Setting up mirrors for optimal download          "
echo "-------------------------------------------------"
iso=$(curl -4 ifconfig.co/country-iso)
timedatectl set-ntp true
pacman -S --noconfirm pacman-contrib terminus-font
setfont ter-v22b
sed -i 's/^#Para/Para/' /etc/pacman.conf
pacman -S --noconfirm curl rsync grub unzip

cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
echo -e "-------------------------------------------------------------------------"
echo -e "   █████╗ ██████╗  ██████╗██╗  ██╗████████╗██╗████████╗██╗   ██╗███████╗"
echo -e "  ██╔══██╗██╔══██╗██╔════╝██║  ██║╚══██╔══╝██║╚══██╔══╝██║   ██║██╔════╝"
echo -e "  ███████║██████╔╝██║     ███████║   ██║   ██║   ██║   ██║   ██║███████╗"
echo -e "  ██╔══██║██╔══██╗██║     ██╔══██║   ██║   ██║   ██║   ██║   ██║╚════██║"
echo -e "  ██║  ██║██║  ██║╚██████╗██║  ██║   ██║   ██║   ██║   ╚██████╔╝███████║"
echo -e "  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝   ╚═╝    ╚═════╝ ╚══════╝"
echo -e "-------------------------------------------------------------------------"
echo -e "-Setting up US & Canada mirrors for faster downloads"
echo -e "-------------------------------------------------------------------------"

#download new mirrorlist and sort by fastest
cd /etc/pacman.d/
curl "https://archlinux.org/mirrorlist/?country=CA&country=US&protocol=http&protocol=https&ip_version=4&use_mirror_status=on" -o "mirrorlist.new"
sed -i 's/^#Server/Server/' 'mirrorlist.new'
rankmirrors -n 10 mirrorlist.new > mirrorlist
cd /

mkdir /mnt


echo -e "\nInstalling prereqs...\n$HR"
pacman -S --noconfirm gptfdisk btrfs-progs

echo "-------------------------------------------------"
echo "-------select your disk to format----------------"
echo "-------------------------------------------------"
lsblk
echo "Please enter disk to work on: (example /dev/sda)"
read DISK
echo "THIS WILL FORMAT AND DELETE ALL DATA ON THE DISK"
read -p "are you sure you want to continue (Y/N):" formatdisk
case $formatdisk in

y|Y|yes|Yes|YES)
echo "--------------------------------------"
echo -e "\nFormatting disk...\n$HR"
echo "--------------------------------------"

# disk prep
sgdisk -Z ${DISK} # zap all on disk
sgdisk -a 2048 -o ${DISK} # new gpt disk 2048 alignment

# create partitions
sgdisk -n 1::+1M --typecode=1:ef02 --change-name=1:'BIOSBOOT' ${DISK} # partition 1 (BIOS Boot Partition)
sgdisk -n 2::+100M --typecode=2:ef00 --change-name=2:'EFIBOOT' ${DISK} # partition 2 (UEFI Boot Partition)
sgdisk -n 3::-10G --typecode=3:8300 --change-name=3:'ROOT' ${DISK} # partition 3 (Root), default start, minus 10G for swap
sgdisk -n 4::- --typecode=4:8200 --change-name=4:'SWAP' ${Disk}
if [[ ! -d "/sys/firmware/efi" ]]; then
    sgdisk -A 1:set:2 ${DISK}
fi

# make filesystems
echo -e "\nCreating Filesystems...\n$HR"
if [[ ${DISK} =~ "nvme" ]]; then
mkfs.vfat -F32 -n "EFIBOOT" "${DISK}p2"
mkfs.ext4 -L "ROOT" "${DISK}p3" -f
mount "${DISK}p3" /mnt
mkswap "${DISK}p4"
swapon "${DISK}p4"
else
mkfs.vfat -F32 -n "EFIBOOT" "${DISK}2"
mkfs.ext4 -L "ROOT" "${DISK}3" -f
mount "${DISK}3" /mnt
mkswap "${DISK}4"
swapon "${DISK}4"
fi
;;
esac

mkdir /mnt/boot
mount -t vfat -L EFIBOOT /mnt/boot/
mkdir /mnt/boot/efi

if ! grep -qs '/mnt' /proc/mounts; then
    echo "Drive is not mounted can not continue"
    echo "Rebooting in 3 Seconds ..." && sleep 1
    echo "Rebooting in 2 Seconds ..." && sleep 1
    echo "Rebooting in 1 Second ..." && sleep 1
    reboot now
fi

echo "--------------------------------------"
echo "-- Arch Install on Main Drive       --"
echo "--------------------------------------"
pacstrap /mnt base base-devel linux linux-firmware neovim git wget curl archlinux-keyring libnewt unzip --noconfirm --needed
genfstab -U /mnt >> /mnt/etc/fstab
echo "keyserver hkp://keyserver.ubuntu.com" >> /mnt/etc/pacman.d/gnupg/gpg.conf
cp -R ${SCRIPT_DIR} /mnt/root/GraniteArch
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
curl -L -O https://github.com/Michae11s/dots/archive/main.zip
unzip main.zip
mv dots-main /mnt/dots/

echo "--------------------------------------"
echo "--GRUB BIOS Bootloader Install&Check--"
echo "--------------------------------------"
if [[ ! -d "/sys/firmware/efi" ]]; then
    grub-install --boot-directory=/mnt/boot ${DISK}
fi
echo "--------------------------------------"
echo "--   SYSTEM READY FOR 1-setup       --"
echo "--------------------------------------"
