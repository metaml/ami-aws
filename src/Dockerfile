FROM public.ecr.aws/lambda/python:3.11

COPY requirements.txt ${LAMBDA_TASK_ROOT}
RUN pip install --requirement requirements.txt

ADD s32rds.py ${LAMBDA_TASK_ROOT}
ADD sns2s3.py ${LAMBDA_TASK_ROOT}

# in some .tf file (re)define CMD
# CMD [ "sns2db.handler" ]