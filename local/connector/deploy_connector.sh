#!/bin/bash
curl -X POST http://localhost:8083/connectors/ -H "Content-Type: application/json" -d @connector/connector-config.json
docker exec kafka bin/kafka-topics.sh --bootstrap-server kafka:9092 --topic dbserver1.STOCK_STREAMING.IBM_STOCK --create 
