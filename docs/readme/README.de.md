# Web Studio für Claude Code

**Lesen auf:** [English](../../README.md) · [Русский](README.ru.md) · [Español](README.es.md) · Deutsch · [中文](README.zh.md)

Web Studio macht aus Claude Code ein vollständiges Webentwicklungsstudio: 30 spezialisierte Agenten
in drei Ebenen, 44 Slash-Befehle, die eine Pipeline von der Idee bis zur Produktion bilden, Hooks,
die Geheimnisse und Commit-Hygiene schützen, pfadbezogene Code-Regeln, Dokumentvorlagen, eine
**datierte Referenz aktueller Stack-Versionen und Best Practices** sowie ein Framework zum Testen
der Agenten selbst. Es deckt Webanwendungen und Browserspiele gleichermaßen ab.¹

Stack: Go 1.27 · PHP 8.5 / Yii3 · TypeScript 7 / Node 24 · Angular 22 (Material, Taiga UI) ·
Vue 3.5 / Nuxt 4 · Vite 8 · GraphQL zuerst, REST wo es passt · PostgreSQL 18 · three.js r185 /
PixiJS 8 / Phaser · Vitest 4 / Playwright · Docker / GitHub Actions · OWASP Top 10:2025 · WCAG 2.2 AA.

Die Gesprächssprache wird pro Projekt gewählt (`/init` fragt danach); Code, Bezeichner und
Commit-Nachrichten bleiben auf Englisch.

---

## 1. Installation

### Option A — Claude-Code-Plugin (empfohlen)
```bash
claude plugin marketplace add gonimar/claude-web-studio
claude plugin install web-studio@claude-web-studio        # --scope user (Standard) | project | local
```
Agenten, Skills und Hooks stehen in jedem Projekt zur Verfügung. Skills haben ein Präfix:
`/web-studio:init`, `/web-studio:help`, … Aktualisieren mit `claude plugin update web-studio`.

### Option B — Kopie im Projekt
```bash
git clone https://github.com/gonimar/claude-web-studio ~/tools/claude-web-studio
~/tools/claude-web-studio/install.sh /pfad/zum/projekt            # --with-testing ergänzt das Agenten-Testframework
```
Alles liegt im `.claude/`-Verzeichnis des Projekts, ohne Plugin-Abhängigkeit, Skills ohne Präfix
(`/init`, `/help`). Aktualisieren durch erneutes Ausführen des Installers oder mit `/update`.

### Option C — neues Projekt aus der Vorlage
```bash
~/tools/claude-web-studio/install.sh --new /pfad/zum/neuen-projekt
```
Legt das Verzeichnis an, führt `git init` aus, installiert Option B und schreibt eine erste `CLAUDE.md`.

Option A und B ergänzen sich: das Plugin liefert zentrale Updates, die Kopie ist pro Projekt frei anpassbar.

---

## 2. Erste Sitzung
1. Claude Code im Projekt öffnen und **`/init`** ausführen (Plugin: `/web-studio:init`). Es fragt die
   Gesprächssprache und den Review-Modus (`lean` für Soloarbeit, `full` für Teams, `solo` ohne
   Gates) und legt die Projektdateien an: Abschnitte in `CLAUDE.md`, `.claude/docs/`
   (Stack-Referenz, Vorlagen, Agentenliste), `.claude/rules/`, `docs/`, `production/`.
2. **Neue Idee?** `/start` ausführen — es fragt, wo Sie stehen (Idee / klares Produkt /
   Browserspiel / bestehender Code), und leitet weiter.
   **Bestehender Code?** `/adopt` ausführen — es erkennt den Stack aus den Lockfiles, prüft
   vorhandene Dokumente, führt Einstellungen zusammen und schreibt einen nummerierten Übernahmeplan.
3. Der Pipeline folgen. `/help` nennt jederzeit die aktuelle Phase und den einen nächsten Befehl.

Pipeline: **discovery → specification → architecture → build → hardening → release → operate**
(`.claude/docs/workflow-catalog.yaml`). Phasen-Gates sind beratend — Sie entscheiden.

