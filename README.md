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
        
## 3. Ejecutar pruebas

Para ejecutar las pruebas ejecute los archivos .sh en la carpeta:       

        src/proj_canales_25/tests


