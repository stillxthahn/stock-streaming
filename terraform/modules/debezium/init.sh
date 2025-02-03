#!/bin/bash
sudo apt update -y 
echo "Docker.io installing..."
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
echo "Docker.io installed successfully"
echo "Docker-compose installing..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
echo "Docker-compose installed successfully"
echo "Cloning the repository..."
git clone https://github.com/stillxthahn/stock-streaming.git
cd stock-streaming/debezium
echo "Cloning successfully..."
echo "Starting the docker-compose..."
sudo docker-compose up -d
echo "Docker-compose started successfully"