# IDEAS.md - Vorschlaege fuer Erweiterungen und Optimierungen

## Teil 1: Übersichtstabelle

*Hinweis: Prioritaet nach erster Einschaetzung (P0 hoch, P1 mittel, P2 niedrig).*

| ID | Prio | Vorschlag | Nutzen | Aufwand | Status | Notiz/Scope |
|----|------|-----------|--------|---------|--------|-------------|
| IDEA-001 | P0 | CI-Pipeline fuer ansible-lint/yamllint | Fruehe Fehlererkennung und konsistenter Stil | M | offen | GitHub Actions/GitLab CI, lint config pflegen |
| IDEA-002 | P0 | Secrets-Audit + konsequente Vault-Keys | Reduziert Risiko von Klartext-Credentials | M | offen | Inventory/vars scan, README/Examples angleichen |
| IDEA-003 | P0 | Standardisiertes Inventory-Layout | Geringere Drift, leichteres Onboarding | M | offen | Host-Conn-Daten in host_vars, groups sauber trennen |
| IDEA-004 | P0 | Playbook-Orchestrierung konsolidieren | Klarere Ausfuehrungspfade, weniger Duplikate | M | offen | main.yml/Setup-Playbooks refactor, Tags vereinheitlichen |
| IDEA-005 | P1 | Molecule-Tests fuer Kernrollen | Regressionen vermeiden, schnelleres Feedback | M-H | offen | my.essentials, my.docker, my.pihole, my.named |
| IDEA-006 | P1 | Rollen-Defaults komplettieren | Weniger undefinierte Variablen | L-M | offen | defaults/main.yml erweitern, README aktualisieren |
| IDEA-007 | P1 | Gemeinsame Variablen-Benennung | Geringere Verwirrung, bessere Suche | L | offen | vault_<scope>_<var> Namensschema erzwingen |
| IDEA-008 | P1 | Ansible-Checks in books/ trennen | Utility vs. Prod sauber trennen | L | offen | books/ fuer einmalige Tasks, setup-* fuer Prod |
| IDEA-009 | P1 | Idempotenz-Review fuer shell/command | Zuverlaessigere Runs | M | offen | ersetze durch Module, changed_when pflegen |
| IDEA-010 | P1 | Tags-Strategie dokumentieren | Schnellere selektive Ausfuehrung | L | offen | role-*, setup-* in README und AGENTS |
| IDEA-011 | P2 | Repo-weite .gitignore haerten | Weniger Log/Output im Repo | L | offen | logs/output/IDE temp, prompt-gen.py/output |
| IDEA-012 | P2 | Ansible Vault helper scripts | Einfacheres Encrypt/Decrypt | L | offen | scripts/ oder Makefile targets |
| IDEA-013 | P2 | Service Health Checks | Bessere Betriebs-Sicherheit | M | offen | z.B. pihole/named/systemd status, ping checks |

---

## Teil 2: Details je Idee

P0 - CI-Pipeline fuer ansible-lint/yamllint
- Fuehre ansible-lint und yamllint bei jedem Push/PR aus.
- Einheitliche Lint-Regeln verhindern Stil-Divergenz.
- Liefert schnelles Feedback vor produktiven Runs.
- Haeufigste Fehler (YAML, Rollen, Tags) werden frueh erkannt.

P0 - Secrets-Audit + konsequente Vault-Keys
- Durchsuche vars/hosts.ini nach Klartext-Secrets.
- Migriere auf vault_* Variablen mit example.yml.
- Dokumentiere die Keys zentral in README/AGENTS.
- Reduziert Risiko und erleichtert Audits.

P0 - Standardisiertes Inventory-Layout
- Halte hosts.ini schlank, keine Passwoerter/Flags.
- Lege Verbindungseinstellungen in host_vars/<host>/vars.yml.
- Benenne Gruppen konsistent und vermeide doppelte Hosts.
- Vereinfacht Wartung und reduziert Fehlkonfigurationen.

P0 - Playbook-Orchestrierung konsolidieren
- Trenne Setup/Utility klar und entferne Duplikate.
- Vereinheitliche Tags (role-*, setup-*).
- Reduziere verschachtelte Imports fuer bessere Uebersicht.
- Erleichtert selektive Runs und Fehlersuche.

P1 - Molecule-Tests fuer Kernrollen
- Erstelle Szenarien fuer my.essentials, my.docker, my.pihole, my.named.
- Fokussiere auf Idempotenz und Kernfunktionen.
- Laeuft lokal oder in CI fuer Regressionen.
- Erhoeht Vertrauen vor Rollouts.

P1 - Rollen-Defaults komplettieren
- Setze sinnvolle Defaults fuer alle Variablen.
- Dokumentiere in README pro Rolle.
- Verhindert undefined-variable Fehler.
- Erleichtert Wiederverwendung der Rollen.

P1 - Gemeinsame Variablen-Benennung
- Einheitliche Prefixe pro Rolle/Scope.
- Vault-Keys nach Schema vault_<scope>_<var>.
- Verbessert Suchbarkeit und Lesbarkeit.
- Hilft bei Refactors.

P1 - Ansible-Checks in books/ trennen
- Utility-Playbooks strikt in books/.
- setup-* Playbooks nur fuer produktive Runs.
- Reduziert Risiko aus Versehen Utility zu starten.
- Bessere Struktur fuer Einsteiger.

P1 - Idempotenz-Review fuer shell/command
- Ersetze shell/command durch Module, wo moeglich.
- Nutze changed_when/creates fuer stabile Runs.
- Verhindert dauerhafte "changed" Zustandsmeldungen.
- Reduziert Seiteneffekte.

P1 - Tags-Strategie dokumentieren
- Definiere einheitliche Tag-Namen und Scope.
- Notiere Beispiele in README/AGENTS.
- Hilft bei selektiven Deployments.
- Vermeidet Tag-Chaos.

P2 - Repo-weite .gitignore haerten
- Fuege Logs, Outputs und lokale Artefakte hinzu.
- Verhindert versehentliche Commits.
- Reduziert Noise im Status.
- Macht CI/Checks stabiler.

P2 - Ansible Vault helper scripts
- Skripte/Makefile Targets fuer encrypt/decrypt/edit.
- Reduziert manuelle Fehler.
- Erleichtert Onboarding.
- Standardisiert den Workflow.

P2 - Service Health Checks
- Fuege einfache Checks fuer Dienste ein (systemd, Ports).
- Optional als books/ Playbook.
- Erhoehte Betriebssicherheit.
- Schnellere Fehlerdiagnose.
