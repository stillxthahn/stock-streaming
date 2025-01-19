from pyspark.sql import SparkSession
from pyspark.sql.functions import from_json, col
from pyspark.sql.types import StringType, StructType, StructField, LongType, DoubleType, IntegerType, BooleanType, NullType


kafka_brokers = "debezium-kafka-1:9092"  
kafka_topic = "dbserver1.STOCK_STREAMING.IBM_STOCK"

spark = SparkSession \
    .builder \
    .appName("StockAnalyze") \
    .getOrCreate()

df = spark \
  .readStream \
  .format("kafka") \
  .option("kafka.bootstrap.servers", kafka_brokers) \
  .option("subscribe", kafka_topic) \
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
        stock_view.after.time,
        stock_view.after.open,
        stock_view.after.high,
        stock_view.after.low,
        stock_view.after.close,
        stock_view.after.volume,
        stock_view.after.symbol,
        stock_view.after.event_time,
        stock_view.source.connector,
        stock_view.source.name,
        stock_view.source.db,
        stock_view.source.table,
        stock_view.source.file
    FROM stock_view
""")

# Hiển thị kết quả
# parsed_df.show(truncate=False)

query = filtered_df.writeStream \
    .outputMode("append") \
    .format("console") \
    .start()

query.awaitTermination()