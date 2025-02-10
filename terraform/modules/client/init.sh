#!/bin/bash
# until [ -f /var/lib/cloud/instance/boot-finished ]; do
#   sleep 1
# done
sudo apt update -y 
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
git clone https://github.com/stillxthahn/stock-streaming.git
cd stock-streaming/client
sudo docker-compose up -d