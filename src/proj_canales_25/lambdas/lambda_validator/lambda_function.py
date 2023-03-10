import json
import logging
from datetime import datetime, timedelta
import pandas as pd
import io
import boto3
from botocore.exceptions import ClientError

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

table_name = 'auna-dl-qa-storage-dsbcanales-dyndb-v1-audit-1'
# topic_arn='arn:aws:sns:us-east-1:369037400928:auna-dlake-qas-job-int-dsbcanales-sns-v1-notifications-1'
topic_arn='arn:aws:sns:us-east-1:369037400928:test_canales_25'

table = dynamodb.Table(table_name)

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def get_item_dynamo(table,prefix):
    name = prefix.split('/')[-1].split('.')[0]
    folder = (prefix.partition('/')[2]).partition('/')[2].split('/')[0]
    
    try:
        response = table.get_item(
            Key={
                'name': name,
                'folder': folder
            }
        )
    except ClientError as e:
        logger.info(f'Error obteniendo item {name}')
        logger.info(e.response['Error']['Message'])
    else:
        return response['Item']
        
def read_item_s3(bucket,prefix,file_type,dataset,folder):
    s3_client = boto3.client('s3')
    obj = s3_client.get_object(Bucket=bucket, Key=prefix)
    error_message = ''
    
    if prefix.endswith(f'.{file_type}'):
        
        try:
            print("============= obj['Body']: ", obj['Body'])
            if file_type == "csv":
                df = pd.read_csv(obj['Body'], sep=';')
                print("============= dataframe from csv: ", df.head()) 
            elif file_type == "xlsx":
                # df=pd.read_excel(obj['Body'], engine='openpyxl')    
                df = pd.read_excel(io.BytesIO(obj['Body'].read()))
                print("============= dataframe from excel: ", df.head(20))
        
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
        
def validate_schema(df,folder,file,schema):
    error_message = ''
    validFile = True
    
    for col in schema:
        name_col = col['name']
        name_type = col['type']

        # Check column names
        if name_col in df.columns:

            if name_type in ["int", "float", "double"]:
                try:
                    pd.to_numeric(df[name_col])
                except:
                    validFile = False
                    description = 'Entero' if name_type == "int" else 'Decimal'
                    error_message += f'\nDashboard canales archivo: {folder} - {file} \n\t- Falló en la regla: [{description}] para el campo {name_col}.'
            elif name_type == "date":
                try:
                    pd.to_datetime(df[name_col], format='%d/%m/%Y')
                except:
                    validFile = False
                    error_message += f'\nDashboard canales archivo: {folder} - {file} \n\t- Falló en la regla: [Fecha, ejm : 13/03/2013] para el campo {name_col}.'
            elif name_type == "time":
                    try:
                        pd.to_datetime(df[name_col], format='%H:%M:%S')
                    except:
                        validFile = False
                        error_message += f'\nDashboard canales archivo: {folder} - {file} \n\t- Falló en la regla: [Fecha, ejm : 01:00:00] para el campo {name_col}.'
            elif name_type == "datetime":
                try:
                    pd.to_datetime(df[name_col], format='%d/%m/%Y %H:%M:%S')
                except:
                    validFile = False
                    error_message += f'\nDashboard canales archivo: {folder} - {file} \n\t- Falló en la regla: [Fecha, ejm : 13/03/2013 01:00:00] para el campo {name_col}.'
            elif name_type == "string":
                try:
                    df[name_col].astype('string')
                except:
                    validFile = False
                    error_message += f'\nDashboard canales archivo: {folder} - {file} \n\t- Falló en la regla: [Cadena alfanumérica] para el campo {name_col}.'
            else:
                validFile = False
                error_message += f'\nDashboard canales archivo: {folder} - {file} \n\t- Falló en la validación de la columna {name_col}, no se encontró.'
        else:
            validFile = False
            error_message += f'\nDashboard canales archivo: {folder} - {file} \n\t- No se encontró la columna {name_col}'
            
    if error_message != '':
        raise Exception(error_message)
        
        
def lambda_handler(event, context):
    

    message = ''
    status = ''
    
    try:
        
        #Recibir datos del evento
        bucket = event['Records'][0]['s3']['bucket']['name']
        prefix = event['Records'][0]['s3']['object']['key']
        print("bucket & prefix: ", bucket,prefix)
    
        dynamo_item = get_item_dynamo(table,prefix)
        #print(dynamo_item)
        
        df = read_item_s3(bucket,prefix,dynamo_item['file_type'],dynamo_item['name'],dynamo_item['folder'])
        print('====> df.columns: ', df.columns)
        df.columns = df.columns.str.upper()
        print('====> df.columns after: ', df.columns)
            
        validate_schema(df,dynamo_item['folder'],dynamo_item['name'],dynamo_item['schema'])
    
        message = f"Archivos válidos (dashboard canales)."
        status = '(SUCCESS)'
        
        
    except Exception as error:
        message += f"Errores: {error}"
        status = '(FAILURE)'

    print(message)
    sns.publish(TopicArn=topic_arn, Message=message, Subject=f'{status} Validacion de archivos')
    
    return
    
    
    
        
        

