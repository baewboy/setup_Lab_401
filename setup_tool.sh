#!/bin/bash

# อัปเดตแพ็คเกจ
sudo apt update

# ติดตั้งแพ็คเกจพื้นฐาน
sudo apt install -y wireshark git vlc putty

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
