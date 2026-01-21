# IaC

## Roles

### my.essentials

#### setup environment

```yaml
my_essentials_install_dotfiles: true
my_essentials_install_navi: true
my_essentials_install_chtsh: true
my_essentials_install_dysk: true
my_essentials_install_vimrc: true
```

#### install Software

```yaml
my_essentials_apt_default_packages:
my_essentials_apt_additional_packages:
my_essentials_pip_packages:
```

#### Create User

```yaml
my_essentials_user_username: "{{ vault_my_essentials_user_username }}"
my_essentials_user_password: "{{ vault_my_essentials_user_password }}"
my_essentials_user_shell: /bin/bash
my_essentials_user_dotfiles_repo: https://github.com/darkiop/dotfiles
my_essentials_user_timezone: Europe/Berlin
my_essentials_user_locale: en_US.UTF-8
my_essentials_user_keyboard_layout: de
my_essentials_user_email:
my_essentials_user_email_password: "{{ vault_user_email_password }}"
```

#### sudo

```yaml
sudoers_bin_nopasswd:
```

#### Network Setup

```yaml
my_essentials_network_mode: "{{ my_essentials_network_mode | default('dhcp') }}" # static/dhcp - default = dhcp
my_essentials_network_interface_name:
my_essentials_network_static_ip_1: "{{ vault_my_essentials_network_static_ip_1 }}"
my_essentials_network_static_ip_2: "{{ vault_my_essentials_network_static_ip_2 }}"
my_essentials_network_gateway: "{{ vault_my_essentials_network_gateway }}"
my_essentials_network_domain_name: "{{ vault_my_essentials_network_domain_name }}"
my_essentials_network_domain_search: "{{ vault_my_essentials_network_domain_search }}"
my_essentials_network_dns_1: "{{ vault_my_essentials_network_dns_1 }}"
my_essentials_network_dns_2: "{{ vault_my_essentials_network_dns_2 }}"
```

### my.docker

Installs Docker CE with geerlingguy.docker and creates docker directories in homedir (prod & test)

### my.keepalived

```yaml
my_keepalived_instance:
my_keepalived_state:
my_keepalived_interface:
my_keepalived_priority:
my_keepalived_virtual_ipv4:
```

### my.macos

```yaml

```

### my.mqtt

Install mosquitto server with a simple configuration.

```yaml
my_mqtt_username:
my_mqtt_password:
```

### my.named

Installs bind9 (named)

```yaml

```

### my.pbs

Installs the Proxmox Backup Server from the no-subscription repo

### my.pbs-client

```yaml

```

### my.pihole

Install Pi-hole based on <https://github.com/r-pufky/ansible_pihole> and creates a custom.list with local DNS records

```yaml
my_pihole_custom_list:

# used vars from r_pufky.pihole
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

### my.proxmox

```yaml
my_proxmox_wol_iface:
my_proxmox_watchdog:
```

### my.samba

```yaml

```

### my.smartmeter

```yaml
my_smartmeter_ser2net_install: true
my_smartmeter_restart_smartmeter_install: true
my_smartmeter_socat_install: false
my_smartmeter_socat_ser2net_host_usb0:
my_smartmeter_socat_ser2net_port_usb0: 9990
my_smartmeter_socat_ser2net_host_usb1:
my_smartmeter_socat_ser2net_port_usb1: 9991
```

### my.ssh

```yaml
my_ssh_authorized_keys: "{{ vault_ssh_public_keys }}"
my_ssh_authorized_keys_root: "{{ vault_ssh_public_keys_root }}"
```

### my.sudoers

```yaml

```

### my.ufw

```yaml

```

## Vault

### group_vars/all/vault

```yaml
vault_my_essentials_user_password: <password>
vault_my_essentials_user_email_password: <password>
vault_user_samba_password: <password>
ansible_sudo_pass: <password>
```

### encrypt

```yaml
ansible-vault encrypt group_vars/all/vault
```

### decrypt

```yaml
ansible-vault decrypt group_vars/all/vault
```

## Links

<https://github.com/shaderecker/ansible-pihole/tree/master>
