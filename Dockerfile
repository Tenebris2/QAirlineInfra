FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        curl \
        unzip \
        ca-certificates \
        python3-pip \
        python3 \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf aws awscliv2.zip

# Clone repositories
RUN git clone https://github.com/Tenebris2/QAirlineCICD /QAirlineCICD && \
    git clone https://github.com/Tenebris2/QAirlineInfra /QAirlineInfra

COPY  dest
# Set working directory
WORKDIR /QAirlineInfra

RUN pip install --no-cache-dir python-dotenv

RUN chmod +x start.sh

RUN ./start.sh
