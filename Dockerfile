FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        curl \
        unzip \
        ca-certificates \
        gnupg \
        software-properties-common \
        python3-pip \
        python3 \
        openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf aws awscliv2.zip

# Install Terraform
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && \
    apt-get install -y terraform && \
    terraform -install-autocomplete

# Clone repositories
RUN git clone https://github.com/Tenebris2/QAirlineCICD /QAirlineCICD
    
# Set working directory
WORKDIR /QAirlineInfra

COPY . /QAirlineInfra
# Install Python deps
RUN pip install --no-cache-dir \
            python-dotenv \ 
            ansible

RUN ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N "" -q

RUN terraform init
# Make sure start.sh is executable
RUN chmod +x start.sh

# Set default command to run start.sh when container starts
CMD ["./start.sh"]
