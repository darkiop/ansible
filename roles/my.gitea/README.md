roles/my.gitea/
├── defaults/
│   ├── main.yml          # Alle Variablen (my_gitea_*)
│   └── vault.example.yml # Platzhalter für vault_my_gitea_admin_password
├── handlers/
│   └── main.yml          # Restart gitea, Reload systemd
├── tasks/
│   ├── main.yml          # Include-Orchestrierung
│   ├── install.yml       # Packages, User/Group, Verzeichnisse, Binary, Systemd-Unit
│   ├── configure.yml     # Secret-Key, app.ini, Admin-User
│   └── service.yml       # Enable/Start
└── templates/
    ├── app.ini.j2         # Gitea-Konfiguration
    └── gitea.service.j2   # Systemd-Service

Wichtige Verbesserungen gegenüber dem Playbook:

gitea_admin_password war im Klartext im Playbook — jetzt vault_my_gitea_admin_password + no_log: true auf dem Task
ansible.builtin.copy mit inline-Content → ansible.builtin.template (mit {{ ansible_managed }})
Der finale "Restart"-Task war nicht idempotent — jetzt Handler der nur bei Config-Änderung feuert
UFW-Tasks (ufw allow) herausgelassen — das ist Aufgabe einer dedizierten UFW-Rolle; nginx ebenso

- role: my.gitea
  tags: role-my.gitea
  vars:
    my_gitea_domain: git.example.com
    my_gitea_admin_username: darkiop
    my_gitea_admin_email: darkiop@gmail.com

---

Das hängt davon ab, was du übertragen willst. Gitea-Daten bestehen aus drei Teilen:

1. Datenbank (Repos, User, Issues, PRs, Settings)

# SQLite (Standard)
cp /var/lib/gitea/data/gitea.db /tmp/gitea.db.bak

2. Repository-Daten (die eigentlichen Git-Repos)
/var/lib/gitea/repositories/

3. Uploads/Avatare/Attachments

/var/lib/gitea/data/
Migrationsvorgehen (sauber):
Auf der alten Instanz Gitea stoppen
gitea dump ausführen — erstellt ein ZIP mit allem:

sudo -u git gitea dump -c /etc/gitea/app.ini
# → gitea-dump-*.zip im aktuellen Verzeichnis
ZIP auf neue Instanz übertragen
Auf neuer Instanz Gitea stoppen, dann entpacken und wiederherstellen:

sudo -u git gitea restore-backup --file gitea-dump-*.zip -c /etc/gitea/app.ini
Wichtig: gitea dump / restore-backup setzt voraus, dass beide Instanzen dieselbe Gitea-Version haben (oder neue >= alte). Da du 1.25.3 in der Rolle verwendest — welche Version läuft auf der alten Instanz?