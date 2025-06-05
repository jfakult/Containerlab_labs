#!/bin/bash

set -e

NET_NAME="frr-net"

# Create network if it doesn't exist
if ! docker network ls --format '{{.Name}}' | grep -q "^${NET_NAME}\$"; then
  echo "Creating Docker network '${NET_NAME}'..."
  sudo docker network create --subnet=192.168.100.0/24 "$NET_NAME"
else
  echo "Docker network '${NET_NAME}' already exists"
fi

# Start containers
echo "Starting frr1..."
sudo docker run -dit --rm \
  --name frr1 \
  --privileged \
  --net frr-net --ip 192.168.100.101 \
  -v "$(pwd)/frr1.conf":/etc/frr/frr.conf \
  -v "$(pwd)/daemons.conf":/etc/frr/daemons \
  frrouting/frr:latest


echo "Starting frr2..."
sudo docker run -dit --rm \
  --name frr2 \
  --privileged \
    --net frr-net --ip 192.168.100.102 \
  -v "$(pwd)/frr2.conf":/etc/frr/frr.conf \
  -v "$(pwd)/daemons.conf":/etc/frr/daemons \
  frrouting/frr:latest

# Wait for user to press Ctrl+C
echo -e "\n🟢 FRR lab is running. Press Ctrl+C to stop and clean up."

# Trap Ctrl+C and clean up
trap cleanup INT

cleanup() {
  echo -e "\n\n🧹 Cleaning up..."

  echo "Stopping containers..."
  sudo docker stop frr1 frr2 || true

  echo "Removing network '${NET_NAME}'..."
  sudo docker network rm "$NET_NAME" || true

  echo "✅ Done."
  exit 0
}

# Wait indefinitely
while true; do sleep 1; done
