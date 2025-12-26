#!/bin/bash
set -e

KEYCLOAK_URL="http://proxy/auth/"
MINIO_URL="http://minio.localhost/minio/health/live"
TERRAFORM_DIR="./terraform"

log() {
    echo -e "\n[$(date +'%H:%M:%S')] $1"
}

wait_for_service() {
    local url=$1
    local name=$2
    log "Oczekiwanie na $name ($url)..."
    
    until curl -s -L --output /dev/null --silent --head --fail "$url"; do
        printf "."
        sleep 2
    done
    echo -e "\n Serwis $name jest gotowy!"
}

run_terraform() {
    log "Uruchamiam Terraform..."
    pushd "$TERRAFORM_DIR" > /dev/null
    terraform init
    terraform apply -auto-approve
    popd > /dev/null
}

cleanup() {
    log "Zatrzymywanie starych kontenerów..."
    docker compose down
}

deploy_infra() {
    log "Uruchamiam infrastrukturę (MinIO, Keycloak, Proxy)..."
    docker compose up -d --build minio keycloak proxy
}

deploy_app() {
    log "Budowanie i uruchamianie reszty aplikacji (Backend, Frontend)..."
    docker compose up -d --build backend frontend database prometheus grafana
}

for arg in "$@"; do
    if [ "$arg" == "--push" ]; then
        log "Wykryto flagę --push. Wysyłam obrazy..."
        ./push_images.sh
    fi
done

cleanup
deploy_infra
wait_for_service "$KEYCLOAK_URL" "Keycloak"
wait_for_service "$MINIO_URL" "MinIO"
run_terraform
deploy_app
log "Deployment zakończony sukcesem!"