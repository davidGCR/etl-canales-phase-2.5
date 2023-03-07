import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import *
from pyspark.sql.types import *
import pandas as pd
import openpyxl

args = getResolvedOptions(sys.argv, ["JOB_NAME"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)

# set custom logging on
logger = glueContext.get_logger()

df = pd.read_excel('s3://auna-dlaqa-landingzone-s3/Modama/dashboard_canales/telemarketing/PLATAFORMAS.xlsx', engine='openpyxl')
logger.info(f"================> df columns: {df.columns}")
logger.info(f"================> df head: {df.head()}")