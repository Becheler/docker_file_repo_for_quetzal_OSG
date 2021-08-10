FROM ubuntu:focal

LABEL maintainer="Arnaud Becheler" \
      description="Basic C++ stuff for CircleCi repo." \
      version="0.1.0"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y
RUN apt-get install -y --no-install-recommends\
                    git \
                    gcc-9 \
                    g++ \
                    build-essential \
                    libboost-all-dev \
                    cmake \
                    unzip \
                    tar \
                    ca-certificates

# Install GDAL dependencies
RUN apt-get install -y libgdal-dev g++ --no-install-recommends && \
    apt-get clean -y

# Update C env vars so compiler can find gdal
ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal

# Python
RUN set -xe \
    apt-get update && apt-get install -y \
    python3.8 \
    python3-pip \
    python3.8-venv \
    --no-install-recommends

RUN pip3 install --upgrade pip
RUN pip3 install build twine pipenv numpy

ENV PYTHON_BIN_PATH="$(python3 -m site --user-base)/bin"
ENV PATH="$PATH:$PYTHON_BIN_PATH"

RUN pip3 install GDAL==$(gdal-config --version)

# Clean to make image smaller
RUN apt-get autoclean && \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
