#!/bin/bash

# Usage: 
# From the lab directory:
# ../../scripts/cl_connect.sh 
# Print all containerlab containers

# ../../scripts/cl_connect.sh [bash,vtysh,etc] 1 2 3 [any other ids of containerlab containers]
# if no $1, just run containerlab inspect
if [ -z "$1" ]; then
  echo "Runnng containerlab inspect"
  containerlab inspect -t *.yaml
  exit 0
fi

# if $1 is not a number, assume it is START_COMMAND
if ! [[ "$1" =~ ^[0-9]+$ ]]; then
  START_COMMAND="$1"
else
  START_COMMAND="vtysh"
fi

CONTAINERS=$(containerlab inspect -t *.yaml 2>/dev/null | grep clab)

# loop through all arguments
for CONNECT_INDEX in "$@"; do
    # if CONNECT_INDEX is not a number, skip
    if ! [[ "$CONNECT_INDEX" =~ ^[0-9]+$ ]]; then
        echo "Invalid index: $CONNECT_INDEX. Please provide a valid number."
        continue
    fi
    CONTAINER=$(echo "$CONTAINERS" | sed -n "${CONNECT_INDEX}p" | awk '{print $2}')

    # spawn new foot terminal for each container with docker exec vtysh
    echo Running: sudo docker exec -it $CONTAINER $START_COMMAND
    foot --title "$CONTAINER" bash -c "sudo docker exec -it $CONTAINER $START_COMMAND" &
    sleep 0.25
done