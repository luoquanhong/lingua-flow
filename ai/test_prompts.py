#!/usr/bin/env python3
"""
LinguaFlow AI Prompt 测试脚本 v1.0
用于验证场景生成、评估、复习提示三个 Prompt 的有效性

依赖: pip install openai requests
运行: python test_prompts.py
"""

import os
import sys
import json
import re
import time
from pathlib import Path
from typing import Optional

# ===================== 配置 =====================
DEEPSEEK_API_KEY = os.environ.get("DEEPSEEK_API_KEY", "")
DEEPSEEK_BASE_URL = "https://api.deepseek.com/v1"
MODEL = "deepseek-chat"

PROMPTS_DIR = Path(__file__).parent / "prompts"
OUTPUT_FILE = Path(__file__).parent / "test_results.json"

# ===================== Prompt 加载 =====================

def load_prompt(filename: str) -> str:
    """从 promts 目录加载 Prompt 文件内容"""
    path = PROMPTS_DIR / filename
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    # 提取 --- 分隔符之间的 system prompt 部分
    lines = content.split("\n")
    system_lines = []
    in_system = False
    for line in lines:
        if line.startswith("## System Prompt"):
            in_system = True
            continue
        if line.startswith("## User Prompt Template"):
            break
        if in_system:
            system_lines.append(line)
    return "\n".join(system_lines).strip()


def extract_user_template(content: str) -> str:
    """从 Prompt 文件中提取 user template 部分"""
    lines = content.split("\n")
    in_user = False
    user_lines = []
    for line in lines:
        if "## User Prompt Template" in line:
            in_user = True
            continue
        if in_user:
            user_lines.append(line)
    return "\n".join(user_lines).strip()


# ===================== API 调用 =====================

def call_deepseek(system_prompt: str, user_prompt: str, model: str = MODEL) -> dict:
    """调用 DeepSeek API"""
    if not DEEPSEEK_API_KEY:
        return {
            "success": False,
            "error": "DEEPSEEK_API_KEY 环境变量未设置，请设置后重试。",
            "output": ""
        }

    try:
        import openai
    except ImportError:
        return {
            "success": False,
            "error": "请先安装 openai: pip install openai",
            "output": ""
        }

    client = openai.OpenAI(api_key=DEEPSEEK_API_KEY, base_url=DEEPSEEK_BASE_URL)

    response = client.chat.completions.create(
        model=model,
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt}
        ],
        temperature=0.8,
        max_tokens=800,
        timeout=60
    )

    return {
        "success": True,
        "output": response.choices[0].message.content,
        "usage": {
            "prompt_tokens": response.usage.prompt_tokens,
            "completion_tokens": response.usage.completion_tokens,
            "total_tokens": response.usage.total_tokens
        }
    }


# ===================== 场景生成测试 =====================

def test_scene_generation(system_prompt: str) -> dict:
    """测试场景生成 Prompt"""
    print("\n" + "="*60)
    print("🧪 测试 1：场景生成 Prompt")
    print("="*60)

    test_words = "anxious, commute, crowded, exhausted, commute, overwhelmed"
    test_user_prompt = f"""## 目标单词
{test_words}

## 用户背景
职业：互联网产品经理
兴趣：摄影、旅行
学习阶段：中级
其他偏好：喜欢真实感强的场景"""

    result = call_deepseek(system_prompt, test_user_prompt)

    # 分析结果
    analysis = {
        "input_words": [w.strip() for w in test_words.split(",")],
        "word_count": 0,
        "words_found": [],
        "words_missing": [],
        "has_second_person": False,
        "has_sensory_details": False,
        "has_underscore_format": False,
        "banned_words_found": [],
        "char_count": 0,
        "passed": False,
        "issues": []
    }

    if result["success"]:
        output = result["output"]
        analysis["char_count"] = len(output)
        analysis["raw_output"] = output

        # 检查第二人称
        analysis["has_second_person"] = "你" in output

        # 检查感官细节（关键词检测）
        sensory_keywords = ["看见", "闻到", "听到", "感觉到", "触摸", "品尝", "眼睛", "鼻子", "耳朵", "皮肤", "手心", "阳光", "雨水", "咖啡", "风"]
        analysis["has_sensory_details"] = any(kw in output for kw in sensory_keywords)

        # 检查下划线格式
        analysis["has_underscore_format"] = bool(re.search(r'___[\w\-]+___', output))

        # 检查词汇覆盖
        unique_words = list(set([w.strip() for w in test_words.split(",")]))
        for word in unique_words:
            pattern = re.compile(rf'___{re.escape(word)}___', re.IGNORECASE)
            if pattern.search(output):
                analysis["words_found"].append(word)
            else:
                analysis["words_missing"].append(word)
        analysis["word_count"] = len(analysis["words_found"])

        # 检查禁止字眼
        banned = ["单词", "背", "记忆", "学习", "请记住", "这个词", "这个单词"]
        for word in banned:
            if word in output:
                analysis["banned_words_found"].append(word)

        # 判断通过
        coverage = len(analysis["words_found"]) / len(unique_words) * 100
        analysis["coverage_rate"] = f"{coverage:.1f}%"
        analysis["passed"] = (
            coverage >= 80 and
            analysis["has_underscore_format"] and
            len(analysis["banned_words_found"]) == 0 and
            100 <= analysis["char_count"] <= 1000
        )

        if coverage < 80:
            analysis["issues"].append(f"词汇覆盖率不足: {coverage:.1f}%（需要≥80%）")
        if not analysis["has_underscore_format"]:
            analysis["issues"].append("未找到下划线标注格式（应为 ___word___）")
        if analysis["banned_words_found"]:
            analysis["issues"].append(f"发现禁止字眼: {analysis['banned_words_found']}")
        if analysis["char_count"] < 100:
            analysis["issues"].append("字数过少（<100字）")

    analysis["api_result"] = result
    return analysis


