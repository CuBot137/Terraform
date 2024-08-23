#!/bin/sh
set -e

# Correct path to atlantis.var
. ../atlantis.var

# Strip any carriage return characters from the variables
URL=$(echo "$URL" | tr -d '\r')
SECRET=$(echo "$SECRET" | tr -d '\r')
TOKEN=$(echo "$TOKEN" | tr -d '\r')
USERNAME=$(echo "$USERNAME" | tr -d '\r')
REPO_ALLOWLIST=$(echo "$REPO_ALLOWLIST" | tr -d '\r')

# Run the Atlantis server with the correct path to the atlantis executable
../atlantis server \
  --atlantis-url="$URL" \
  --gh-user="$USERNAME" \
  --gh-token="$TOKEN" \
  --gh-webhook-secret="$SECRET" \
  --repo-allowlist="$REPO_ALLOWLIST"
