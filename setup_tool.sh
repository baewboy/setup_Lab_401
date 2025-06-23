#!/bin/bash
first_setup(){
# อัปเดตแพ็คเกจ
sudo apt update
sudo apt upgrade -y
# ติดตั้งแพ็คเกจพื้นฐาน
sudo apt install -y wireshark git vlc putty 
#ssh
sudo apt install openssh-server
sudo systemctl start ssh
sudo systemctl enable ssh

#docker
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

#docker desktop
	curl -LO https://desktop.docker.com/linux/main/amd64/docker-desktop-4.31.0-amd64.deb
	sudo apt update
	sudo apt install ./docker-desktop-4.31.0-amd64.deb
	if [ $? -ne 0 ]; then
   	 echo "พบปัญหา dependency: กำลังรัน 'sudo apt --fix-broken install'"
   	 sudo apt --fix-broken install -y
   	 echo "ลองติดตั้งอีกครั้ง..."
   	 sudo apt install ./docker-desktop-4.31.0-amd64.deb
	fi
	systemctl --user start docker-desktop
	systemctl --user enable docker-desktop
#packetTracer 
	

#vscode
sudo apt install wget gpg -y
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt install code -y

# 	ติดตั้ง Google Chrome
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

echo "เลือกเมนู:"
echo "1) first setup"
echo "2) something"
echo "3) ออกจากโปรแกรม"


read -p "เลือก: " choice
case "$choice" in 
	1)
		first_setup
		;;
	2)
		echo "something"
		;;
	3)     
		echo "exit program"
		exit 0
		;;
	*)	
		echo "wrong choice"
		exit 0
		;;
esac
