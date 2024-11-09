FROM python:3.10.7-bullseye

RUN apt-get update
RUN apt install -y libpython3.9-dev

COPY requirements.txt /build/requirements.txt

WORKDIR /build
RUN pip install --default-timeout=1000 --no-cache-dir -r requirements.txt