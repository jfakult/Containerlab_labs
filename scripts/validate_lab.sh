#!/bin/bash
set -e

LAB_PATH="$1"

echo "Validating lab at: $LAB_PATH"

# Basic checks
[ -f "$LAB_PATH/topology.yaml" ] || { echo "Missing topology.yaml"; exit 1; }
[ -f "$LAB_PATH/daemons.conf" ] || { echo "Missing daemons.conf"; exit 1; }

# Check all .conf files exist
for cfg in "$LAB_PATH"/configs/*.conf; do
  [ -f "$cfg" ] || { echo "Missing config: $cfg"; exit 1; }
done

# Optional: dry-run or inspect topology
containerlab inspect --topo "$LAB_PATH/topology.yaml" --quiet || {
  echo "Containerlab inspect failed"; exit 1;
}

echo "✅ Validation passed for $LAB_PATH"
