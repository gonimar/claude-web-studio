# Web Studio para Claude Code

**Leer en:** [English](../../README.md) · [Русский](README.ru.md) · Español · [Deutsch](README.de.md) · [中文](README.zh.md)

Web Studio convierte Claude Code en un estudio completo de desarrollo web: 30 agentes
especializados en tres niveles, 44 comandos que forman una cadena desde la idea hasta producción,
hooks que protegen secretos y la higiene de los commits, reglas de código por rutas, plantillas de
documentos, una **referencia fechada de versiones actuales del stack y buenas prácticas** y un
marco para probar a los propios agentes. Sirve tanto para aplicaciones web como para juegos de navegador.¹

Stack: Go 1.27 · PHP 8.5 / Yii3 · TypeScript 7 / Node 24 · Angular 22 (Material, Taiga UI) ·
Vue 3.5 / Nuxt 4 · Vite 8 · GraphQL primero, REST donde encaje · PostgreSQL 18 · three.js r185 /
PixiJS 8 / Phaser · Vitest 4 / Playwright · Docker / GitHub Actions · OWASP Top 10:2025 · WCAG 2.2 AA.

El idioma de conversación se elige por proyecto (`/init` lo pregunta); el código, los
identificadores y los mensajes de commit se mantienen en inglés.

---

## 1. Instalación

### Opción A — plugin de Claude Code (recomendada)
```bash
claude plugin marketplace add <owner>/claude-web-studio   # repositorio privado: gh auth login && gh auth setup-git
claude plugin install web-studio@claude-web-studio        # --scope user (por defecto) | project | local
```
Agentes, skills y hooks quedan disponibles en todos los proyectos. Los skills llevan prefijo:
`/web-studio:init`, `/web-studio:help`, … Actualización: `claude plugin update web-studio`.

### Opción B — copia dentro del proyecto
```bash
git clone <este repositorio> ~/tools/claude-web-studio
~/tools/claude-web-studio/install.sh /ruta/al/proyecto            # añade --with-testing para el marco de pruebas de agentes
```
Todo vive en `.claude/` del proyecto, sin depender del plugin, skills sin prefijo (`/init`, `/help`).
Actualiza volviendo a ejecutar el instalador o con `/update`.

### Opción C — proyecto nuevo desde la plantilla
```bash
~/tools/claude-web-studio/install.sh --new /ruta/al/nuevo-proyecto
```
Crea el directorio, ejecuta `git init`, instala la opción B y escribe un `CLAUDE.md` inicial.

Las opciones A y B conviven: el plugin ofrece actualizaciones centralizadas; la copia es totalmente editable por proyecto.

---

## 2. Primera sesión
1. Abre Claude Code en el proyecto y ejecuta **`/init`** (plugin: `/web-studio:init`). Pregunta el
   idioma de conversación y el modo de revisión (`lean` para trabajo en solitario, `full` para
   equipos, `solo` sin puertas) y crea los archivos del proyecto: secciones de `CLAUDE.md`,
   `.claude/docs/` (referencia del stack, plantillas, plantilla de agentes), `.claude/rules/`, `docs/`, `production/`.
2. **¿Idea nueva?** ejecuta `/start`: pregunta dónde estás (idea / producto claro / juego de
   navegador / código existente) y te orienta.
   **¿Código existente?** ejecuta `/adopt`: detecta el stack por los lockfiles, audita los documentos
   existentes, fusiona la configuración y escribe un plan de adopción numerado.
3. Sigue la cadena. `/help` siempre indica la fase actual y el único comando siguiente.

Cadena: **discovery → specification → architecture → build → hardening → release → operate**
(`.claude/docs/workflow-catalog.yaml`). Las puertas de fase son consultivas: decides tú.

## 3. Volver en una sesión nueva
No hay que explicar nada de nuevo. Al iniciar la sesión el hook imprime la rama, los commits
recientes, la fase actual, la antigüedad de la referencia del stack y, si dejaste trabajo a medias,
el contenido de `production/session-state/active.md` (`Task:`, `Branch:`, `Next:`, `Blocked:`).
`CLAUDE.md` se carga automáticamente, así que el idioma, el stack y los principios ya se conocen.

Regreso típico: leer el resumen de sesión → `/help` → continuar con el comando indicado
(normalmente `/dev-story S-NNN` o `/code-review --diff`). Antes de compactar el contexto el hook
vuelca el mismo estado, y `/dev-story` mantiene `active.md` actualizado mientras trabaja. El plan
de referencia es `production/roadmap.md` (lista de casillas); sprints e historias viven en `production/`.

