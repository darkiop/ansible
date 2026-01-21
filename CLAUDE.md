AGENTS.md - Projektregeln fuer Codex/Agents

Zweck
- Diese Datei beschreibt Arbeitsregeln fuer Automationen und Agenten.
- Fokus: sichere Aenderungen, reproduzierbare Playbooks, klare Variablenstruktur.

Projektstruktur (ueberblick)
- Inventar: hosts.ini
- Gruppenvariablen: group_vars/
- Hostvariablen: host_vars/
- Rollen: roles/
- Playbooks: *.yml im Repo-Root, books/ fuer Utility-Playbooks
- Templates: roles/*/templates/ und templates/
- Files: roles/*/files/ und files/

Allgemeine Arbeitsregeln
- Arbeite stets idempotent; keine unnoetigen Shell-Kommandos.
- Bevorzuge built-in Module gegenueber shell/command.
- Aendere nur Dateien, die zum Task gehoeren; keine Formatierungs-Wellen.
- Nutze sprechende Variablennamen mit Role-Prefix (z.B. my_essentials_*).
- Vermeide harte Geheimnisse im Repo; nutze Vault oder example.yml.
- Neue Dateien immer mit Ansible-Standardheader (---) bei Playbooks.
- Verwende ASCII in Datei-Inhalten, sofern nicht anders begruendet.

Variablen und Secrets
- Secrets nur in *_vault.yml oder vault.yml (verschluesselt) speichern.
- Example-Dateien pflegen: vault.example.yml mit Platzhaltern.
- Keine Klartext-Passwoerter in hosts.ini oder group_vars/vars.yml.
- Nutze feste Namenskonventionen: vault_<scope>_<var>.

Inventar und Host-Definitionen
- hosts.ini enthaelt nur Hostnamen und optionale Gruppen.
- Host-spezifische Verbindungseinstellungen in host_vars/<host>/vars.yml.
- Keine Passwoerter im Inventar; nutze host_vars/<host>/vault.yml.

Rollen und Tasks
- Rolle: eine Aufgabe, klarer Scope.
- Tasks modularisieren (include_tasks) statt monolithisch.
- Fuer externe Tools: Rolle in roles/ pflegen, nicht in Playbook.
- Templates immer validieren (z.B. visudo -cf %s).

Playbooks
- Root-Playbooks orchestrieren Rollen; keine Logik dort.
- books/ nur fuer Einmal- oder Utility-Playbooks.
- Tags konsequent setzen (role-*, setup-*).

Linting und Tests
- Vor PR/Commit: ansible-lint und ggf. yamllint ausfuehren.
- Optional: ansible-playbook --check --diff gegen Test-Hosts.
- Bei Aenderungen an Templates: syntax-check/validate nutzen.

Dokumentation
- README.md aktualisieren, wenn neue Rollen/Variablen entstehen.
- Kommentare kurz halten; nur bei komplexer Logik.
- IDEAS.md stets pflegen: Teil 1 Tabelle (Backlog) und Teil 2 Detail-Beschreibung; bei Aenderungen beides konsistent halten.

Git und Commits
- Kleine, thematisch klare Commits.
- Keine auto-generierten oder lokalen Artefakte committen.
- Logfiles und Output in .gitignore aufnehmen.

Sicherheit
- Keine sensiblen Werte in Logs, Tasks oder Debug-Ausgaben.
- Erhoehe Privilegien nur dort, wo notwendig.
