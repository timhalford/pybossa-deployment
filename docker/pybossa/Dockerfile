FROM ubuntu:16.04

RUN apt-get update && \
	apt-get install -y \
		git-core \
		python \
		python-dev \
		python-psycopg2 \
		python-pip \
		dbus \
		libdbus-1-dev \
		libdbus-glib-1-dev \
		libldap2-dev \
		libsasl2-dev \
		python-dev \
		build-essential \
		libjpeg-dev \
		libssl-dev \
		libffi-dev
RUN pip install -U pip
RUN git clone --recursive https://github.com/Scifabric/pybossa /opt/pybossa

ARG PYBOSSA_VERSION=2.7.1

RUN cd /opt/pybossa && \
	git checkout v$PYBOSSA_VERSION  && \
	pip install -r requirements.txt

COPY settings_local.py alembic.ini /opt/pybossa/

WORKDIR /opt/pybossa