## 4. Cómo funciona el estudio
- **Agentes por niveles**: dos directores (Opus) deciden, siete líderes (Sonnet) diseñan y revisan,
  veintiún especialistas implementan. Los skills envían el trabajo al agente adecuado.
- **Un protocolo para todos**: preguntar si la especificación no está clara → ofrecer 2–3 opciones
  con su coste → decides tú → mostrar un borrador → «¿Puedo escribir?» → verificar ejecutando pruebas y comandos.
- **Nada se da por hecho sin evidencia**: los criterios de aceptación se asocian a pruebas y `/story-done` las ejecuta.
- **Seguridad integrada**: los hooks bloquean secretos en commits y archivos y los force-push; toda
  ruta sensible pasa una revisión de seguridad; la puerta de release exige auditorías limpias.
- **La referencia del stack es la fuente de verdad sobre versiones**: los agentes leen
  `.claude/docs/stack-reference/<tecnología>.md` antes de trabajar y avisan si tiene más de 60 días.
  `/stack-update` la refresca desde fuentes oficiales.

---

## 5. Todos los comandos
En modo plugin cada uno lleva el prefijo `web-studio:`.

**Incorporación y mantenimiento**
- `/init` — crea los archivos del estudio en el proyecto, pregunta idioma y modo de revisión y fusiona la configuración.
- `/start` — incorporación de un proyecto nuevo: pregunta dónde estás y te lleva a los primeros pasos.
- `/help` — muestra la fase actual, los pasos hechos y el único comando siguiente.
- `/adopt` — conecta el estudio a un proyecto existente: detecta el stack, audita documentos y produce un plan de adopción.
- `/setup-stack` — elige y fija el stack (backend, frontend, estilo de API, motor, base de datos, pruebas, CI) con versiones exactas.
- `/stack-update` — refresca la referencia del stack desde fuentes oficiales con fechas y propone un plan de actualización.
- `/update` — actualiza el propio estudio en el proyecto (plugin o reinstalación de la copia) conservando los cambios locales.
- `/skill-test` — pasa el linter a skills y agentes, los evalúa contra especificaciones de comportamiento e informa de la cobertura.
- `/skill-improve` — ejecuta un ciclo probar → corregir → volver a probar sobre un skill o agente.

**Producto y diseño**
- `/brainstorm` — convierte una idea vaga en un concept brief con audiencia, diferenciación e hipótesis.
- `/product-spec` — escribe la especificación de producto sección por sección: objetivos, usuarios, alcance, NFR y riesgos.
- `/feature-spec` — escribe la especificación de una funcionalidad: escenarios, reglas, contrato, estados, casos límite, seguridad y criterios de aceptación.
- `/ux-spec` — especifica un flujo o pantalla con todos sus estados, textos, accesibilidad y comportamiento responsive.
- `/design-system` — define tokens de diseño, temas e inventario de componentes, mapeados a Material, Taiga o un kit de Vue.
- `/game-concept` — escribe el concepto de un juego de navegador: bucle principal, mecánicas, economía, presupuestos de viabilidad y plan de prototipo.

**Arquitectura**
- `/architecture-decision` — crea o completa un ADR con opciones, decisión, consecuencias y verificación.
- `/architecture-review` — contrasta ADR, contratos, modelo de datos, modelo de amenazas y especificaciones (solo lectura).
- `/api-contract` — diseña el contrato de API antes del código: GraphQL SDL por defecto, o OpenAPI/AsyncAPI/protocolos WebSocket.
- `/data-model` — diseña entidades, DDL de PostgreSQL con índices justificados y migraciones expand/contract.
- `/threat-model` — construye el modelo de amenazas STRIDE por superficie de ataque con mitigaciones y prioridades.
- `/test-setup` — configura la estrategia y la infraestructura de pruebas del stack elegido, de unitarias a e2e y seguridad.

**Construcción**
- `/create-stories` — divide una especificación en historias de corte vertical con una matriz criterio → prueba.
- `/dev-story` — implementa una historia de principio a fin con los ingenieros adecuados, con pruebas y verificación de criterios.
- `/code-review` — revisa archivos o el diff actual: corrección, estándares, conformidad con ADR, seguridad y rendimiento.
- `/story-done` — comprueba que una historia está realmente terminada (pruebas ejecutadas, checks verdes, revisión aprobada) y la cierra.
- `/sprint-plan` — planifica un sprint a partir de historias listas, capacidad y dependencias.
- `/sprint-status` — informa del progreso del sprint según artefactos, bloqueos y riesgo para el objetivo.
- `/qa-plan` — asocia los criterios de aceptación de cada historia a niveles de prueba, herramientas y archivos.
- `/tech-debt` — inventaría la deuda técnica y propone historias priorizadas.

