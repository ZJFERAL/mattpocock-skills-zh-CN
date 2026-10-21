# 用 Matt Pocock 的 Skills 替代 Superpowers

本仓库的 skills 覆盖了 Superpowers 插件的绝大多数能力，但两者的运行方式不同，切换后需要自己补上几条常驻约束。本文说明切换步骤、逐项对应关系，以及需要自己补的缺口。

本文以 **Kimi Code** 环境为例。其他 harness（Claude Code、Codex）的停用与安装方式不同，但对照表部分通用。

## 定位差异

**Superpowers 是会话级框架。** 它的 Kimi Code 插件清单声明了 `sessionStart.skill: "using-superpowers"`，因此每个新会话启动时都会把该 skill 注入 context，强制 agent 在回答任何问题之前先检查并调用适用的 skill。流程由框架推动，你不需要记命令。

**Matt 的 skills 是按需调用的工具集。** 它们不介入会话启动，而是分两层：

- **纪律层是 Model-invoked**：`tdd`、`diagnosing-bugs`、`grilling`、`code-review`、`prototype`、`domain-modeling`、`codebase-design`、`pr`、`research`、`wizard`、`writing-for-agents`。它们的 description 带丰富触发措辞，模型在任务匹配时会自动触达，行为接近 Superpowers。
- **编排层是 User-invoked**：`ask-matt`、`grill-with-docs`、`to-spec`、`to-tickets`、`implement`、`implement-spec`、`wayfinder`、`triage`、`retro`、`improve-codebase-architecture`。这些只在你敲命令时运行，模型不能自行调用。

替代的本质是：把「框架替你选流程」换成「你用 `/ask-matt` 问路，然后自己选流程」。

## 切换步骤

### 1. 确认 Matt 的 skills 已链接到 Kimi Code

```bash
bash scripts/link-skills-kimi.sh
```

脚本把仓库的公开 skills 以 junction 链接到 `~/.agents/skills`，Kimi Code 在会话启动时扫描该目录。脚本幂等，可重复运行。新增或删除 skill 后必须重跑，且要开新会话才会出现在选择器里。

### 2. 停用 Superpowers 插件

```
/plugins disable superpowers
/reload
```

`/reload` 或开新会话后生效。想彻底移除安装记录用 `/plugins remove superpowers`；注意它只删除安装记录，`~/.kimi-code/plugins/managed/superpowers` 下的副本和原始源码都留在盘上。

想保留插件、只做对照实验，用 `disable` 就够了，随时可以 `/plugins enable superpowers` 加 `/reload` 开回来。

### 3. 补上常驻约束

Superpowers 的强制规则随插件一起消失，见下文「缺口与补法」。

## 逐项对照

| Superpowers skill | 它做什么 | Matt 的对应 | 覆盖 |
| --- | --- | --- | --- |
| `using-superpowers` | 会话启动注入，强制先调用 skill | `ask-matt`（问路路由器） | 机制不同 |
| `brainstorming` | 创意工作前追问，找出真正想要的东西 | `grilling`（可复用 primitive）、`grill-me`、`grill-with-docs` | 完整，更强 |
| `writing-plans` | 写实现计划，存到 `docs/superpowers/plans/` | `to-spec` 加 `to-tickets`（发到 issue tracker） | 部分，产物形态不同 |
| `executing-plans` | 自己逐任务内联执行计划 | `implement` | 完整 |
| `subagent-driven-development` | 每任务一个 fresh implementer，加任务级 review | `implement-spec` | 完整 |
| `dispatching-parallel-agents` | 独立任务并行派发 | 无独立 skill；能力散在 `implement-spec`、`code-review`、`research` | 部分 |
| `requesting-code-review` | 派发 reviewer subagent 检查任务 | `code-review` | 完整，更强 |
| `receiving-code-review` | 收到 review 反馈时的纪律：先验证再实现 | 无 | 无 |
| `verification-before-completion` | 声称完成前必须跑一遍验证命令 | 无独立 skill；要求散在 `implement`、`tdd`、`retro` | 部分 |
| `systematic-debugging` | 四阶段根因调试 | `diagnosing-bugs` | 完整，更强 |
| `test-driven-development` | red-green-refactor | `tdd` | 完整 |
| `using-git-worktrees` | 建立隔离工作区 | 无通用 skill；`implement-spec` 内建每个 subagent 一个 worktree | 部分 |
| `finishing-a-development-branch` | 跑测试、呈现 merge/PR/保留/丢弃、清理 | 无 | 无 |
| `writing-skills` | 用 TDD 方法写 skill | `writing-for-agents` | 完整，方法不同 |
| `diagnosing-superpowers` | 诊断 superpowers 会话为什么出问题 | `retro` | 完整 |

