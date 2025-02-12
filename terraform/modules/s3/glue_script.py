import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(sys.argv, ['JOB_NAME', 'catalog_database', 'catalog_table'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Script generated for node Amazon S3
AmazonS3_node1739281797147 = glueContext.create_dynamic_frame.from_options(format_options={"quoteChar": "\"", "withHeader": True, "separator": ",", "multiLine": "false", "optimizePerformance": False}, connection_type="s3", format="csv", connection_options={"paths": ["s3://ibm-stock/streaming-data/"]}, transformation_ctx="AmazonS3_node1739281797147")

# Script generated for node Select Fields
SelectFields_node1739287401907 = SelectFields.apply(frame=AmazonS3_node1739281797147, paths=["time", "open", "high", "low", "close", "volume", "symbol", "event_time"], transformation_ctx="SelectFields_node1739287401907")

# Script generated for node AWS Glue Data Catalog
AWSGlueDataCatalog_node1739288010416 = glueContext.write_dynamic_frame.from_catalog(frame=SelectFields_node1739287401907, database=args['catalog_database'], table_name=args['catalog_table'], transformation_ctx="AWSGlueDataCatalog_node1739288010416")

job.commit()