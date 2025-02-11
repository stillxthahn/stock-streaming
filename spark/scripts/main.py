import os

from pyspark.sql import SparkSession
from pyspark.sql.functions import from_json, col
from pyspark.sql.types import StringType, StructType, StructField, LongType, DoubleType, IntegerType, BooleanType, NullType

KAFKA_BROKERS = os.environ.get("KAFKA_BROKERS")
KAFKA_TOPICS = os.environ.get("KAFKA_TOPICS")
REGION = os.environ.get("REGION")
AWS_ACCESS_KEY_ID = os.environ.get("AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY = os.environ.get("AWS_SECRET_ACCESS_KEY")
print("KAFKA_BROKERS",KAFKA_BROKERS)
print("KAFKA_TOPICS",KAFKA_TOPICS)
s3_bucket = "ibm-stock"
s3_prefix = "streaming-data"
s3_output_path = f"s3a://{s3_bucket}/{s3_prefix}"
print("s3_output_path",s3_output_path)
spark = SparkSession \
    .builder \
    .appName("StockAnalyze") \
    .config("spark.jars.packages", "org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.0,org.apache.hadoop:hadoop-aws:3.3.2") \
    .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
    .config("spark.hadoop.fs.s3a.aws.credentials.provider", "org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider") \
    .config("spark.hadoop.fs.s3a.access.key", AWS_ACCESS_KEY_ID) \
    .config("spark.hadoop.fs.s3a.secret.key", AWS_SECRET_ACCESS_KEY) \
    .getOrCreate()
    # .config("spark.hadoop.fs.s3a.endpoint", s3_output_path) \


df = spark \
  .readStream \
  .format("kafka") \
  .option("kafka.bootstrap.servers", KAFKA_BROKERS) \
  .option("subscribe", KAFKA_TOPICS) \
  .option("startingOffsets", "earliest") \
  .load()

df = df.selectExpr("CAST(value AS STRING) as json_value")

schema = StructType([
    StructField("schema", StructType([]), True), 
    StructField("payload", StructType([
        StructField("before", NullType(), True), 
        StructField("after", StructType([
            StructField("time", LongType(), True),
            StructField("open", DoubleType(), True),
            StructField("high", DoubleType(), True),
            StructField("low", DoubleType(), True),
            StructField("close", DoubleType(), True),
            StructField("volume", DoubleType(), True),
            StructField("symbol", StringType(), True),
            StructField("event_time", LongType(), True)
        ]), True),
        StructField("source", StructType([
            StructField("version", StringType(), True),
            StructField("connector", StringType(), True),
            StructField("name", StringType(), True),
            StructField("ts_ms", LongType(), True),
            StructField("snapshot", BooleanType(), True),
            StructField("db", StringType(), True),
            StructField("sequence", NullType(), True),
            StructField("ts_us", LongType(), True),
            StructField("ts_ns", LongType(), True),
            StructField("table", StringType(), True),
            StructField("server_id", IntegerType(), True),
            StructField("gtid", NullType(), True),
            StructField("file", StringType(), True),
            StructField("pos", IntegerType(), True),
            StructField("row", IntegerType(), True),
            StructField("thread", IntegerType(), True),
            StructField("query", NullType(), True)
        ]), True),
        StructField("transaction", NullType(), True), 
        StructField("op", StringType(), True),
        StructField("ts_ms", LongType(), True),
        StructField("ts_us", LongType(), True),
        StructField("ts_ns", LongType(), True)
        ]), True), 
])

parsed_df = df.select(
    from_json(col("json_value"), schema).alias("data")
).select("data.payload.*")

parsed_df.createOrReplaceTempView("stock_view")

filtered_df = spark.sql("""
    SELECT 
        after.time AS time,
        after.open AS open,
        after.high AS high,
        after.low AS low,
        after.close AS close,
        after.volume AS volume,
        after.symbol AS symbol,
        after.event_time AS event_time,
        source.connector AS connector,
        source.name AS source_name,
        source.db AS db,
        source.table AS table_name,
        source.file AS file_name
    FROM stock_view
""")


query = filtered_df.writeStream \
    .format("csv") \
    .option("header", "true") \
    .outputMode("append") \
    .option("checkpointLocation", "/tmp/spark-checkpoints/stock") \
    .start(s3_output_path)

print("Query started")
query.awaitTermination()