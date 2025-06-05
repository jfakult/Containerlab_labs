#!/bin/bash

# Usage: ./generate_configs.sh <number_of_routers>

set -e

pwd

if [ -z "$1" ]; then
  echo "Usage: $0 <number_of_routers>"
  exit 1
fi

NUM_ROUTERS=$1
BASE_CONF="base.conf"
CONFIG_DIR="configs"

# Check for base.conf
if [ ! -f "$BASE_CONF" ]; then
  echo "⚠️  base.conf not found. Continue anyway? (y/n)"
  read -r answer
  if [[ "$answer" != "y" ]]; then
    echo "Aborted."
    exit 1
  fi
fi

mkdir -p "$CONFIG_DIR"

for i in $(seq 1 "$NUM_ROUTERS"); do
  ROUTER_NAME="r${i}"
  LOOPBACK_IP="${i}.${i}.${i}.${i}"
  CONF_FILE="$CONFIG_DIR/${ROUTER_NAME}.conf"
  PREVIOUS_NUMBER="$((i - 1))"
  NEXT_NUMBER=$((i + 1))
  IS_EVEN=$(($PREVIOUS_NUMBER % 2))

  # 0 pad to 4 chars
  ROUTER_ID=$(printf "%04d" "$i")

  # delete existing config file if it exists
  if [ -f "$CONF_FILE" ]; then
    echo "Deleting existing config file: $CONF_FILE"
    rm "$CONF_FILE"
  fi

  # rewrite the above with single command
  cat <<EOF >> "$CONF_FILE"
! Auto-generated config for $ROUTER_NAME

service integrated-vtysh-config
log stdout

hostname $ROUTER_NAME

interface lo
    ip address $LOOPBACK_IP/32

interface eth1
  ip address 10.$PREVIOUS_NUMBER.$i.$IS_EVEN/24
exit
!

interface eth2
  ip address 10.$i.$NEXT_NUMBER.$IS_EVEN/24
exit
!

router isis 0
 net 49.0001.0000.0000.$ROUTER_ID.00
exit
!


!

! Base configuration
EOF

  if [ -f "$BASE_CONF" ]; then
    cat "$BASE_CONF" >> "$CONF_FILE"
  else
    echo "! Base configuration not found, skipping."
  fi

  echo "✅ Generated $CONF_FILE"
done