## 3. Rückkehr in einer neuen Sitzung
Nichts muss neu erklärt werden. Beim Start gibt der Hook Branch, letzte Commits, aktuelle Phase,
Alter der Stack-Referenz und — bei unerledigter Arbeit — den Inhalt von
`production/session-state/active.md` aus (`Task:`, `Branch:`, `Next:`, `Blocked:`). `CLAUDE.md`
wird automatisch geladen, Sprache, Stack und Grundsätze sind also bekannt.

Typische Rückkehr: Sitzungszusammenfassung lesen → `/help` → mit dem genannten Befehl weitermachen
(meist `/dev-story S-NNN` oder `/code-review --diff`). Vor einer Kontextverdichtung schreibt der
Hook denselben Zustand aus, und `/dev-story` hält `active.md` während der Arbeit aktuell. Der
maßgebliche Plan ist `production/roadmap.md` (Checkbox-Liste); Sprints und Stories liegen in `production/`.

## 4. So arbeitet das Studio
- **Agenten in Ebenen**: zwei Direktoren (Opus) entscheiden, sieben Leads (Sonnet) entwerfen und
  prüfen, einundzwanzig Spezialisten setzen um. Skills leiten Arbeit automatisch an die richtigen Agenten.
- **Ein Protokoll für alle**: bei unklarer Spezifikation fragen → 2–3 Optionen mit Kosten anbieten →
  Sie entscheiden → Entwurf zeigen → „Darf ich schreiben?“ → durch Tests und Befehle verifizieren.
- **Nichts gilt ohne Nachweis als erledigt**: Akzeptanzkriterien sind Tests zugeordnet, `/story-done` führt sie aus.
- **Sicherheit eingebaut**: Hooks blockieren Geheimnisse in Commits und Dateien sowie Force-Pushes;
  jeder sensible Pfad erhält ein Security-Review; das Release-Gate verlangt saubere Audits.
- **Die Stack-Referenz ist die Wahrheitsquelle für Versionen**: Agenten lesen vor der Arbeit
  `.claude/docs/stack-reference/<technologie>.md` und warnen, wenn sie älter als 60 Tage ist.
  `/stack-update` erneuert sie aus offiziellen Quellen.

---

## 5. Alle Befehle
Im Plugin-Modus erhält jeder das Präfix `web-studio:`.

**Einstieg und Wartung**
- `/init` — legt die Studio-Dateien im Projekt an, fragt Gesprächssprache und Review-Modus und führt Einstellungen zusammen.
- `/start` — Einstieg für ein neues Projekt: fragt, wo Sie stehen, und leitet zu den ersten Schritten.
- `/help` — zeigt die aktuelle Phase, erledigte Schritte und den einen nächsten Befehl.
- `/adopt` — bindet das Studio an ein bestehendes Projekt an: erkennt den Stack, prüft Dokumente, erstellt einen Übernahmeplan.
- `/setup-stack` — wählt und fixiert den Stack (Backend, Frontend, API-Stil, Engine, Datenbank, Tests, CI) mit exakten Versionen.
- `/stack-update` — erneuert die Stack-Referenz aus offiziellen Quellen mit Datum und schlägt einen Upgrade-Plan für das Projekt vor.
- `/update` — aktualisiert das Studio selbst im Projekt (Plugin-Update oder Neuinstallation der Kopie) und bewahrt lokale Änderungen.
- `/skill-test` — prüft Skills und Agenten mit einem Linter, bewertet sie gegen Verhaltensspezifikationen und berichtet die Abdeckung.
- `/skill-improve` — führt eine Schleife Test → Korrektur → erneuter Test für einen Skill oder Agenten aus.

