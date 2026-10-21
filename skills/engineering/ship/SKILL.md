---
name: ship
description: "把 idea 一路推到 ship 的严格流程：对齐、计划、执行、审查、验证、收尾、复盘，每阶段带硬 gate。需要按部就班时手动调用；只想用单个 skill 时不要用它。"
disable-model-invocation: true
---

# Ship

把本仓库分散的 skills 串成一条带 gate 的完整流程，效果对齐 Superpowers 的强制闭环，但由你手动开启。

**它和其他 skills 的关系**：`ship` 是编排层，不替代任何 skill。每个阶段内部仍然调用本仓库的 skill 完成实际工作；`ship` 只负责决定**何时**进入下一阶段，以及**什么条件下不许进入**。

**为什么内联**：本仓库 16 个 user-invoked skill 不能被模型调用，包括 `to-spec`、`to-tickets`、`implement`、`implement-spec`、`retro`。因此这些阶段的内容在本文内联重写，不转发。model-invoked 的 skills（`grilling`、`domain-modeling`、`prototype`、`tdd`、`code-review`、`pr`、`diagnosing-bugs`）正常调用。

## 何时使用

- 多文件、跨 session 的功能开发。
- 你希望 agent 不许跳步、不许提前声称完成。
- 一次改动需要留下 spec、tickets、ADRs 等可追溯产物。

**不要用**：单文件小修、纯问答、探索性调研。那些直接调单个 skill 更快。诊断疑难 bug 直接走 `/diagnosing-bugs`。

## 前置条件

确认 `docs/agents/issue-tracker.md` 存在。不存在就让用户先运行 `/skill:setup-matt-pocock-skills`，它配置 issue tracker、triage labels 和 domain docs 布局。每个 repo 只需一次。

## Context 纪律

Phase 1 到 Phase 3 必须留在**同一个未中断的 context window**，不要 compact 也不要 clear，这样访谈、spec 和 tickets 建立在同一组思考之上。

Phase 4 起每个 ticket 开 fresh session，只基于对应 ticket 工作。

接近 smart zone（约 150k tokens）时在最近的阶段边界用 `/compact`，不要硬撑降级状态。

## 流程

每个阶段都有 **Done when**。不满足就不进入下一阶段。

### Phase 1：对齐

调用 `Skill(grilling)`。它按 **rounds** 逐轮问完整条 **frontier**，每个问题附推荐答案。答案依赖本轮未解决问题的，属于更晚一轮。

同时调用 `Skill(domain-modeling)`：挑战模糊术语、解决 overloaded word、把难以逆转的 decision 写成 ADR，并就地更新 `GLOSSARY.md`。

需要来自 environment 的事实时，派 sub-agent 去查，不要问用户能自己查到的内容。

**Done when**：frontier 为空，即没有任何 decision 还悬着；`GLOSSARY.md` 里本次涉及的新术语已落地。

### Phase 2：设计绕行（条件执行）

仅当某个问题必须**可运行**才能回答时进入：state model 感觉对不对，或 UI 该长什么样。

调用 `Skill(prototype)`。prototype 是 throwaway code，默认不持久化，跳过 polish。

需要在原型目录和主 thread 之间切换时，让用户手动运行 `/skill:handoff`。

**Done when**：原型回答了这个具体问题，答案已折回 Phase 1 的 design tree。

### Phase 3：计划

内联执行 `to-spec` 和 `to-tickets` 的核心规则。

**先定 seams。** 写下准备在哪些 seams 上测试这个 feature，优先用现有 seams，理想数量是一个。与用户确认，未确认的 seam 不写 test。

**再写 spec**，发布到 issue tracker，应用 `ready-for-agent` label。模板：

```
**Problem Statement**
用户正在面对的问题，从用户视角描述。

**Solution**
问题的解决方案，从用户视角描述。

**User Stories**
1. As an <actor>, I want a <feature>, so that <benefit>

**Implementation Decisions**
**Testing Decisions**
**Out of Scope**
**Further Notes**
```

**再拆 tickets。** 每条必须是 tracer bullet：

- 贯穿每一层（schema、API、UI、tests）形成窄而完整的路径，不是某一层的 horizontal slice。
- 完成的 slice 可独立 demo 或 verify。
- 大小能放进一个 fresh context window。
- 先完成所有 prefactoring。
- 声明 **blocking edges**：本地 tracker 用文本，真实 tracker 用 native blocking links。

**Done when**：spec 已发布；每个 ticket 都有 acceptance criteria 和 blocking edges；tickets 构成一张有 ready frontier 的 task graph。

### Phase 4：执行

按 ticket 数量选择：

**单 ticket 或少量**：在当前 context 直接实现。每个 ticket 驱动 `Skill(tdd)`，一次一个 red-green vertical slice。

**多 ticket**：创建 integration branch，把 tickets 当 task graph 推进。在 ready frontier 上并行运行 implementer subagents，每个 subagent 在自己的 worktree 和 branch 上工作，开始前确认 worktree 基于 integration branch。subagent 之间只传 **context pointers**（spec、ticket、research notes、commit），不重复 pointers 已经提供的信息。

