import json
import boto3
import os
import subprocess
from datetime import datetime
from src.utils.logger import logger

def get_db_credentials(secret_arn):
    client = boto3.client('secretsmanager')
    try:
        get_secret_value_response = client.get_secret_value(SecretId=secret_arn)
        secret = get_secret_value_response['SecretString']
        return json.loads(secret)
    except Exception as e:
        logger.error(f"Error retrieving secret: {e}")
        raise e

def download_migrations_from_s3(bucket_name, prefix, download_path):
    s3 = boto3.client('s3')
    try:
        objects = s3.list_objects_v2(Bucket=bucket_name, Prefix=prefix)
        if 'Contents' in objects:
            for obj in objects['Contents']:
                key = obj['Key']
                if key.endswith('/') or 'results/' in key:  # Skip directories and the results folder
                    continue
                file_path = os.path.join(download_path, os.path.basename(key))
                s3.download_file(bucket_name, key, file_path)
                logger.info(f"Downloaded {key} to {file_path}")
        else:
            logger.info("No migration files found in the bucket.")
    except Exception as e:
        logger.error(f"Error downloading migration files from S3: {e}")
        raise e

def run_flyway_command(command, flyway_conf_path):
    try:
        result = subprocess.run(["/flyway/flyway", command, "-configFiles=" + flyway_conf_path], capture_output=True, text=True)
        logger.info(result.stdout)
        if result.returncode != 0:
            raise Exception(result.stderr)
        return result.stdout
    except Exception as e:
        logger.error(f"Error running Flyway command {command}: {e}")
        raise e

def upload_results_to_s3(bucket_name, key, content):
    s3 = boto3.client('s3')
    try:
        s3.put_object(Bucket=bucket_name, Key=key, Body=content)
        logger.info(f"Uploaded results to s3://{bucket_name}/{key}")
    except Exception as e:
        logger.error(f"Error uploading results to S3: {e}")
        raise e

def lambda_handler(event, context):
    secret_arn = os.environ['DB_SECRET_ARN']
    db_endpoint = os.environ['DB_ENDPOINT']
    db_name = os.environ['DB_NAME']
    s3_bucket = os.environ['DB_MIGRATION_BUCKET']
    s3_prefix = os.environ['DB_MIGRATION_BUCKET_PREFIX']

    logger.info("Fetching database credentials from Secrets Manager")
    creds = get_db_credentials(secret_arn)

    # Download migration files from S3
    download_path = "/tmp/migrations"
    os.makedirs(download_path, exist_ok=True)
    download_migrations_from_s3(s3_bucket, s3_prefix, download_path)

    flyway_conf_content = f"""
    flyway.url=jdbc:postgresql://{db_endpoint}:5432/{db_name}
    flyway.user={creds['username']}
    flyway.password={creds['password']}
    flyway.locations=filesystem:{download_path}
    """

    flyway_conf_path = "/tmp/flyway.conf"
    with open(flyway_conf_path, "w") as flyway_conf_file:
        flyway_conf_file.write(flyway_conf_content)

    # Get the Flyway command from the event
    flyway_command = event.get('flyway', 'info')  # Default to 'info' if no command is provided

    try:
        output = run_flyway_command(flyway_command, flyway_conf_path)
        # Upload the result back to S3
        timestamp = datetime.utcnow().strftime('%Y%m%d%H%M%S')
        result_key = f"{s3_prefix}/results/{flyway_command}_result_{timestamp}.txt"
        upload_results_to_s3(s3_bucket, result_key, output)
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({
                "message": f"Error running Flyway command {flyway_command}",
                "error": str(e)
            })
        }

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": f"Flyway command {flyway_command} executed successfully",
            "output": output
        })
    }
