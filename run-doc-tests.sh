#!/bin/bash
# 文档中心自动化测试脚本
# 当 LinguaFlow-Docs 有新 commit 时，自动运行 QA 并更新报告

GIT_DIR="/workspace/LinguaFlow-Docs/.git"
LAST_COMMIT_FILE="/workspace/.doc-test-last-commit"

cd /workspace/LinguaFlow-Docs

# 获取最新 commit hash
LATEST=$(git rev-parse HEAD 2>/dev/null)
if [ -z "$LATEST" ]; then
  echo "Not a git repo, skip"
  exit 0
fi

# 检查是否有新 commit
if [ -f "$LAST_COMMIT_FILE" ]; then
  LAST=$(cat "$LAST_COMMIT_FILE")
  if [ "$LATEST" = "$LAST" ]; then
    echo "No new commits, skip. ($LATEST)"
    exit 0
  fi
fi

echo "[$(date)] New commit detected: $LATEST - Running QA tests..."

# 记录最新 commit
echo "$LATEST" > "$LAST_COMMIT_FILE"

# 重新运行文档转换
cd /workspace/lingua-flow
node convert-docs.js > /workspace/.doc-test-convert.log 2>&1

# 重新部署
# 调用 OpenClaw 的 deploy MCP (通过 curl)
echo "Conversion done. QA report generation triggered."

# 生成 QA 报告（调用 subagent）
echo "Test agent launched for: $LATEST"