无论哪种，都遵守 TDD 铁律：先写失败测试，**看着它失败**，再写刚好够通过的最小代码，**看着它通过**，然后重构。没看过红的测试，你不知道它测的是不是对的东西。

定期运行 typecheck，定期运行单个测试文件，最后运行完整套件。

**Done when**：所有 ticket 关闭；完整测试套件绿。

### Phase 5：审查

调用 `Skill(code-review)`，fixed point 用 integration branch 的起点或用户指定位置。

它并行跑两条轴：**Standards**（是否符合本仓库记录的编码标准）和 **Spec**（是否忠实实现来源 issue/spec），然后聚合 findings。

收到 review 反馈后，按下面「接收审查反馈」处理，不要直接开始改。

**Done when**：两条轴的 findings 都已分类处置：修复、或有理由地驳回。

### Phase 6：验证 gate

**这是硬 gate，不通过不许说完成。**

在声称任何「完成 / 修好 / 通过」之前：

1. **识别**：哪个命令能证明这个 claim？
2. **运行**：完整跑一遍，就在本轮消息里，不能引用之前的输出。
3. **确认**：读实际输出，确认结果符合 claim。
4. **再声称**：只有前三步都成立才说完成。

不能声称的情况：只跑了单个测试文件就说完整套通过；只编译通过就说功能可用；上一次运行是上一轮对话；测试红了但认为「应该没问题」。

**Done when**：本轮消息里贴出了新鲜验证命令和它的实际输出。

### Phase 7：收尾

先跑项目完整测试套件（`npm test`、`cargo test`、`pytest`、`go test ./...` 按项目而定）。**测试红了就停下**，报告失败，不给收尾菜单。

绿了之后向用户呈现四个选项：

1. **本地合并**：合到 base branch，在合并结果上再跑一次测试。
2. **推送并开 PR**：推送后调用 `Skill(pr)` 塑形 PR 正文，它要求最小可视化摘要、before/after 证据、以及单向门还是双向门的判断。
3. **保留现状**：branch 留着，worktree 留着。
4. **丢弃**：确认后删除 branch 和 worktree。

用户选定后再清理 worktree。

**Windows 警告**：删 worktree 前必须先拆 junction。如果 worktree 里用目录链接复用了主仓库的 `node_modules`，`git worktree remove` 会递归穿透链接删除主仓库内容。正确顺序是先逐个删链接（不递归），再 `git worktree remove`，最后用 PowerShell 二次确认无残留链接。

**Done when**：用户选定的收尾动作已执行并验证；worktree 已按正确顺序清理。

### Phase 8：复盘

内联执行 `retro` 的核心检查。针对 coding agent 的 **environment** 提改进建议，不是改代码。按严重程度排序。

检查五类：

- **Navigation**：agent 找对文件有多难？有没有隐藏依赖？能否加 pointer 让定位更容易？
- **Automated checks**：有没有 lint、typecheck、test 能捕获这次犯的错？先读 repo 自己的 `lint`/`check` scripts 和 CI workflow。
- **Coding standards**：是否有规则该给 reviewer 加？先分类：mechanical 违规（固定语法、禁用 API、import 形式、文件位置）交给 deterministic check；judgement call 写成 coding standard。
- **AGENTS.md**：是否有 steering instruction 该移到 coding standards 或 automated checks？steering file 是否已经太臃肿？
- **Tool economy**：有没有可以简化的昂贵 tool call？

**Done when**：每个候选项都有具体改动位置，且区分了「这次就该做」和「以后再说」。

## 接收审查反馈

Phase 5 收到 findings 后，按顺序处理，不许跳步：

1. **读完**：完整读完所有反馈，先不反应。
2. **复述**：用自己的话重述要求，或提问确认。
3. **核实**：对照 codebase 现实检查，反馈描述的代码是否真的如此。
4. **评估**：在这个 codebase 里技术上是否成立。
5. **回应**：技术上确认，或有理由地驳回。
6. **实现**：一次一项，每项都测试。

禁止的回应：`You're absolutely right!`、`Great point!`、没核实就照做、表面同意然后不改。技术上不成立就直说并给证据；对方已经决定就服从。

## 硬 gate 汇总

这四条在任何阶段都不可协商：

- **未对齐不计划**：Phase 1 的 frontier 没空，不进 Phase 3。
- **未看红不写绿**：没看过失败的测试，不许写实现。
- **未验证不声称**：没有本轮新鲜验证证据，不许说完成。
- **测试红不收尾**：套件没绿，不给合并或 PR 选项。

## 快速参考

| Phase | 调用 | 关键产物 |
| --- | --- | --- |
| 1 对齐 | `grilling` + `domain-modeling` | design tree 收敛、`GLOSSARY.md`、ADR |
| 2 设计 | `prototype`（条件） | 可运行答案 |
| 3 计划 | 内联 spec + tickets | spec、tracer-bullet tickets、blocking edges |
| 4 执行 | `tdd`（每个 slice） | 绿的测试、已关闭 tickets |
| 5 审查 | `code-review` | Standards + Spec 双轴 findings |
| 6 验证 | 内联 gate | 本轮验证输出 |
| 7 收尾 | 内联 + `pr` | 合并或 PR、已清理 worktree |
| 8 复盘 | 内联 retro | 按严重度排序的环境改进 |
