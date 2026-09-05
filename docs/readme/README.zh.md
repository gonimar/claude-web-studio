# Web Studio for Claude Code

**语言：** [English](../../README.md) · [Русский](README.ru.md) · [Español](README.es.md) · [Deutsch](README.de.md) · 中文

Web Studio 把 Claude Code 变成一个完整的 Web 开发工作室：三层共 30 个专业代理、44 条构成"从想法到上线"
流水线的斜杠命令、保护密钥与提交规范的钩子、按路径生效的编码规则、文档模板、**带日期的技术栈版本与最佳实践
参考**，以及用于测试代理本身的框架。既适用于 Web 应用，也适用于浏览器游戏。¹

技术栈：Go 1.27 · PHP 8.5 / Yii3 · TypeScript 7 / Node 24 · Angular 22（Material、Taiga UI）·
Vue 3.5 / Nuxt 4 · Vite 8 · GraphQL 优先，REST 按需 · PostgreSQL 18 · three.js r185 / PixiJS 8 / Phaser ·
Vitest 4 / Playwright · Docker / GitHub Actions · OWASP Top 10:2025 · WCAG 2.2 AA。

对话语言按项目选择（`/init` 会询问）；代码、标识符和提交信息保持英文。

---

## 1. 安装

### 方式 A — Claude Code 插件（推荐）
```bash
claude plugin marketplace add gonimar/claude-web-studio
claude plugin install web-studio@claude-web-studio        # --scope user（默认）| project | local
```
代理、技能和钩子在所有项目中可用。技能带命名空间前缀：`/web-studio:init`、`/web-studio:help` ……
更新：`claude plugin update web-studio`。

### 方式 B — 复制到项目内部
```bash
git clone https://github.com/gonimar/claude-web-studio ~/tools/claude-web-studio
~/tools/claude-web-studio/install.sh /path/to/project            # 加 --with-testing 同时安装代理测试框架
```
一切都放在项目的 `.claude/` 目录中，不依赖插件，技能无前缀（`/init`、`/help`）。
更新：重新运行安装脚本或执行 `/update`。

### 方式 C — 用模板新建项目
```bash
~/tools/claude-web-studio/install.sh --new /path/to/new-project
```
创建目录、执行 `git init`、按方式 B 安装并写入初始 `CLAUDE.md`。

方式 A 与 B 可以并存：插件提供集中更新，副本可按项目自由修改。

---

## 2. 第一次会话
1. 在项目中打开 Claude Code，运行 **`/init`**（插件：`/web-studio:init`）。它会询问对话语言和评审模式
   （`lean` 适合单人，`full` 适合团队，`solo` 无关卡），然后创建项目文件：`CLAUDE.md` 各节、
   `.claude/docs/`（技术栈参考、模板、代理名册）、`.claude/rules/`、`docs/`、`production/`。
2. **新想法？** 运行 `/start`——它会询问你处于哪个阶段（想法 / 明确的产品 / 浏览器游戏 / 已有代码）并引导你。
   **已有代码？** 运行 `/adopt`——它从锁文件识别技术栈，审核已有文档，合并设置，并写出编号的接入计划。
3. 沿流水线推进。`/help` 随时告诉你当前阶段和唯一的下一条命令。

流水线：**discovery → specification → architecture → build → hardening → release → operate**
（`.claude/docs/workflow-catalog.yaml`）。阶段关卡仅供参考——由你决定。

## 3. 在新会话中回到工作
无需重新解释任何事情。会话启动时钩子会打印分支、最近提交、当前阶段、技术栈参考的时效，以及——如果有未完成
工作——`production/session-state/active.md` 的内容（`Task:`、`Branch:`、`Next:`、`Blocked:`）。
`CLAUDE.md` 自动加载，因此语言、技术栈和原则都是已知的。

典型的回归流程：阅读会话摘要 → `/help` → 用它指出的命令继续（通常是 `/dev-story S-NNN` 或
`/code-review --diff`）。上下文压缩前钩子会输出同样的状态，`/dev-story` 在工作中持续更新 `active.md`。
正式计划是 `production/roadmap.md`（复选框列表）；冲刺和故事放在 `production/`。

