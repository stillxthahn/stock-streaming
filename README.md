# Stock Streaming | Realtime Data Streaming | Data Engineering Project

## Introduction 
This project is my self-learning projects that utilizes technological stack to establish an end-to-end data processing pipeline. It fetches IBM stock data using the Stock API from [Alphavantage]("https://www.alphavantage.co/").

This project can be deployed in two environments: local and AWS.
- [**Local**](./local)
  - Producing persistent data in **MySQL** using an API built with **Flask**.
  - Identify and track changes to data in a database using **Debezium**.
  - Read the streaming data from **Kafka** topic using **PySpark** (Spark Streaming).
  - Store the data in **Minio**.
  - Monitoring the services with **Prometheus** and **Grafana**.
- [**AWS**](./terraform)
  - Uses EC2 instance for **Flask**, **Debezium**, **Kafka** and **Spark**.
  - Store processed data in **AWS S3**.
  - Schedule **AWS Glue** job to extract data and loading into **Glue Data Catalog**. 
  - Query data using **AWS Athena** for analytics.
## System Architecture
- [**Local**](./local)

<!-- ![Local Deployment](./images/local-architecture.png) -->
<div style="text-align: center;">
    <img src="./images/local-architecture.png" alt="Local Deployment">
</div>

- [**AWS**](./terraform)

<!-- ![Cloud Deployment](./images/cloud-architecture.png) -->
<div style="text-align: center;">
    <img src="./images/cloud-architecture.png" alt="Cloud Deployment">
</div>

---

<p>&copy; 2025 XuanThanh</p>


