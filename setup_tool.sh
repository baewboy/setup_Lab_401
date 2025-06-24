#!/bin/bash

setup_tool(){
# อัปเดตแพ็คเกจ
sudo apt update

sudo apt install -y timeshift
sudo timeshift --create --comments "default"
last=$(sudo ls -td /timeshift/snapshots/* | head -n1)
echo "last snapshot is:  $last"
sudo mv "$last" /timeshift/snapshots/default
echo "✅ Snapshot renamed to: default"  


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
sudo apt install -y python3 python3-pip python3-venv

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

install_packettracer(){


# อัพเดตแพ็กเกจและติดตั้ง python3-venv ถ้ายังไม่มี
if ! dpkg -s python3-venv >/dev/null 2>&1; then
  echo "ติดตั้ง python3-venv..."
  sudo apt update
  sudo apt install -y python3-venv
fi

# สร้าง virtual environment ถ้ายังไม่มีโฟลเดอร์ myenv
if [ ! -d "gdown_env" ]; then
  echo "สร้าง virtual environment..."
  python3 -m venv gdown_env
fi

# activate virtual environment


# ติดตั้ง gdown ใน venv
echo "ติดตั้ง gdown..."
./gdown_env/bin/pip install --upgrade pip
./gdown_env/bin/pip install gdown

# ดาวน์โหลดไฟล์จาก Google Drive
FILE_ID="1sgpENt8hQmLdTJHlhIMa_eGn7iZcPhIx"
OUTPUT="Packet_Tracer822_amd64_signed.deb"

./gdown_env/bin/gdown https://drive.google.com/uc?id=${FILE_ID} -O ${OUTPUT}

echo "ดาวน์โหลดเสร็จสิ้น: ${OUTPUT}"

git clone https://github.com/farhatizakaria/CiscoPacketTracer-Ubuntu_24.10.git
cd CiscoPacketTracer-Ubuntu_24.10

echo "อัพเดตและอัพเกรดระบบ..."
sudo apt update && sudo apt upgrade -y
sudo dpkg -i libgl1-mesa-glx_23.0.4-0ubuntu1~22.04.1_amd64.deb
sudo dpkg -i dialog_1.3-20240101-1_amd64.deb
sudo dpkg -i libxcb-xinerama0-dev_1.15-1ubuntu2_amd64.deb

sudo apt --fix-broken install -y 



cd ..
sudo dpkg -i Packet_Tracer822_amd64_signed.deb


packettracer

}

setup_nis(){
 sudo apt install -y nis
 echo "domain coe.rmutsv.ac.th server 172.16.81.1" | sudo tee -a /etc/yp.conf

 
# backup ก่อนเผื่อมีปัญหา
sudo cp /etc/nsswitch.conf /etc/nsswitch.conf.bak.$(date +%F_%T)

# เขียนทับไฟล์
sudo tee /etc/nsswitch.conf > /dev/null <<EOF
passwd:        nis  files systemd sss
group:         nis  files systemd sss
shadow:        nis files systemd sss
gshadow:       files systemd

hosts:         nis files mdns4_minimal [NOTFOUND=return] dns
networks:      files

protocols:     db files
services:      db files sss
ethers:        db files
rpc:           db files

netgroup:      nis sss
automount:     sss
EOF

echo "coe.rmutsv.ac.th" | sudo tee /etc/defaultdomain

sudo systemctl restart rpcbind nscd ypbind
sudo systemctl enable rpcbind nscd ypbind 
echo "แก้ไข /etc/nsswitch.conf เรียบร้อยแล้ว (backup ไฟล์เดิมไว้ที่ /etc/nsswitch.conf.bak.*)"



}
setup_pam(){
	sudo tar -xzf pam_elogin.tar.gz
	cd pam-elogin/
	sudo make install
	# สำรองไฟล์เก่า พร้อมเวลาปัจจุบัน
sudo cp /etc/pam.d/common-auth /etc/pam.d/common-auth.bak.$(date +%F_%T)

# เขียนทับไฟล์ด้วยเนื้อหาใหม่
sudo tee /etc/pam.d/common-auth > /dev/null <<'EOF'
# /etc/pam.d/common-auth - authentication settings common to all services
#
# This file is included from other service-specific PAM config files,
# and should contain a list of the authentication modules that define
# the central authentication scheme for use on the system
# (e.g., /etc/shadow, LDAP, Kerberos, etc.).  The default is to use the
# traditional Unix authentication mechanisms.
#
# As of pam 1.0.1-6, this file is managed by pam-auth-update by default.
# To take advantage of this, it is recommended that you configure any
# local modules either before or after the default block, and use
# pam-auth-update to manage selection of other modules.  See
# pam-auth-update(8) for details.

# here are the per-package modules (the "Primary" block)
auth    [success=3 default=ignore]      pam_elogin_api.so
auth    [success=2 default=ignore]      pam_unix.so nullok
auth    [success=1 default=ignore]      pam_sss.so use_first_pass
# here's the fallback if no module succeeds
auth    requisite                       pam_deny.so
# prime the stack with a positive return value if there isn't one already;
# this avoids us returning an error just because nothing sets a success code
# since the modules above will each just jump around
auth    required                        pam_permit.so
# and here are more per-package modules (the "Additional" block)
auth    optional                        pam_cap.so
# end of pam-auth-update config
EOF

# สำรองไฟล์เก่า พร้อมเวลาปัจจุบัน
sudo cp /etc/pam.d/common-session /etc/pam.d/common-session.bak.$(date +%F_%T)

# เขียนทับไฟล์ด้วยเนื้อหาใหม่
sudo tee /etc/pam.d/common-session > /dev/null <<'EOF'
#
# /etc/pam.d/common-session - session-related modules common to all services
#
# This file is included from other service-specific PAM config files,
# and should contain a list of modules that define tasks to be performed
# at the start and end of interactive sessions.
#
# As of pam 1.0.1-6, this file is managed by pam-auth-update by default.
# To take advantage of this, it is recommended that you configure any
# local modules either before or after the default block, and use
# pam-auth-update to manage selection of other modules.  See
# pam-auth-update(8) for details.

# here are the per-package modules (the "Primary" block)
session [default=1]                     pam_permit.so
# here's the fallback if no module succeeds
session requisite                       pam_deny.so
# prime the stack with a positive return value if there isn't one already;
# this avoids us returning an error just because nothing sets a success code
# since the modules above will each just jump around
session required                        pam_permit.so
# The pam_umask module will set the umask according to the system default in
# /etc/login.defs and user settings, solving the problem of different
# umask settings with different shells, display managers, remote sessions etc.
# See "man pam_umask".
session optional                        pam_umask.so
# and here are more per-package modules (the "Additional" block)
session required        pam_unix.so
session optional                        pam_sss.so
session optional        pam_systemd.so

session required pam_mkhomedir.so skel=/etc/skel umask=0077
# end of pam-auth-update config
EOF

echo '%student ALL=(ALL) ALL' | sudo tee /etc/sudoers.d/student
sudo chmod 440 /etc/sudoers.d/student
echo "/etc/pam.d/common-session ถูกแก้ไขเรียบร้อยแล้ว และสำรองไฟล์เก่าไว้ที่ /etc/pam.d/common-session.bak.*"
echo "/etc/pam.d/common-auth ถูกแก้ไขเรียบร้อยแล้ว และสำรองไฟล์เก่าไว้ที่ /etc/pam.d/common-auth.bak.*"		
}

save_timeshift(){
	sudo timeshift --create --comments "starter"
	last=$(sudo ls -td /timeshift/snapshots/* | head -n1)
	echo "last snapshot is:  $last"
	sudo mv "$last" /timeshift/snapshots/starter
	echo "✅ Snapshot renamed to: starter" 	
}

setup_ansible_for_client(){
	sudo useradd -m -s /bin/bash ansible
	echo "ansible:ansible" | sudo chpasswd
	sudo usermod -aG sudo ansible

	echo "ansible ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ansible
	sudo chmod 440 /etc/sudoers.d/ansible
	echo "✅ User ansible พร้อมใช้งานแล้ว (sudo แบบไม่ต้องใส่ password)"
}

echo "please select choice"
echo "enter 0 for automate"
echo "1) setup tool"
echo "2) install docker "
echo "3) install packettracer"
echo "4) setup nis "
echo "5) setup pam"
echo "6) setup_timeshift"
echo "7) setup ansible"
read choice

case $choice in 
	0)
		setup_tool
		install_docker
		install_packettracer
		setup_nis
		setup_pam
		save_timeshift
		sudo reboot
		;;
	1)
		setup_tool
		;;
	2)
		install_docker
		;;
	3)
		install_packettracer
		;;
	4)
		setup_nis
		;;
	5)
		setup_pam
		;;
	6) 
		save_timeshift
		;;
	7)
		setup_ansible_for_client
	*)
		echo "wrong choice"
		exit 1
		;;
esac
