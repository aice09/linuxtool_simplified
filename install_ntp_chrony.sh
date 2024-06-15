#!/bin/bash

# Function to install and configure Chrony as NTP client
install_chrony_client() {
    echo "Installing Chrony as NTP client..."
    sudo apt-get update
    sudo apt-get install -y chrony

    # Configure Chrony as NTP client
    echo "Configuring Chrony as NTP client..."
    sudo sed -i 's/^pool /#pool /g' /etc/chrony/chrony.conf
    echo "server $ntp_server iburst" | sudo tee -a /etc/chrony/chrony.conf
    sudo systemctl restart chronyd
    sudo systemctl enable chronyd

    echo "Chrony has been installed and configured as an NTP client with server $ntp_server."
}

# Function to install and configure Chrony as NTP server
install_chrony_server() {
    echo "Installing and configuring Chrony as NTP server..."
    sudo apt-get update
    sudo apt-get install -y chrony

    # Prompt for timezone
    read -p "Enter the timezone (e.g., 'America/New_York'): " timezone
    sudo timedatectl set-timezone $timezone

    # Configure Chrony as NTP server
    sudo cp /etc/chrony/chrony.conf /etc/chrony/chrony.conf.backup
    sudo sed -i 's/^pool /#pool /g' /etc/chrony/chrony.conf
    echo "allow $subnet" | sudo tee -a /etc/chrony/chrony.conf
    sudo systemctl restart chronyd
    sudo systemctl enable chronyd

    echo "Chrony has been installed and configured as an NTP server."
}

# Prompt user to choose between Chrony as client or server
echo "Do you want to install Chrony as:"
echo "1) NTP client"
echo "2) NTP server"
read -p "Enter the number of your choice: " chrony_option

# Check user choice and set up Chrony accordingly
if [ "$chrony_option" -eq 1 ]; then
    ntp_service="chrony"
    read -p "Do you have a preferred NTP server? (y/n): " preferred_ntp
    if [ "$preferred_ntp" == "y" ]; then
        read -p "Enter your preferred NTP server: " ntp_server
    else
        ntp_server="pool.ntp.org"
    fi
    install_chrony_client
elif [ "$chrony_option" -eq 2 ]; then
    ntp_service="chrony"
    read -p "Enter the subnet (CIDR format) to allow NTP clients (e.g., 192.168.1.0/24): " subnet
    install_chrony_server
else
    echo "Invalid choice. Exiting."
    exit 1
fi

echo "Script completed."
