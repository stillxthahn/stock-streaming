#!/bin/bash
until [ -f /var/lib/cloud/instance/boot-finished ]; do
  sleep 1
done
echo "Target EC2 IP: ${CLIENT_IP}" 
echo "HOST IP: ${HOST_IP}" 
sudo apt update -y 
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
git clone https://github.com/stillxthahn/stock-streaming.git
cd stock-streaming/debezium
sudo docker-compose up -d
sudo docker ps -a
# localhost -> curl: (56) Recv failure: Connection reset by peer
# HOST_IP -> curl: connection refused
sudo curl -L localhost:8083/connectors/
sudo curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ --data '{ "name": "stock-connector", "config": { "connector.class": "io.debezium.connector.mysql.MySqlConnector", "tasks.max": "1", "database.hostname": "'${CLIENT_IP}'", "database.port": "3306", "database.user": "root", "database.password": "root", "database.server.id": "184054", "topic.prefix": "dbserver1", "database.include.list": "STOCK_STREAMING", "schema.history.internal.kafka.bootstrap.servers": "kafka:9092", "schema.history.internal.kafka.topic": "schema-changes.STOCK_STREAMING" } }' 
sudo docker exec debezium-kafka-1 bin/kafka-console-consumer.sh --bootstrap-server debezium-kafka-1:9092 --topic dbserver1.STOCK_STREAMING.IBM_STOCK --from-beginning
