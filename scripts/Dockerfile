FROM 686958470997.dkr.ecr.us-east-1.amazonaws.com/idd-tcr-nonprod-ecr-1/validator:latest
COPY ./function.py ${LAMBDA_TASK_ROOT}

CMD [ "function.lambda_handler" ]
