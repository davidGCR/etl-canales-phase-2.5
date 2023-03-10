import pandas as pd
import io
import boto3
from botocore.exceptions import ClientError
import logging
from io import StringIO

s3 = boto3.client('s3')
sns = boto3.client('sns')
# topic_arn='arn:aws:sns:us-east-1:369037400928:auna-dlake-qas-job-int-dsbcanales-sns-v1-notifications-1'
topic_arn='arn:aws:sns:us-east-1:369037400928:test_canales_25'

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def read_item_s3(bucket, prefix, file_type, dataset, folder):
    """Leer objeto de S3 y cargarlo a dataframe

    Args:
        bucket (str): Nombre del bucket
        prefix (str): Key o ruta del archivo
        file_type (str): Tipo de archivo u extension
        dataset (str): Nombre del dataset
        folder (str): Nombre de la carpeta contenedora

    Raises:
        Exception: Formato incorrecto
        Exception: Error de lectura

    Returns:
        datafraem: Pandas dataframe
    """
    s3_client = boto3.client('s3')
    obj = s3_client.get_object(Bucket=bucket, Key=prefix)
    error_message = ''
    if prefix.endswith(f'.{file_type}'):
        try:
            df = pd.read_excel(io.BytesIO(obj['Body'].read()))
        except Exception as e:
            error_message = f'\nDashboard canales archivo: {folder} - {dataset} \n\t {e}.'
        else:
            return df
    else:
        raise Exception(
            f'\t-El archivo {dataset} debe ser en formato .{file_type}'
        )
    if error_message != '':
        raise Exception(error_message)

def xlsx2csv(bucket, prefix, df):
    """Convierte un archivo XLSX cargado a dataframe. Reemplaza CSV por XLSX

    Args:
        bucket (str): Nombre del bucket
        prefix (str): Ruta de carpeta y nombre del archivo xlsx
        df (pandas.dataframe): Dataframe con data de xlsx

    Raises:
        Exception: Error conversion or Error deletion
    """
    csv_buffer = StringIO()
    df.to_csv(csv_buffer, encoding='utf-8', index=False, sep=';')
    s3_resource = boto3.resource('s3')
    error_message = ''
    # Copy csv to s3
    response = s3_resource.Object(bucket, prefix[:-5]+'.csv').put(Body=csv_buffer.getvalue())
    print("====> conversion response: ", response)
    if response["ResponseMetadata"]["HTTPStatusCode"] != 200:
        error_message = f"\tError en la CONVERSION del archivo: {prefix}"  
    else:
        # Remove xlsx from s3  
        response = s3_resource.Object(bucket, prefix).delete()
        print("====> deletion response: ", response)
        if response["ResponseMetadata"]["HTTPStatusCode"] != 200:
            error_message = f"\tError en la ELIMINACION del archivo: {prefix}"  
    
    if error_message != '':
        raise Exception(error_message)

def lambda_handler(event, context):
    message = ''
    status = ''
    try:
        bucket = event['Records'][0]['s3']['bucket']['name']
        prefix = event['Records'][0]['s3']['object']['key']
        print("bucket & prefix: ", bucket, prefix)
        df = read_item_s3(bucket=bucket, prefix=prefix, file_type="xlsx", dataset="", folder="")
        xlsx2csv(bucket=bucket, prefix=prefix, df=df)
        message = f"Archivo convertido (dashboard canales)."
        status = '(SUCCESS)'
    except Exception as error:
        message += f"Errores: {error}"
        status = '(FAILURE)'

    print(message)
    return