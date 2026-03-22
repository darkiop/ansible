# Ansible IaC

Infrastruktur-as-Code Repository fuer die Heiminfrastruktur. Verwaltet Proxmox-Nodes, LXC-Container, VMs, Raspberry Pis, NAS-Systeme, VPN-Gateways und macOS-Hosts.

---

## Inhaltsverzeichnis

- [Projektstruktur](#projektstruktur)
- [Inventar und Gruppen](#inventar-und-gruppen)
- [Playbooks](#playbooks)
- [Rollen](#rollen)
- [Variablen und Vault](#variablen-und-vault)
- [Verwendung](#verwendung)
- [Abhaengigkeiten (Galaxy)](#abhaengigkeiten-galaxy)
- [Testing](#testing)

---

## Projektstruktur

```
.
├── ansible.cfg               # Ansible-Konfiguration
├── hosts.ini                 # Inventar
├── main.yml                  # Master-Playbook (importiert alle setup-*.yml)
├── bootstrap.yml             # Bootstrap fuer neue Hosts
├── setup-adblock.yml         # Adblock (Pi-hole)
├── setup-docker.yml          # Docker-Hosts
├── setup-lxc-vm.yml          # Alle Proxmox LXC + VMs (Basis-Setup)
├── setup-macos.yml           # macOS
├── setup-nas.yml             # Synology NAS
├── setup-proxmox-hosts.yml   # Proxmox-Nodes
├── setup-samba.yml           # Samba
├── setup-vpn_gw_ext.yml      # Externe VPN-Gateways
├── setup-vpn_gw_hetzner.yml  # Hetzner VPN-Gateway
├── books/                    # Utility-Playbooks (Einzel-Tasks, Diagnose)
├── roles/                    # Eigene Rollen (my.*) + WIP-Rollen (wip_my.*)
├── group_vars/               # Gruppen-Variablen und Vault-Dateien
├── host_vars/                # Host-spezifische Variablen
├── files/                    # Statische Dateien (Skripte, Host-spezifisch)
├── templates/                # Jinja2-Templates (global)
└── examples/                 # Beispiel-Tasks fuer Referenz
```

---

## Inventar und Gruppen

Inventar: `hosts.ini`

| Gruppe         | Hosts                                                                                                       | Beschreibung                        |
|----------------|-------------------------------------------------------------------------------------------------------------|-------------------------------------|
| `pve_hosts`    | pve01, pve02                                                                                                | Proxmox VE Nodes                    |
| `pve_backup`   | pbs-odin, pbs-freya                                                                                         | Proxmox Backup Server               |
| `pve_lxc`      | pve-ct-grafana, pve-ct-pihole, pve-ct-rustdesk, pve-ct-uptimekuma, pve-ct-mariadb, pve-ct-influxdb, pve-ct-bind-master, pve-ct-dev, pve-ct-mqtt, pve-ct-vpn-hetzner, pve-ct-iobroker | Proxmox LXC Container |
| `pve_vm`       | pve-vm-docker                                                                                               | Proxmox VMs                         |
| `rpi`          | loki, loki-new                                                                                              | Raspberry Pi                        |
| `nas`          | odin, freya                                                                                                 | Synology NAS                        |
| `adblock`      | loki-new, pve-ct-pihole, vpn-gw-hs6, vpn-gw-bw17                                                           | Pi-hole Instanzen                   |
| `docker`       | pve-vm-docker, pve-ct-dev                                                                                   | Docker-Hosts                        |
| `vpn_gw_ext`   | vpn-gw-hs6, vpn-gw-bw17                                                                                     | Externe VPN-Gateways                |
| `hetzner_cloud`| vpn-hetzner                                                                                                 | Hetzner VPN-Gateway                 |
| `os_windows`   | pve-vm-win11                                                                                                | Windows VMs (WinRM)                 |
| `os_macos`     | yggdrasil                                                                                                   | macOS Hosts                         |
| `test_hosts`   | (auskommentiert)                                                                                            | Test-Systeme (Ubuntu, Debian)       |

**Uebergeordnete Gruppen:**

- `hosts` - alle Hosts (children: alle Gruppen)
- `essentials` - erhaelt `my.essentials` + `my.ssh` im Bootstrap (children: pve_hosts, pve_lxc, pve_vm, vpn_gw_ext, test_hosts + loki-new direkt)
- `samba` - erhaelt Samba-Konfiguration

---

## Playbooks

### `bootstrap.yml` - Ersteinrichtung neuer Hosts

Wendet die Basis-Rollen auf alle Linux-Hosts an. Einstiegspunkt fuer neue Systeme.

```bash
ansible-playbook bootstrap.yml -l <host>
ansible-playbook bootstrap.yml -l pve_lxc --tags role-essentials
```

Rollen:
- `my.essentials` - System-Grundkonfiguration
- `my.ssh` - SSH-Key-Verwaltung
- `chriswayg.msmtp-mailer` - Mail via MSMTP (Gmail)
- `geerlingguy.ntp` - NTP-Synchronisation

### `main.yml` - Master-Orchestrator

Importiert alle `setup-*.yml` Playbooks der Reihe nach. Wird typischerweise mit `-l` (Limit) oder `--tags` eingeschraenkt.

```bash
ansible-playbook main.yml -l pve01
ansible-playbook main.yml --tags role-pihole
```

### Spezifische Setup-Playbooks

| Playbook                    | Hosts          | Rollen / Aufgaben                                          |
|-----------------------------|----------------|------------------------------------------------------------|
| `setup-proxmox-hosts.yml`   | pve_hosts      | my.proxmox, stuvusit.smartd (nvme), Skript-Deployment      |
| `setup-lxc-vm.yml`          | pve_lxc, pve_vm| my.samba, geerlingguy.security                             |
| `setup-adblock.yml`         | adblock        | my.pihole                                                  |
| `setup-docker.yml`          | docker         | my.docker                                                  |
| `setup-nas.yml`             | nas            | Skripte auf Synology deployen                              |
| `setup-macos.yml`           | os_macos       | my.macos                                                   |
| `setup-vpn_gw_ext.yml`      | vpn_gw_ext     | my.docker, my.samba, my.wireguard-client, my.tailscale, nmcli static IP |
| `setup-vpn_gw_hetzner.yml`  | hetzner_cloud  | Hetzner VPN-spezifisches Setup                             |
| `setup-samba.yml`           | samba          | my.samba                                                   |

### Host-spezifische Plays in `main.yml`

| Host              | Rollen / Tasks                                                                                       |
|-------------------|------------------------------------------------------------------------------------------------------|
| `pve-ct-iobroker` | my.smartmeter, Skripte deployen, Cronjobs (iface metric, rsync-backups.sh)                          |
| `loki-new`        | geerlingguy.security, my.samba, my.smartmeter, my.tailscale, my.docker, RPi-Config (WiFi/BT off), Cronjobs (arp.sh, backup_bind.sh) |
| `pbs-odin`        | my.pbs, NFS-Mount (/mnt/pbs-odin), Datastore-Konfiguration                                          |
| `pbs-freya`       | my.pbs, Datastore-Konfiguration (/data)                                                              |

### Utility-Playbooks (`books/`)

| Playbook                    | Zweck                                      |
|-----------------------------|--------------------------------------------|
| `books/dump-variables.yml`  | Alle Variablen eines Hosts ausgeben        |
| `books/get-facts.yml`       | Ansible-Facts sammeln                      |
| `books/get-os-release.yml`  | OS-Release-Info abfragen                   |
| `books/check-network-config-mode.yml` | Netzwerkmodus pruefen             |
| `books/pi-detect.yml`       | Raspberry Pi erkennen                      |
| `books/pve-migrate-all-nodes.yml` | Proxmox VM-Migration               |
| `books/pbs-client-test.yml` | PBS-Client testen                          |
| `books/install-iobroker.yml`| ioBroker installieren                      |
| `books/win.yml`             | Windows-Tasks                              |

---

## Rollen

### Eigene Rollen (`roles/my.*`)

#### `my.essentials`

Basis-Systemkonfiguration fuer alle Linux-Hosts.

```yaml
# Optionale Features aktivieren/deaktivieren
my_essentials_install_dotfiles: true
my_essentials_install_navi: true
my_essentials_install_chtsh: true
my_essentials_install_dysk: true
my_essentials_install_vimrc: true

# APT-Pakete
my_essentials_apt_default_packages:   # Standard-Paketliste (in group_vars/all/vars.yml definiert)
my_essentials_apt_additional_packages: # Zusaetzliche Pakete (pro Gruppe/Host)
my_essentials_pip_packages:            # pip3-Pakete

# Benutzer anlegen
my_essentials_user_username: "{{ vault_my_essentials_user_username }}"
my_essentials_user_password: "{{ vault_my_essentials_user_password }}"
my_essentials_user_shell: /bin/bash
my_essentials_user_dotfiles_repo: https://github.com/darkiop/dotfiles
my_essentials_user_timezone: Europe/Berlin
my_essentials_user_locale: C
my_essentials_user_keyboard_layout: de
my_essentials_user_email: "{{ vault_my_essentials_user_email }}"
my_essentials_user_email_password: "{{ vault_my_essentials_user_email_password }}"

# Sudoers (passwordlose Befehle)
sudoers_bin_nopasswd: /usr/bin/apt-get, /usr/bin/apt, /usr/sbin/reboot, /usr/sbin/poweroff

# Netzwerkkonfiguration (optional, Standard: dhcp)
my_essentials_network_mode: "dhcp"  # static | dhcp
my_essentials_network_interface_name:
my_essentials_network_static_ip_1: "{{ vault_my_essentials_network_static_ip_1 }}"
my_essentials_network_static_ip_2: "{{ vault_my_essentials_network_static_ip_2 }}"
my_essentials_network_gateway: "{{ vault_my_essentials_network_gateway }}"
my_essentials_network_domain_name: "{{ vault_my_essentials_network_domain_name }}"
my_essentials_network_domain_search: "{{ vault_my_essentials_network_domain_search }}"
my_essentials_network_dns_1: "{{ vault_my_essentials_network_dns_1 }}"
my_essentials_network_dns_2: "{{ vault_my_essentials_network_dns_2 }}"
```

Standard-APT-Pakete (Auszug): `sudo`, `git`, `curl`, `vim`, `zsh`, `tmux`, `btop`, `lsd`, `bat`, `nmap`, `dnsutils`, `tcpdump`, `iperf3`, `rsync`, `nfs-common`, `wakeonlan`, u.v.m.

---

#### `my.docker`

Installiert Docker CE via `geerlingguy.docker` und legt Docker-Verzeichnisse im Homeverzeichnis an (`docker/prod/`, `docker/test/`).

---

#### `my.mqtt`

Installiert und konfiguriert einen Mosquitto MQTT-Broker.

```yaml
my_mqtt_username:
my_mqtt_password:
```

---

#### `my.named`

Installiert BIND9 (named) als DNS-Server.

---

#### `my.pbs`

Installiert den Proxmox Backup Server aus dem No-Subscription-Repository.

---

#### `my.pihole`

Installiert Pi-hole via [`r_pufky.pihole`](https://github.com/r-pufky/ansible_pihole) und erstellt eine `custom.list` fuer lokale DNS-Eintraege.

```yaml
my_pihole_custom_list:          # Liste lokaler DNS-Records

# Variablen fuer r_pufky.pihole
pihole_update_enable:
pihole_webpassword:
pihole_pihole_interface:
pihole_rev_server: true
pihole_rev_server_cidr:
pihole_rev_server_target:
pihole_rev_server_domain:
pihole_pihole_dns_1:
pihole_pihole_dns_2:
pihole_pihole_dns_3:
pihole_pihole_dns_4:
pihole_ad_sources:
```

---

#### `my.proxmox`

Konfiguriert Proxmox VE Nodes.

```yaml
my_proxmox_wol_iface:   # Wake-on-LAN Interface
my_proxmox_watchdog:    # Watchdog aktivieren
```

---

#### `my.samba`

Konfiguriert Samba (via `bertvv.samba`). Variablen in `group_vars/all/vars.yml`:

```yaml
samba_users:
  - name: "{{ vault_samba_user }}"
    password: "{{ vault_samba_password }}"
samba_workgroup: HOME
samba_server_max_protocol: SMB3
samba_server_min_protocol: SMB3
samba_load_homes: true
samba_apple_extensions: true
```

Templates: `templates/samba-global-include.conf`, `templates/samba-homes-include.conf`

---

#### `my.smartmeter`

Liest Smartmeter-Daten via USB aus und stellt sie per `ser2net` oder `socat` im Netzwerk bereit.

```yaml
my_smartmeter_ser2net_install: true
my_smartmeter_restart_smartmeter_install: true
my_smartmeter_socat_install: false
my_smartmeter_socat_ser2net_host_usb0:
my_smartmeter_socat_ser2net_port_usb0: 9990
my_smartmeter_socat_ser2net_host_usb1:
my_smartmeter_socat_ser2net_port_usb1: 9991
```

---

#### `my.ssh`

Verwaltet SSH-Authorized-Keys und `~/.ssh/config`.

```yaml
my_ssh_authorized_keys: "{{ vault_ssh_public_keys }}"
my_ssh_authorized_keys_root: "{{ vault_ssh_public_keys_root }}"
my_ssh_ssh_config: "{{ vault_ssh_config }}"
```

---

#### `my.tailscale`

Installiert und konfiguriert Tailscale VPN via `artis3n.tailscale` Collection.

---

#### `my.wireguard-client`

Konfiguriert WireGuard als VPN-Client via `githubixx.ansible_role_wireguard`.

---

#### `my.macos`

Basis-Konfiguration fuer macOS-Hosts via `geerlingguy.mac` Collection.

---

#### `my.pdm`

Installiert und konfiguriert PDM (Python Dependency Manager).

---

### WIP-Rollen (`roles/wip_my.*`)

In Entwicklung, noch nicht produktiv eingesetzt:

| Rolle                    | Beschreibung                        |
|--------------------------|-------------------------------------|
| `wip_my.dotfiles`        | Dotfiles-Verwaltung als Rolle       |
| `wip_my.grafana`         | Grafana-Installation                |
| `wip_my.iobroker`        | ioBroker Smart-Home-Plattform       |
| `wip_my.pbs-client`      | Proxmox Backup Client               |
| `wip_my.proxmox-lxc`     | Proxmox LXC-Verwaltung              |
| `wip_my.ufw`             | UFW Firewall-Konfiguration          |
| `wip_my.windows`         | Windows-Konfiguration               |
| `wip_my.zabbix-client`   | Zabbix Monitoring Agent             |
| `wip_my.zabbix-server`   | Zabbix Monitoring Server            |

---

## Variablen und Vault

### Struktur

```
group_vars/
├── all/
│   ├── vars.yml          # Globale Variablen (alle Hosts)
│   ├── vault.yml         # Globale Secrets (verschluesselt)
│   └── vault.example.yml # Vorlage fuer vault.yml
├── pve_hosts/
│   ├── vars.yml
│   ├── vault.yml
│   └── vault.example.yml
├── pve_lxc/              # analog
├── pve_vm/               # analog
├── rpi/                  # analog
├── nas/                  # analog
├── adblock/              # analog
├── vpn_gw_ext/           # analog
├── os_windows/           # analog
└── os_macos/             # analog

host_vars/
├── pve-ct-bind-master/vars.yml
├── pve-ct-iobroker/vars.yml
├── pve-ct-npm/vars.yml
├── pve-ct-vpn-hetzner/vars.yml
└── loki/vault.yml
```

### Globale Vault-Variablen (`group_vars/all/vault.yml`)

```yaml
vault_ansible_user: <user>
vault_ansible_sudo_pass: <password>
vault_ansible_ssh_private_key_file: <path>
vault_my_essentials_user_username: <user>
vault_my_essentials_user_password: <password>
vault_my_essentials_user_email: <email>
vault_my_essentials_user_email_password: <password>
vault_samba_user: <user>
vault_samba_password: <password>
vault_ssh_public_keys: [<key1>, ...]
vault_ssh_public_keys_root: [<key1>, ...]
vault_ssh_config: <ssh config content>
vault_local_fqdn: <domain>
```

### Vault-Befehle

```bash
# Verschluesseln
ansible-vault encrypt group_vars/all/vault.yml

# Entschluesseln
ansible-vault decrypt group_vars/all/vault.yml

# Bearbeiten (ohne entschluesseln)
ansible-vault edit group_vars/all/vault.yml

# Passwort aendern
ansible-vault rekey group_vars/all/vault.yml
```

### Vault-Passwort

Das Vault-Passwort wird ueber `ansible.cfg` oder `--vault-password-file` / `--ask-vault-pass` bereitgestellt.

---

## Verwendung

### Voraussetzungen

```bash
# Galaxy-Rollen und Collections installieren
ansible-galaxy install -r roles/requirements.yml
ansible-galaxy collection install -r roles/requirements.yml
```

### Typische Befehle

```bash
# Einzelnen Host konfigurieren
ansible-playbook main.yml -l pve01

# Nur bestimmte Tags ausfuehren
ansible-playbook main.yml --tags role-pihole
ansible-playbook main.yml -l adblock --tags role-pihole

# Neuen Host bootstrappen
ansible-playbook bootstrap.yml -l pve-ct-dev

# Dry Run (kein Aendern)
ansible-playbook main.yml -l pve01 --check --diff

# Mit SSH-Passwort statt Key
ansible-playbook bootstrap.yml -l pve-ct-dev --ask-pass

# Sudo-Passwort interaktiv abfragen
ansible-playbook main.yml -l pve01 --ask-become-pass

# Facts eines Hosts abfragen
ansible loki -m setup
ansible loki -m setup -a 'filter=ansible_architecture'

# Alle Variablen eines Hosts ausgeben
ansible-playbook books/dump-variables.yml -l pve01

# Ad-hoc Befehl
ansible pve_lxc -m ping
ansible all -m shell -a "uptime"
```

### Verfuegbare Tags

| Tag                    | Beschreibung                        |
|------------------------|-------------------------------------|
| `role-essentials`      | my.essentials                       |
| `role-ssh`             | my.ssh                              |
| `role-docker`          | my.docker                           |
| `role-pihole`          | my.pihole                           |
| `role-proxmox`         | my.proxmox                          |
| `role-pbs`             | my.pbs                              |
| `role-samba`           | my.samba                            |
| `role-smartmeter`      | my.smartmeter                       |
| `role-tailscale`       | my.tailscale                        |
| `role-wireguard-client`| my.wireguard-client                 |
| `role-security`        | geerlingguy.security                |
| `role-ntp`             | geerlingguy.ntp                     |
| `role-msmtp`           | chriswayg.msmtp-mailer              |
| `role-smartd`          | stuvusit.smartd                     |
| `copy-scripts`         | Skripte in ~/bin deployen           |
| `crontab`              | Cronjobs einrichten                 |
| `network`              | Netzwerkkonfiguration               |
| `rpi-config`           | Raspberry Pi spezifisch             |

---

## Abhaengigkeiten (Galaxy)

Installieren mit:
```bash
ansible-galaxy install -r roles/requirements.yml
ansible-galaxy collection install -r roles/requirements.yml

# Aktualisieren
ansible-galaxy install -r roles/requirements.yml --force
```

### Rollen

| Rolle                               | Zweck                              |
|-------------------------------------|------------------------------------|
| `geerlingguy.security`              | SSH-Haertung, Auto-Updates         |
| `geerlingguy.ntp`                   | NTP-Konfiguration                  |
| `geerlingguy.docker`                | Docker CE Installation             |
| `geerlingguy.nodejs`                | Node.js Installation               |
| `bertvv.samba`                      | Samba Fileserver                   |
| `chriswayg.msmtp-mailer`            | MSMTP Mail-Relay (Gmail)           |
| `stuvusit.smartd`                   | SMART-Monitoring                   |
| `lae.proxmox`                       | Proxmox VE Konfiguration           |
| `djarbz.proxmox_backup_client`      | Proxmox Backup Client              |
| `sbaerlocher.snmp`                  | SNMP-Agent                         |
| `r_pufky.pihole`                    | Pi-hole (v6.x)                     |
| `githubixx.ansible_role_wireguard`  | WireGuard VPN                      |
| `elliotweiser.osx-command-line-tools` | macOS CLI-Tools (Xcode)          |

### Collections

| Collection              | Zweck                              |
|-------------------------|------------------------------------|
| `ansible.posix`         | POSIX-Module (mount, firewalld, …) |
| `community.general`     | Allgemeine Module (nmcli, …)       |
| `community.docker`      | Docker-Module                      |
| `geerlingguy.mac`       | macOS-Konfiguration                |
| `hifis.toolkit`         | Diverse Hilfsmittel                |
| `artis3n.tailscale`     | Tailscale VPN                      |
| `community.windows`     | Windows-Module                     |

---

## Testing

### Molecule (Rollen-Tests)

Aus dem jeweiligen Rollenverzeichnis ausfuehren:

```bash
cd roles/my.essentials && molecule test -s default
cd roles/my.docker    && molecule test -s default
cd roles/my.pihole    && molecule test -s default
cd roles/my.named     && molecule test -s default
```

### Lint

```bash
ansible-lint .
yamllint .
```

### Dry Run gegen echte Hosts

```bash
ansible-playbook main.yml -l test-host-debian --check --diff
```

### OS-Kompatibilitaet der Rollen (Referenz)

| Rolle                   | Ubuntu | Debian | macOS | Anmerkung                         |
|-------------------------|--------|--------|-------|-----------------------------------|
| my.essentials           | OK     | OK     | -     |                                   |
| my.ssh                  | OK     | OK     | -     |                                   |
| my.docker               | OK     | OK     | -     |                                   |
| my.pihole               | OK     | OK     | -     | TODO: Upgrade auf Pi-hole V6      |
| my.mqtt                 | OK     | OK     | -     |                                   |
| my.named                | OK     | OK     | -     |                                   |
| my.samba                | OK     | OK     | -     |                                   |
| my.smartmeter           | OK     | OK     | -     |                                   |
| my.tailscale            | OK     | OK     | -     |                                   |
| my.wireguard-client     | OK     | OK     | -     |                                   |
| my.pbs                  | -      | OK     | -     | Nur Debian                        |
| my.pdm                  | -      | OK     | -     | Nur Debian                        |
| my.macos                | -      | -      | OK    |                                   |

---

## Konfiguration (`ansible.cfg`)

```ini
[defaults]
inventory            = hosts.ini
timeout              = 30
forks                = 20
default_verbosity    = 1
host_key_checking    = False
deprecation_warnings = False
stdout_callback      = default
callback_result_format = yaml
interpreter_python   = auto_silent
collections_path     = ./.ansible/collections

[ssh_connection]
pipelining = True
ssh_args   = -o ControlMaster=auto -o ControlPersist=80s
```

---

## Links

- [geerlingguy.security](https://github.com/geerlingguy/ansible-role-security)
- [geerlingguy.docker](https://github.com/geerlingguy/ansible-role-docker)
- [bertvv.samba](https://github.com/bertvv/ansible-role-samba)
- [r_pufky.pihole](https://github.com/r-pufky/ansible_pihole)
- [githubixx.wireguard](https://galaxy.ansible.com/ui/standalone/roles/githubixx/ansible_role_wireguard/)
- [artis3n.tailscale](https://galaxy.ansible.com/ui/repo/published/artis3n/tailscale/)
