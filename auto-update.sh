#!/bin/bash
# bash <(curl -Ls https://raw.githubusercontent.com/JmzTaylor/ServerScripts/master/auto-update.sh) USERNAME 'PASSWORD'
if [[ $# -eq 2 ]] ; then
    useradd -s /bin/bash -m ${1}
    echo ${1}:${2} | chpasswd
    usermod -aG sudo ${1}
    echo "Hardening SSH"
    sed -i 's/PermitRootLogin.*/PermitRootLogin no/g' /etc/ssh/sshd_config
    sed -i '/PasswordAuthentication/c\#PasswordAuthentication no' /etc/ssh/sshd_config
    ssh-keygen -M generate -O bits=2048 moduli-2048.candidates
    if [ $? -ne 0 ]; then
        ssh-keygen -G moduli-2048.candidates -b 2048
    fi
    ssh-keygen -M screen -f moduli-2048.candidates moduli-2048
    if [ $? -ne 0 ]; then
        ssh-keygen -T moduli-2048 -f moduli-2048.candidates
    fi
    mv moduli-2048 /etc/ssh/moduli
    echo 'KexAlgorithms curve25519-sha256@libssh.org' >> /etc/ssh/sshd_config
    echo 'Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr' >> /etc/ssh/sshd_config
    echo 'MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com' >> /etc/ssh/sshd_config
    sed -i 's/^\#HostKey \/etc\/ssh\/ssh_host_\(rsa\|ed25519\)_key$/HostKey \/etc\/ssh\/ssh_host_\1_key/g' /etc/ssh/sshd_config
    sed -i 's/X11Forwarding.*/X11Forwarding no/g' /etc/ssh/sshd_config
    sed -i 's/PasswordAuthentication.*/PasswordAuthentication no/g' /etc/ssh/sshd_config
    echo -e "\n# Restrict key exchange, cipher, and MAC algorithms, as per sshaudit.com\n# hardening guide.\nKexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group-exchange-sha256\nCiphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr\nMACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128-etm@openssh.com\nHostKeyAlgorithms ssh-ed25519,ssh-ed25519-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,sk-ssh-ed25519-cert-v01@openssh.com,rsa-sha2-256,rsa-sha2-512,rsa-sha2-256-cert-v01@openssh.com,rsa-sha2-512-cert-v01@openssh.com" >> /etc/ssh/sshd_config.conf
    rm /etc/ssh/ssh_host_*
    ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ""
    ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
    awk '$5 >= 3071' /etc/ssh/moduli > /etc/ssh/moduli.safe
    mv /etc/ssh/moduli.safe /etc/ssh/moduli
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
       usermod -aG docker ${1}
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
