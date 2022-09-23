FROM public.ecr.aws/lambda/provided:al2.2022.09.09.11 as build

ARG VERSION=v1.0.0
RUN yum install -y gcc-c++
COPY ./schemavalidator.cpp /
COPY ./rapidjson /rapidjson
COPY ./tclap /tclap
RUN g++ -I /rapidjson/include -I /tclap/include/ /schemavalidator.cpp -o /validator

# Amazon Linux 2 containing AWS Lambda runtime
FROM public.ecr.aws/lambda/provided:al2.2022.09.09.11
COPY --from=build /validator /cms-mrf-validator/
COPY ./scripts/bootstrap ${LAMBDA_RUNTIME_DIR}
COPY ./scripts/function.sh ${LAMBDA_TASK_ROOT}
RUN yum install -y curl jq unzip &&\
    yum clean all
RUN curl -o /master.zip -L https://github.com/CMSgov/price-transparency-guide/archive/refs/heads/master.zip &&\
    unzip -d / /master.zip &&\
    rm /master.zip &&\
    mv /price-transparency-guide-master /cms-mrf-validator/price-transparency-guide

# Default function validates TOC file
# Override CMD in Lambda configuration to run other functions
CMD [ "function.toc" ]
