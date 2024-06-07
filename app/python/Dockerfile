FROM python:3.9-slim

WORKDIR /usr/src/app
COPY app.py ./app.py
COPY requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 8080

CMD ["python", "app.py"]
