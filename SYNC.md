## 最新同步

`mattpocock/skills@24fe0ef`（v1.3.1）于 2026-10-08

提醒：每次同步上游导致 `.claude-plugin/plugin.json` 版本变化时，要同步 bump
`dsh-plugin/package.json` 并按同名 tag 打 GitHub Release，`publish-dsh-plugin.yml`
workflow 会自动把 dsh 插件发布到 npm。

## 同步记录

- 2026-10-21：**本地扩展**，非上游同步。新增 `ship` skill（`skills/engineering/ship/`），把本仓库分散的 skills 串成一条带硬 gate 的完整流程，用于对齐 Superpowers 的强制闭环。它内联了 `to-spec`、`to-tickets`、`implement`、`implement-spec`、`retro` 的核心规则，因为 Kimi Code 不允许模型调用 user-invoked skill。同步上游时需保留此 skill，上游没有对应条目，不要被覆盖或删除。同时新增 `docs/engineering/ship.md` 与 `docs/replacing-superpowers.md`。
- 2026-10-08：已同步 `mattpocock/skills@24fe0ef`（v1.3.1）：`implement-spec`、`pr`、`retro` 从 in-progress 毕业至 engineering，移除 `resolving-merge-conflicts`，`CONTEXT.md`/`CONTEXT-MAP.md` 约定重命名为 `GLOSSARY.md`/`GLOSSARY-MAP.md`，并落地上游的 em-dash 清理与跨 skill 调用措辞修正；维护 commit 为 `f659bb3`，PR 为 [#40](https://github.com/vinvcn/mattpocock-skills-zh-CN/pull/40)。
- 2026-09-24：已同步 `mattpocock/skills@c55ee46`，新增 beta `pr` skill 的简体中文翻译；由 Codex 自动翻译并通过本地结构、行为不变量和 Markdown 检查，维护 commit 为 `d71a03d`。
- 2026-09-17：已同步 `mattpocock/skills@959a8e9` 对 `retro` 的 deterministic checks 指引，并补齐既有的 `Skills` 行为说明；由 Codex 自动翻译并通过本地结构、行为不变量和 Markdown 检查，维护 commit 为 `fb3bd36`。
- 2026-08-25：已同步 `mattpocock/skills@6654f6b` 的内容变化；由 Codex 自动翻译并通过本地结构、行为不变量和 Markdown 检查，维护 commit 为 `df042c8`，PR 为 [#29](https://github.com/vinvcn/mattpocock-skills-zh-CN/pull/29)。该工作使用 `/Users/hcc/projects/mattpocock-skills-zh-CN` 作为持久化维护副本。
