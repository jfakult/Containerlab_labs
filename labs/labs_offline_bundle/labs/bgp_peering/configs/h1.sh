#!/bin/sh
sleep 5
ip link set dev eth1 up
ip address add 10.255.1.2/24 dev eth1
ip route delete default
ip route add default via 10.255.1.1
sleep 365d