## 4. 工作室如何运作
- **分层代理**：两位总监（Opus）做决定，七位负责人（Sonnet）设计与评审，二十一位专家实现。技能会自动把工作路由给合适的代理。
- **所有代理遵循同一协议**：规格不清先提问 → 给出 2–3 个带成本的方案 → 由你决定 → 展示草稿 → "可以写入吗？" → 通过运行测试和命令验证。
- **没有证据不算完成**：验收标准映射到测试，`/story-done` 会运行它们。
- **内置安全**：钩子阻止提交和文件中的密钥以及强制推送；每条敏感路径都经过应用安全评审；发布关卡要求审计干净。
- **技术栈参考是版本的唯一事实来源**：代理在工作前读取 `.claude/docs/stack-reference/<technology>.md`，超过 60 天会提醒。`/stack-update` 从官方来源刷新它。

---

## 5. 全部命令
插件模式下每条命令加前缀 `web-studio:`。

**接入与维护**
- `/init` — 在项目中搭建工作室文件，询问对话语言和评审模式，合并设置。
- `/start` — 新项目引导：询问你所处的阶段并引导到正确的第一步。
- `/help` — 显示当前阶段、已完成的步骤和唯一的下一条命令。
- `/adopt` — 把工作室接入已有项目：识别技术栈，审核文档，生成接入计划。
- `/setup-stack` — 选择并固定技术栈（后端、前端、API 风格、引擎、数据库、测试、CI）及精确版本。
- `/stack-update` — 从官方来源刷新技术栈参考并标注日期，为项目提出升级计划。
- `/update` — 更新项目中的工作室本身（插件更新或副本重装），保留本地修改。
- `/skill-test` — 对技能和代理做静态检查、按行为规格评估并报告覆盖率。
- `/skill-improve` — 对一个技能或代理执行"测试 → 修复 → 重测"循环。

**产品与设计**
- `/brainstorm` — 把模糊的想法整理成含受众、差异化和假设的概念简报。
- `/product-spec` — 逐节编写产品规格：目标、用户、范围、非功能需求、风险。
- `/feature-spec` — 编写单个功能规格：场景、规则、契约、状态、边界情况、安全、验收标准。
- `/ux-spec` — 描述一个流程或页面的全部状态、文案、无障碍与响应式行为。
- `/design-system` — 定义设计令牌、主题和组件清单，并映射到 Material、Taiga 或 Vue 组件库。
- `/game-concept` — 编写浏览器游戏概念：核心循环、机制、经济、可行性预算、原型计划。

**架构**
- `/architecture-decision` — 创建或补全 ADR：方案、决策、后果、验证。
- `/architecture-review` — 交叉检查 ADR、契约、数据模型、威胁模型与规格的一致性（只读）。
- `/api-contract` — 在写代码前设计 API 契约：默认 GraphQL SDL，或 OpenAPI/AsyncAPI/WebSocket 协议。
- `/data-model` — 设计实体、带索引依据的 PostgreSQL DDL 以及 expand/contract 迁移。
- `/threat-model` — 按攻击面建立 STRIDE 威胁模型，含缓解措施与优先级。
- `/test-setup` — 为所选技术栈搭建测试策略与配置，从单元测试到端到端和安全测试。

**开发**
- `/create-stories` — 把功能规格切分为垂直切片故事，并生成"标准 → 测试"矩阵。
- `/dev-story` — 由合适的工程师端到端实现一个故事，含测试与标准核对。
- `/code-review` — 评审文件或当前 diff：正确性、规范、ADR 符合度、安全、性能。
- `/story-done` — 验证故事真正完成（测试已运行、检查通过、评审批准）并关闭。
- `/sprint-plan` — 根据就绪故事、产能和依赖规划冲刺。
- `/sprint-status` — 依据产物报告冲刺进度、阻塞和目标风险。
- `/qa-plan` — 把每个故事的验收标准映射到测试层级、工具和文件。
- `/tech-debt` — 盘点技术债务并提出按优先级排序的故事。

