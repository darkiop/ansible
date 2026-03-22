# CLAUDE.md - Projektregeln fuer Agents und Automationen

Zweck dieser Datei: Verbindliche Arbeitsregeln fuer Claude und andere Agents, die in diesem Repo taetig sind. Alle Regeln sind einzuhalten, sofern der Nutzer nicht ausdruecklich etwas anderes anweist.

---

## Projektueberblick

Ansible IaC-Repo fuer eine Heiminfrastruktur mit Proxmox, LXC-Containern, VMs, Raspberry Pis, Synology NAS, VPN-Gateways und macOS. Produktive Systeme werden direkt durch Playbooks verwaltet - Fehler haben reale Auswirkungen.

**Kernprinzip: Sicherheit vor Schnelligkeit. Idempotenz vor Eleganz.**

---

## Projektstruktur

```
hosts.ini                    # Inventar (nur Hostnamen und Gruppen)
main.yml                     # Master-Playbook (importiert setup-*.yml)
bootstrap.yml                # Ersteinrichtung neuer Hosts
setup-*.yml                  # Gruppen-Playbooks (Prod)
books/                       # Utility- und Diagnose-Playbooks (kein Prod-Einsatz)
roles/my.*                   # Produktive eigene Rollen
roles/wip_my.*               # Rollen in Entwicklung (NICHT in Prod-Playbooks einsetzen)
roles/requirements.yml       # Galaxy-Rollen und Collections
group_vars/<gruppe>/vars.yml # Gruppen-Variablen (Klartext)
group_vars/<gruppe>/vault.yml# Gruppen-Secrets (verschluesselt, NIEMALS entschluesseln)
group_vars/all/vars.yml      # Globale Variablen (gilt fuer alle Hosts)
host_vars/<host>/vars.yml    # Host-spezifische Variablen
host_vars/<host>/vault.yml   # Host-spezifische Secrets
templates/                   # Globale Jinja2-Templates
files/                       # Statische Dateien (Skripte, host-spezifisch in files/hosts/<host>/)
examples/                    # Beispiel-Tasks zur Orientierung (nicht direkt einsetzen)
```

---

## Allgemeine Arbeitsregeln

### Idempotenz
- Jeder Task muss wiederholbar sein ohne unerwuenschte Seiteneffekte.
- `shell`/`command` Module nur wenn kein geeignetes Built-in-Modul existiert; dann immer `changed_when` oder `creates` setzen.
- Keine Tasks, die bei jedem Run als "changed" gelten (pruefe mit `--check --diff`).

### Module-Wahl
- Bevorzuge stets Built-in-Module: `ansible.builtin.copy`, `ansible.builtin.template`, `ansible.builtin.lineinfile`, `ansible.posix.mount`, etc.
- `community.general.*` und `ansible.posix.*` sind installiert und bevorzugt gegenueber `shell`.
- `shell`/`command` nur als letztes Mittel; immer begruenden (Kommentar).

### Dateiaenderungen
- Aendere ausschliesslich Dateien, die zum aktuellen Task gehoeren.
- Keine Formatierungswellen oder "Cleanup nebenher" - das erschwert Code-Reviews.
- Neue Playbook-Dateien immer mit YAML-Header beginnen: `---`
- Dateiinhalte in ASCII halten, sofern keine UTF-8-Notwendigkeit besteht.

### Tags
- Jede Rolle in einem Playbook erhaelt einen `tags:`-Eintrag.
- Schema: `role-<rollenname>` (z.B. `role-essentials`, `role-pihole`, `role-docker`).
- Weitere fachliche Tags: `copy-scripts`, `crontab`, `network`, `rpi-config`, `mount`.
- Nie Tags erfinden, die bereits unter anderem Namen existieren - erst in README.md pruefen.

---

## Variablen und Namenskonventionen

### Variablen-Schema