**Endurecimiento**
- `/security-audit` — audita código y configuración según OWASP Top 10:2025 con herramientas, hallazgos con CVSS y correcciones.
- `/dependency-audit` — audita la cadena de suministro: vulnerabilidades, paquetes abandonados, versiones mayores obsoletas, licencias, fijación.
- `/harden` — endurece cabeceras, TLS, proxy, contenedores y CI verificando con peticiones reales.
- `/pentest` — ejecuta pruebas dinámicas autorizadas contra la propia aplicación del proyecto dentro de un alcance registrado.
- `/perf-audit` — mide Core Web Vitals, bundles, latencia de API, consultas o frames del juego frente a presupuestos y prioriza mejoras.
- `/a11y-audit` — audita la accesibilidad según WCAG 2.2 AA con axe y una lista manual de teclado.

**Release y operación**
- `/changelog` — genera el changelog a partir de Conventional Commits y propone el salto de versión.
- `/release-checklist` — pasa la puerta de release con evidencias y escribe el archivo de release con pasos de reversión.
- `/deploy` — planifica y ejecuta un despliegue con confirmaciones, smoke checks y reversión, delegando en un skill de despliegue si existe.
- `/hotfix` — acelera una corrección urgente en producción desde la prueba que falla hasta el despliegue y el backport.
- `/incident` — coordina la respuesta a incidentes y escribe un postmortem sin culpables.

**Equipos (orquestación)**
- `/team-feature` — entrega una funcionalidad completa: contrato → datos → backend → frontend/juego → pruebas → revisión de seguridad y código.
- `/team-security` — ejecuta el ciclo de seguridad completo: modelo de amenazas, auditorías, endurecimiento, pentest opcional, informe consolidado.
- `/team-release` — publica una versión: auditorías en paralelo → changelog → checklist → despliegue → verificación.
- `/team-game` — construye un corte jugable: simulación, render, UI, multijugador opcional, mediciones.

---

## 6. Tres recorridos

### A. Un panel SaaS con Go + GraphQL + Angular
```
/init                      → idioma: Español, modo de revisión: lean
/start                     → «B) producto claro», tipo: fullstack
/setup-stack               → Go 1.27, GraphQL (gqlgen), Angular 22 + Taiga UI 5, PostgreSQL 18, Playwright
/product-spec "Analítica de equipos"
/feature-spec "Miembros del espacio de trabajo"
/api-contract F-001        → schema.graphql con connections Relay y errores en payload
/data-model F-001          → tablas, índices, migración
/threat-model              → superficies: auth, GraphQL, invitaciones
/test-setup --apply
/create-stories F-001      → S-001 contrato+codegen, S-002 resolvers, S-003 página Angular, S-004 e2e
/dev-story S-001 … /code-review --diff … /story-done S-001   (repetir por historia)
/team-security pre-release → /release-checklist 0.1.0 → /deploy 0.1.0
```

### B. Un sitio de contenidos con PHP/Yii3 + Nuxt y SEO, adoptado desde código existente
```
/init                      → idioma: Español, modo de revisión: solo
/adopt                     → detecta PHP 8.5 / yiisoft/* y Nuxt 4 en los lockfiles, no encuentra ADR, escribe docs/adoption-plan-<fecha>.md
/architecture-decision retrofit docs/adr/old-decision.md
/api-contract --style rest → OpenAPI para la API pública de contenidos y los webhooks
/ux-spec "Página de artículo"   → estados, textos, accesibilidad
/dev-story S-012           → página SSR de Nuxt + endpoint Yii3, con pruebas
/a11y-audit /articles      → hallazgos WCAG corregidos
/perf-audit web https://staging.example → LCP/INP dentro del presupuesto
/harden --apply            → CSP con nonce, HSTS, límites de Caddy
/team-release 2.3.0
```

