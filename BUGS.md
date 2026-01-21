BUGS.md - Potentielle Bugs (Scan)

Stand: erster Scan, ohne Ausfuehrungstests.

| ID | Schweregrad | Kurzbeschreibung | Datei |
|----|-------------|------------------|-------|
| BUG-001 | Hoch | Host-spezifische sudoers-Datei wird nie gefunden/kopiert | roles/my.essentials/tasks/sudoers.yml |
| BUG-002 | Mittel | Falsche Rechte in /etc/sudoers.d koennen sudo brechen | roles/my.essentials/tasks/sudoers.yml |
| BUG-003 | Mittel | community.general fehlt, npm-Module schlagen fehl | roles/requirements.yml, roles/my.essentials/tasks/npm-install.yml, books/install-codex.yml |
| BUG-004 | Niedrig | Parallel-Write auf lokales Log kann Datei korrumpieren | books/check-crontabs.yml |

Details und Hinweise

BUG-001
- ansible.builtin.stat prueft einen lokalen Pfad, laeuft aber auf dem Zielhost.
- Der Pfad "../files/..." existiert dort nicht, daher bleibt file.stat.exists false.
- Folge: Host-spezifische sudoers-Dateien werden nie kopiert.
- Fix: stat auf localhost oder Pfad via role_path; copy mit src "sudoers.d/{{ inventory_hostname }}".

BUG-002
- /etc/sudoers.d erwartet 0440; 0644 oder 0660 werden von sudo ggf. ignoriert.
- Betroffen: disable_mail_badpass (lineinfile) und host-spezifische Copy.
- Risiko: sudo bricht mit "bad permissions" oder ignoriert Eintraege.
- Fix: mode "0440" fuer alle Dateien unter /etc/sudoers.d.

BUG-003
- npm Modul kommt aus community.general.
- roles/requirements.yml listet community.general nicht.
- Folge: Playbooks schlagen mit "module not found" fehl.
- Fix: collection community.general in roles/requirements.yml aufnehmen.

BUG-004
- books/check-crontabs.yml schreibt von allen Hosts parallel in eine lokale Datei.
- Bei paralleler Ausfuehrung sind Race-Conditions moeglich.
- Ergebnis: gemischte/teilweise ueberschriebene Log-Blocks.
- Fix: serial: 1, throttle: 1 oder run_once mit loop und delegate_to.
