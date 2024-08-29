FROM python:3.9-slim-buster

COPY . /app

WORKDIR /app

# Update the local package index with the latest packages from the repositories
RUN apt update -y

# Install a couple of packages to successfully install postgresql server locally
RUN apt install build-essential libpq-dev -y

# Update python modules to successfully build the required modules
RUN pip install --upgrade pip setuptools wheel

RUN pip install -r ./analytics/requirements.txt

CMD python ./analytics/app.py