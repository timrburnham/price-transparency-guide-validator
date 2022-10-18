import logging
from pathlib import Path
import subprocess as sp

import boto3
from botocore import client

logger = logging.getLogger()
logger.setLevel(logging.INFO)
s3 = boto3.client('s3', config=client.Config(signature_version='s3v4'))


def lambda_handler(event, context):
    logger.info(event)
    url = s3.generate_presigned_url(
        ClientMethod='get_object',
        ExpiresIn=900,
        Params=event['s3'])

    schema_dir = Path("/cms-mrf-validator/price-transparency-guide/schemas")
    schema = event['schema']
    schema = (schema_dir/schema/schema).with_suffix('.json')

    # stream http into unix pipeline
    # let stderr leak out into logs for debugging
    # CloudWatch log group ex: /aws/lambda/idd-tcr-nonprod-lam-validator-1
    curl = sp.Popen(['curl', '-s', '-L', str(url)],
        stdout=sp.PIPE)
    gunzip = sp.Popen(['gunzip', '-c'],
        stdin=curl.stdout,
        stdout=sp.PIPE)
    validator = sp.run(['/cms-mrf-validator/validator', str(schema), '-'],
        stdin=gunzip.stdout,
        stdout=sp.PIPE)

    return validator.stdout
