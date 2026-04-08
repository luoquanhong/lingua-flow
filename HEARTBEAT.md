# HEARTBEAT.md

## ⚠️ 文档变更铁律（任何人必须遵守，含 Agent）

> 适用场景：任何 Agent 对 `lingua-flow/` 仓库中的文档进行增、删、改、移动操作时
> 执行者：产品经理 Agent、项目经理 Agent、小红（我）或其他 Agent

### 文档变更标准流程

> 任何文档变更必须按以下顺序执行，否则视为违规操作。

#### 第 1 步：变更前——检查受影响范围
变更前必须确认：
- 本次变更涉及哪些文件？
- 这些文件是否被 `docs-site/index.html` 链接引用？
- `docs/` 目录（GitHub Pages 读取位置）是否需要同步更新？

#### 第 2 步：执行变更并提交
按计划执行文档增删改操作

#### 第 3 步：Regression Test（必须通过）
> **必须在提交前完成，不得绕过**

测试人员职责（由我或项目经理 Agent 执行）：

**A. GitHub Pages 可访问性测试**
- 访问 `https://yb8js3jf1klk.space.minimaxi.com`
- 确认文档中心页面可正常加载
- 确认左上角总文档数量统计正常（不报错）

**B. 核心文档可点击测试（抽查 ≥ 3 份）**
- 点击「竞品早报」→ 确认第1~4期均可打开
- 点击「产品经理」tab → 确认 PRD 等核心文档可打开
- 点击任一子文档 → 确认内容正常加载（非 404）

**C. 新增/移动文档的链接验证**
- 确认 docs/index.html 中所有 `href` 链接指向的文件均存在于 `docs/` 目录
- 确认 `LinguaFlow-Docs/` 目录下的文件路径引用未被破坏

**D. 结构完整性检查**
- 确认 `LinguaFlow-Docs/` 和 `docs/` 内容同步
- 确认 `docs/index.html` 已被 git 追踪（不得被 .gitignore 忽略）

#### 第 4 步：测试通过后——方可 Merge / 提交
- 测试通过 → 执行 `git push origin master`
- 测试失败 → 修复问题 → 重新测试 → 通过后再提交

> ⚠️ **违规警告：** 未经验证直接推送的行为，将导致文档中心故障，所有 Agent 必须自律遵守。

---

## 定时任务配置（小红每日执行）

### 工作日 09:00（第①阶段：搜索）
- **产品经理 Agent（第①阶段）**：并发搜索多知网 + 芥末堆 + 行业媒体
- **搜索要求（必须遵守）：**
  - 每条结果必须注明：来源网站名称 + 具体 URL + 精确发布时间（YYYY-MM-DD）
  - 只筛选 **2026 年** 的新闻，过时内容（2025年及以前）一律过滤，不收录
  - 优先搜索近 3 天内发布的新闻
  - 来源尽量多样化：多知网、芥末堆、36kr、虎嗅、知乎等
- 产出：搜索结果写入 `/workspace/LinguaFlow-Docs/竞品早报/搜索结果-YYYY-MM-DD.md`
- 每条结果格式：
  ```
  - **标题**
    - 来源：网站名
    - URL：链接
    - 发布时间：YYYY-MM-DD
    - 摘要：（50字以内）
  ```
- 不生成报告，只搜索+保存 raw 结果，不超时
- 如有紧急竞品动态，立即推送给我（统筹人）

### 工作日 09:15（第②阶段：生成）
- **产品经理 Agent（第②阶段）**：基于上一步搜索结果生成竞品早报
- **生成要求（必须遵守）：**
  - 每条内容必须标注来源 URL 和具体日期
  - 纯2026年新闻，不包含任何2025年及以前的信息
  - 总字数：300~500字
  - 结尾"一句话结论"必须结合 LinguaFlow 实际项目情况
- 读取搜索结果文件，生成 markdown 早报，保存到 `/workspace/LinguaFlow-Docs/竞品早报/竞品早报-YYYY-MM-DD.md`
- HTML 版同步保存到 `/workspace/LinguaFlow-Docs/竞品早报/竞品早报-YYYY-MM-DD.html`
- 任务轻量，避免超时

### 工作日 09:30
- **项目经理 Agent**：核查 Sprint 进度，更新看板，标注阻塞项

### 工作日 17:00
- **自动提醒**：提醒全体成员 17:30 前提交每日报告
- 方式：推送飞书消息，或在当前会话推送文字提醒

### 工作日 18:00
- **小红汇总**：《团队每日速递》，发布给统筹人

### 每周五 16:30
- 提醒产品经理：17:00 前提交竞品周报；召开需求池评审会（3条待评审）

