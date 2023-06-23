#!/bin/sh

trim() {
  # Remove leading and trailing spaces using parameter expansion
  trimmed="${1#"${1%%[![:space:]]*}"}"
  trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"
  
  # Return the trimmed string
  echo "$trimmed"
}

set -e

echo "Start Clean Up At $(date)"

# Check Env DOCKER_REGISTRY_URL is present
if [ -z "$DOCKER_REGISTRY_URL" ]; then
  echo "Error: Required environment DOCKER_REGISTRY_URL variables are not set. Exiting."
  echo "Failed Clean Up At $(date)"
  exit 1
fi

# Check Env DOCKER_REGISTRY_USER is present
if [ -z "$DOCKER_REGISTRY_USER" ]; then
  echo "Error: Required environment DOCKER_REGISTRY_USER variables are not set. Exiting."
  echo "Failed Clean Up At $(date)"
  exit 1
fi

# Check Env DOCKER_REGISTRY_PASSWORD is present
if [ -z "$DOCKER_REGISTRY_PASSWORD" ]; then
  echo "Error: Required environment DOCKER_REGISTRY_PASSWORD variables are not set. Exiting."
  echo "Failed Clean Up At $(date)"
  exit 1
fi

# Check Env DOCKER_IMAGE_CUTOFF_DAYS is present
if [ -z "$DOCKER_IMAGE_CUTOFF_DAYS" ]; then
  echo "Error: Required environment DOCKER_IMAGE_CUTOFF_DAYS variables are not set. Exiting."
  echo "Failed Clean Up At $(date)"
  exit 1
fi

# Docker registry and credentials
REGISTRY=$DOCKER_REGISTRY_URL
USER=$DOCKER_REGISTRY_USER
PASSWORD=$DOCKER_REGISTRY_PASSWORD
CUTOFF_DAYS=$DOCKER_IMAGE_CUTOFF_DAYS

if [ "$DEBUG" = "true" ]
then
  echo "DOCKER_REGISTRY_URL: $DOCKER_REGISTRY_URL"
  echo "DOCKER_REGISTRY_USER: $DOCKER_REGISTRY_USER"
  echo "DOCKER_REGISTRY_PASSWORD: $DOCKER_REGISTRY_PASSWORD"
  echo "DOCKER_IMAGE_CUTOFF_DAYS: $DOCKER_IMAGE_CUTOFF_DAYS"
fi

# Get list of repositories
REPOS=$(curl -s -H 'accept: application/json' -u "${USER}:${PASSWORD}" https://${REGISTRY}/v2/_catalog | jq -r .repositories[])

if [ "$DEBUG" = "true" ]; then
  echo "REPOS: $REPOS"
fi

for REPO in $REPOS
do
  if [ "$DEBUG" = "true" ]
  then
    echo "Current REPO: $REPO"
  fi

  # Get list of tags
  TAGS_RESP=$(curl -H 'accept: application/json' -u "${USER}:${PASSWORD}" https://${REGISTRY}/v2/${REPO}/tags/list)
  TAGS=$(echo $TAGS_RESP | jq -r .tags[] || continue)

  if [ "$DEBUG" = "true" ]; then
    echo "TAGS_RESP: $TAGS_RESP"
    echo "TAGS: $TAGS"
  fi

  # Check value is null
  if [ "$TAGS" = "" ]; then
    echo "TAGS is null. Continuing loop..."
    continue
  fi

  for TAG in $TAGS
  do

    if [ "$DEBUG" = "true" ]; then
      echo "Current Tag: $TAG"
    fi

    # Get the image's creation date
    CREATED_AT=$(curl -s -H 'accept: application/json' -u "${USER}:${PASSWORD}" https://${REGISTRY}/v2/${REPO}/manifests/${TAG} | jq -r .history[0].v1Compatibility | jq -r .created )

    if [ "$DEBUG" = "true" ]; then
      echo "CREATED_AT: $CREATED_AT"
    fi

    # Check value is null
    if [ "$CREATED_AT" = "null" ]; then
      echo "CREATED_AT is null. Continuing loop..."
      continue
    fi

    # Calculate the image's age
    AGE=$(date -u -d "$CREATED_AT" "+%s")
    NOW=$(date +%s)
    DAYS_OLD=$(( ( $NOW - $AGE ) / 86400 ))

    if [ "$DEBUG" = "true" ]; then
      echo "AGE: $AGE"
      echo "NOW: $NOW"
      echo "DAYS_OLD: $DAYS_OLD"
    fi

    # If the image is older than the cutoff, delete it
    if [ "$DAYS_OLD" -gt "$CUTOFF_DAYS" ]; then
      echo "Deleting image $REPO:$TAG which is $DAYS_OLD days old."
      DIGEST=$(curl -I -s -u "${USER}:${PASSWORD}" -H "Accept: application/vnd.docker.distribution.manifest.v2+json" https://${REGISTRY}/v2/${REPO}/manifests/${TAG} | grep docker-content-digest | awk '{print $2}')
      DIGEST_TRIMMED=$(trim $DIGEST)
      if [ "$DEBUG" = "true" ]; then
        echo "DIGEST: $DIGEST_TRIMMED"
      fi
      curl -u "${USER}:${PASSWORD}" -X DELETE https://$REGISTRY/v2/$REPO/manifests/$DIGEST_TRIMMED
    else
      echo "There is no image older than $CUTOFF_DAYS day"
    fi
  done
done

echo "End Clean Up At $(date)"