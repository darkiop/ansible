# iac-ansible
ansible-playbook2

# Software

group_vars/all/vars.yml
default_software:
additional_software:
# Passwords

group_vars/all/vault

vault_user_password: <password>
vault_user_email_password: <password>
vault_user_samba_password: <password>

# SSH Public Keys
files/ssh/<username>.key.pub