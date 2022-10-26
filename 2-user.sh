#!/usr/bin/env bash
#-------------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗████████╗██╗████████╗██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║╚══██╔══╝██║╚══██╔══╝██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║   ██║   ██║   ██║   ██║   ██║███████╗
#  ██╔══██║██╔══██╗██║     ██╔══██║   ██║   ██║   ██║   ██║   ██║╚════██║
#  ██║  ██║██║  ██║╚██████╗██║  ██║   ██║   ██║   ██║   ╚██████╔╝███████║
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝   ╚═╝    ╚═════╝ ╚══════╝
#-------------------------------------------------------------------------
cd ~/build/GraniteArch
source ./settings
source ./Pkgs
cd ~
mkdir ~/.local
xdg-user-dirs-update

#Setup gits
git config --global user.email $GEMAIL
git config --global user.name $GNAME
git config --global credential.helper store

echo -e "\nCloning Gits\n"
# You can solve users running this script as root with this and then doing the same for the next for statement. However I will leave this up to you.

echo "CLONING: AURACLE"
mkdir ~/build
cd ~/build
git clone "https://aur.archlinux.org/auracle-git.git"
cd auracle-git
makepkg -si --noconfirm

echo "Loading Dotfiles"
cd ~/build
git clone https://github.com/Michae11s/dots.git
cd dots
./deployDots.sh
cp ./.fehbg ~/
~/.fehbg
ln -sf ~/build/dots/.local/bin/ ~/.local/bin
ln -sf ~/.local/bin/ ~/bin

echo "Loading the pacUpdt timer"
cd ~/build/
git clone https://github.com/Michae11s/pacUpdt.git
cd pacUpdt/
makepkg -si --noconfirm
sudo systemctl enable pacUpdt.timer

if (( $GUI )); then
	echo "Import spotify gpg key"
	curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | gpg --import -
	for PKG in "${AURPKGS[@]}"; do
		cd ~/build
		echo "****************************************************"
		echo "*** Installing: "$PKG" ***"
		echo "****************************************************"
		auracle clone $PKG
		cd $PKG
		makepkg -si --noconfirm
	done

	#run inital flavours commands
	flavours update all
fi

~/build/dots/deployDots.sh

echo "*************************"
echo "* Checking if in VMware *"
echo "*************************"

if [[ $(lspci | grep -c VMware) ]]; then
	sudo pacman -S --noconfirm open-vm-tools gtkmm gtk2
	sudo systemctl enable vmtoolsd
fi

echo -e "\nDone 2-user\n"
exit