**Produkt und Design**
- `/brainstorm` — verdichtet eine vage Idee zu einem Concept Brief mit Zielgruppe, Differenzierung und Hypothesen.
- `/product-spec` — schreibt die Produktspezifikation abschnittsweise: Ziele, Nutzer, Umfang, NFR, Risiken.
- `/feature-spec` — schreibt die Spezifikation eines Features: Szenarien, Regeln, Vertrag, Zustände, Randfälle, Sicherheit, Akzeptanzkriterien.
- `/ux-spec` — spezifiziert einen Ablauf oder Bildschirm mit allen Zuständen, Texten, Barrierefreiheit und responsivem Verhalten.
- `/design-system` — definiert Design-Tokens, Themes und das Komponenteninventar, abgebildet auf Material, Taiga oder ein Vue-Kit.
- `/game-concept` — schreibt ein Browserspiel-Konzept mit Core Loop, Mechaniken, Ökonomie, Machbarkeitsbudgets und Prototyp-Plan.

**Architektur**
- `/architecture-decision` — erstellt oder ergänzt ein ADR mit Optionen, Entscheidung, Konsequenzen und Verifikation.
- `/architecture-review` — gleicht ADRs, Verträge, Datenmodell, Bedrohungsmodell und Spezifikationen auf Konsistenz ab (nur lesend).
- `/api-contract` — entwirft den API-Vertrag vor dem Code: standardmäßig GraphQL SDL, sonst OpenAPI/AsyncAPI/WebSocket-Protokolle.
- `/data-model` — entwirft Entitäten, PostgreSQL-DDL mit begründeten Indizes und Expand/Contract-Migrationen.
- `/threat-model` — erstellt das STRIDE-Bedrohungsmodell je Angriffsfläche mit Maßnahmen und Prioritäten.
- `/test-setup` — richtet Teststrategie und -konfiguration für den gewählten Stack ein, von Unit bis E2E und Security.

**Umsetzung**
- `/create-stories` — zerlegt eine Feature-Spezifikation in vertikale Stories mit einer Kriterium-zu-Test-Matrix.
- `/dev-story` — setzt eine Story Ende-zu-Ende über die passenden Engineers um, mit Tests und Kriterienprüfung.
- `/code-review` — prüft Dateien oder das aktuelle Diff auf Korrektheit, Standards, ADR-Konformität, Sicherheit und Performance.
- `/story-done` — verifiziert, dass eine Story wirklich fertig ist (Tests gelaufen, Checks grün, Review genehmigt), und schließt sie.
- `/sprint-plan` — plant einen Sprint aus bereiten Stories, Kapazität und Abhängigkeiten.
- `/sprint-status` — berichtet den Sprint-Fortschritt anhand von Artefakten, Blockern und Risiko für das Ziel.
- `/qa-plan` — ordnet die Akzeptanzkriterien jeder Story Testebenen, Werkzeugen und Dateien zu.
- `/tech-debt` — inventarisiert technische Schulden und schlägt priorisierte Stories vor.

**Härtung**
- `/security-audit` — prüft Code und Konfiguration gegen OWASP Top 10:2025 mit Werkzeugen, CVSS-bewerteten Befunden und Korrekturen.
- `/dependency-audit` — prüft die Lieferkette: Schwachstellen, verwaiste Pakete, veraltete Major-Versionen, Lizenzen, Pinning.
- `/harden` — härtet Header, TLS, Proxy, Container und CI und verifiziert mit echten Anfragen.
- `/pentest` — führt autorisierte dynamische Tests gegen die eigene Anwendung des Projekts in einem festgehaltenen Umfang aus.
- `/perf-audit` — misst Core Web Vitals, Bundles, API-Latenz, Abfragen oder Spiel-Frames gegen Budgets und priorisiert Verbesserungen.
- `/a11y-audit` — prüft Barrierefreiheit nach WCAG 2.2 AA mit axe und einer manuellen Tastatur-Checkliste.

**Release und Betrieb**
- `/changelog` — erzeugt das Changelog aus Conventional Commits und schlägt die Versionsanhebung vor.
- `/release-checklist` — durchläuft das Release-Gate anhand von Nachweisen und schreibt die Release-Datei mit Rollback-Schritten.
- `/deploy` — plant und führt ein Deployment mit Bestätigungen, Smoke-Checks und Rollback aus und delegiert an einen installierten Deploy-Skill.
- `/hotfix` — beschleunigt eine dringende Produktionskorrektur vom fehlschlagenden Test bis zu Deployment und Backport.
- `/incident` — koordiniert die Reaktion auf einen Vorfall und schreibt ein schuldfreies Postmortem.

