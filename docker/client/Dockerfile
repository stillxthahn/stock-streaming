FROM python:3.7-slim

WORKDIR /app

COPY ../../../scripts/client /app

ENV MYSQL_HOST=mysql

EXPOSE 8000

RUN pip install -r requirements.txt
CMD ["python", "main.py"]