#!/bin/bash

# Function to display current network settings
display_network_settings() {
    echo "Current Network Settings:"
    echo "-------------------------"
    echo "Computer Name: $(hostname)"
    echo "Domain: $(hostname -d)"
    echo "IP Address: $(hostname -I)"
    echo "Gateway: $(ip route | grep default | awk '{print $3}')"
    echo "DNS Servers:"
    cat /etc/resolv.conf | grep nameserver | awk '{print "  "$2}'
    echo "-------------------------"
}

# Function to update computer name
update_computer_name() {
    read -p "Enter new computer name: " new_name
    hostnamectl set-hostname $new_name
    echo "Computer name updated to: $new_name"
}

# Function to update domain name
update_domain_name() {
    read -p "Enter new domain name: " new_domain
    echo $new_domain > /etc/domainname
    echo "Domain name updated to: $new_domain"
}

# Function to update network settings
update_network_settings() {
    echo "Updating network settings..."
    systemctl restart systemd-networkd
    echo "Network settings updated."
}

# Function to update DNS servers
update_dns_servers() {
    echo "Updating DNS servers..."
    read -p "Enter comma-separated list of DNS servers: " dns_servers
    echo "nameserver $dns_servers" | sudo tee /etc/resolv.conf > /dev/null
    echo "DNS servers updated to: $dns_servers"
}

# Main script execution
echo "Script to check and modify network settings."
echo "--------------------------------------------"
display_network_settings

# Prompt user if they want to modify settings
read -p "Do you want to modify any settings? (yes/no): " modify_choice
if [ "$modify_choice" = "yes" ]; then
    echo "Choose what you want to modify:"
    echo "1. Computer Name"
    echo "2. Domain Name"
    echo "3. DNS Servers"
    echo "4. Update Network Settings"

    read -p "Enter your choice (1/2/3/4): " option

    case $option in
        1) update_computer_name ;;
        2) update_domain_name ;;
        3) update_dns_servers ;;
        4) update_network_settings ;;
        *) echo "Invalid choice." ;;
    esac
fi

# Prompt user to update system
read -p "Are you sure you want to update the system? (yes/no): " update_choice
if [ "$update_choice" = "yes" ]; then
    echo "Updating system..."
    if [ -f /etc/debian_version ]; then
        apt-get update && apt-get upgrade -y
    elif [ -f /etc/redhat-release ]; then
        yum update -y
    fi
    echo "System updated successfully."
else
    echo "System update skipped."
fi

echo "Script execution complete."
