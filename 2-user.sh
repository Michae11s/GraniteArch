#!/usr/bin/env bash
#-------------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗████████╗██╗████████╗██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║╚══██╔══╝██║╚══██╔══╝██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║   ██║   ██║   ██║   ██║   ██║███████╗
#  ██╔══██║██╔══██╗██║     ██╔══██║   ██║   ██║   ██║   ██║   ██║╚════██║
#  ██║  ██║██║  ██║╚██████╗██║  ██║   ██║   ██║   ██║   ╚██████╔╝███████║
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝   ╚═╝    ╚═════╝ ╚══════╝
#-------------------------------------------------------------------------
cd ~/GraniteArch
source ./settings
source ./Pkgs
cd ~
mkdir ~/.local
mkdir ~/.local/bin
ln -s ~/.local/bin/ ~/bin
xdg-user-dirs-update
echo -e "\nINSTALLING AUR SOFTWARE\n"
# You can solve users running this script as root with this and then doing the same for the next for statement. However I will leave this up to you.

echo "CLONING: AURACLE"
mkdir ~/build
cd ~/build
git clone "https://aur.archlinux.org/auracle-git.git"
cd auracle-git
makepkg -si --noconfirm

echo "Loading Dotfiles"
cd ~/build
git config --global credential.helper store
git clone https://github.com/Michae11s/dots.git
cd dots
./deployDots.sh
mv ./.fehbg ~/
~/.fehbg

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

echo "Installing AUR Packages"
for PKG in "${AURPKGS[@]}"; do
	cd ~/build
	echo "****************************************************"
	echo "******************Installing: "$PKG"****************"
	echo "****************************************************"
	auracle clone $PKG
	cd $PKG
	makepkg -si --noconfirm
done

echo -e "\nDone!\n"
exit
