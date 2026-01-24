#!/bin/bash
set -e
wait_for_service() {
    local url=$1
    local name=$2
    echo "Czekam na $name ($url)..."
     until curl -k -s -L --output /dev/null --silent --head --fail "$url"; do
        printf '.'
        sleep 2
    done
    echo -e "\n$name jest gotowy!"
}

cd terraform
source .env
terraform init

CHECK_IP=$(terraform output -raw instance_ip 2>/dev/null || echo "")

terraform apply -target=aws_instance.app_server -auto-approve
KEY_FILE="todo-app-key.pem"
if [ -f "$KEY_FILE" ]; then
    eval "$(ssh-agent -s)"
    ssh-add "$KEY_FILE"
    trap 'kill $SSH_AGENT_PID' EXIT
else
    echo "BŁĄD: Plik $KEY_FILE nie został utworzony przez Terraform!"
    exit 1
fi

terraform apply \
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
wait_for_service "http://$CHECK_IP/auth/" "Keycloak"


terraform apply -auto-approve
echo "Gotowe"
