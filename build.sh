#!/bin/bash
set -e
wait_for_service() {
    local url=$1
    local name=$2
    echo "Czekam na $name ($url)..."
     until curl -s -L --output /dev/null --silent --head --fail "$url"; do
        printf '.'
        sleep 2
    done
    echo -e "\n$name jest gotowy!"
}

cd terraform
terraform init
TARGET=${1:-local}
if [ "$TARGET" == "local" ]; then
    CHECK_IP="127.0.0.1"
else
    CHECK_IP=$(terraform output -raw instance_ip 2>/dev/null || echo "")
fi

terraform apply -var="deployment_target=$TARGET" \
  -target=module.infrastructure \
  -target=docker_container.proxy \
  -target=docker_container.minio \
  -target=docker_container.keycloak \
  -target=docker_network.todo_net \
  -target=docker_volume.minio_data \
  -auto-approve

if [ "$TARGET" == "aws" ]; then
    CHECK_IP=$(terraform output -raw instance_ip)
fi

wait_for_service "http://$CHECK_IP:9000/minio/health/live" "MinIO"
wait_for_service "http://$CHECK_IP/auth" "Keycloak"


terraform apply -var="deployment_target=$TARGET" -auto-approve
echo "Gotowe"