**Teams (Orchestrierung)**
- `/team-feature` — liefert ein ganzes Feature: Vertrag → Daten → Backend → Frontend/Spiel → Tests → Security- und Code-Review.
- `/team-security` — führt den vollständigen Sicherheitszyklus aus: Bedrohungsmodell, Audits, Härtung, optionaler Pentest, Gesamtbericht.
- `/team-release` — veröffentlicht eine Version: parallele Audits → Changelog → Checkliste → Deployment → Verifikation.
- `/team-game` — baut einen spielbaren Spielausschnitt: Simulation, Rendering, UI-Overlay, optionaler Multiplayer, Messungen.

---

## 6. Drei Beispiele

### A. Ein SaaS-Dashboard mit Go + GraphQL + Angular
```
/init                      → Sprache: Deutsch, Review-Modus: lean
/start                     → „B) klares Produkt“, Typ: fullstack
/setup-stack               → Go 1.27, GraphQL (gqlgen), Angular 22 + Taiga UI 5, PostgreSQL 18, Playwright
/product-spec "Team-Analytics"
/feature-spec "Workspace-Mitglieder"
/api-contract F-001        → schema.graphql mit Relay-Connections und Payload-Fehlern
/data-model F-001          → Tabellen, Indizes, Migration
/threat-model              → Angriffsflächen: Auth, GraphQL, Einladungen
/test-setup --apply
/create-stories F-001      → S-001 Vertrag+Codegen, S-002 Resolver, S-003 Angular-Seite, S-004 E2E
/dev-story S-001 … /code-review --diff … /story-done S-001   (je Story wiederholen)
/team-security pre-release → /release-checklist 0.1.0 → /deploy 0.1.0
```

### B. Eine Content-Site mit PHP/Yii3 + Nuxt und SEO, übernommen aus bestehendem Code
```
/init                      → Sprache: Deutsch, Review-Modus: solo
/adopt                     → erkennt PHP 8.5 / yiisoft/* und Nuxt 4 aus den Lockfiles, findet keine ADRs, schreibt docs/adoption-plan-<datum>.md
/architecture-decision retrofit docs/adr/old-decision.md
/api-contract --style rest → OpenAPI für die öffentliche Content-API und Webhooks
/ux-spec "Artikelseite"    → Zustände, Texte, Barrierefreiheit
/dev-story S-012           → Nuxt-SSR-Seite + Yii3-Endpunkt, mit Tests
/a11y-audit /articles      → WCAG-Befunde behoben
/perf-audit web https://staging.example → LCP/INP im Budget
/harden --apply            → CSP mit Nonce, HSTS, Caddy-Limits
/team-release 2.3.0
```

### C. Ein Multiplayer-Browserspiel mit three.js und Go-Server
```
/init                      → Sprache: Deutsch, Review-Modus: lean
/start                     → „C) Browserspiel“
/setup-stack game+backend  → three.js r185 (WebGPU + Fallback), Go-WebSocket-Server, PostgreSQL für Profile
/game-concept "Orbital Drift"   → Core Loop, Budgets (16,6 ms, ≤150 Draw Calls), Spikes
/architecture-decision "Engine und Netcode"  → three.js + serverautoritative Simulation mit 30 Hz
/api-contract --style ws   → versioniertes Binärprotokoll
/team-game prototype       → Simulation, Rendering, UI-Overlay und Server parallel, Frame-Messungen
/perf-audit game           → Draw Calls, Speicher, Ladezeit über 4G
/a11y-audit                → Remapping, Untertitel, Farbfehlsicht-Modus, Tastaturmenüs
/security-audit api        → WebSocket-Origin, Rate-Limits, Anti-Cheat-Prüfungen
/release-checklist 0.1.0 → /deploy
```

Ein vierter, alltäglicher Fall — Rückkehr nach einer Pause: Projekt öffnen, Sitzungszusammenfassung
lesen, `/help`, `/sprint-status`, dann `/dev-story` für die genannte Story.

