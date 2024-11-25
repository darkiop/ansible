# TODO

- Move most of dotfiles/bin to ansible/files
- Role my.proxmox: wake-on-lan config
- Proxmox Storage (<https://galaxy.ansible.com/lae/proxmox>)
- Proxmox Network (<https://galaxy.ansible.com/lae/proxmox>)
- Proxmox Backup Server (<https://github.com/djarbz/ansible-proxmox-backup-client>)
└─ ansible
   ├─ books
   │  └─ pve-migrate-all-nodes.yml
   │     └─ line 5: TODO Fix: if /etc/pve/ha/resources.cfg.bak does not exist > auth error before copying
   ├─ group_vars
   │  └─ vars.yml
   │     ├─ line 17: TODO Split for Debian/Ubuntu
   │     ├─ line 18: TODO remove commented / find correct package
   │     └─ line 161: TODO convert to role my.sudoers
   ├─ host_vars
   │  ├─ vpn-gw-bw17
   │  │  └─ vars.yml
   │  │     └─ line 19: TODO remove and use my.docker role?
   │  └─ vpn-gw-hs6
   │     └─ vars.yml
   │        └─ line 19: TODO remove and use my.docker role?
   ├─ roles
   │  ├─ my.essentials
   │  │  ├─ defaults
   │  │  │  └─ main.yml
   │  │  │     └─ line 42: TODO change name of variable
   │  │  └─ tasks
   │  │     ├─ main.yml
   │  │     │  ├─ line 50: TODO move to role my.dotfiles
   │  │     │  └─ line 82: TODO : wip
   │  │     └─ wip__setup-network.yml
   │  │        └─ line 55: TODO Ubuntu config
   │  ├─ my.keepalived
   │  │  └─ main.yml
   │  │     └─ line 26: TODO check pihole-ftl status with script
   │  ├─ my.pbs
   │  │  └─ main.yml
   │  │     ├─ line 47: TODO add boot-up.sh.j2 and shutdown.sh.j2
   │  │     └─ line 48: TODO add and configure datastore
   │  ├─ my.pihole
   │  │  └─ main.yml
   │  │     └─ line 1: TODO : why defaults/main.yml is not used?
   │  ├─ my.ssh
   │  │  ├─ authorized-keys.yml
   │  │  │  └─ line 16: TODO /Users -> ~
   │  │  └─ main.yml
   │  │     └─ line 22: TODO add private keys
   │  ├─ my.zabbix-agent
   │  │  └─ main.yml
   │  │     └─ line 129: TODO add host to server
   │  ├─ wip_my.dotfiles
   │  │  └─ main.yml
   │  │     └─ line 1: TODO role for dotfiles
   │  ├─ wip_my.grafana
   │  │  └─ main.yml
   │  │     └─ line 1: TODO add tasks for grafana install
   │  ├─ wip_my.iobroker
   │  │  └─ main.yml
   │  │     └─ line 1: TODO role for ioBroker
   │  ├─ wip_my.named
   │  │  └─ main.yml
   │  │     └─ line 1: TODO role for named
   │  ├─ wip_my.tailscale
   │  │  └─ main.yml
   │  │     └─ line 1: TODO role for Tailscale
   │  ├─ wip_my.ufw
   │  │  └─ main.yml
   │  │     └─ line 34: TODO https://github.com/hannseman/ansible-raspbian/blob/master/tasks/ufw.yml
   │  ├─ wip_my.webmin
   │  │  └─ main.yml
   │  │     └─ line 1: TODO role for Webmin
   │  ├─ wip_my.windows
   │  │  └─ main.yml
   │  │     └─ line 1: TODO role for Windows
   │  └─ wip_my.wireguard
   │     └─ main.yml
   │        └─ line 1: TODO role for Wireguard
   ├─ TODO.md
   │  └─ line 1: TODO 
   └─ main.yml
      ├─ line 75: TODO keepalived for pveproxy ui?
      ├─ line 78: TODO move to my.essentials
      ├─ line 88: TODO move to my.essentials
      ├─ line 120: TODO add role my.docker
      ├─ line 121: TODO add role my.wireguard
      ├─ line 130: TODO package docker-ce not available - maybe with Debian 12?
      ├─ line 135: TODO use role my.essentials if ready
      ├─ line 196: TODO add role my.iobroker
      ├─ line 275: TODO add role my.named
      ├─ line 276: TODO add role my.tailscale
      ├─ line 401: TODO add copy of scripts to role
      └─ line 425: TODO role: my.wireguard
