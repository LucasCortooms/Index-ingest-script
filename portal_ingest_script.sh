#!/bin/bash

# Set the Elasticsearch host and port
ELASTICSEARCH_HOST="localhost"
ELASTICSEARCH_PORT="9200"

# Set the reindex request body
REINDEX_REQUEST='
{
  "source": {
    "index": "kibana_sample_data_ecommerce"
  },
  "dest": {
    "index": "test_index",
    "pipeline": "remove-field-pipeline"
  }
}
'

# Set the interval between reindex calls (in seconds)
INTERVAL=300

# Prompt the user for their Elasticsearch credentials
read -p "Enter your Elasticsearch username: " ELASTICSEARCH_USERNAME
read -sp "Enter your Elasticsearch password: " ELASTICSEARCH_PASSWORD
echo

while true; do
  # Send the reindex request to Elasticsearch
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
    -u "$ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD" \
    -H "Content-Type: application/json" \
    -d "$REINDEX_REQUEST" \
    "$ELASTICSEARCH_HOST:$ELASTICSEARCH_PORT/_reindex")

  # Check if the response indicates an authentication error
  if [ "$RESPONSE" == "401" ]; then
    echo "Error: Invalid Elasticsearch credentials"
    exit 1
  fi

  # Wait for the specified interval before sending the next request
  sleep $INTERVAL
done
