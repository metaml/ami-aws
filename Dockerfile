FROM public.ecr.aws/lambda/python:3.11

COPY requirements.txt ${LAMBDA_TASK_ROOT}
RUN pip install --requirement requirements.txt

COPY src/s32rb.py ${LAMBDA_TASK_ROOT}
COPY src/sns2db.py ${LAMBDA_TASK_ROOT}

# in some .tf file (re)define CMD
# CMD [ "sns2db.handler" ]