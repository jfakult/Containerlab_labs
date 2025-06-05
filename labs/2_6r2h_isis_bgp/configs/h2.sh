#!/bin/sh

# Wait just a sec for containerlab to get everything going
sleep 5

ip link set dev eth1 up
ip address add 10.255.2.2/24 dev eth1
ip route delete default
ip route add default via 10.255.2.1

# Containerlab will shut down the container if no process is running
sleep 365d