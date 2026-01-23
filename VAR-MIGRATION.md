VAR-MIGRATION.md - Mapping fuer Vereinheitlichung von Variablen

Zielschema
- Vault: vault_<scope>_<var>
- Non-Vault: roleprefix_*
- scope: Rolle oder funktionaler Bereich (z.B. my_essentials, my_wireguard_client, my_tailscale)

Mapping-Liste (alt -> neu)

| Bereich | Alt | Neu | Fundstellen (Beispiele) | Hinweis |
|--------|-----|-----|-------------------------|---------|
| my.essentials | vault_user_email_password | vault_my_essentials_user_email_password | README.md | README aktualisieren |
| samba | vault_user_samba_password | vault_samba_password | README.md | README angleichen |
| my.essentials | vault_network_static_ip_address | vault_my_essentials_network_static_ip_1 | host_vars/loki/vault.example.yml, host_vars/loki-new/vault.example.yml | Beispiel/Vars konsolidieren |
| my.essentials | vault_network_static_ip_address_2 | vault_my_essentials_network_static_ip_2 | host_vars/loki/vault.example.yml, host_vars/loki-new/vault.example.yml | Beispiel/Vars konsolidieren |
| my.essentials | vault_network_static_routers | vault_my_essentials_network_gateway | host_vars/loki/vault.example.yml, host_vars/loki-new/vault.example.yml | Begriffe angleichen (routers/gateway) |
| my.essentials | vault_network_static_domain_name | vault_my_essentials_network_domain_name | host_vars/loki/vault.example.yml, host_vars/loki-new/vault.example.yml | Beispiel/Vars konsolidieren |
| my.essentials | vault_network_static_domain_search | vault_my_essentials_network_domain_search | host_vars/loki/vault.example.yml, host_vars/loki-new/vault.example.yml | Beispiel/Vars konsolidieren |
| my.essentials | vault_network_static_domain_name_servers | vault_my_essentials_network_dns_1 | host_vars/loki/vault.example.yml, host_vars/loki-new/vault.example.yml | DNS-1/2 Mapping definieren |
| my.essentials | dhcpcd_static_* | my_essentials_network_* | host_vars/vpn-gw-bw17/vars.yml, host_vars/vpn-gw-hs6/vars.yml | Optional: eigenes dhcpcd-Scope beibehalten |
| my.essentials | vault_dhcpcd_static_* | vault_my_essentials_network_* | host_vars/vpn-gw-bw17/vault.example.yml, host_vars/vpn-gw-hs6/vault.example.yml | Wenn dhcpcd-Scope nicht beibehalten wird |
| my.wireguard-client | wg_private_key | my_wireguard_client_wg_private_key | host_vars/test-host-ubuntu/vars.yml | In Linie mit vpn-gw vars bringen |
| my.wireguard-client | vault_public_key | vault_my_wireguard_client_public_key | host_vars/test-host-ubuntu/vars.yml | "public_key" auf role-scope |
| my.wireguard-client | vault_preshared_key | vault_my_wireguard_client_preshared_key | host_vars/test-host-ubuntu/vars.yml | Role-scope |
| my.wireguard-client | vault_endpoint | vault_my_wireguard_client_endpoint | host_vars/test-host-ubuntu/vars.yml | Role-scope |
| my.tailscale | tailscale_auth_key | my_tailscale_auth_key | host_vars/test-host-ubuntu/vars.yml | Role-scope |
| my.tailscale | vault_tailscale_auth_key | vault_my_tailscale_auth_key | host_vars/test-host-ubuntu/vars.yml | Role-scope |

Vorgehen (empfohlen)
1) Schema final bestaetigen (dhcpcd_* beibehalten oder umbenennen).
2) Mapping pro Rolle umsetzen, jeweils mit Backward-Compat:
   new_var: "{{ new_var | default(old_var) }}"
3) README und vault.example.yml konsistent nachziehen.
4) Alte Variablen nach einer Migrationsrunde entfernen.
