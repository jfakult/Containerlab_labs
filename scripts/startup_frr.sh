#!/bin/bash

sudo docker run -it --rm \
  --name "$1" \
  --privileged \
  -v "$(pwd)/images/frr/frr.conf":/etc/frr/frr.conf \
  frrouting/frr:latest

