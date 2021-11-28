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

#PKGS=(
#'autojump'
#'awesome-terminal-fonts'
#'brave-bin' # Brave Browser
#'dxvk-bin' # DXVK DirectX to Vulcan
#'github-desktop-bin' # Github Desktop sync
#'lightly-git'
#'lightlyshaders-git'
#'mangohud' # Gaming FPS Counter
#'mangohud-common'
#'nerd-fonts-fira-code'
#'nordic-darker-standard-buttons-theme'
#'nordic-darker-theme'
#'nordic-kde-git'
#'nordic-theme'
#'noto-fonts-emoji'
#'papirus-icon-theme'
#'plasma-pa'
#'ocs-url' # install packages from websites
#'sddm-nordic-theme-git'
#'snapper-gui-git'
#'ttf-droid'
#'ttf-hack'
#'ttf-meslo' # Nerdfont package
#'ttf-roboto'
#'zoom' # video conferences
#'snap-pac'
#)

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
~/build/dots/deployDots.sh

echo "*************************"
echo "* Checking if in VMware *"
echo "*************************"

if [[ $(lspci | grep -c VMware) ]]; then
	sudo pacman -S open-vm-tools gtkmm gtk2
	sudo systemctl enable vmtoolsd
fi

echo -e "\nDone 2-user\n"
exit
