#!/bin/bash
set -e

DOCKERHUB_USER="mateusznasewicz"
TAG="latest"

declare -A IMAGES=(
    ["todo-app-frontend"]="Dockerfile.frontend"
    ["todo-app-backend"]="Dockerfile.backend"
)

for REPO in "${!IMAGES[@]}"; do
    DOCKERFILE=${IMAGES[$REPO]}
    FULL_NAME="$DOCKERHUB_USER/$REPO:$TAG"
    docker build -f "$DOCKERFILE" -t "$FULL_NAME" .
    docker push "$FULL_NAME"
done