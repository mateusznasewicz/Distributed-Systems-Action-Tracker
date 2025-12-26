#!/bin/bash
set -e 

PUSH_IMAGES=false
for arg in "$@"
do
    if [ "$arg" == "--push" ]; then
        PUSH_IMAGES=true
    fi
done

docker compose down

if [ "$PUSH_IMAGES" = true ]; then
    ./push_images.sh
fi

docker compose up -d --build

echo "Waiting for keycloak"
until $(curl --output /dev/null --silent --head --fail http://proxy/auth/); do
    printf '.'
    sleep 2
done
echo "Keycloak is ready"

cd terraform
terraform init
terraform apply -auto-approve
