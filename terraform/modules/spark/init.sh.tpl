#!/bin/bash
echo "KAFKA_BROKERS: ${KAFKA_BROKERS}" 
echo "KAFKA_TOPICS: ${KAFKA_TOPICS}" 
echo "REGION: ${REGION}" 
echo "AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}" 
echo "AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}" 
echo "S3_BUCKET: ${S3_BUCKET}" 
echo "S3_FOLDER: ${S3_FOLDER}" 
sudo apt update -y 
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
git clone https://github.com/stillxthahn/stock-streaming.git
cd stock-streaming/docker/spark
sudo S3_BUCKET=${S3_BUCKET} S3_FOLDER=${S3_FOLDER} KAFKA_BROKERS=${KAFKA_BROKERS} KAFKA_TOPICS=${KAFKA_TOPICS} REGION=${REGION} AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}  docker-compose up -d
sudo docker ps -a

while [[ "$(curl -o /dev/null -s -w "%%{http_code}" localhost:9091)" != "200" ]]; do 
	sleep 3; 
	echo "Spark worker is unhealthy, waiting for 3s...";
done

sudo docker exec spark-worker-1 /opt/bitnami/spark/bin/spark-submit --master spark://spark-master-1:7077  --deploy-mode client --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.0 /opt/spark-scripts/main.py