#!/bin/bash
docker compose down
./push_images.sh
docker compose up -d --build
docker image prune -f