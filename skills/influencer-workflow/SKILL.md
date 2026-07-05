---
name: influencer-workflow
description: Influencer book 项目完整工作流 — 新增/修改条目、更新索引、构建验证、提交的端到端流程
---

# Skill: 完整工作流 — Influencer Book 项目

本 Skill 定义了在本项目（influencer book — mdbook 知识库）中的**完整端到端工作流**。处理任何任务时，按以下阶段依次执行，不要跳过。

---

## 第 1 阶段：需求分析与探索

1. **明确任务**：搞清楚要做什么——新增条目、修改现有条目、批量操作、还是其他。
2. **查阅现有条目**：在 `src/{首字母}/` 下找同名文件确认是否已存在。
3. **查阅 `src/_meta/list.yaml`**：确认条目是否已在索引中。
4. **查阅同类条目**：找到与目标人物同分类/同标签的现有条目，参考其格式与字段。
5. **身份验证（重要）**：用户提供的社交账号（如 `ig@xxx`、`x@xxx`），必须从**该平台本身**获取真实身份信息。
   - **严禁**：仅凭相似用户名就跨平台推定是同一人（如 `ig@babbyang.g` ≠ `x@babbyangg`）
   - 信息不足时，向用户确认人物真实姓名或更多线索

### 信息获取方法（按成功率排序）

| 平台 | 方法 | 成功率 |
|------|------|--------|
| **Instagram** | **① `https://search.brave.com/search?q={username}+instagram`** → 提取简介/粉丝 | ✅ 高 |
| | **② 聚合页：`linktr.ee/{username}` / `linkbio.co/{username}` / `beacons.ai/{username}` 等** → 详见 [linktree.md](/linktree.md) | ✅ 高（如有） |
| | ③ Puppeteer：访问 `instagram.com/{username}/` → 可提取公开资料 | ⚠️ 中（受登录墙影响） |
| | ❌ 第三方查看器（imginn、dumpoir、instasave）→ 被 Cloudflare 拦截 | ❌ 低 |
| **Threads** | `threads.net/@{username}` → 直接查看公开资料 | ✅ 高 |
| **X/Twitter** | Nitter RSS：`nitter.net/{handle}/rss` → 提取显示名/推文 | ✅ 高 |
| **한국 (韩国)** | **`https://namu.wiki/w/{한글명}`** → 详细百科（平台/身体/经历/获奖） | ✅ 非常高 |
| **其他** | Brave Search 搜 `{username}` → 发现更多平台关联 | ✅ 中 |

> **实践验证**：`ig@babbyang.g` 通过 Brave Search 找到 Linktree → 从中发现 YouTube、TikTok、Spotify、Threads、音乐作品等全部平台。Instagram 第三方查看器均因 Cloudflare 不可用。韩国人物优先查 namu.wiki，信息非常详尽（平台数据、身体尺寸、参赛经历、人际关系等）。

## 第 2 阶段：创建/编辑条目文件

### 文件位置规则
- **中文名**：取拼音首字母作为目录（如 艾小青 → A/）
- **日文名**：取平假名读音首字母作为目录（如 沢地優佳（さわち）→ S/）
- **韩文名**：取韩文读音首字母作为目录（如 李孝利（이효리）→ L/）
- **英文名**：取首字母作为目录（如 Ariana Grande → A/）
- 文件路径：`src/{首字母}/{人物名}.md`
- 同名人物加区分后缀。

### 文件格式模板

```markdown
---
tags: [分类]
---

# 人物名

## 简介

一句话简介。

## 基本信息

| 属性 | 值 |
|------|-----|
| 分类 |  |
| 地区 |  |
| Instagram | @xxx |

## 参考资料

- Instagram: https://instagram.com/xxx
- 百科: https://namu.wiki/w/xxx
```

### 字段规范
- **分类**：使用一级标签。可选值：`演员`、`模特`、`歌手`、`偶像`、`声优`、`Coser`、`网红`、`グラビアアイドル` 等。
- **tags** 数组：前端 `---` 中的 tags 列表，仅包含一个分类标签。
- **地区**：按实际地区填写（大陆、台湾、日本、韩国、美国等）。
- **参考资料**：条目底部必须附 `## 参考资料` 章节，列出信息来源的链接（社交平台、百科、新闻、报道等），每行 `- 平台: URL` 格式。

## 第 3 阶段：更新索引 `src/_meta/list.yaml`

在 `list.yaml` 的 `entries` 列表中按**语言对应的音序**插入新的条目记录（各语言按自身音序排列，跨语言时按首字母/音整体排序）：

- **中文名** → `reading` 填拼音，按拼音顺序排列
- **日文名** → `reading` 填平假名（ひらがな），按五十音順排列
- **韩文名** → `reading` 填韩文（한글），按가나다순排列
- **英文名** → `reading` 留空，按英文字母顺序排列

```yaml
- name: 人物名
  reading: ''  # 中文填拼音 / 日文填平假名 / 韩文填韩文
  path: {首字母}/{人物名}.md
  tags:
  - 分类
  completeness: 83
```

> **注意**：必须插入到正确的音序位置，保持列表有序。

## 第 4 阶段：构建验证

`src/_tags/` 目录已列入 `.gitignore`（本地标签索引，不受版本控制），无需关注。只需确保条目文件的 `tags` frontmatter 正确即可。

运行以下命令确保项目无误：

```bash
mdbook build
```

检查是否有任何错误或警告。如有问题则修复。

## 第 5 阶段：提交与推送

提交信息应遵循以下格式：

- **新增条目**：`Add profile for {人物名}`
- **修改条目**：`Update {人物名}: {修改摘要}`
- **批量操作**：`Add {N} profiles: {范围说明}`

提交步骤：
```bash
git add src/{对应文件}
git commit -m "{提交信息}"
```

## 通用原则

- **保持文件有序**：list.yaml 按语言自身音序排列（中文→拼音、日文→五十音順、韩文→가나다순、英文→字母）。
- **不破坏已有数据**：编辑现有文件时，只增不改原有内容结构。
- **文件编码**：UTF-8，换行符 LF。
- **保持最小变更**：只修改与任务直接相关的文件。
