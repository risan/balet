#!/bin/bash

# Colors.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Command arguments.
WEBSITE_TYPE="$1"               # Website type: html, html-ssl, php, php-ssl.
WEBSITE_NAME="$2"               # The website domain.
WEBSITE_RELATIVE_ROOT_DIR="$3"  # The relative path to the root directory.
PROXY_PORT="$3"                 # Reverse proxy port.

CURRENT_DIR="$PWD"
BALET_DIR="`dirname $0`"
CONFIGURATIONS_DIR="$BALET_DIR/configurations"
LOGS_DIR="$BALET_DIR/logs"
SERVERS_DIR="$BALET_DIR/servers"
SSL_DIR="$BALET_DIR/ssl"
TEMPLATES_DIR="$BALET_DIR/templates"
HOSTS_FILE="/etc/hosts"

# Make sure that the website type is set.
if [ -z $WEBSITE_TYPE ]; then
  echo "${RED}The website-type argument is required!${NC}\n"
  echo "${YELLOW}balet add website-type domain [root-dir | port]\n${NC}"
  echo "${YELLOW}[website-type]${NC}"
  echo "${YELLOW}- html: HTML website type.${NC}"
  echo "${YELLOW}- html-ssl: HTML website with SSL type.${NC}"
  echo "${YELLOW}- php: PHP website type.${NC}"
  echo "${YELLOW}- php-ssl: PHP website with SSL type.${NC}"
  echo "${YELLOW}- reverse-proxy: Reverse proxy server type.${NC}"
  echo "${YELLOW}- reverse-proxy-ssl: Reverse proxy server with SSL type.${NC}"
  exit 1
fi

WEBSITE_TEMPLATE_FILE="$TEMPLATES_DIR/$WEBSITE_TYPE.dev"

# Make sure that the template for the website type is exists.
if [ ! -f $WEBSITE_TEMPLATE_FILE ]; then
  echo "${RED}The website configuration template for type $WEBSITE_TYPE is not exists: $WEBSITE_TEMPLATE_FILE${NC}"
  exit 1
fi

# Make sure that the website name is set.
if [ -z $WEBSITE_NAME ]; then
  echo "${RED}The website-name argument is required!${NC}"
  if [ "$WEBSITE_TYPE" == "reverse-proxy" ] || [ "$WEBSITE_TYPE" == "reverse-proxy-ssl" ]; then
    echo "${YELLOW}sh addsite.sh $WEBSITE_TYPE website-name [reverse-proxy-port]${NC}"
  else
    echo "${YELLOW}sh addsite.sh $WEBSITE_TYPE website-name [website-root-dir]${NC}"
  fi
  exit 1
fi

WEBSITE_CONFIG_FILE="$SERVERS_DIR/$WEBSITE_NAME"
WEBSITE_ERROR_LOG_FILE="$LOGS_DIR/$WEBSITE_NAME-error.log"

# Check if the webiste configuration file is already exist.
if [ -f $WEBSITE_CONFIG_FILE ]; then
  echo "${RED}The configuration file for $WEBSITE_NAME is already exists: $WEBSITE_CONFIG_FILE${NC}"
  exit 1
fi

# Get root directory.
if [ -z $WEBSITE_RELATIVE_ROOT_DIR ]; then
  if [ -d "$CURRENT_DIR/public" ]; then
    WEBSITE_ROOT_DIR="$CURRENT_DIR/public"
  elif [ -d "$CURRENT_DIR/html" ]; then
    WEBSITE_ROOT_DIR="$CURRENT_DIR/html"
  else
    WEBSITE_ROOT_DIR="$CURRENT_DIR"
  fi
else
  WEBSITE_ROOT_DIR="$CURRENT_DIR/$WEBSITE_RELATIVE_ROOT_DIR"
fi

# Make sure that the reverse proxy port is not empty.
if [ "$WEBSITE_TYPE" == "reverse-proxy" ]; then
  if [ -z $PROXY_PORT ]; then
    # If none given, set the proxy port number to 3000.
    PROXY_PORT="3000"
  fi
fi

