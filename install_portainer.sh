#!/bin/bash

# Exit on any error
set -e

# Function to install Docker on various distributions
install_docker() {
    # Detect the distribution
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        echo "Unsupported distribution"
        exit 1
    fi

    case $OS in
        ubuntu|debian)
            echo "Installing Docker on $OS..."
            apt-get update
            apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
            curl -fsSL https://download.docker.com/linux/$OS/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$OS $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            apt-get update
            apt-get install -y docker-ce docker-ce-cli containerd.io
            ;;
        centos|fedora|rhel)
            echo "Installing Docker on $OS..."
            yum install -y yum-utils
            yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            yum install -y docker-ce docker-ce-cli containerd.io
            ;;
        *)
            echo "Unsupported distribution"
            exit 1
            ;;
    esac

    # Start and enable Docker
    echo "Starting and enabling Docker..."
    systemctl start docker
    systemctl enable docker
}

# Function to install Docker Compose
install_docker_compose() {
    echo "Installing Docker Compose..."
    LATEST_COMPOSE=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep browser_download_url | grep docker-compose-$(uname -s)-$(uname -m) | cut -d '"' -f 4)
    curl -L $LATEST_COMPOSE -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
}

# Function to install Portainer
install_portainer() {
    echo "Pulling the latest Portainer image..."
    docker pull portainer/portainer-ce:latest

    echo "Creating a volume for Portainer data..."
    docker volume create portainer_data

    echo "Running the Portainer container..."
    docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v portainer_data:/data \
        portainer/portainer-ce:latest
}

# Main script execution
install_docker
install_docker_compose
install_portainer

# Print completion message
echo "Installation is complete. Please access the web interface to finalize the setup."

# Display the IP address for access
IP_ADDRESS=$(hostname -I | awk '{print $1}')
echo "You can access Portainer at http://$IP_ADDRESS:9000"
