#!/bin/bash
echo MYSQL_HOST=${MYSQL_HOST}
sudo apt update -y 
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo git clone https://github.com/stillxthahn/stock-streaming.git
cd stock-streaming/docker/client
sudo docker build -t client .
sudo docker run -e MYSQL_HOST=${MYSQL_HOST} -p 8000:8000 client