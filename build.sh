#!/bin/bash
docker compose down
./push_images.sh
docker compose up -d --build
