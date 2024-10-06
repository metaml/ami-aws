FROM public.ecr.aws/lambda/python:3.11.2024.09.06.09

COPY requirements.txt ${LAMBDA_TASK_ROOT}
RUN pip install --requirement requirements.txt

ADD ./*.py ${LAMBDA_TASK_ROOT}

# in some .tf file (re)define CMD
# CMD [ "sns2db.handler" ]