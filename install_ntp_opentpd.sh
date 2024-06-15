#!/bin/bash

# Function to install and configure OpenNTPD
install_openntpd() {
    echo "Installing OpenNTPD..."
    sudo apt-get update
    sudo apt-get install -y openntpd

    # Configure OpenNTPD
    sudo cp /etc/openntpd/ntpd.conf /etc/openntpd/ntpd.conf.backup
    sudo sed -i 's/^server /#server /g' /etc/openntpd/ntpd.conf
    echo "server $preferred_ntp" | sudo tee -a /etc/openntpd/ntpd.conf
    sudo systemctl restart openntpd
    sudo systemctl enable openntpd

    echo "OpenNTPD has been installed and configured with server $preferred_ntp."
}

# Prompt user for preferred NTP server
echo "Installing OpenNTPD..."
read -p "Do you have a preferred NTP server? (y/n): " preferred_ntp
if [ "$preferred_ntp" == "y" ]; then
    read -p "Enter your preferred NTP server: " preferred_ntp
else
    preferred_ntp="pool.ntp.org"
fi

install_openntpd

echo "Script completed."
