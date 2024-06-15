#!/bin/bash

# Function to install and enable SSH on Debian-based distributions
install_ssh_debian() {
    sudo apt update
    sudo apt install -y openssh-server
    sudo systemctl enable ssh
    sudo systemctl start ssh
    echo "SSH installed and started on Debian-based distribution."
}

# Function to install and enable SSH on Red Hat-based distributions
install_ssh_redhat() {
    sudo yum install -y openssh-server
    sudo systemctl enable sshd
    sudo systemctl start sshd
    echo "SSH installed and started on Red Hat-based distribution."
}

# Function to install and enable SSH on SUSE-based distributions
install_ssh_suse() {
    sudo zypper install -y openssh
    sudo systemctl enable sshd
    sudo systemctl start sshd
    echo "SSH installed and started on SUSE-based distribution."
}

# Function to install and enable SSH on Arch-based distributions
install_ssh_arch() {
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm openssh
    sudo systemctl enable sshd
    sudo systemctl start sshd
    echo "SSH installed and started on Arch-based distribution."
}

# Function to configure firewall to allow SSH
configure_firewall() {
    if command -v firewall-cmd > /dev/null 2>&1; then
        # For firewalld
        sudo firewall-cmd --add-service=ssh --permanent
        sudo firewall-cmd --reload
        echo "Firewall configured to allow SSH (firewalld)."
    elif command -v ufw > /dev/null 2>&1; then
        # For UFW
        sudo ufw allow ssh
        sudo ufw reload
        echo "Firewall configured to allow SSH (ufw)."
    elif command -v iptables > /dev/null 2>&1; then
        # For iptables
        sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
        sudo iptables-save | sudo tee /etc/iptables/rules.v4
        echo "Firewall configured to allow SSH (iptables)."
    else
        echo "No known firewall tool found. Manual configuration might be needed."
    fi
}

# Detect the Linux distribution and call the appropriate function
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
        debian|ubuntu|linuxmint)
            install_ssh_debian
            ;;
        centos|fedora|rhel)
            install_ssh_redhat
            ;;
        suse|opensuse|sles)
            install_ssh_suse
            ;;
        arch|manjaro)
            install_ssh_arch
            ;;
        *)
            echo "Unsupported Linux distribution: $ID"
            exit 1
            ;;
    esac

    # Configure firewall
    configure_firewall

else
    echo "Cannot detect the Linux distribution."
    exit 1
fi