| Typ | Schema | Beispiel |
|-----|--------|---------|
| Rollen-Variable (Klartext) | `my_<rollenname>_<bereich>_<var>` | `my_essentials_user_username` |
| Vault-Variable | `vault_<scope>_<var>` | `vault_my_essentials_user_password` |
| Externe Rollen-Variable | So wie von der Rolle vorgegeben | `samba_workgroup`, `pihole_webpassword` |

- Scope entspricht dem Rollenname oder einem fachlichen Bereich (z.B. `my_essentials`, `my_pihole`, `my_wireguard_client`).
- Keine Abkuerzungen, die den Scope unklar machen.
- Variablen-Migrations-Mapping: siehe `VAR-MIGRATION.md`.

### Variablen-Orte
- Globale Defaults: `group_vars/all/vars.yml`
- Gruppen-Overrides: `group_vars/<gruppe>/vars.yml`
- Host-spezifisch: `host_vars/<host>/vars.yml`
- Secrets IMMER in `vault.yml` (verschluesselt), NIEMALS in `vars.yml` oder `hosts.ini`

### Neue Variablen hinzufuegen
1. Klartext-Default in `roles/<rolle>/defaults/main.yml` oder `group_vars/all/vars.yml`.
2. Wenn Secret: in `group_vars/<gruppe>/vault.yml` und Platzhalter in `vault.example.yml`.
3. README.md in der entsprechenden Rollen-Sektion aktualisieren.

---

## Vault / Secrets

- Vault-Dateien (`vault.yml`) werden NIEMALS im Klartext committet.
- Zu jeder `vault.yml` existiert eine `vault.example.yml` mit Platzhaltern (z.B. `<password>`, `<key>`).
- `vault.example.yml` ist immer aktuell zu halten, wenn neue Vault-Keys hinzukommen.
- Vault-Namensschema: `vault_<scope>_<var>` - niemals abweichen.
- Keine Secrets in: `hosts.ini`, `group_vars/*/vars.yml`, `host_vars/*/vars.yml`, Tasks, Debug-Ausgaben, Logs.
- Wenn eine neue Variable einen geheimen Wert enthaelt: sofort als Vault-Variable anlegen.

### Vault-Operationen
```bash
ansible-vault encrypt group_vars/all/vault.yml
ansible-vault decrypt group_vars/all/vault.yml   # nur lokal, nie committen
ansible-vault edit group_vars/all/vault.yml       # bevorzugt
ansible-vault rekey group_vars/all/vault.yml
```

---

## Inventar (`hosts.ini`)

- Enthaelt nur Hostnamen, Gruppen-Definitionen und zwingend notwendige Verbindungsparameter.
- Keine Passwoerter, keine SSH-Keys, keine sensiblen Werte.
- Host-spezifische Verbindungseinstellungen gehoeren in `host_vars/<host>/vars.yml`.
- Ausnahme (bestehend, nicht erweitern): `pve-vm-win11` hat WinRM-Parameter direkt in `hosts.ini`.

### Gruppen-Uebersicht
- `pve_hosts` - Proxmox VE Nodes (pve01, pve02)
- `pve_backup` - Proxmox Backup Server (pbs-odin, pbs-freya)
- `pve_lxc` - LXC-Container
- `pve_vm` - VMs
- `rpi` - Raspberry Pi (loki, loki-new)
- `nas` - Synology NAS (odin, freya)
- `adblock` - Pi-hole Instanzen
- `docker` - Docker-Hosts
- `vpn_gw_ext` - Externe VPN-Gateways
- `hetzner_cloud` - Hetzner VPN-Gateway
- `os_windows` - Windows-Hosts (WinRM)
- `os_macos` - macOS-Hosts
- `essentials` - Hosts, die bootstrap.yml erhalten (children: pve_hosts, pve_lxc, pve_vm, vpn_gw_ext, test_hosts)
- `test_hosts` - Testsysteme (normal auskommentiert)

