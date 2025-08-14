# FRR CLI Cheat Sheet

## Common Mode Navigation
```
enable
configure terminal
```

## Interface Configuration
```
interface eth1
 ip address 10.0.0.1/30
 no shutdown
```

## OSPF
```
router ospf
 network 10.0.0.0/8 area 0
```

## BGP
```
router bgp 65001
 bgp router-id 1.1.1.1
 neighbor 10.0.0.2 remote-as 65002
 network 10.0.0.0/24
```

## IS-IS
```
router isis
 net 49.0001.0000.0000.0001.00
 is-type level-2
 interface eth1
  ip router isis
```

## Show Commands
```
show ip route
show ip ospf neighbor
show ip bgp summary
show isis neighbor
show interface
```


# Enable MPLS on interfaces
interface eth1
 mpls ip

interface eth2
 mpls ip

# LDP Configuration
router ldp
 router-id 1.1.1.1
 address-family ipv4
  discovery transport-address 1.1.1.1
  interface eth1
  interface eth2

show mpls ldp discovery
show mpls ldp neighbor
show mpls forwarding-table
traceroute <dest> mpls



# Interface-level setup
interface vxlan100
 vxlan id 100
 vxlan local-tunnelip 10.0.0.1
 vxlan remote 10.0.0.2
 bridge-access 100
 no shutdown

interface br100
 bridge-ports vxlan100 eth1
 no shutdown

# BGP EVPN
router bgp 65001
 bgp router-id 1.1.1.1
 address-family l2vpn evpn
  neighbor 10.0.0.2 activate
  advertise-all-vni

 address-family l2vpn evpn
  vni 100
   rd 1.1.1.1:100
   route-target import 65001:100
   route-target export 65001:100
   advertise-svi

show evpn vni
show bridge vlan
show bgp l2vpn evpn summary
show vxlan



router bgp 65006
 bgp router-id 6.6.6.6
 timers bgp 10 30
 neighbor 1.1.1.1 remote-as 65001


 router bgp 65001
 bgp router-id 1.1.1.1
 timers bgp 10 30
 neighbor 6.6.6.6 remote-as 65006