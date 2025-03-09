#!/bin/bash

set -e

# If script is run as appuser, restart it with root permissions
# if [ "$(id -u)" -ne 0 ]; then
#     echo "Switching to root for setup..."
#     exec gosu root "$0" "$@"
# fi

echo "Updating host file :: In Kafka, the controller address must bind to a network interface on the machine or pod"
printf "%s\t%s\n" "${MY_POD_IP}" "${KUBERNETES_SERVICE_NAME}.${KUBERNETES_NAMESPACE}.svc.cluster.local" >> /etc/hosts
cat /etc/hosts
echo ""

echo "Starting Kafka..."
echo ""

# Set default values if not provided
export KAFKA_PROCESS_ROLES="broker,controller"
export KAFKA_NODE_ID="${KAFKA_NODE_ID:-1}"
export KAFKA_CONTROLLER_QUORUM_VOTERS="1@${KUBERNETES_SERVICE_NAME}.${KUBERNETES_NAMESPACE}.svc.cluster.local:9094"
export KAFKA_LISTENER_SECURITY_PROTOCOL_MAP="SSL:SSL,CONTROLLER:SSL"
export KAFKA_INTER_BROKER_LISTENER_NAME="SSL"
export KAFKA_CONTROLLER_LISTENER_NAMES="CONTROLLER"
export KAFKA_AUTO_CREATE_TOPICS_ENABLE="true"
export KAFKA_SSL_ENDPOINT_IDENTIFICATION_ALGORITHM="HTTPS"
export KAFKA_AUTO_CREATE_TOPICS_ENABLE="true"
export KAFKA_DELETE_TOPIC_ENABLE="false"

# Set TLS settings dynamically
export KAFKA_LISTENERS="SSL://${MY_POD_NAME}:9093,CONTROLLER://${MY_POD_NAME}:9094"
export KAFKA_ADVERTISED_LISTENERS="SSL://${KUBERNETES_SERVICE_NAME}.${KUBERNETES_NAMESPACE}.svc.cluster.local:${BROKER_PORT}"
export KAFKA_SSL_KEYSTORE_LOCATION="${KAFKA_CERTS}/${KUBERNETES_SERVICE_NAME}.${KUBERNETES_NAMESPACE}.jks"
export KAFKA_SSL_KEYSTORE_FILENAME="${KUBERNETES_SERVICE_NAME}.${KUBERNETES_NAMESPACE}.jks"
export KAFKA_SSL_TRUSTSTORE_LOCATION="${KAFKA_CERTS}/truststore.jks"
export KAFKA_SSL_TRUSTSTORE_FILENAME="truststore.jks"
export KAFKA_SSL_ENABLED_PROTOCOLS="TLSv1.2,TLSv1.3"
export KAFKA_SSL_KEYSTORE_TYPE="PKCS12"
export KAFKA_SSL_TRUSTSTORE_TYPE="PKCS12"
export KAFKA_SSL_CLIENT_AUTH="required"

# Check if keystore/truststore exist
if [[ ! -f "$KAFKA_SSL_KEYSTORE_LOCATION" || ! -f "$KAFKA_SSL_TRUSTSTORE_LOCATION" ]]; then
    echo "❌ Keystore or Truststore is missing. Exiting..."
    exit 1
fi

echo "Setup completed. Switching to appuser..."
echo ""

# Start Kafka
exec gosu appuser /etc/confluent/docker/run