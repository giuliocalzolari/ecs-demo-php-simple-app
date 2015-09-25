FROM ubuntu:12.04

# Install app
WORKDIR /srv
RUN rm -rf /srv/*
ADD src /srv

# Configure apache
RUN pip install -r requirements.txt

EXPOSE 80

CMD ["python", "app.py"]
