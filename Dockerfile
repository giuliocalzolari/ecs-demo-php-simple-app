FROM ubuntu:15.10

# Install app
RUN     mkdir /app
WORKDIR /app
RUN rm -rf /app/*
ADD src /app

run apt-get update && \
    apt-get install -y python-pip

# Configure apache
RUN pip install -r requirements.txt

EXPOSE 8001

CMD ["python", "app.py"]
