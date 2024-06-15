#!/bin/bash

# Exit on any error
set -e

# Update system packages
echo "Updating system packages..."
if [ -f /etc/debian_version ]; then
    apt-get update -y
    apt-get install -y ntp
elif [ -f /etc/redhat-release ]; then
    yum update -y
    yum install -y ntp
else
    echo "Unsupported distribution"
    exit 1
fi

# Configure NTP server
echo "Configuring NTP server..."
cat <<EOT > /etc/ntp.conf
driftfile /var/lib/ntp/ntp.drift

# Permit time synchronization with our time source, but do not 
# permit the source to query or modify the service on this system.
restrict default nomodify notrap nopeer noquery

# Permit all access over the loopback interface.  This could
# be tightened as well, but to do so would affect some of
# the administrative functions.
restrict 127.0.0.1
restrict ::1

# Hosts on local network are less restricted.
#restrict 192.168.1.0 mask 255.255.255.0 nomodify notrap

# Use public servers from the pool.ntp.org project.
# Please consider joining the pool (http://www.pool.ntp.org/join.html).
server 0.asia.pool.ntp.org iburst
server 1.asia.pool.ntp.org iburst
server 2.asia.pool.ntp.org iburst
server 3.asia.pool.ntp.org iburst

# Enable public key cryptography.
#crypto

# If you want to provide time to your local network, change the next line.
# (Again, the address is an example only.)
#broadcast 192.168.1.255

# If you want to listen to time broadcasts on your local network, de-comment the next lines.
#disable auth
#broadcastclient

EOT

# Enable and start the NTP service
echo "Enabling and starting the NTP service..."
if [ -f /etc/debian_version ]; then
    systemctl enable ntp
    systemctl start ntp
elif [ -f /etc/redhat-release ]; then
    systemctl enable ntpd
    systemctl start ntpd
fi

# Set the timezone to Asia/Manila
echo "Setting the timezone to Asia/Manila..."
timedatectl set-timezone Asia/Manila

# Print completion message
echo "NTP server setup is complete. The time zone is set to Asia/Manila."