---

## Rollen

### Eigene Rollen (`roles/my.*`) - Produktiv

| Rolle | Zweck | OS |
|-------|-------|----|
| `my.essentials` | Basis-Setup: User, Pakete, Dotfiles, Timezone, Sudo, Netzwerk | Debian/Ubuntu |
| `my.docker` | Docker CE via geerlingguy.docker + Verzeichnisstruktur | Debian/Ubuntu |
| `my.mqtt` | Mosquitto MQTT-Broker | Debian/Ubuntu |
| `my.named` | BIND9 DNS-Server | Debian/Ubuntu |
| `my.pbs` | Proxmox Backup Server (No-Sub-Repo) | Debian only |
| `my.pdm` | Python Dependency Manager | Debian only |
| `my.pihole` | Pi-hole via r_pufky.pihole + custom.list | Debian/Ubuntu |
| `my.proxmox` | Proxmox VE Node-Konfiguration | Proxmox/Debian |
| `my.samba` | Samba Fileserver via bertvv.samba | Debian/Ubuntu |
| `my.smartmeter` | Smartmeter-Auslesen via ser2net/socat | Debian/Ubuntu |
| `my.ssh` | SSH-Key-Verwaltung, ~/.ssh/config | Debian/Ubuntu |
| `my.tailscale` | Tailscale VPN via artis3n.tailscale | Debian/Ubuntu |
| `my.wireguard-client` | WireGuard Client via githubixx | Debian/Ubuntu |
| `my.macos` | macOS Basis-Konfiguration | macOS only |

### WIP-Rollen (`roles/wip_my.*`) - NICHT in Prod-Playbooks

Diese Rollen sind in Entwicklung und duerfen NICHT in `setup-*.yml`, `bootstrap.yml` oder `main.yml` eingebunden werden, bis sie explizit als produktiv erklaert werden.

| Rolle | Stand |
|-------|-------|
| `wip_my.dotfiles` | In Arbeit |
| `wip_my.grafana` | In Arbeit |
| `wip_my.iobroker` | In Arbeit |
| `wip_my.pbs-client` | In Arbeit |
| `wip_my.proxmox-lxc` | In Arbeit |
| `wip_my.ufw` | In Arbeit |
| `wip_my.windows` | In Arbeit |
| `wip_my.zabbix-client` | In Arbeit |
| `wip_my.zabbix-server` | In Arbeit |

### Neue Rolle anlegen
1. Template-Skript nutzen: `bash roles/create-new-role-template.sh`
2. Prefix `my.` fuer produktive Rollen, `wip_my.` fuer Rollen in Entwicklung.
3. `defaults/main.yml` immer anlegen - alle Variablen mit sinnvollen Defaults oder leerem Wert.
4. `vault.example.yml` in `defaults/` oder `group_vars/` anlegen, wenn Secrets noetig.
5. Rolle in `README.md` dokumentieren.
6. `requirements.yml` aktualisieren, wenn externe Abhaengigkeiten hinzukommen.

---

## Playbooks

### Trennung Prod / Utility

| Typ | Speicherort | Zweck |
|-----|-------------|-------|
| Produktion | `setup-*.yml`, `bootstrap.yml`, `main.yml` | Systeme konfigurieren |
| Utility / Diagnose | `books/` | Einmalige Tasks, Checks, Diagnose |

- Root-Playbooks orchestrieren nur Rollen - keine Logik, keine Tasks direkt dort.
- Host-spezifische Tasks in `main.yml` sind akzeptiert, aber mit `TODO add role my.<name>` zu markieren.
- `books/` Playbooks niemals aus Versehen gegen Prod-Hosts laufen lassen.

### Playbooks schreiben
- Immer `---` als ersten Header.
- `become: true` nur auf Play-Ebene setzen, nicht pro Task (ausser zwingend notwendig).
- Handlers fuer Dienst-Neustarts verwenden (`notify:`), nie direkt im Task restarten.
- Templates immer validieren (z.B. `visudo -cf %s` fuer sudoers, `named-checkconf` fuer BIND).