**加固**
- `/security-audit` — 依据 OWASP Top 10:2025 用工具审计代码与配置，给出 CVSS 评分的发现与修复。
- `/dependency-audit` — 审计供应链：漏洞、废弃包、过时主版本、许可证、版本锁定。
- `/harden` — 加固响应头、TLS、代理、容器和 CI，并用真实请求验证。
- `/pentest` — 在记录的范围内对项目自身应用做授权的动态测试。
- `/perf-audit` — 对照预算测量 Core Web Vitals、包体、API 延迟、查询或游戏帧，并排序修复项。
- `/a11y-audit` — 用 axe 和手动键盘清单按 WCAG 2.2 AA 审计无障碍。

**发布与运维**
- `/changelog` — 由 Conventional Commits 生成变更日志并建议版本号。
- `/release-checklist` — 依据证据通过发布关卡，写出含回滚步骤的发布文件。
- `/deploy` — 规划并执行部署：确认、冒烟检查、回滚，若已安装部署技能则委托给它。
- `/hotfix` — 快速处理紧急生产修复：从失败测试到部署再到回合并。
- `/incident` — 协调事故响应并撰写不追责的事后复盘。

**团队（编排）**
- `/team-feature` — 交付完整功能：契约 → 数据 → 后端 → 前端/游戏 → 测试 → 安全与代码评审。
- `/team-security` — 完整安全周期：威胁模型、审计、加固、可选渗透测试、汇总报告。
- `/team-release` — 发布版本：并行审计 → 变更日志 → 清单 → 部署 → 验证。
- `/team-game` — 构建可玩的游戏切片：模拟、渲染、UI 覆盖层、可选多人、测量。

---

## 6. 三个案例

### A. Go + GraphQL + Angular 的 SaaS 仪表盘
```
/init                      → 语言：中文，评审模式：lean
/start                     → "B) 明确的产品"，类型：fullstack
/setup-stack               → Go 1.27、GraphQL（gqlgen）、Angular 22 + Taiga UI 5、PostgreSQL 18、Playwright
/product-spec "团队分析"
/feature-spec "工作区成员"
/api-contract F-001        → 带 Relay connections 和 payload 错误的 schema.graphql
/data-model F-001          → 表、索引、迁移
/threat-model              → 攻击面：认证、GraphQL、邀请
/test-setup --apply
/create-stories F-001      → S-001 契约+代码生成，S-002 解析器，S-003 Angular 页面，S-004 端到端
/dev-story S-001 … /code-review --diff … /story-done S-001   （每个故事重复）
/team-security pre-release → /release-checklist 0.1.0 → /deploy 0.1.0
```

### B. 从已有代码接入的 PHP/Yii3 + Nuxt 内容站（含 SEO）
```
/init                      → 语言：中文，评审模式：solo
/adopt                     → 从锁文件识别 PHP 8.5 / yiisoft/* 与 Nuxt 4，未发现 ADR，写出 docs/adoption-plan-<日期>.md
/architecture-decision retrofit docs/adr/old-decision.md
/api-contract --style rest → 公共内容 API 与 webhook 的 OpenAPI
/ux-spec "文章页"           → 状态、文案、无障碍
/dev-story S-012           → Nuxt SSR 页面 + Yii3 端点，含测试
/a11y-audit /articles      → 修复 WCAG 发现
/perf-audit web https://staging.example → LCP/INP 在预算内
/harden --apply            → 带 nonce 的 CSP、HSTS、Caddy 限流
/team-release 2.3.0
```

