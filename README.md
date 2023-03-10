# Projecto Canales - Fase 2.5

ETLs para carga de datos desde Excel en AWS.

## 1. Empezando
Siga las siguientes instrucciones para la ejecucion y pruebas del codigo.

### 1.1 Prerequisitos

Requerimientos para ejecutar el codigo
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Terraform](https://developer.hashicorp.com/terraform/downloads?product_intent=terraform)

### 1.2 Instalacion Prerequisitos
- Instalar AWS ClI y configure el perfil default con el Access Key. Verifique la instalacion con el siguiente comando en un terminal.
        
        aws --version

- Instalar Terraform. Verifique la instalacion con el siguiente comando en un terminal.

        terraform --version

## 2. Despliegue

- Abra un terminal y muevase a la carpeta: src/proj_canales_25

        cd src/proj_canales_25
- Inicialize terraform

        terraform init
- Ejecute el sgte comando para construir estado:

        terraform plan
- Verifique los recursos a crear. Si todo conforme, despliegue el projecto en AWS con el siguiente comando

        terraform apply --auto-approve
        
## 3. Probar Lambda con invoke+json

Para ejecutar las pruebas ejecute los archivos .sh en la carpeta: *src/proj_canales_25/lambdas/tests*. Ingrese parametros -n y -t
```bash
./invoke -n {nombre funcion} -t {input.json}
```
        

## 4. Prueba de validacion 1 (Flujo: excel => S3 => Lambda)

### 4.1 Subir schema a DynamoDB
- *Paso 0:* Dirijase a la carpeta dyndb. 
```bash
cd dyndb
``` 
 - *Paso 1 (Opcional):* Si es la primera ejecucion, inicialize terraform con:
```bash
terraform init
``` 

- *Paso 2:* Cree el json con el esquema en la carpeta: *data/*
- *Paso 3:* Agregue el nombre del archivo json en el archivo: *dyndb_main.tf*
- *Paso 4:* Cree el estado con:
```bash
terraform plan
```
- *Paso 5:* Despliegue cambios a AWS con:
```bash
terraform apply --auto-approve
```
- *Paso 6:* Revise archivos en la consola S3 para validar subida.

### 4.1 Subir xlsx a S3 Landing

- *Paso 0:* Dirijase a la carpeta s3_upload. 
```bash
cd s3_upload
``` 
 - *Paso 1 (Opcional):* Si es la primera ejecucion, inicialize terraform con:
```bash
terraform init
``` 

- *Paso 2:* Copie o mueva el archivo .xlsx a subir en la carpeta: *s3_upload/data/folder*
- *Paso 3:* Agregue el nombre del archivo .xlsx en el archivo: *s3_main.tf*
- *Paso 4:* Cree el estado con:
```bash
terraform plan
```
- *Paso 4:* Verifique si es necesario agregar la subscripcion con nuevo email. Si es necesario, modifique el archivo: *src/proj_canales_25/sns.tf* agregando el email en el bloque *locals*
- *Paso 5:* Despliegue cambios a AWS con:
```bash
terraform apply --auto-approve
```
- *Paso 6:* Revise archivos en la consola S3 para validar subida.



