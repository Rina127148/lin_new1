
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    g++ \
    libreadline-dev \
    libfuse3-dev \
    pkg-config \
    fuse3 \
    sudo \
    python3 \
    python3-pip \
    adduser \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy kubsh source and Makefile
COPY kubsh.cpp Makefile ./

# Build kubsh
RUN make all

# Install kubsh to /usr/local/bin
RUN cp kubsh /usr/local/bin/kubsh && chmod +x /usr/local/bin/kubsh

# Copy optional test files
COPY opt_from_container /opt

# Install pytest
RUN pip install pytest

# Create users directory for VFS
RUN mkdir -p /root/users

# Default command
CMD ["bash"]
