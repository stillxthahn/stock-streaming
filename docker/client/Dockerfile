FROM python:3.7-slim

WORKDIR /app

COPY . /app

ENV MYSQL_HOST=localhost

EXPOSE 8000

RUN pip install -r requirements.txt
CMD ["python", "app.py"]