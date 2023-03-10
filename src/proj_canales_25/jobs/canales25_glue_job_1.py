import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
# from pyspark.sql.functions import *
from pyspark.sql import functions as F
from pyspark.sql.types import DecimalType
import pandas as pd
# import openpyxl

args = getResolvedOptions(sys.argv, ["JOB_NAME"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)

# set custom logging on
logger = glueContext.get_logger()

# df = pd.read_excel('s3://auna-dlaqa-landingzone-s3/Modama/dashboard_canales/telemarketing/PLATAFORMAS.xlsx', engine='openpyxl')
# logger.info(f"================> df columns: {df.columns}")
# logger.info(f"================> df head: {df.head()}")

canal_folder = "telemarketing"

dy_PLATAFORMAS = glueContext.create_dynamic_frame.from_options(
    format_options={"withHeader": True, "separator": ";", "optimizePerformance": False},
    connection_type="s3",
    format="csv",
    connection_options={
        "paths": [
            f"s3://auna-dlaqa-landingzone-s3/Modama/dashboard_canales/{canal_folder}/PLATAFORMAS.csv"
        ],
        "recurse": True,
    },
)

print(f"plataformas schema: \n{dy_PLATAFORMAS.toDF().printSchema()}")
print(f"plataformas show: \n{dy_PLATAFORMAS.toDF().show(10)}")

# logger.info(f"================> df PLATAFORMAS data: {dy_PLATAFORMAS.take(20)}")
# dataframe_info(PLATAFORMAS.toDF())

dy_OBJETIVOS_NIVEL = glueContext.create_dynamic_frame.from_options(
    format_options={"withHeader": True, "separator": ";", "optimizePerformance": False},
    connection_type="s3",
    format="csv",
    connection_options={
        "paths": [
            f"s3://auna-dlaqa-landingzone-s3/Modama/dashboard_canales/{canal_folder}/OBJETIVOS_NIVEL.csv"
        ],
        "recurse": True,
    },
)

print(f"objetivos_nivel schema: \n{dy_OBJETIVOS_NIVEL.toDF().printSchema()}")
print(f"objetivos_nivel show: \n{dy_OBJETIVOS_NIVEL.toDF().show(10)}")

m_PLATAFORMAS = ApplyMapping.apply(
    frame=dy_PLATAFORMAS,
    mappings=[
        ("COD_PERIODO", "string", "COD_PERIODO", "string"),
        ("DES_PLATAFORMA", "string", "DES_PLATAFORMA", "string"),
        ("NOM_COORDINADOR", "string", "NOM_COORDINADOR", "string"),
        ("TIPO", "string", "TIPO", "string")
    ],
)

m_OBJETIVOS_NIVEL = ApplyMapping.apply(
    frame=dy_OBJETIVOS_NIVEL,
    mappings=[
        ("ANIO", "string", "ANIO", "string"),
        ("MES", "string", "MES", "string"),
        ("TIPO", "string", "TIPO", "string"),
        ("NIVEL", "string", "NIVEL", "string"),
        ("NOMBRE_CALL", "string", "NOMBRE_CALL", "string"),
        ("OBJETIVO", "string", "OBJETIVO", "string")
    ],
)

df_PLATAFORMAS = m_PLATAFORMAS.toDF()
df_OBJETIVOS_NIVEL = m_OBJETIVOS_NIVEL.toDF()

df_OBJETIVOS_NIVEL = df_OBJETIVOS_NIVEL.withColumn("OBJETIVO", F.col("OBJETIVO").cast(DecimalType(15,2)))
print(f"df_OBJETIVOS_NIVEL schema: \n{df_OBJETIVOS_NIVEL.printSchema()}")
print(f"df_OBJETIVOS_NIVEL show: \n{df_OBJETIVOS_NIVEL.show(10)}")

df_PLATAFORMAS.write.mode('overwrite') \
				.format('parquet') \
				.save(f's3://auna-dlaqa-raw-s3/structured-data/OLAP/Modama/dashboard_canales/{canal_folder}/PLATAFORMAS/')
df_OBJETIVOS_NIVEL.write.mode('overwrite') \
				.format('parquet') \
				.save(f's3://auna-dlaqa-raw-s3/structured-data/OLAP/Modama/dashboard_canales/{canal_folder}/OBJETIVOS_NIVEL/')