### C. three.js + Go 服务器的多人浏览器游戏
```
/init                      → 语言：中文，评审模式：lean
/start                     → "C) 浏览器游戏"
/setup-stack game+backend  → three.js r185（WebGPU + 回退）、Go WebSocket 服务器、PostgreSQL 存档案
/game-concept "Orbital Drift"   → 核心循环、预算（16.6 ms，≤150 draw calls）、验证性 spike
/architecture-decision "引擎与网络代码"  → three.js + 30 Hz 服务器权威模拟
/api-contract --style ws   → 带版本的二进制协议
/team-game prototype       → 模拟、渲染、UI 覆盖层与服务器并行构建，帧测量
/perf-audit game           → draw calls、内存、4G 加载时间
/a11y-audit                → 键位重映射、字幕、色盲模式、键盘菜单
/security-audit api        → WebSocket Origin、限流、反作弊检查
/release-checklist 0.1.0 → /deploy
```

第四个日常场景——中断后回归：打开项目，阅读会话摘要，`/help`、`/sprint-status`，然后对指定的故事执行 `/dev-story`。

---

## 7. 保持最新
- `/stack-update` 从官方来源（Angular、Vue、Vite、Nuxt、Vitest、Taiga、three.js、Pixi、Babylon、Hono、NestJS 的 llms.txt；
  Go、PHP、Yii3、TypeScript、GraphQL 的发布页；endoflife.date）获取最新版本与实践，带日期和链接重写 `docs/stack-reference/`，并与项目锁文件对比。
- `/update` 更新项目中的工作室并保留本地修改；项目数据（`docs/specs`、`docs/architecture`、`production/`、已配置的 `technical-preferences.md`、`CLAUDE.md`）绝不会被覆盖。
- 套件发布：提升 `.claude-plugin/plugin.json` 中的 `version` 并在 `CHANGELOG.md` 添加条目——插件用户只在版本变化时收到更新。

## 8. 测试工作室本身
`testing/` 包含目录、质量评分表和 74 份行为规格。在本仓库或以 `--with-testing` 安装的项目中运行
`/skill-test static all`、`/skill-test spec <skill>`、`/skill-test agent <agent>`、`/skill-test audit` 或
`/skill-improve <name>`。详情：[testing/README.md](../../testing/README.md)。

## 9. 仓库结构
```
.claude-plugin/   plugin.json + marketplace.json（本仓库同时是 marketplace 和插件）
agents/           30 个代理        skills/     44 个技能        hooks/      hooks.json + 10 个脚本
rules/            13 条路径规则                   docs/       stack-reference/、templates/、名册、流水线目录、安全基线
templates/        CLAUDE.md、settings.json、settings.plugin-mode.json、statusline.sh
testing/          代理与技能测试框架                install.sh  副本 / 新项目安装脚本
```

## 10. 代理
| 层级 | 代理 |
|---|---|
| 总监（Opus） | `technical-director`、`product-director` |
| 负责人（Sonnet） | `backend-lead`、`frontend-lead`、`design-lead`、`security-lead`、`qa-lead`、`devops-lead`、`game-lead` |
| 后端 | `go-engineer`、`php-engineer`、`node-engineer`、`database-engineer`、`api-designer`、`graphql-engineer` |
| 前端 | `angular-engineer`、`vue-engineer`、`typescript-engineer`、`css-engineer`、`accessibility-specialist`、`seo-specialist` |
| 游戏 | `threejs-engineer`、`web-game-engineer`、`multiplayer-engineer` |
| 安全 | `appsec-engineer`、`network-security-engineer` |
| 质量与运维 | `test-engineer`、`performance-engineer`、`devops-engineer`、`tech-writer` |

配套技能——外部战略顾问或部署操作员——若已安装会被识别并由 `/start`、`/deploy` 和名册使用；它们并非必需。

## 参与贡献、要求与许可证
想添加代理、技能或技术，或修复问题？请参阅 [CONTRIBUTING.md](../../CONTRIBUTING.md)（本地开发、扩展指南、pull request、发布）。要求：可访问 `opus`、`sonnet`、`haiku` 的 Claude Code；`jq` 可选（钩子回退到 python3）；技术栈工具按项目而定。MIT 许可证；致谢见 [NOTICE](../../NOTICE)。

---
¹ 工作室的结构受 [Claude Code Game Studios](https://github.com/Donchitos/Claude-Code-Game-Studios) 模板启发。