### 标注「更强」的三处

- **`grilling` 比 `brainstorming` 更有结构。** 它把设计映射成一棵 **design tree**，按 **rounds** 逐轮问完整条 **frontier**（prerequisites 已敲定、现在就能问的那些 decision），每个问题附上推荐答案。需要来自 environment 的事实时，它派 sub-agent 去查，而不是问你。配合 `grill-with-docs` 还能在访谈过程中同步产出 `GLOSSARY.md` 和 ADRs。
- **`code-review` 比 `requesting-code-review` 更明确。** 它规定两条轴：**Standards**（是否符合本仓库记录的编码标准）和 **Spec**（是否忠实实现来源 issue/spec），并行跑两个 sub-agent 并排报告，避免互相污染 context。
- **`diagnosing-bugs` 比 `systematic-debugging` 更严。** Phase 1 要求先构建一个会在**这个** bug 上变红的 tight loop，没有这个 pass/fail signal 就不许进入后续阶段，并给出 loop 的六种构建方式（failing test、curl/HTTP script、CLI invocation、headless browser script、replay captured trace、throwaway harness），按顺序尝试。

## 缺口与补法

以下六项是停用 Superpowers 后需要自己接手的地方。

### 1. 会话启动的强制约束

Superpowers 靠 `sessionStart.skill` 强制「动手前先 brainstorm、写代码前先写测试、声称完成前先验证」。停用后这些约束不会自动回来。

**补法**：在仓库根或用户全局的 `AGENTS.md`（或 `CLAUDE.md`）里写常驻 steering instructions。用 `writing-for-agents` 写，它讲了 pointer 措辞、context load 预算和 leading word 的取舍。建议至少写三条：

- 任何新功能或行为变更，动手前先跑 `/skill:grilling` 或 `/skill:grill-with-docs`。
- 写实现代码前先跑 `/skill:tdd`，先写失败测试并看着它失败。
- 声称「完成 / 修好 / 通过」前，必须在本轮消息里跑过验证命令并贴出输出。

### 2. 分支收尾

`finishing-a-development-branch` 的完整流程（跑完整测试套件、检测环境、呈现 merge / PR / 保留 / 丢弃四个选项、执行、清理 worktree）没有对应。`pr` 只管 PR 正文，`implement` 只提交到当前 branch，`implement-spec` 只处理 integration branch 的合并。

**补法**：把这段写成 `AGENTS.md` 里的规则，或手动执行。注意本仓库 `AGENTS.md` 已记录的 Windows 踩坑：删 worktree 前必须先拆 junction，否则 `git worktree remove` 会递归删进主仓库。

### 3. 接收 review 反馈的纪律

`receiving-code-review` 要求：完整读完反馈、用自己的话复述、对照 codebase 现实核实、判断技术上是否成立、再逐项实现并测试。Matt 没有对应 skill。

**补法**：写进 `AGENTS.md`，重点是「先验证再实现，先提问再假设」。

### 4. 完成前的验证 gate

`verification-before-completion` 的铁律是「没有新鲜的验证证据，不许声称完成」。Matt 把这条分散在三处：`implement` 要求定期 typecheck、定期跑单个测试文件、最后跑完整套件；`tdd` 要求 watch it fail 和 watch it pass；`retro` 会检查 repo 有没有 automated checks。

**补法**：合并成 `AGENTS.md` 里的一条硬规则，和上面第 1 条合写。

### 5. 计划文档的形态变化

`writing-plans` 产出 `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`。Matt 的 `to-spec` 和 `to-tickets` 发到 issue tracker（GitHub、Linear 或本地 markdown 文件），`to-tickets` 用 tracer-bullet vertical slice 加 blocking edges 组织，每个 ticket 都要小到能放进一个 fresh context window。

首次使用前要跑一次 `/skill:setup-matt-pocock-skills`，配置 issue tracker、triage labels 和 domain docs 布局。这个 skill 每个 repo 只需运行一次。

### 6. 并行派发

`dispatching-parallel-agents` 是独立 skill，教怎么识别独立 domain、给每个 agent 写聚焦任务、怎么整合结果。Matt 没有这个 skill，但能力在：`implement-spec` 在 ready frontier 上并行跑 implementer subagents，`code-review` 并行跑两个 review subagent，`research` 用 background agent。

**补法**：单独派发并行任务时，直接按「一个 agent 一个独立 domain，不共享状态」的原则做；成规模的任务交给 `implement-spec` 编排。

## 日常工作流对照

### Superpowers 的日常