### C. Un juego de navegador multijugador con three.js y servidor en Go
```
/init                      → idioma: Español, modo de revisión: lean
/start                     → «C) juego de navegador»
/setup-stack game+backend  → three.js r185 (WebGPU + fallback), servidor WebSocket en Go, PostgreSQL para perfiles
/game-concept "Orbital Drift"   → bucle principal, presupuestos (16,6 ms, ≤150 draw calls), spikes
/architecture-decision "Motor y netcode"  → three.js + simulación autoritativa en servidor a 30 Hz
/api-contract --style ws   → protocolo binario versionado
/team-game prototype       → simulación, render, UI y servidor en paralelo, mediciones de frame
/perf-audit game           → draw calls, memoria, carga en 4G
/a11y-audit                → remapeo, subtítulos, modo daltónico, menús por teclado
/security-audit api        → Origin de WebSocket, límites de tasa, comprobaciones anti-trampas
/release-checklist 0.1.0 → /deploy
```

Un cuarto caso, cotidiano — volver tras una pausa: abrir el proyecto, leer el resumen de sesión,
`/help`, `/sprint-status` y luego `/dev-story` con la historia indicada.

---

## 7. Mantenerlo al día
- `/stack-update` obtiene las versiones y prácticas más recientes de fuentes oficiales (llms.txt de
  Angular, Vue, Vite, Nuxt, Vitest, Taiga, three.js, Pixi, Babylon, Hono, NestJS; páginas de
  releases de Go, PHP, Yii3, TypeScript, GraphQL; endoflife.date), reescribe `docs/stack-reference/`
  con fechas y enlaces y lo compara con los lockfiles del proyecto.
- `/update` actualiza el estudio en un proyecto conservando los cambios locales; los datos del
  proyecto (`docs/specs`, `docs/architecture`, `production/`, un `technical-preferences.md`
  configurado, `CLAUDE.md`) nunca se sobrescriben.
- Releases del kit: sube `version` en `.claude-plugin/plugin.json` y añade una entrada en
  `CHANGELOG.md`; los usuarios del plugin solo reciben la actualización cuando cambia la versión.

## 8. Probar el propio estudio
`testing/` contiene un catálogo, una rúbrica de calidad y 74 especificaciones de comportamiento.
Ejecuta `/skill-test static all`, `/skill-test spec <skill>`, `/skill-test agent <agent>`,
`/skill-test audit` o `/skill-improve <nombre>` en este repositorio o en un proyecto instalado con
`--with-testing`. Detalles: [testing/README.md](../../testing/README.md).

## 9. Estructura del repositorio
```
.claude-plugin/   plugin.json + marketplace.json (este repositorio es a la vez marketplace y plugin)
agents/           30 agentes       skills/     44 skills        hooks/      hooks.json + 10 scripts
rules/            13 reglas por ruta            docs/       stack-reference/, templates/, plantilla de agentes, catálogo de flujo, línea base de seguridad
templates/        CLAUDE.md, settings.json, settings.plugin-mode.json, statusline.sh
testing/          marco de pruebas de agentes y skills      install.sh  instalador de copia / proyecto nuevo
```

## 10. Agentes
| Nivel | Agentes |
|---|---|
| Directores (Opus) | `technical-director`, `product-director` |
| Líderes (Sonnet) | `backend-lead`, `frontend-lead`, `design-lead`, `security-lead`, `qa-lead`, `devops-lead`, `game-lead` |
| Backend | `go-engineer`, `php-engineer`, `node-engineer`, `database-engineer`, `api-designer`, `graphql-engineer` |
| Frontend | `angular-engineer`, `vue-engineer`, `typescript-engineer`, `css-engineer`, `accessibility-specialist`, `seo-specialist` |
| Juegos | `threejs-engineer`, `web-game-engineer`, `multiplayer-engineer` |
| Seguridad | `appsec-engineer`, `network-security-engineer` |
| Calidad y operación | `test-engineer`, `performance-engineer`, `devops-engineer`, `tech-writer` |

Los skills complementarios — un asesor estratégico externo o un operador de despliegue — se
detectan si están instalados y los usan `/start`, `/deploy` y la plantilla de agentes; no son obligatorios.

## Contribuir, requisitos y licencia
¿Quieres añadir un agente, un skill o una tecnología, o corregir algo? Consulta [CONTRIBUTING.md](../../CONTRIBUTING.md)
(desarrollo local, guías de extensión, pull requests, releases). Requisitos: Claude Code con acceso a `opus`, `sonnet` y `haiku`; `jq` opcional (los hooks recurren a python3); herramientas del stack según el proyecto. Licencia MIT; atribuciones en [NOTICE](../../NOTICE).

---
¹ La estructura del estudio está inspirada en la plantilla [Claude Code Game Studios](https://github.com/Donchitos/Claude-Code-Game-Studios).
