#!/bin/bash
set -e
setup_tool(){
# อัปเดตแพ็คเกจ
sudo apt update

# ติดตั้งแพ็คเกจพื้นฐาน
sudo apt install -y wireshark git vlc putty

#ssh
sudo apt install -y openssh-server
sudo systemctl start ssh
sudo systemctl enable ssh
#vscode
sudo apt install wget gpg -y
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt install code -y

# ติดตั้ง Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable_current_amd64.deb
rm -f google-chrome-stable_current_amd64.deb

# ติดตั้ง Node.js LTS
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# ติดตั้ง Python
sudo apt update
sudo apt install -y python3 python3-pip

# ติดตั้ง Go (ตรวจสอบว่ามีไฟล์ go1.24.4.linux-amd64.tar.gz ในไดเรกทอรีเดียวกันก่อนรัน)
wget https://go.dev/dl/go1.24.4.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.24.4.linux-amd64.tar.gz

# สร้างไฟล์โปรไฟล์สำหรับ Go
sudo tee /etc/profile.d/go.sh > /dev/null << EOF
export PATH=\$PATH:/usr/local/go/bin
EOF
sudo chmod +x /etc/profile.d/go.sh



echo "🎉 เสร็จสิ้นการติดตั้งและตั้งค่า! โปรด  logout และ login ใหม่ สำหรับโหลด path go"
}
install_docker(){

echo "Removing old versions of Docker if any..."
sudo apt-get remove -y docker docker-engine docker.io containerd runc || true

echo "Updating apt package index..."
sudo apt-get update

echo "Installing dependencies..."
sudo apt-get install -y ca-certificates curl gnupg lsb-release

echo "Creating keyrings directory..."
sudo mkdir -p /etc/apt/keyrings

echo "Downloading Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "Adding Docker repository to APT sources..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Updating apt package index again..."
sudo apt-get update

echo "Installing Docker Engine and related packages..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Verifying Docker installation..."
docker --version

echo "Downloading Docker Desktop for Linux (amd64)..."
wget https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb

echo "Installing Docker Desktop..."
sudo apt install -y ./docker-desktop-*.deb

echo "Enabling and starting Docker Desktop..."
systemctl --user enable docker-desktop
systemctl --user start docker-desktop

echo "Docker installation complete!"
	
	
}

echo "please select choice"
echo "1) setup tool"
echo "2) install docker "
echo "3) install packettracer"


read choice

case $choice in 
	1)
		setup_tool
		;;
	2)
		install_docker
		;;
	3)
		echo "install packettracer"
		;;
	*)
		echo "wrong choice"
		exit
		;;
esac