# Generating certificate files.
if [ "$WEBSITE_TYPE" == "html-ssl" ] || [ "$WEBSITE_TYPE" == "php-ssl" ] || [ "$WEBSITE_TYPE" == "reverse-proxy-ssl" ]; then
  SYSTEM_KEYCHAIN_PATH="/Library/Keychains/System.keychain"
  SSL_DH_PARAM_FILE="$SSL_DIR/dhparam.pem"
  WEBSITE_SSL_DIR="$SSL_DIR/$WEBSITE_NAME"
  WEBSITE_SSL_PRIVATE_KEY_FILE="$WEBSITE_SSL_DIR/private.key"
  WEBSITE_SSL_SIGNING_REQUEST_FILE="$WEBSITE_SSL_DIR/signing-request.csr"
  WEBSITE_SSL_CERTIFICATE_FILE="$WEBSITE_SSL_DIR/certificate.crt"

  if [ ! -f $SSL_DH_PARAM_FILE ]; then
    # Create a strong SSL DH parameters file.
    openssl dhparam -out $SSL_DH_PARAM_FILE 2048
    echo "${CYAN}The new SSL DH parameters file is generated: $SSL_DH_PARAM_FILE${NC}"
  fi

  # Create a directory for website's SSL certificates.
  rm -Rf "$WEBSITE_SSL_DIR"
  mkdir "$WEBSITE_SSL_DIR"

  # Generating an SSL private key file.
  openssl genrsa -out "$WEBSITE_SSL_PRIVATE_KEY_FILE" 2048
  echo "${CYAN}SSL private key file is generated: $WEBSITE_SSL_PRIVATE_KEY_FILE${NC}"

  # Generating an SSL signing request file.
  openssl req -new -subj "/C=/ST=/O=/localityName=/commonName=$WEBSITE_NAME/organizationalUnitName=/emailAddress=/" -key "$WEBSITE_SSL_PRIVATE_KEY_FILE" -out "$WEBSITE_SSL_SIGNING_REQUEST_FILE" -passin pass:
  echo "${CYAN}SSL signing request file is generated: $WEBSITE_SSL_SIGNING_REQUEST_FILE${NC}"

  # Generating an SSL certificate file.
  openssl x509 -req -days 365 -in "$WEBSITE_SSL_SIGNING_REQUEST_FILE" -signkey "$WEBSITE_SSL_PRIVATE_KEY_FILE" -out "$WEBSITE_SSL_CERTIFICATE_FILE"
  echo "${CYAN}SSL certificate file is generated: $WEBSITE_SSL_CERTIFICATE_FILE${NC}"

  # Trust the generated certificate.
  sudo security add-trusted-cert -d -r trustRoot -k "$SYSTEM_KEYCHAIN_PATH" "$WEBSITE_SSL_CERTIFICATE_FILE"
  echo "${CYAN}SSL certificate file is added to trusted list.${NC}"
fi

# Copy and configure the website template configuration file.
echo "${CYAN}Creating website configuration file for: $WEBSITE_NAME...${NC}"
cp "$WEBSITE_TEMPLATE_FILE" "$WEBSITE_CONFIG_FILE"
sed -i '' "s/WEBSITE_NAME/$WEBSITE_NAME/g" $WEBSITE_CONFIG_FILE
sed -i '' "s~WEBSITE_ERROR_LOG_FILE~$WEBSITE_ERROR_LOG_FILE~g" $WEBSITE_CONFIG_FILE
sed -i '' "s~CONFIGURATIONS_DIR~$CONFIGURATIONS_DIR~g" $WEBSITE_CONFIG_FILE

if [ "$WEBSITE_TYPE" == "reverse-proxy" ] || [ "$WEBSITE_TYPE" == "reverse-proxy-ssl" ]; then
  # Replace the proxy port number.
  sed -i '' "s/PROXY_PORT/$PROXY_PORT/g" $WEBSITE_CONFIG_FILE
else
  # Replace the website root directory.
  sed -i '' "s~WEBSITE_ROOT_DIR~$WEBSITE_ROOT_DIR~g" $WEBSITE_CONFIG_FILE
fi

# Update the certificate, private key, and dhparam files.
if [ "$WEBSITE_TYPE" == "html-ssl" ] || [ "$WEBSITE_TYPE" == "php-ssl" ] || [ "$WEBSITE_TYPE" == "reverse-proxy-ssl" ]; then
  sed -i '' "s~WEBSITE_SSL_CERTIFICATE_FILE~$WEBSITE_SSL_CERTIFICATE_FILE~g" $WEBSITE_CONFIG_FILE
  sed -i '' "s~WEBSITE_SSL_PRIVATE_KEY_FILE~$WEBSITE_SSL_PRIVATE_KEY_FILE~g" $WEBSITE_CONFIG_FILE
  sed -i '' "s~SSL_DIR~$SSL_DIR~g" $WEBSITE_CONFIG_FILE
fi

# Update the hosts file.
echo "${CYAN}Updating the hosts file...${NC}"
sed -i '' "/127.0.0.1 $WEBSITE_NAME/d" $HOSTS_FILE  # Remove the domain if any.
echo "127.0.0.1 $WEBSITE_NAME" >> $HOSTS_FILE       # Add the domain to the hosts file.

# Reload nginx.
echo "${CYAN}Restarting the Nginx server...${NC}"
nginx -s reload

echo "${GREEN}The $WEBSITE_NAME website is created \xE2\x9C\x94${NC}"
