#!/bin/bash

# Old start script.
# Now we just use container lab to do this (and have a daemons.conf etc specified in the topology.yaml)
#     cd to lab folder then
#     containerlab -t topology.yaml [deploy/destroy/graph/inspect]

sudo docker run -it --rm \
  --name "$1" \
  --privileged \
  -v "$(pwd)/images/frr/frr.conf":/etc/frr/frr.conf \
  frrouting/frr:latest