```
你说「做个 X」
  → brainstorming 自动介入，追问需求
  → writing-plans 产出实现计划
  → subagent-driven-development 逐任务派 implementer
  → 每个任务后 requesting-code-review
  → verification-before-completion 卡住完成声明
  → finishing-a-development-branch 决定怎么合并
```

### Matt 的日常

```
/skill:ask-matt              问路：这个情境该走哪条流程
  ↓
/skill:grill-with-docs       追问，同时建 GLOSSARY.md 和 ADRs
  ↓ 需要可运行的答案？
/skill:prototype + /skill:handoff   原型回答问题，再 handoff 带回来
  ↓ 是跨 session 的活？
/skill:to-spec → /skill:to-tickets
  ↓
/skill:implement             逐 ticket 推进（ticket 之间 /clear 清空 context）
  或 /skill:implement-spec   整份 spec，并行 subagent
  ↓ 内部驱动 /skill:tdd，末尾 /skill:code-review
/skill:pr
```

### 调用方式对照

| | Superpowers | Matt |
| --- | --- | --- |
| 触发方式 | 会话启动自动注入 | `/skill:<name>`，或名称未被系统命令占用时的简写 `/<name>` |
| 记不住名字 | 不需要记 | `/skill:ask-matt` 问路 |
| 模型自动调用 | 全部可自动 | 只有 Model-invoked 那一批 |

Kimi Code 在会话启动时扫描 skill 目录，所以新链接的 skill 要开新会话才会出现在选择器里。

### 两条需要自己遵守的 context 规则

Superpowers 没有这两条，它们来自 `ask-matt`，替代后需要你自己记住。

**Context 卫生。** 从 grilling 到 `/to-tickets` 要留在同一个未中断的 context window 里，不要 compact 也不要 clear，这样 grilling、spec 和 tickets 才建立在同一组思考之上。之后每个 `/implement` 都从 fresh session 开始，只基于对应 ticket 工作。限制来自 smart zone：窗口内（最新模型大约 150k tokens）模型还能保持敏锐推理，接近这个区间时在最近的 phase boundary 用 `/compact`，不要硬撑降级状态。

**Phase 边界。** 在 grilling、implementation、QA 这些阶段之间，`ask-matt` 给了五个选项：continue（原地不动）、`/clear`（内容对接下来都不重要时）、`/handoff`（换 harness、换目录、交给同事、或阶段中途分叉 side task）、subagent（把 tightly-scoped task 送到独立 context）、`/compact`（默认项）。决定要在 boundary 处做，阶段中途要么继续，要么把剩余工作拆成 subagents。

## Matt 独有、Superpowers 没有的能力

- **`domain-modeling` 加 `GLOSSARY.md` 和 ADRs**：建立项目共享语言，减少 agent 啰嗦、让变量和文件命名一致、让 agent 更容易导航 codebase，也让它花更少 tokens 思考。这是本仓库的招牌能力，Superpowers 完全没有对应。
- **`codebase-design`**：deep modules 的共享词汇（module、interface、depth、seam、adapter、leverage、locality）和原则。
- **`improve-codebase-architecture`**：扫描 codebase 中的深化机会，产出可视化 HTML 报告，再围绕你选中的候选项继续 grilling。建议每隔几天跑一次。
- **`triage` 与 `wayfinder`**：issue 的 triage roles 状态机，以及把单个 session 装不下的大块工作绘制成 issue tracker 上的 decision tickets 共享地图。
- **`prototype`、`research`、`pr`、`wizard`、`retro`**：一次性原型、对照一手来源调研、PR 正文形态、交互式 bash wizard、session retrospective。
- **`handoff`、`teach`、`to-questionnaire`、`wait-what`**：交接文档、多 session 教学、把答不了的 decision 转成问卷、以及让 agent 用平实的语言重新表述。
- **`git-guardrails-claude-code`、`setup-pre-commit`、`migrate-to-shoehorn`、`scaffold-exercises`**：git 危险命令拦截、Husky pre-commit、类型断言迁移、练习目录脚手架。

## 结论

- **能替代的部分**：追问对齐、计划与拆票、执行（内联或 subagent 驱动）、TDD、调试、代码审查、写 skill、会话复盘。这些要么完整对应，要么比 Superpowers 更强。
- **不能替代的部分**：会话启动的强制约束、分支收尾（含 worktree 清理）、接收 review 反馈的纪律、完成前的验证 gate、计划文档的存放形态、通用的并行派发。前四项需要在 `AGENTS.md` 里补写常驻规则，后两项按上面第 5、6 节处理。
- **换来的是什么**：流程不再被框架接管。每个 skill 都小、可读、可改，你可以 hack 它们变成自己的东西，出问题时也更容易定位。
