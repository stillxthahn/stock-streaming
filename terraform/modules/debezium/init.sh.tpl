#!/bin/bash
echo "Target EC2 IP: ${CLIENT_IP}" 
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
echo "Target EC2 IP: ${CLIENT_IP}" 

# echo "Waiting port 8083 open..."
# max_tries=20
# try=1
# until nc -z localhost 8083; do
#     if [ $try -ge $max_tries ]; then
#         echo "Timeout: port 8083 doesn't open after $((max_tries*5))s."
#         exit 1
#     fi
#     echo "Not opening, waiting 5s... (Try: $try)"
#     try=$((try+1))
#     sleep 5
# done
# echo "Port 8083 has opened"
# 0.0.0.0 -> curl: (52) Empty reply from server
# localhost -> curl: (52) Empty reply from server
# 127.0.0.1
sudo docker ps -a
echo "curl -L 127.0.0.1:8083/connectors/"
sudo curl -L 127.0.0.1:8083/connectors/

sudo curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" 127.0.0.1:8083/connectors/ --data '{ "name": "stock-connector", "config": { "connector.class": "io.debezium.connector.mysql.MySqlConnector", "tasks.max": "1", "database.hostname": "'${CLIENT_IP}'", "database.port": "3306", "database.user": "root", "database.password": "root", "database.server.id": "184054", "topic.prefix": "dbserver1", "database.include.list": "STOCK_STREAMING", "schema.history.internal.kafka.bootstrap.servers": "kafka:9092", "schema.history.internal.kafka.topic": "schema-changes.STOCK_STREAMING" } }' 
# sudo docker exec debezium-kafka-1 bin/kafka-console-consumer.sh --bootstrap-server debezium-kafka-1:9092 --topic dbserver1.STOCK_STREAMING.IBM_STOCK --from-beginning
