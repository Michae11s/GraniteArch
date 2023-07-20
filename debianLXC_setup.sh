#!/bin/bash

apt update && apt upgrade
apt install -y neovim git curl wget sudo

curl https://raw.githubusercontent.com/Michae11s/GraniteArch/main/bashrc_debian -o .bashrc

useradd -m -s /bin/bash -G sudo admin
\cp .bashrc /home/admin/.bashrc
