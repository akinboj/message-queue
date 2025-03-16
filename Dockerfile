FROM confluentinc/cp-kafka:7.6.0

ARG IMAGE_BUILD_TIMESTAMP
ENV IMAGE_BUILD_TIMESTAMP=${IMAGE_BUILD_TIMESTAMP}
RUN echo IMAGE_BUILD_TIMESTAMP=${IMAGE_BUILD_TIMESTAMP}

ENV KAFKA_HOME=/opt/kafka
ENV KAFKA_LOG_DIRS=/var/lib/kafka/data
ENV KAFKA_CERTS=/etc/kafka/secrets
ENV KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1
ENV TZ="Australia/Sydney"

USER root

# Install gosu for Red Hat (amd64/arm64-compatible)
RUN microdnf install -y curl && \
    ARCH=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/') && \
    curl -fsSL "https://github.com/tianon/gosu/releases/download/1.16/gosu-$ARCH" -o /usr/local/bin/gosu && \
    chmod +x /usr/local/bin/gosu || { echo "Error installing gosu" ; exit 1; }

# Ensure Kafka has the right permissions
RUN mkdir -p /var/lib/kafka/data && \
    chown -R 1000:1000 /var/lib/kafka/data

# Copy start script
COPY start-kafka.sh /usr/local/bin/start-kafka.sh
RUN chmod +x /usr/local/bin/start-kafka.sh

# Entry point
ENTRYPOINT ["/usr/local/bin/start-kafka.sh"]