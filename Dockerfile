FROM ubuntu:focal as base

# Install dependencies
# We need uhd so enb and ue are built
# Use curl and unzip to get a specific commit state from github
# Also install ping to test connections
RUN apt update

RUN DEBIAN_FRONTEND=noninteractive apt install -y \
     build-essential \
     cmake libfftw3-dev \
     libmbedtls-dev \
     libboost-program-options-dev \
     libconfig++-dev \
     libsctp-dev \
     curl \
     iputils-ping \
     iproute2 \
     iptables \
     unzip \
     git

RUN rm -rf /var/lib/apt/lists/*

WORKDIR /srsran

# Pinned git commit used for this example
ARG COMMIT=48cfe041f06942bb32213a126f7706a46a676713

# Download and build
RUN git clone https://github.com/srsRAN/srsRAN.git ./
RUN git fetch origin ${COMMIT}
RUN git checkout ${COMMIT}

WORKDIR /srsran/build

RUN cmake -j$(nproc) ../
RUN make -j$(nproc)
RUN make -j$(nproc) install
RUN srsran_install_configs.sh service

# Update dynamic linker
RUN ldconfig

WORKDIR /srsran

RUN apt-get update && apt-get install -y python python3-requests
