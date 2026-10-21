## 它做什么

`ship` 把本仓库分散的 skills 串成一条带 gate 的完整流程，效果对齐 Superpowers 的强制闭环，但由你手动开启。

它不替代任何 skill。每个阶段内部仍然调用本仓库的 skill 完成实际工作；`ship` 只负责决定何时进入下一阶段，以及什么条件下不许进入。

这条流程覆盖八个阶段：对齐、设计绕行、计划、执行、审查、验证、收尾、复盘。

## 何时使用

你通过输入 `/ship` 调用它，agent 不会自行取用。它带着 `disable-model-invocation: true` 发布，所以模型既不会自动触发它，也不能从其他 skill 内部调用它。

- 多文件、跨 session 的功能开发。
- 你希望 agent 不许跳步、不许提前声称完成。
- 一次改动需要留下 spec、tickets、ADRs 等可追溯产物。

**不要用**：单文件小修、纯问答、探索性调研。那些直接调单个 skill 更快。诊断疑难 bug 直接走 [diagnosing-bugs](https://aihero.dev/skills-diagnosing-bugs)。

## 为什么它要内联部分内容

Kimi Code 的规则是 `disableModelInvocation: true` 的 skill 连模型显式调用都会被拦。本仓库 16 个 user-invoked skill 都属于这一类，包括 [to-spec](https://aihero.dev/skills-to-spec)、[to-tickets](https://aihero.dev/skills-to-tickets)、[implement](https://aihero.dev/skills-implement)、[implement-spec](https://aihero.dev/skills-implement-spec)、[retro](https://aihero.dev/skills-retro)。

因此这些阶段的内容在 `ship` 里内联重写，不转发。model-invoked 的那批（[grilling](https://aihero.dev/skills-grilling)、[domain-modeling](https://aihero.dev/skills-domain-modeling)、[prototype](https://aihero.dev/skills-prototype)、[tdd](https://aihero.dev/skills-tdd)、[code-review](https://aihero.dev/skills-code-review)、[pr](https://aihero.dev/skills-pr)）正常调用。

## 八个阶段

| Phase | 调用 | 关键产物 |
| --- | --- | --- |
| 1 对齐 | `grilling` + `domain-modeling` | design tree 收敛、`GLOSSARY.md`、ADR |
| 2 设计 | `prototype`（条件执行） | 可运行答案 |
| 3 计划 | 内联 spec + tickets | spec、tracer-bullet tickets、blocking edges |
| 4 执行 | `tdd`（每个 slice） | 绿的测试、已关闭 tickets |
| 5 审查 | `code-review` | Standards + Spec 双轴 findings |
| 6 验证 | 内联 gate | 本轮验证输出 |
| 7 收尾 | 内联 + `pr` | 合并或 PR、已清理 worktree |
| 8 复盘 | 内联 retro | 按严重度排序的环境改进 |

每个阶段都有 **Done when**。不满足就不进入下一阶段。

Phase 1 到 Phase 3 必须留在同一个未中断的 context window，不要 compact 也不要 clear。Phase 4 起每个 ticket 开 fresh session。

## 四条硬 gate

这四条在任何阶段都不可协商：

- **未对齐不计划**：Phase 1 的 frontier 没空，不进 Phase 3。
- **未看红不写绿**：没看过失败的测试，不许写实现。
- **未验证不声称**：没有本轮新鲜验证证据，不许说完成。
- **测试红不收尾**：套件没绿，不给合并或 PR 选项。

后两条正是本仓库其他 skill 没有硬性覆盖的地方，`ship` 把它们补齐，这也是它能对齐 Superpowers 严格度的原因。

## 前置条件

确认 `docs/agents/issue-tracker.md` 存在。不存在就让用户先运行 `/setup-matt-pocock-skills`，它配置 issue tracker、triage labels 和 domain docs 布局。

## 常见问题

**它和 ask-matt 有什么区别？**

[ask-matt](https://aihero.dev/skills-ask-matt) 是路由器，回答「我这个情境该走哪条 flow」，然后你自己逐个调用 skill。`ship` 是把那条 main flow 固化下来并加上 gate，一次调用走完全程。

**我可以中途退出吗？**

可以。每个阶段结束时都在一个干净的边界上，你可以直接停在那里，后续用单个 skill 继续。

**为什么它不是 model-invoked？**

你的需求是「需要严格流程时才用，平时不介入」。model-invoked 会让它在每个会话里被自动触发的风险，user-invoked 把控制权留在你手里。

**Windows 上删 worktree 有什么要注意的？**

Phase 7 会提醒：如果 worktree 里用目录链接复用了主仓库的 `node_modules`，`git worktree remove` 会递归穿透链接删除主仓库内容。正确顺序是先逐个删链接（不递归），再 `git worktree remove`，最后用 PowerShell 二次确认无残留链接。

## 它正常工作的标志

- 开始时不直接写代码，而是先进入 Phase 1 访谈。
- 每个阶段结束时明确报告 Done when 是否满足，而不是默默往下走。
- 声称完成之前，消息里能看到本轮跑过的验证命令和实际输出。
- 测试红了就不会出现「合并 / 开 PR」的选项。

## 它在整体中的位置

```txt
ship = grill-with-docs → to-spec → to-tickets → implement → code-review → 验证 → 收尾 → retro
```

它把 [ask-matt](https://aihero.dev/skills-ask-matt) 描述的 main flow 固化成一条可执行路径，并在其中补上本仓库原本缺失的验证 gate、分支收尾和 review 接收纪律。

当你不需要严格流程时，照常单独调用各个 skill，`ship` 不会介入。
