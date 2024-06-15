#!/bin/bash

# Prompt user to choose between Chrony and NTPd
echo "Welcome to NTP Configuration Toolkit"
echo "-------------------------------------"
echo "Which NTP server do you want to install?"
echo "1) Chrony"
echo "2) NTPd"
read -p "Enter the number of your choice: " choice

# Check user choice and set the NTP server accordingly
if [ "$choice" -eq 1 ]; then
    ntp_service="chrony"
elif [ "$choice" -eq 2 ]; then
    ntp_service="ntp"
else
    echo "Invalid choice. Exiting."
    exit 1
fi

# Ask if the user has a preferred NTP server
read -p "Do you have a preferred NTP server? (y/n): " preferred_ntp

if [ "$preferred_ntp" == "y" ]; then
    read -p "Enter your preferred NTP server: " ntp_server
else
    # Use default or web-based NTP servers
    if [ "$ntp_service" == "chrony" ]; then
        ntp_server="pool.ntp.org"
    elif [ "$ntp_service" == "ntp" ]; then
        ntp_server="pool.ntp.org"
    fi
fi

# Install the chosen NTP server
echo "Installing $ntp_service..."
sudo apt-get update
sudo apt-get install -y $ntp_service

# Configure the NTP server
if [ "$ntp_service" == "chrony" ]; then
    echo "Configuring Chrony..."
    sudo sed -i 's/^pool /#pool /g' /etc/chrony/chrony.conf
    echo "server $ntp_server iburst" | sudo tee -a /etc/chrony/chrony.conf
    sudo systemctl restart chronyd
    sudo systemctl enable chronyd
elif [ "$ntp_service" == "ntp" ]; then
    echo "Configuring NTPd..."
    sudo sed -i 's/^server /#server /g' /etc/ntp.conf
    echo "server $ntp_server iburst" | sudo tee -a /etc/ntp.conf
    sudo systemctl restart ntp
    sudo systemctl enable ntp
fi

echo "$ntp_service has been installed and configured with the NTP server $ntp_server."