### 每周一 10:00
- 小红检查上周核心指标（DAU/留存/付费/AI质量）
- 如有异常立即上报

### Sprint 结束前 1 天
- 提醒项目经理：准备 Sprint 演示 + 回顾

---

## 当前项目状态

**Sprint 0 进行中**（2026-04-06 启动，预计 2026-04-19 结束）

已确认（V1.0）：
- ✅ 技术选型确认书（Flutter + React + Go + DeepSeek-V3）— 统筹人 2026-04-06 14:42 UTC 确认
- ✅ CI/CD 流水线 V1.0（含 Go / Flutter / React Web 三套 GitHub Actions）
- ✅ GitHub 仓库已激活（github.com/luoquanhong/lingua-flow）
- ✅ 团队运作制度 V1.0
- ✅ GitHub Actions 工作流文件（已补录，commit 883ac86）
- ✅ GitHub Secrets 配置指南（已补录，commit 15ea05b）

Sprint 0 完成度：**67%（8/12）**

**今日完成（2026-04-06）：**
- ✅ 后端：数据库 ER 图（7张表）+ SQL 迁移脚本
- ✅ AI：情感叙事 Prompt v1.0（3个Prompt + 测试脚本）
- ✅ PM：Sprint看板更新 + PRD大纲 + 工作日志
- ✅ 前端：Flutter脚手架（12个文件）+ UI设计方案

**今日完成（2026-04-07）：**
- ✅ 竞品早报（第3期）—— PM Agent 搜索+生成两阶段模式
- ✅ Sprint 0 进度核查（67%）
- ✅ GitHub Actions CI/CD 工作流文件（Go / Flutter / React Web）
- ✅ GitHub Secrets 配置指南

**Sprint 0 待完成（Week 2）：**
- ⏳ PRD v1.0 终版（产品经理 Agent）
- ⏳ API 接口文档 v1.0（后端 Agent）
- ⏳ Go 项目初始化（后端 Agent）
- ⏳ React Web 脚手架（前端 Agent）
- ⏳ GitHub Actions Secrets 配置（统筹人需手动完成）
- ⏳ AI Prompt 测试验收（需统筹人参与）

**⚠️ 阻塞项（需统筹人处理）：**
1. **GitHub Secrets 配置**（最优先）：`DEEPSEEK_API_KEY`、`DOCKER_USERNAME`、`DOCKER_PASSWORD`、`SSH_PRIVATE_KEY`、`SERVER_HOST`、`SERVER_USER`
2. **AI Prompt 测试验收**：统筹人需给出验收结论

**Sprint 1 预告（预计 2026-04-20 启动）：**
- 单词学习核心流程 MVP
- 用户注册/登录 → 单词添加 → AI场景生成 → 复习闭环

---

## 文档库快速访问

| 文档 | 链接/路径 |
|------|---------|
| 项目手册（总览） | https://yb8js3jf1klk.space.minimaxi.com |
| 技术选型确认书 | https://nmgokmthfs2t.space.minimaxi.com |
| 今日日报（第1期） | https://4wnalf2orfwf.space.minimaxi.com |
| GitHub Secrets 配置指南 | /workspace/LinguaFlow-Docs/开发规范文档/GitHub-Secrets-配置指南.md |
| 文档库索引 | /workspace/LinguaFlow-Docs/ |
| Git 仓库 | /workspace/lingua-flow/ |

---

## Sprint 0 进度（2026-04-07 更新）

| 任务 | 状态 | 交付时间 |
|------|------|---------|
| 技术选型确认 | ✅ 已完成 | 2026-04-06 |
| CI/CD 流水线 | ✅ 已完成 | 2026-04-06 |
| Git 仓库初始化 | ✅ 已完成 | 2026-04-06 |
| 数据库设计（ER图） | ✅ 已完成 | 2026-04-06 (commit 0556926) |
| AI Prompt v1.0 | ✅ 已完成 | 2026-04-06 (commit ed37b9f) |
| Flutter 脚手架 | ✅ 已完成 | 2026-04-06 (commit e164655) |
| UI 设计稿 | ✅ 已完成 | 2026-04-06 |
| PM Sprint看板 + PRD大纲 | ✅ 已完成 | 2026-04-06 (commit 92682e4) |
| GitHub Actions 工作流 | ✅ 已完成 | 2026-04-07 (commit 883ac86) |
| PRD v1.0 终版 | ⏳ 进行中 | Week 2 |
| API 接口文档 | ⏳ 待开始 | Week 2 |
| Go 项目初始化 | ⏳ 待开始 | Week 2 |
| React Web 脚手架 | ⏳ 待开始 | Week 2 |

**Sprint 0 进度：8/12 ✅ 完成 67%**