# ===================== 场景评估测试 =====================

def test_scene_evaluation(system_prompt: str, generated_scene: str) -> dict:
    """测试场景评估 Prompt"""
    print("\n" + "="*60)
    print("🧪 测试 2：场景评估 Prompt")
    print("="*60)

    test_words = "anxious, commute, crowded, exhausted, overwhelmed"
    test_user_prompt = f"""## 待评估场景正文
{generated_scene}

## 目标单词列表
{test_words}

请根据以上 4 个维度，对场景进行严格评估。"""

    result = call_deepseek(system_prompt, test_user_prompt)

    analysis = {
        "passed": False,
        "scores": {},
        "issues": []
    }

    if result["success"]:
        output = result["output"]
        analysis["raw_output"] = output

        # 尝试提取评分
        for dim in ["情感强度", "词汇覆盖率", "故事流畅度", "个人化程度"]:
            # 匹配 "情感强度 | X/10 | 10 | ✅/❌" 类似格式
            pattern = rf'{dim}.*?(\d+)'
            match = re.search(pattern, output)
            if match:
                analysis["scores"][dim] = match.group(1)

        # 判断通过（4项全部有评分）
        if len(analysis["scores"]) == 4:
            analysis["passed"] = True

    analysis["api_result"] = result
    return analysis


# ===================== 复习提示测试 =====================

def test_review_hint(system_prompt: str) -> dict:
    """测试复习引导 Prompt"""
    print("\n" + "="*60)
    print("🧪 测试 3：复习引导 Prompt")
    print("="*60)

    sample_scene = """那天加班到凌晨，你端着便利店买来的咖啡，推开公司大门。
冷风 ___anxious___ 扑面而来，你抬头，天空竟然飘着细细的雪。
地铁 ___commute___ 车厢里挤满了人，你 ___crowded___ 得几乎喘不过气，
一天的疲惫让你 ___exhausted___ 得不行，心里 ___overwhelmed___ 的情绪终于爆发。
你愣在原地，咖啡的香气混着冷空气，那一刻所有的情绪都被 ___治愈___ 了。"""

    test_user_prompt = f"""## 用户反馈
回忆不起来

## 原场景正文
{sample_scene}

## 用户点击"回忆不起来"的次数
第 1 次

## 目标单词（仅用于确认提示方向，**不要透露**）
anxious, commute, crowded, exhausted, overwhelmed

请根据以上信息，生成一条记忆提示。"""

    result = call_deepseek(system_prompt, test_user_prompt)

    analysis = {
        "passed": False,
        "gives_answer": False,
        "uses_hint": False,
        "issues": []
    }

    if result["success"]:
        output = result["output"]
        analysis["raw_output"] = output

        # 检查：是否直接给答案（禁止出现完整单词）
        target_words = ["anxious", "commute", "crowded", "exhausted", "overwhelmed"]
        for word in target_words:
            # 单词作为独立词出现（而非在提示词中提到）
            pattern = rf'(?<![a-zA-Z]){word}(?![a-zA-Z])'
            if re.search(pattern, output, re.IGNORECASE):
                analysis["gives_answer"] = True
                analysis["issues"].append(f"直接透露了单词: {word}")

        # 检查：是否使用了提示性语言
        hint_keywords = ["想象", "回想", "那个瞬间", "场景", "感觉", "当时", "那一刻", "试着"]
        analysis["uses_hint"] = any(kw in output for kw in hint_keywords)

        analysis["passed"] = not analysis["gives_answer"] and analysis["uses_hint"]

        if analysis["gives_answer"]:
            analysis["issues"].append("Prompt 失效：提示中直接出现了目标单词")

    analysis["api_result"] = result
    return analysis


# ===================== 提示层级渐进测试 =====================

