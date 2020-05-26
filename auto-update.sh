#!/bin/bash
# bash <(curl -Ls https://raw.githubusercontent.com/JmzTaylor/ServerScripts/master/auto-update.sh) USERNAME 'PASSWORD'
if [[ $# -eq 2 ]] ; then
    useradd -s /bin/bash -m ${1}
    echo ${1}:${2} | chpasswd
    usermod -aG sudo ${1}
    sed -i 's/PermitRootLogin.*/PermitRootLogin no/g' /etc/ssh/sshd_config
    sed -i '/PasswordAuthentication/c\#PasswordAuthentication no' /etc/ssh/sshd_config
    /etc/init.d/ssh restart
    apt update 
    apt upgrade -o Dpkg::Options::="--force-confold" --force-yes -y
    apt install -y unattended-upgrades
    sed -i 's/\/\/\t\"${distro_id}:${distro_codename}-updates\";/        \"${distro_id}:${distro_codename}-updates\";/g' /etc/apt/apt.conf.d/50unattended-upgrades
    sed -i 's/\/\/\Unattended-Upgrade::Mail \"root\";/Unattended-Upgrade::Mail \"jmz.taylor16@gmail.com\";/g' /etc/apt/apt.conf.d/50unattended-upgrades
    sed -i 's/\/\/\Unattended-Upgrade::MailOnlyOnError \"true\";/Unattended-Upgrade::MailOnlyOnError \"true\";/g' /etc/apt/apt.conf.d/50unattended-upgrades
    sed -i 's/\/\/\Unattended-Upgrade::Remove-Unused-Dependencies \"true\";/Unattended-Upgrade::Remove-Unused-Dependencies \"true\";/g' /etc/apt/apt.conf.d/50unattended-upgrades
    sed -i 's/\/\/\Unattended-Upgrade::Automatic-Reboot \"false\";/Unattended-Upgrade::Automatic-Reboot \"true\";/g' /etc/apt/apt.conf.d/50unattended-upgrades
    sed -i 's/\/\/\Unattended-Upgrade::Automatic-Reboot-Time \"02:00\";/Unattended-Upgrade::Automatic-Reboot-Time \"02:00\";/g' /etc/apt/apt.conf.d/50unattended-upgrades
    echo 'APT::Periodic::Update-Package-Lists "1";' > /etc/apt/apt.conf.d/20auto-upgrades
    echo 'APT::Periodic::Download-Upgradeable-Packages "1";' >> /etc/apt/apt.conf.d/20auto-upgrades
    echo 'APT::Periodic::AutocleanInterval "7";' >> /etc/apt/apt.conf.d/20auto-upgrades
    echo 'APT::Periodic::Unattended-Upgrade "1";' >> /etc/apt/apt.conf.d/20auto-upgrades
    unattended-upgrades --dry-run --debug
    read -p "Install Docker? (y/n)" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
       apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
       curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
       add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
       apt update
       apt install -y docker-ce docker-ce-cli containerd.io
    fi
    read -p "Install Docker Compose? (y/n)" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
       curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
       chmod +x /usr/local/bin/docker-compose
       echo "Docker-compose installed"
    fi
    
else
    echo "Username and password missing\n"
    echo "i.e. ./auto-update.sh username 'password'"
fi
