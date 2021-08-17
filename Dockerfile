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

# Install Quetzal-EGGS
RUN git clone --recurse-submodules https://github.com/Becheler/quetzal-EGGS \
&& cd quetzal-EGGS \
&&  mkdir Release \
&&  cd Release \
&& cmake .. -DCMAKE_INSTALL_PREFIX="/usr/local/quetzal-EGGS" \
&& cmake --build . --config Release --target install

# Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.8 \
    python3-pip \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
# Make sure you have numpy installed before attempting to install GDAL Python bindings; without numpy, the _gdal_array native code will not be installed.
RUN pip3 install numpy
RUN pip3 install GDAL==$(gdal-config --version) pyvolve==1.0.3 quetzal-crumbs==0.0.6

# Clean to make image smaller
RUN apt-get autoclean && \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
