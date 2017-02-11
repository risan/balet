#!/bin/bash

# Colors.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Command arguments.
WEBSITE_NAME="$1"

BALET_DIR="`dirname $0`"
LOGS_DIR="$BALET_DIR/logs"
SERVERS_DIR="$BALET_DIR/servers"
SSL_DIR="$BALET_DIR/ssl"
HOSTS_FILE="/etc/hosts"

# Make sure that the website name is set.
if [ -z $WEBSITE_NAME ]; then
  echo "${RED}The website-name argument is required!${NC}"
  echo "${YELLOW}sh removesite.sh website-name${NC}"
  exit 1
fi

WEBSITE_CONFIG_FILE="$SERVERS_DIR/$WEBSITE_NAME"
WEBSITE_ERROR_LOG_FILE="$LOGS_DIR/$WEBSITE_NAME-error.log"
WEBSITE_SSL_DIR="$BALET_DIR/ssl/$WEBSITE_NAME"

# Check if the webiste configuration file is not exist.
if [ ! -f $WEBSITE_CONFIG_FILE ]; then
  echo "${RED}The configuration file for $WEBSITE_NAME is not exists: $WEBSITE_CONFIG_FILE${NC}"
  exit 1
fi

# Delete the configuration file, log, and certificate directory.
rm "$WEBSITE_CONFIG_FILE"
rm "$WEBSITE_ERROR_LOG_FILE"
rm -Rf "$WEBSITE_SSL_DIR"

# Remove the domain from the hosts file.
sed -i '' "/127.0.0.1 $WEBSITE_NAME/d" $HOSTS_FILE

# Reload nginx.
nginx -s reload
