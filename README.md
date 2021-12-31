# iac-ansible
ansible-playbook2

## TODO
* Proxmox Storage (https://galaxy.ansible.com/lae/proxmox)
* Proxmox Network (https://galaxy.ansible.com/lae/proxmox)
* Proxmox Backup Server (https://github.com/djarbz/ansible-proxmox-backup-client)

## Software

group_vars/all/vars.yml
```
# a set of standard packages
default_software:

# aditional software, defined in host_vars/<host>/vars.yml
aditional_software:
```
## Passwords

group_vars/all/vault

```
vault_user_password: <password>
vault_user_email_password: <password>
vault_user_samba_password: <password>
```

```
ansible-vault encrypt group_vars/all/vault
ansible-vault decrypt group_vars/all/vault
```
## SSH Public Keys
files/ssh/[username].key.pub