#!/bin/bash

# Set the Elasticsearch host and port
ELASTICSEARCH_HOST="localhost"
ELASTICSEARCH_PORT="9200"

# Set the reindex request body
REINDEX_REQUEST='
{
  "source": {
    "index": "sample_index"
  },
  "dest": {
    "index": "portal_index",
    "pipeline": "remove-field-pipeline"
  },
  "script": {
    "source": """
      if (ctx._source.containsKey('log.id.uid')) {
        ctx._id = ctx._source.log.id.uid;
      } else if (ctx._source.containsKey('log.id.id')) {
        ctx._id = ctx._source.log.id.id;
      }
    """
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
RESPONSE=$(curl -s -X POST \
  -u "$ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD" \
  -H "Content-Type: application/json" \
  -d "$REINDEX_REQUEST" \
  "$ELASTICSEARCH_HOST:$ELASTICSEARCH_PORT/_reindex")

  # Check if the response indicates an authentication error
  if [ "$RESPONSE" == "401" ]; then
    echo "$(date) - Error: Invalid Elasticsearch credentials"
    exit 1
  fi

  # Print a message to the console once the update has been executed, with a timestamp
  echo "$(date) - Reindex operation completed with response code: $RESPONSE"

  # Wait for the specified interval before sending the next request
  sleep $INTERVAL
done
