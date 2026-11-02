## 最新同步

`mattpocock/skills@59db609`（v1.3.1 后未发版）于 2026-10-28

提醒：每次同步上游导致 `.claude-plugin/plugin.json` 版本变化时，要同步 bump
`dsh-plugin/package.json` 并按同名 tag 打 GitHub Release，`publish-dsh-plugin.yml`
workflow 会自动把 dsh 插件发布到 npm。

## 同步记录

- 2026-11-02：**fork 同步**。把上游中文仓库 `vinvcn/mattpocock-skills-zh-CN` 的 `c48fd4a`（同步 `mattpocock/skills@59db609`）与 `5b57718`（dsh 技能计数）合并进本 fork，冲突仅 `README.md`、`SYNC.md` 两处：README 采用上游重构后的五条安装路线并统一回 `ZJFERAL` 路径，SYNC 合并两条记录。同时修正 dsh 插件计数：上游按 38 计（含 `chief-of-staff`），本 fork 另有本地 `ship`，实际为 **39**，已同步 `SKILL_NAMES`、`EXPECTED_SKILLS`、`package.json` 描述、dsh README 与 `provider.test.mjs`；补齐 `chief-of-staff` 在 `skills/in-progress/README.md` 的条目（上游漏记）；`AGENTS.md` 同步 `CLAUDE.md` 新增的 marketplace 说明与 Triage labels 段。验证：`check-translation.mjs` 通过、`verify.mjs` 报 `ok: 39 skills verified`、`node --test` 20 通过、`verify-version-sync.mjs` 通过。plugin 版本仍为 v1.3.1，未发版。
- 2026-10-28：已同步 `mattpocock/skills@59db609`：新增 in-progress `chief-of-staff` skill；`setup-matt-pocock-skills` 落地 reachable repo 检查、tracker label 创建，GitHub tracker 换用 sub-issue 与 native blocking 新约定；`implement` 先 fetch 传入的 ticket reference 并复述标题；`grilling` 新增「yes 即接受推荐答案」措辞规则；28 个 docs 页面随上游 prose 重写刷新；`.out-of-scope/` 新增 6 条记录并新增顶层 `SCOPE.md` 译本；README 安装章节随上游重构，新增 Codex、Copilot、Gemini CLI 路线（安装路径已适配本仓库）。上游未发版（仍为 v1.3.1），plugin 版本无变化，dsh-plugin 无需 bump。维护 commit 为 `72f94d0`。
- 2026-10-26：**本地扩展**，非上游同步。增强 `code-review` skill：新增只读审查、不嵌套子代理、先核实再报告、不静默省略的行为约束，补上 spec/diff/standards 缺失三种失败路径，两个轴线 brief 增加读改动连接代码、finding 四元组与 declined-to-judge，Spec 轴线增加「spec 沉默不等于许可」的评判原则。同步上游时需保留这些本地增补。
- 2026-10-21：**本地扩展**，非上游同步。新增 `ship` skill（`skills/engineering/ship/`），把本仓库分散的 skills 串成一条带硬 gate 的完整流程，用于对齐 Superpowers 的强制闭环。它内联了 `to-spec`、`to-tickets`、`implement`、`implement-spec`、`retro` 的核心规则，因为 Kimi Code 不允许模型调用 user-invoked skill。同步上游时需保留此 skill，上游没有对应条目，不要被覆盖或删除。同时新增 `docs/engineering/ship.md` 与 `docs/replacing-superpowers.md`。
- 2026-10-08：已同步 `mattpocock/skills@24fe0ef`（v1.3.1）：`implement-spec`、`pr`、`retro` 从 in-progress 毕业至 engineering，移除 `resolving-merge-conflicts`，`CONTEXT.md`/`CONTEXT-MAP.md` 约定重命名为 `GLOSSARY.md`/`GLOSSARY-MAP.md`，并落地上游的 em-dash 清理与跨 skill 调用措辞修正；维护 commit 为 `f659bb3`，PR 为 [#40](https://github.com/vinvcn/mattpocock-skills-zh-CN/pull/40)。
- 2026-09-24：已同步 `mattpocock/skills@c55ee46`，新增 beta `pr` skill 的简体中文翻译；由 Codex 自动翻译并通过本地结构、行为不变量和 Markdown 检查，维护 commit 为 `d71a03d`。
- 2026-09-17：已同步 `mattpocock/skills@959a8e9` 对 `retro` 的 deterministic checks 指引，并补齐既有的 `Skills` 行为说明；由 Codex 自动翻译并通过本地结构、行为不变量和 Markdown 检查，维护 commit 为 `fb3bd36`。
- 2026-08-25：已同步 `mattpocock/skills@6654f6b` 的内容变化；由 Codex 自动翻译并通过本地结构、行为不变量和 Markdown 检查，维护 commit 为 `df042c8`，PR 为 [#29](https://github.com/vinvcn/mattpocock-skills-zh-CN/pull/29)。该工作使用 `/Users/hcc/projects/mattpocock-skills-zh-CN` 作为持久化维护副本。