---

## 7. Aktuell halten
- `/stack-update` holt die neuesten Versionen und Praktiken aus offiziellen Quellen (llms.txt von
  Angular, Vue, Vite, Nuxt, Vitest, Taiga, three.js, Pixi, Babylon, Hono, NestJS; Release-Seiten
  von Go, PHP, Yii3, TypeScript, GraphQL; endoflife.date), schreibt `docs/stack-reference/` mit
  Datum und Links neu und vergleicht mit den Lockfiles des Projekts.
- `/update` aktualisiert das Studio in einem Projekt und bewahrt lokale Änderungen; Projektdaten
  (`docs/specs`, `docs/architecture`, `production/`, eine konfigurierte `technical-preferences.md`,
  `CLAUDE.md`) werden nie überschrieben.
- Releases des Kits: `version` in `.claude-plugin/plugin.json` anheben und einen Eintrag in
  `CHANGELOG.md` ergänzen — Plugin-Nutzer erhalten ein Update nur bei geänderter Version.

## 8. Das Studio selbst testen
`testing/` enthält einen Katalog, eine Qualitätsrubrik und 74 Verhaltensspezifikationen. Führen Sie
`/skill-test static all`, `/skill-test spec <skill>`, `/skill-test agent <agent>`, `/skill-test audit`
oder `/skill-improve <name>` in diesem Repository oder in einem mit `--with-testing` installierten
Projekt aus. Details: [testing/README.md](../../testing/README.md).

## 9. Aufbau des Repositorys
```
.claude-plugin/   plugin.json + marketplace.json (dieses Repository ist Marketplace und Plugin zugleich)
agents/           30 Agenten       skills/     44 Skills        hooks/      hooks.json + 10 Skripte
rules/            13 pfadbezogene Regeln        docs/       stack-reference/, templates/, Agentenliste, Workflow-Katalog, Sicherheits-Baseline
templates/        CLAUDE.md, settings.json, settings.plugin-mode.json, statusline.sh
testing/          Testframework für Agenten und Skills      install.sh  Installer für Kopie / neues Projekt
```

## 10. Agenten
| Ebene | Agenten |
|---|---|
| Direktoren (Opus) | `technical-director`, `product-director` |
| Leads (Sonnet) | `backend-lead`, `frontend-lead`, `design-lead`, `security-lead`, `qa-lead`, `devops-lead`, `game-lead` |
| Backend | `go-engineer`, `php-engineer`, `node-engineer`, `database-engineer`, `api-designer`, `graphql-engineer` |
| Frontend | `angular-engineer`, `vue-engineer`, `typescript-engineer`, `css-engineer`, `accessibility-specialist`, `seo-specialist` |
| Spiele | `threejs-engineer`, `web-game-engineer`, `multiplayer-engineer` |
| Sicherheit | `appsec-engineer`, `network-security-engineer` |
| Qualität und Betrieb | `test-engineer`, `performance-engineer`, `devops-engineer`, `tech-writer` |

Begleit-Skills — ein externer strategischer Berater oder ein Deployment-Operator — werden erkannt,
wenn sie installiert sind, und von `/start`, `/deploy` und der Agentenliste genutzt; sie sind nicht erforderlich.

## Mitwirken, Voraussetzungen und Lizenz
Sie möchten einen Agenten, einen Skill oder eine Technologie hinzufügen oder etwas korrigieren? Siehe [CONTRIBUTING.md](../../CONTRIBUTING.md)
(lokale Entwicklung, Erweiterungsanleitungen, Pull Requests, Releases). Voraussetzungen: Claude Code mit Zugriff auf `opus`, `sonnet` und `haiku`; `jq` optional (Hooks weichen auf python3 aus); Stack-Werkzeuge je Projekt. MIT-Lizenz; Zuschreibungen in [NOTICE](../../NOTICE).

---
¹ Die Struktur des Studios ist von der Vorlage [Claude Code Game Studios](https://github.com/Donchitos/Claude-Code-Game-Studios) inspiriert.
