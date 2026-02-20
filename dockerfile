# Lightweight, secure Terraform + AWS CLI + Python + Git + jq image
# Balanced for size, maintenance, and security
# Build: docker build -t tfdev:latest --build-arg TERRAFORM_VERSION=1.13.5 .

 
# export AWS_ACCESS_KEY_ID=<id>
# export AWS_SECRET_ACCESS_KEY=<key>
# export AWS_DEFAULT_REGION=us-east-1

# docker run --rm -it \
#   -e AWS_ACCESS_KEY_ID \
#   -e AWS_SECRET_ACCESS_KEY \
#   -e AWS_DEFAULT_REGION \
#   -v "$(pwd)":/home/ci \
#   -w /home/ci \
#   tfdev:latest

FROM debian:bookworm-slim AS base

ARG TERRAFORM_VERSION=1.13.5
ARG AWSCLI_ZIP_URL=https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip

ENV PATH="/usr/local/bin:/usr/local/sbin:${PATH}"
ENV DEBIAN_FRONTEND=noninteractive

# Install minimal dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      unzip \
      git \
      jq \
      python3 \
      python3-pip \
      python3-venv \
      gnupg \
  && rm -rf /var/lib/apt/lists/*

# ------------------------------
# Install Terraform
# ------------------------------
RUN set -eux; \
    tfzip="/tmp/terraform.zip"; \
    curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o "${tfzip}"; \
    unzip -d /usr/local/bin "${tfzip}"; \
    chmod +x /usr/local/bin/terraform; \
    rm -f "${tfzip}"

# ------------------------------
# Install AWS CLI v2
# ------------------------------
RUN set -eux; \
    awszip="/tmp/awscliv2.zip"; \
    curl -fsSL "${AWSCLI_ZIP_URL}" -o "${awszip}"; \
    unzip -q "${awszip}" -d /tmp; \
    /tmp/aws/install -i /usr/local/aws-cli -b /usr/local/bin; \
    rm -rf /tmp/aws /tmp/awscliv2.zip

# Create non-root user
RUN useradd -m -s /bin/bash ci && \
    mkdir -p /home/ci/.local/bin && \
    chown -R ci:ci /home/ci

USER ci
WORKDIR /home/ci

# Health and version checks (optional)
RUN terraform -version && aws --version && python3 --version && git --version && jq --version

ENTRYPOINT ["bash"]