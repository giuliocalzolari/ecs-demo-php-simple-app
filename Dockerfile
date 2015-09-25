FROM ubuntu:15.10

# Install app
WORKDIR /srv
RUN rm -rf /srv/*
ADD src /srv

run apt-get update && \
    apt-get install -y python-pip

# Configure apache
RUN pip install -r requirements.txt

EXPOSE 80

CMD ["python", "app.py"]
