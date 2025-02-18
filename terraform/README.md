# Realtime Data Streaming | Data Engineering Project (AWS Deployment)

## Introduction 
This deployment uses **Terraform** to provision and manage the necessary AWS infrastructure.


> **Note:** This deployment will charge you for the resources used in AWS. Please make sure to destroy the infrastructure after you are done with the project.

## System Architecture
![Cloud Deployment](../images/cloud-architecture.png)

## Prerequisites
- Terraform 1.10.5
- AWS Access Key, AWS Secret key

## Getting Started
1.  **Clone the repository**:
    ```bash
    git clone https://github.com/stillxthahn/stock-streaming
	chmod 400 ./stock-streaming/docker/mysql/config/mysql.cnf
	cd stock-streaming/terraform
    ```

2. **Setting up environment variables**:

	```bash
	export TF_VAR_access_key="your-access-key"
	export TF_VAR_secret_key="your_secret_key"
	```

	> **Note:** On Windows, you can set these variables in environment variables under System Properties.

3. **Creating infrastructure**:
	```bash
   	terraform init
	terraform plan
	terraform apply
    ```
	
	Your infrastructure should now be created and it takes about 4-5 minutes to complete.

Inital output will be:

![](../images/cloud-output.png)

## How-to Guide
> **Note:** Your instances will take a few minutes to initiate user data. Please wait for about 1-2 minutes before accessing the instances.

1. **Accessing client instance**:
 - You can access the client instance using the public IP address provided in the output with port 8080.

![](../images/cloud-example-client.png)

 - You first fetch the data from the API using ```/fetch``` endpoint and then insert them row by row into the database using ```/stock``` endpoint. 

![](../images/cloud-example-client-stock.png)
  
2. **Monitoring Data lake**:
 - Monitor the data lake by accessing the S3 bucket ```dev-stockstreaming-ibm```. It will store all the data in the form of csv files.

![](../images/cloud-example-datalake.png)


3. **Monitoring Glue Job**:
 - Monitor the Glue job ```dev-stockstreaming-glue-job``` by accessing the AWS Glue console. The job will be triggered **every 5 minutes** to extract data from the S3 bucket datalake and load it into the Glue Data Catalog.
  
![](../images/cloud-example-gluejob.png)

4. **Querying the data with Athena**:
 - Query the data using Athena by accessing the AWS Athena console. You can run the following query to get the data from the ```dev-stockstreaming-catalog-db``` database.

```sql
SELECT * FROM streaming_data
```

![](../images/cloud-example-athena.png)

5. **Destroying infrastructure**:
 - Destroy the infrastructure using the following command:

```bash
	terraform destroy
```

---

<p>&copy; 2025 XuanThanh</p>


	