FROM public.ecr.aws/lambda/python:3.9 as build

ARG VERSION=v1.0.0
RUN yum install -y gcc-c++
COPY ./schemavalidator.cpp /
COPY ./rapidjson /rapidjson
COPY ./tclap /tclap
RUN g++ -I /rapidjson/include -I /tclap/include/ /schemavalidator.cpp -o /validator

# Amazon Linux 2 containing AWS Lambda runtime
FROM public.ecr.aws/lambda/python:3.9
COPY --from=build /validator /cms-mrf-validator/
# COPY ./scripts/bootstrap ${LAMBDA_RUNTIME_DIR}
COPY ./scripts/function.py ${LAMBDA_TASK_ROOT}
RUN yum install -y curl gzip unzip &&\
    rm -rf /var/cache/yum
RUN curl -o /master.zip -L https://github.com/CMSgov/price-transparency-guide/archive/refs/heads/master.zip &&\
    unzip -d / /master.zip &&\
    rm /master.zip &&\
    mv /price-transparency-guide-master /cms-mrf-validator/price-transparency-guide

CMD [ "function.lambda_handler" ]