def test_hint_progression(system_prompt: str) -> dict:
    """测试提示层级是否逐步具体"""
    print("\n" + "="*60)
    print("🧪 测试 4：提示层级渐进性")
    print("="*60)

    sample_scene = """你站在公司天台，夜风吹得你 ___exhausted___ 得不行。
加班一个月，项目还是 ___overwhelmed___ 了整个团队。
你想 ___commute___ 回家，但地铁已经停运了。"""

    test_cases = [
        {"次数": 1, "level": "Level 1（情感引导）"},
        {"次数": 2, "level": "Level 2（语境线索）"},
        {"次数": 3, "level": "Level 3（语义暗示）"},
    ]

    results = []
    for i, case in enumerate(test_cases):
        user_prompt = f"""## 用户反馈
回忆不起来

## 原场景正文
{sample_scene}

## 用户点击"回忆不起来"的次数
第 {case['次数']} 次

## 目标单词（仅用于确认提示方向，**不要透露**）
exhausted, overwhelmed, commute

请根据以上信息，生成一条记忆提示。"""

        result = call_deepseek(system_prompt, user_prompt)
        if result["success"]:
            results.append({
                "level": case["level"],
                "output": result["output"][:200]
            })
            print(f"\n--- {case['level']} ---")
            print(result["output"][:200])
        time.sleep(1)  # 避免 API 限流

    return {"progression_results": results}


# ===================== 主函数 =====================

def main():
    print("="*60)
    print("🚀 LinguaFlow AI Prompt 测试套件 v1.0")
    print("="*60)

    # 检查 API Key
    if not DEEPSEEK_API_KEY:
        print("\n⚠️  警告：DEEPSEEK_API_KEY 未设置")
        print("   测试将跳过 API 调用，仅验证 Prompt 文件结构。")
        print("   设置环境变量: export DEEPSEEK_API_KEY=your_key_here")
        print()

    # 检查 Prompt 文件
    required_files = [
        "scene_generation_prompt_v1.md",
        "scene_evaluation_prompt_v1.md",
        "review_hint_prompt_v1.md"
    ]
    print("📁 检查 Prompt 文件...")
    for filename in required_files:
        path = PROMPTS_DIR / filename
        if path.exists():
            print(f"   ✅ {filename}")
        else:
            print(f"   ❌ {filename} 未找到！")
            sys.exit(1)

    # 加载 Prompts
    generation_system = load_prompt("scene_generation_prompt_v1.md")
    evaluation_system = load_prompt("scene_evaluation_prompt_v1.md")
    hint_system = load_prompt("review_hint_prompt_v1.md")

    print(f"\n📋 Prompt 加载完成:")
    print(f"   场景生成: {len(generation_system)} chars")
    print(f"   场景评估: {len(evaluation_system)} chars")
    print(f"   复习提示: {len(hint_system)} chars")

    all_results = {
        "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
        "tests": {}
    }

    # 测试 1: 场景生成
    gen_result = test_scene_generation(generation_system)
    all_results["tests"]["scene_generation"] = gen_result

    if gen_result["api_result"]["success"]:
        output = gen_result["api_result"]["output"]
        print(f"\n📝 生成的场景预览（前500字）:\n{output[:500]}")
        print(f"\n📊 覆盖率: {gen_result.get('coverage_rate', 'N/A')}")
        print(f"   第二人称使用: {'✅' if gen_result.get('has_second_person') else '❌'}")
        print(f"   感官细节: {'✅' if gen_result.get('has_sensory_details') else '❌'}")
        print(f"   下划线格式: {'✅' if gen_result.get('has_underscore_format') else '❌'}")
        print(f"   字数: {gen_result.get('char_count', 0)}")
        if gen_result.get("banned_words_found"):
            print(f"   ⚠️ 禁止字眼: {gen_result['banned_words_found']}")
        if gen_result.get("words_missing"):
            print(f"   ⚠️ 未覆盖单词: {gen_result['words_missing']}")

        # 测试 2: 场景评估
        eval_result = test_scene_evaluation(evaluation_system, output)
        all_results["tests"]["scene_evaluation"] = eval_result

        if eval_result["api_result"]["success"]:
            print(f"\n📋 评估结果:\n{eval_result['raw_output'][:500]}")

    # 测试 3: 复习提示
    hint_result = test_review_hint(hint_system)
    all_results["tests"]["review_hint"] = hint_result

    if hint_result["api_result"]["success"]:
        print(f"\n💡 复习提示输出:\n{hint_result['raw_output']}")
        print(f"   直接给答案: {'❌ 是（违规）' if hint_result.get('gives_answer') else '✅ 否（合规）'}")
        print(f"   使用提示语言: {'✅ 是' if hint_result.get('uses_hint') else '❌ 否'}")

    # 测试 4: 提示层级渐进
    if DEEPSEEK_API_KEY:
        prog_result = test_hint_progression(hint_system)
        all_results["tests"]["hint_progression"] = prog_result

    # 保存结果
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(all_results, f, ensure_ascii=False, indent=2)
    print(f"\n💾 测试结果已保存到: {OUTPUT_FILE}")

    # 总结
    print("\n" + "="*60)
    print("📊 测试总结")
    print("="*60)
    passed = 0
    total = 0
    for name, result in all_results["tests"].items():
        total += 1
        status = "✅ 通过" if result.get("passed") else "⚠️ 需审查"
        print(f"   {name}: {status}")
        if result.get("passed"):
            passed += 1

    print(f"\n通过率: {passed}/{total}")
    print("\n✨ 测试完成！")

    return 0 if passed == total else 1


if __name__ == "__main__":
    sys.exit(main())
