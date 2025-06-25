#!/bin/bash

sudo systemctl stop docker
sudo systemctl stop docker.socket

sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras

sudo apt-get purge -y docker-desktop

sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
sudo rm -rf ~/.docker
sudo rm -rf ~/.config/docker
sudo rm -rf ~/.local/share/docker-desktop
sudo rm -rf /usr/local/bin/com.docker.cli

docker --version


sudo timeshift --delete --snapshot 'starter'

sudo timeshift --create --comments "starter"
last=$(sudo ls -td /timeshift/snapshots/* | head -n1)
echo "last snapshot is:  $last"
sudo mv "$last" /timeshift/snapshots/starter
echo "✅ Snapshot renamed to: starter"  

