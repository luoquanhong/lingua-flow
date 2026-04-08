# LinguaFlow Sprint 看板

> 本文件记录当前 Sprint 的各项工作进度，随任务推进实时更新。

---

## Sprint 信息

- **Sprint 编号**：Sprint 0（奠基 Sprint）
- **Sprint 周期**：2026-04-06 ~ 2026-04-19（预计 14 天）
- **总体进度**：67%（8/12 交付物已完成）
- **当前状态**：进行中（Week 2 推进中）
- **最后更新**：2026-04-07 09:30 UTC

---

## Sprint 0 交付物进度

| # | 任务 | 状态 | 完成时间 | 备注 |
|---|------|------|---------|------|
| 1 | 技术选型确认 | ✅ 已完成 | 2026-04-06 | Flutter + React + Go + DeepSeek-V3 |
| 2 | CI/CD 流水线 | ✅ 已完成 | 2026-04-06 | GitHub Actions Secrets 待配置 |
| 3 | Git 仓库初始化 | ✅ 已完成 | 2026-04-06 | github.com/luoquanhong/lingua-flow |
| 4 | 数据库设计（ER 图） | ✅ 已完成 | 2026-04-06 | commit 0556926，7张表 + SQL 迁移脚本 |
| 5 | AI Prompt v1.0 | ✅ 已完成 | 2026-04-06 | commit ed37b9f，3个Prompt + 测试脚本 |
| 6 | Flutter 脚手架 | ✅ 已完成 | 2026-04-06 | commit e164655，12个文件 |
| 7 | UI 设计稿 | ✅ 已完成 | 2026-04-06 | 与 Flutter 脚手架同步 commit |
| 8 | PM Sprint 看板 + PRD 大纲 | ✅ 已完成 | 2026-04-06 | commit 92682e4 |
| 9 | PRD v1.0 终版 | ⏳ 进行中 | — | 产品经理 Agent 负责，Week 2 继续 |
| 10 | API 接口文档 | ⏳ 待开始 | — | 后端 Agent 负责，Week 2 启动 |
| 11 | Go 项目初始化 | ⏳ 待开始 | — | 后端 Agent 负责，Week 2 启动 |
| 12 | React Web 脚手架 | ⏳ 待开始 | — | 前端 Agent 负责，Week 2 启动 |

---

## 已完成交付物（8/12）

1. ✅ **技术选型确认书**（commit 0556926 同期）
   - 技术栈：Flutter + React + Go + DeepSeek-V3
   - 文档 URL：https://nmgokmthfs2t.space.minimaxi.com
2. ✅ **CI/CD 流水线 V1.0**（GitHub Actions）
3. ✅ **GitHub 仓库激活**（github.com/luoquanhong/lingua-flow）
4. ✅ **数据库 ER 图**（7张表 + SQL 迁移脚本）
5. ✅ **AI 情感叙事 Prompt v1.0**（3个 Prompt + 测试脚本）
6. ✅ **Flutter 脚手架**（12个文件，UI设计方案）
7. ✅ **UI 设计稿**（与 Flutter 脚手架同期交付）
8. ✅ **PM Sprint 看板 + PRD 大纲**（项目管理文档目录）

---

## Week 2 待推进任务（4/12）

| 任务 | 状态 | 负责人 | 阻塞项 |
|------|------|--------|--------|
| PRD v1.0 终版 | ⏳ 进行中 | 产品经理 Agent | ⚠️ PM Agent 历史超时，需人工兜底 |
| API 接口文档 | ⏳ 待开始 | 后端 Agent | — |
| Go 项目初始化 | ⏳ 待开始 | 后端 Agent | — |
| React Web 脚手架 | ⏳ 待开始 | 前端 Agent | — |

---

## ⚠️ 阻塞项与风险

| 风险 | 等级 | 说明 |
|------|------|------|
| PM Agent 执行不稳定 | 🟡 中 | 历史出现超时未完成情况（如竞品早报第2期），PRD 终版存在延期风险 |
| GitHub Actions Secrets 未配置 | 🟡 中 | CI/CD 流水线完整功能受限，需后端 Agent 补充 |
| 后端任务（3项）均未开始 | 🟡 中 | Week 2 后半段需集中推进，避免 Sprint 收尾压力过大 |
| AI Prompt 测试验收 | 🟡 中 | 需统筹人参与，当前仅有脚本未见实测结果 |

---

## Sprint 1 预告任务清单

> 预计启动时间：2026-04-20（周一）

| 任务 | 描述 | 负责人（预估） |
|------|------|---------------|
| 单词学习核心流程 MVP | 用户注册/登录 → 单词添加 → AI场景生成 → 复习闭环 | 全体 |
| 用户注册/登录模块 | 账号体系、Token 鉴权 | 后端 Agent |
| 单词添加功能 | 前端交互 + API 接入 | 前端 Agent |
| AI 场景生成集成 | DeepSeek-V3 API 接入 | 后端 + AI Agent |
| 复习闭环设计 | Spaced Repetition 逻辑 | 产品经理 |
| React Web 正式开发 | 响应式页面 + 状态管理 | 前端 Agent |

---

## 文档库快速访问

| 文档 | 路径 |
|------|------|
| 项目手册（总览） | https://yb8js3jf1klk.space.minimaxi.com |
| 技术选型确认书 | https://nmgokmthfs2t.space.minimaxi.com |
| 文档库索引 | /workspace/LinguaFlow-Docs/ |
| Git 仓库 | /workspace/lingua-flow/ |

---

*最后更新：2026-04-07 09:30 UTC*