---

## Templates

- Alle Templates in `roles/<rolle>/templates/` oder `templates/` (globale).
- Dateiendung: `.j2` (Jinja2).
- Jedes Template mit `{{ ansible_managed }}` Kommentar beginnen (aus `ansible.cfg` konfiguriert).
- Nach Deployment immer Syntax-Check/Validierung per Task einbauen.

---

## Externe Abhaengigkeiten (Galaxy)

Installieren/aktualisieren:
```bash
ansible-galaxy install -r roles/requirements.yml
ansible-galaxy collection install -r roles/requirements.yml
ansible-galaxy install -r roles/requirements.yml --force  # Update
```

Neue Abhaengigkeit hinzufuegen:
1. Eintrag in `roles/requirements.yml` erganzen (mit URL-Kommentar).
2. Versionspinning verwenden wenn moeglich (z.B. `version: 13-6.4.1-1.0.0`).
3. README.md Abschnitt "Galaxy" aktualisieren.

---

## Linting und Tests

### Vor jedem Commit
```bash
ansible-lint .
yamllint .
```

### Dry Run
```bash
ansible-playbook <playbook>.yml -l <host> --check --diff
```

### Molecule (Rollen-Tests)
```bash
cd roles/my.essentials && molecule test -s default
cd roles/my.docker    && molecule test -s default
cd roles/my.pihole    && molecule test -s default
cd roles/my.named     && molecule test -s default
```

- Molecule-Tests existieren fuer: my.essentials, my.docker, my.pihole, my.named.
- Neue Rollen sollen ebenfalls Molecule-Tests erhalten (siehe IDEAS.md IDEA-005).

---

## Dokumentation

### README.md
- Aktualisieren wenn: neue Rolle, neue Variablen, neue Playbooks, geaenderte Hosts.
- Rollen-Variablen vollstaendig dokumentieren.

### IDEAS.md
- Backlog-Tabelle (Teil 1) und Detail-Beschreibung (Teil 2) sind immer konsistent zu halten.
- Neue Ideen in beide Teile aufnehmen.
- Status-Spalte aktuell halten: `offen`, `in Arbeit`, `erledigt`.

### BUGS.md
- Gefundene Bugs eintragen mit: ID, Schweregrad, Beschreibung, Datei, Status.
- Nach Fix: Status auf `behoben` setzen und Fix-Beschreibung ergaenzen.
- Bekannte offene Bugs vor Beginn eines Tasks lesen.

### VAR-MIGRATION.md
- Variablen-Migrations-Mapping pflegen.
- Vor Umbenennung von Variablen pruefen, ob sie dort bereits erfasst sind.

### Kommentare im Code
- Kurz halten: nur bei nicht-offensichtlicher Logik.
- `# TODO <beschreibung>` fuer offene Punkte - konsequent setzen.
- `# TODO add role my.<name>` wenn Tasks spaeter in eine Rolle ausgelagert werden sollen.

---

## Git und Commits

- Kleine, thematisch klare Commits (eine Rolle, ein Bugfix, ein Feature).
- Commit-Message auf Englisch oder Deutsch, konsistent pro Session.
- NICHT committen: entschluesselte vault-Dateien, Logfiles, Output-Dateien, `.ansible/`-Ordner, lokale Artefakte.
- `.gitignore` pruefen bevor neue Dateitypen hinzukommen.
- Keine auto-generierten Dateien ohne explizite Anweisung committen.

---

## Sicherheit

