echo "#!/bin/bash" > settings
echo "-------------------------------------------------"
echo "-------select the install disk-------------------"
echo "-------------------------------------------------"
echo "THIS WILL FORMAT AND DELETE ALL DATA ON THE DISK"
lsblk
echo "Please enter disk to work on: (example /dev/sda)"
read DISK
echo "DISK="$DISK >> settings
echo ""
read -p "Do you want a Graphical Environment [Y/n]:" GraphicAns
case $GraphicAns in 
	y|Y|yes|Yes|YES|"") GUI=1 ;;
	*) GUI=0 ;;
esac
echo "GUI="$GUI >> settings
read -p "Enter hostname:" HNAME
echo "HNAME="$HNAME >> settings
read -p "Enter username:" USER
echo "USER="$USER >> settings
read -p "Enter userpass:" UPASS
echo "UPASS="$UPASS >> settings
read -p "Enter root pass:" RPASS
echo "RPASS="$RPASS >> settings
