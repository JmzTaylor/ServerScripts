#!/bin/bash
# bash <(curl -Ls https://raw.githubusercontent.com/JmzTaylor/ServerScripts/master/auto-update.sh)
if [[ $# -eq 2 ]] ; then
    useradd -s /bin/bash -m $1
    echo ${1}:${2} | chpasswd
    usermod -aG ${1} sudo
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
else
    echo "Username and password missing\n"
    echo "i.e. ./auto-update.sh username 'password'"
fi
