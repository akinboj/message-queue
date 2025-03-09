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

# Install curl if it's not already present.
RUN microdnf install -y curl

# Download and install gosu. <will be used later to switch to non-root user>
RUN curl -L https://github.com/tianon/gosu/releases/download/1.16/gosu-amd64 > /usr/local/bin/gosu && \
    chmod +x /usr/local/bin/gosu

# Install nc (netcat)
RUN microdnf install -y nc && microdnf clean all

# Ensure Kafka has the right permissions
RUN mkdir -p /var/lib/kafka/data && \
    chown -R 1000:1000 /var/lib/kafka/data

# Copy start script
COPY start-kafka.sh /usr/local/bin/start-kafka.sh
RUN chmod +x /usr/local/bin/start-kafka.sh

# Switch to non-root user
# USER appuser

# Entry point
ENTRYPOINT ["/usr/local/bin/start-kafka.sh"]