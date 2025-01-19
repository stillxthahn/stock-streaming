from pyspark.sql import SparkSession
from pyspark.sql.functions import from_json, col
from pyspark.sql.types import StringType, StructType, StructField


kafka_brokers = "debezium-kafka-1:9092"  # Địa chỉ Kafka broker
kafka_topic = "dbserver1.STOCK_STREAMING.IBM_STOCK"        # Tên Kafka topic

spark = SparkSession \
    .builder \
    .appName("StockAnalyze") \
    .getOrCreate()

df = spark \
  .readStream \
  .format("kafka") \
  .option("kafka.bootstrap.servers", kafka_brokers) \
  .option("subscribe", kafka_topic) \
  .load()
df.selectExpr("CAST(key AS STRING)", "CAST(value AS STRING)")

df_value = df.selectExpr("CAST(key AS STRING)", "CAST(value AS STRING)")
print(f"Schema: {df_value.printSchema()}")
