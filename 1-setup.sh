#!/usr/bin/env bash
#-------------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗████████╗██╗████████╗██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║╚══██╔══╝██║╚══██╔══╝██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║   ██║   ██║   ██║   ██║   ██║███████╗
#  ██╔══██║██╔══██╗██║     ██╔══██║   ██║   ██║   ██║   ██║   ██║╚════██║
#  ██║  ██║██║  ██║╚██████╗██║  ██║   ██║   ██║   ██║   ╚██████╔╝███████║
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝   ╚═╝    ╚═════╝ ╚══════╝
#-------------------------------------------------------------------------
cd /root/GraniteArch
source ./settings
source ./Pkgs
echo "--------------------------------------"
echo "--          Network Setup           --"
echo "--------------------------------------"
pacman -S networkmanager dhclient --noconfirm --needed
systemctl enable --now NetworkManager
echo "-------------------------------------------------"
echo "Setting up mirrors for optimal download          "
echo "-------------------------------------------------"
pacman -S --noconfirm pacman-contrib curl
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

nc=$(grep -c ^processor /proc/cpuinfo)
echo "You have " $nc" cores."
echo "-------------------------------------------------"
echo "Changing the makeflags for "$nc" cores."
TOTALMEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[  $TOTALMEM -gt 8000000 ]]; then
sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$nc\"/g" /etc/makepkg.conf
echo "Changing the compression settings for "$nc" cores."
sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g" /etc/makepkg.conf
fi
echo "-------------------------------------------------"
echo "       Setup Language to US and set locale       "
echo "-------------------------------------------------"
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc
cp -r /dots/etc/* /etc/
locale-gen

pacman -Sy --noconfirm

echo -e "\nInstalling Base System\n"

#PKGS=(
#'mesa' # Essential Xorg First
#'xorg'
#'xorg-server'
#'xorg-apps'
#'xorg-drivers'
#'xorg-xkill'
#'xorg-xinit'
#'xterm'
#'plasma-desktop' # KDE Load second
#'alsa-plugins' # audio plugins
#'alsa-utils' # audio utils
#'ark' # compression
#'audiocd-kio' 
#'autoconf' # build
#'automake' # build
#'base'
#'bash-completion'
#'bind'
#'binutils'
#'bison'
#'bluedevil'
#'bluez'
#'bluez-libs'
#'bluez-utils'
#'breeze'
#'breeze-gtk'
#'bridge-utils'
#'btrfs-progs'
#'celluloid' # video players
#'cmatrix'
#'code' # Visual Studio code
#'cronie'
#'cups'
#'dialog'
#'discover'
#'dolphin'
#'dosfstools'
#'dtc'
#'efibootmgr' # EFI boot
#'egl-wayland'
#'exfat-utils'
#'extra-cmake-modules'
#'filelight'
#'flex'
#'fuse2'
#'fuse3'
#'fuseiso'
#'gamemode'
#'gcc'
#'gimp' # Photo editing
#'git'
#'gparted' # partition management
#'gptfdisk'
#'grub'
#'grub-customizer'
#'gst-libav'
#'gst-plugins-good'
#'gst-plugins-ugly'
#'gwenview'
#'haveged'
#'htop'
#'iptables-nft'
#'jdk-openjdk' # Java 17
#'kate'
#'kcodecs'
#'kcoreaddons'
#'kdeplasma-addons'
#'kde-gtk-config'
#'kinfocenter'
#'kscreen'
#'kvantum-qt5'
#'kitty'
#'konsole'
#'kscreen'
#'layer-shell-qt'
#'libdvdcss'
#'libnewt'
#'libtool'
#'linux'
#'linux-firmware'
#'linux-headers'
#'lsof'
#'lutris'
#'lzop'
#'m4'
#'make'
#'milou'
#'nano'
#'neofetch'
#'networkmanager'
#'ntfs-3g'
#'ntp'
#'okular'
#'openbsd-netcat'
#'openssh'
#'os-prober'
#'oxygen'
#'p7zip'
#'pacman-contrib'
#'patch'
#'picom'
#'pkgconf'
#'plasma-meta'
#'plasma-nm'
#'powerdevil'
#'powerline-fonts'
#'print-manager'
#'pulseaudio'
#'pulseaudio-alsa'
#'pulseaudio-bluetooth'
#'python-notify2'
#'python-psutil'
#'python-pyqt5'
#'python-pip'
#'qemu'
#'rsync'
#'sddm'
#'sddm-kcm'
#'snapper'
#'spectacle'
#'steam'
#'sudo'
#'swtpm'
#'synergy'
#'systemsettings'
#'terminus-font'
#'traceroute'
#'ufw'
#'unrar'
#'unzip'
#'usbutils'
#'vim'
#'virt-manager'
#'virt-viewer'
#'wget'
#'which'
#'wine-gecko'
#'wine-mono'
#'winetricks'
#'xdg-desktop-portal-kde'
#'xdg-user-dirs'
#'zeroconf-ioslave'
#'zip'
#'zsh'
#'zsh-syntax-highlighting'
#'zsh-autosuggestions'
#)

sudo pacman -S ${BASEPKGS[@]} --noconfirm --needed

if [[ $GUI ]]; then
	echo "INSTALLING GRAPHICAL ENVIRONMENT"
	sudo pacman -S ${GUIPKGS[@]} --noconfirm --needed
fi

#
# determine processor type and install microcode
# 
proc_type=$(lscpu | awk '/Vendor ID:/ {print $3}')
case "$proc_type" in
	GenuineIntel)
		print "Installing Intel microcode"
		pacman -S --noconfirm intel-ucode
		proc_ucode=intel-ucode.img
		;;
	AuthenticAMD)
		print "Installing AMD microcode"
		pacman -S --noconfirm amd-ucode
		proc_ucode=amd-ucode.img
		;;
esac	

# Graphics Drivers find and install
if lspci | grep -E "NVIDIA|GeForce"; then
    pacman -S nvidia --noconfirm --needed
elif lspci | grep -E "Radeon"; then
    pacman -S xf86-video-amdgpu --noconfirm --needed
elif lspci | grep -E "Integrated Graphics Controller"; then
    pacman -S libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils --needed --noconfirm
fi

#add the user
useradd -m -G wheel,adm,rfkill,uucp -s /bin/bash $USER 
echo -e $UPASS"\n"$UPASS | passwd $USER
echo -e $RPASS"\n"$RPASS | passwd
mkdir -p /home/$USER/build/
cp -R /root/GraniteArch /home/$USER/build/
chown -R $USER: /home/$USER/build
echo $HNAME > /etc/hostname
echo "127.0.0.1 "$HNAME >> /etc/hosts