- Keine sensiblen Werte in: Tasks, Debug-Ausgaben (`debug: msg`), Logs, Commit-Messages.
- `no_log: true` fuer Tasks setzen, die Passwoerter oder Keys verarbeiten.
- `become: true` nur dort, wo es wirklich noetig ist (Principle of Least Privilege).
- Windows-Hosts (WinRM): Passwort in `host_vars/<host>/vault.yml`, nie in `hosts.ini`.
- SSH-Keys nur ueber `my.ssh`-Rolle verwalten, nie manuell in Tasks kopieren.
- Vor dem Hinzufuegen eines neuen externen Hosts: pruefen, ob er in die richtige Gruppe gehoert und keine Prod-Rollen unbeabsichtigt erhaelt.

---

## Bekannte Besonderheiten und Fallstricke

### loki-new (Raspberry Pi)
- WiFi und Bluetooth werden explizit per `/boot/firmware/config.txt` deaktiviert.
- Cronjobs fuer `arp.sh` (Wake-on-LAN) und `backup_bind.sh` sind aktiv.
- Hat mehrere Rollen: security, samba, smartmeter, tailscale, docker.

### pve-ct-iobroker
- Netzwerk-Interface-Metrik wird per Cronjob bei Reboot gesetzt (eth0=100, eth1=200).
- rsync-Backup laeuft taeglich um 10:00 Uhr.
- TODO: Rolle `my.iobroker` anlegen und Tasks auslagern.

### pbs-odin / pbs-freya
- NFS-Mount auf odin: `192.168.1.30:/volume1/pbs-pve` nach `/mnt/pbs-odin`.
- Datastore-Konfiguration wird direkt als File deployt.

### vpn_gw_ext (vpn-gw-hs6, vpn-gw-bw17)
- Statische IP-Konfiguration via `community.general.nmcli`.
- Variablen noch teilweise im alten Schema (`dhcpcd_static_*`), Migration ausstehend (VAR-MIGRATION.md).

### Windows (pve-vm-win11)
- WinRM-Verbindung, kein SSH.
- `ansible_password` ist leer in `hosts.ini` - muss in `host_vars/pve-vm-win11/vault.yml` gepflegt werden.
- Collection `community.windows` verwenden.

### Pi-hole (adblock-Gruppe)
- Laeuft auf: loki-new, pve-ct-pihole, vpn-gw-hs6, vpn-gw-bw17.
- Pihole-Backup-Daten liegen in `group_vars/pihole/data/` (ZIP-Dateien).
- TODO: Upgrade auf Pi-hole V6 (IDEA im Backlog).

### Port-Konflikt BIND / Pi-hole
- `my.named` und Pi-hole koennen nicht gleichzeitig auf Port 53 laufen.
- Auf `loki-new`: `my.named` ist auskommentiert wegen dieses Konflikts.

---

## Checkliste: Neuen Host hinzufuegen

1. Hostname in `hosts.ini` der richtigen Gruppe zuordnen.
2. `host_vars/<hostname>/vars.yml` anlegen (Verbindungsparameter, host-spezifische Variablen).
3. `host_vars/<hostname>/vault.yml` anlegen wenn Host-spezifische Secrets noetig.
4. Pruefen welche Gruppen-Variablen der Host erbt (group_vars/<gruppe>/).
5. Bootstrap ausfuehren: `ansible-playbook bootstrap.yml -l <hostname>`.
6. Playbook ausfuehren: `ansible-playbook main.yml -l <hostname>`.

## Checkliste: Neue Rolle hinzufuegen

1. `bash roles/create-new-role-template.sh` ausfuehren.
2. Prefix `wip_my.` setzen bis Rolle produktionsreif ist.
3. `defaults/main.yml` mit allen Variablen befuellen.
4. `vault.example.yml` anlegen wenn Secrets benoetigt.
5. `roles/requirements.yml` aktualisieren bei externen Abhaengigkeiten.
6. README.md erganzen (Rollen-Abschnitt).
7. Molecule-Test-Szenario anlegen.
8. Erst nach Abnahme Prefix auf `my.` aendern und in Prod-Playbooks einbinden.
