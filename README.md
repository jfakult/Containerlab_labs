# Containerlab Labs

A collection of small routing labs built with [Containerlab](https://containerlab.dev). Each lab is a set of Docker containers running [FRRouting](https://frrouting.org) (FRR) routers, wired together as described in a topology file.

## Summary

Every lab lives in its own folder under `labs/` and follows the same layout:

```
labs/<lab_name>/
  topology.yaml   # which nodes exist and how they are linked
  daemons.conf    # which FRR daemons to turn on (ospfd, bgpd, isisd, ...)
  configs/        # one FRR config per router (r1.conf, r2.conf, ...)
```

Routers use the `frrouting/frr` image and hosts use `alpine`. Containerlab reads `topology.yaml`, starts the containers, connects them with virtual links, and mounts the matching config file into each router.

### Labs

| Lab | What it is |
| --- | --- |
| `1_2node_docker` | Two FRR routers started with plain Docker (no Containerlab). The simplest starting point. |
| `2_6r2h_isis_bgp` | Six routers and two hosts running IS-IS inside the network and BGP between parts of it. |
| `3_100r_ram_stress_test` | 100 routers, to see how much RAM and CPU a big topology uses. Makes for very fun traceroutes :) |
| `4_ospf_single_area_broadcast_p2p` | A single-area OSPF network with broadcast segments (DR/BDR election) and point-to-point links. `layout.txt` has a diagram. |
| `labs_offline_bundle` | Extra starter labs (BGP, EVPN/VXLAN, IS-IS SR, MPLS LDP, OSPF) and an FRR CLI cheat sheet. |

### Helper scripts (`scripts/`)

- `cl_connect.sh`: open a terminal on one or more lab containers (runs `vtysh` by default).
- `generate_router_configs.sh`: create `r1.conf` ... `rN.conf` from a `base.conf`. Used for the large lab.
- `generate_gitlab_ci.py`: writes a `.gitlab-ci.yml` with one validation job per lab. Only useful if you run GitLab CI.
- `validate_lab.sh`: checks that a lab has the files it needs. Currently disabled (it exits right away).
- `startup_frr.sh`: old way of starting a single FRR container. Kept for reference.

## Installation

You need a Linux machine with:

1. **Docker**: follow the [Docker install guide](https://docs.docker.com/engine/install/).
2. **Containerlab**: `curl -sL https://containerlab.dev/setup | sudo -E bash -s "all"`, or see the [install docs](https://containerlab.dev/install/).
3. **Optional**: the [foot](https://codeberg.org/dnkl/foot) terminal, which `cl_connect.sh` uses to open windows. Edit the script if you use a different terminal.

Then clone the repo and pull the images:

```
git clone https://github.com/jfakult/Containerlab_labs.git
cd Containerlab_labs
docker pull frrouting/frr:latest
docker pull alpine:latest
```

## Usage

Go into a lab folder and run Containerlab against its topology file:

```
cd labs/2_6r2h_isis_bgp
sudo containerlab deploy -t topology.yaml     # start the lab
sudo containerlab inspect -t topology.yaml    # list nodes and their IPs
sudo containerlab graph -t topology.yaml      # draw the topology in a browser
sudo containerlab destroy -t topology.yaml    # stop and remove the lab
```

To get a shell on a router:

```
# Using the helper script (from inside the lab folder)
../../scripts/cl_connect.sh            # list containers
../../scripts/cl_connect.sh 1 2        # open vtysh on containers 1 and 2
../../scripts/cl_connect.sh bash 3     # open bash on container 3

# Or directly
sudo docker exec -it clab-2_6r2h_isis_bgp-r1 vtysh
```

Useful commands inside `vtysh`: `show ip route`, `show ip ospf neighbor`, `show isis neighbor`, `show bgp summary`. More are in `labs/labs_offline_bundle/frr_cli_cheatsheet.md`.

`1_2node_docker` does not use Containerlab. Run `./start.sh` in that folder and press Ctrl+C to clean up.

### Making a large lab

```
cd labs/3_100r_ram_stress_test
../../scripts/generate_router_configs.sh 100
```

This writes `configs/r1.conf` through `configs/r100.conf` based on `base.conf`. You still need the matching nodes and links in `topology.yaml`.

### Notes

- Containerlab creates `clab-<lab name>/` folders inside each lab with generated files (inventories, TLS keys). These are regenerated on every deploy and do not need to be committed.
- Containerlab needs root, hence `sudo`.
