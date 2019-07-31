#!/bin/bash
# bash <(curl -Ls https://raw.githubusercontent.com/JmzTaylor/ServerScripts/master/auto-update.sh)
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
