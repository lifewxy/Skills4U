---
name: sketch-image-prompt
description: Transforms article content or summaries into minimalist hand-drawn style JSON prompts for AI image generation tools. Use this skill whenever the user wants to create any kind of visual from text content — including banners, article illustrations, inline diagrams, infographics, or concept visuals. Trigger on requests like "turn this into a visual", "create an image prompt", "make an illustration for this", "generate a diagram from this article", "I need a sketch for this section", or any request combining content analysis with image/visual prompt generation. Always use this skill when the user provides text content and wants an AI-ready image prompt output.
license: MIT
allowed-tools: visualize:show_widget, visualize:read_me
compatibility: Requires visualize tools for color palette widget display. Compatible with Midjourney, Stable Diffusion, and any AI image generation tool that accepts natural language prompts.
metadata:
  version: "1.3.0"
  created: "2026-03-01"
  updated: "2026-05-04"
  author: Boss
  changelog:
    - version: "1.3.0"
      date: "2026-05-04"
      changes: "Hardened layout rules to prevent single-axis compression. Added prominent warning, decision tree, and pre-generation self-check. Demoted linear flow layouts to require ≥4 elements with strong sequence. Template now mandates explicit spatial positioning per element and enforces 'elements distributed across full canvas, NOT a single line' clause."
    - version: "1.2.1"
      date: "2026-05-04"
      changes: "Fully purged mint green tones — removed 嫩草 #F1F8E9 from the palette (visually a pale mint) and fixed the leftover '薄荷绿背景' example in the design summary template. Palette reduced from 14 to 13 backgrounds."
    - version: "1.2.0"
      date: "2026-03-19"
      changes: "Expanded layout system from single linear flow to 5 spatial modes per ratio (linear, satellite, zone, diagonal, quadrant). Added layout selection principles to prevent vertical whitespace waste."
    - version: "1.1.0"
      date: "2026-03-18"
      changes: "Removed mint green preset. Expanded color palette to 14 backgrounds covering tech, business, creative, education, nature, and brand themes."
    - version: "1.0.0"
      date: "2026-03-01"
      changes: "Initial release. Minimalist hand-drawn prompt generator with aspect ratio selection and 5 color presets."
---

# Sketch Image Prompt

将文字内容转化为极简手绘风格图像提示词，供 Midjourney、Stable Diffusion 等 AI 绘图工具直接使用。

## 工作流程

### 第一步：询问尺寸比例

用户提供内容后，**必须先询问尺寸比例**，再进行分析：

> "请问这张图的尺寸比例是？
>
> 横屏：
> - **16:9** — 横向展示 / Twitter / 社交媒体
> - **5:2** — 博客头图 / 宽幅横图
> - **21:9** — 微信公众号封面 / 超宽幅
> - **4:3** — 通用横图 / 演示文稿
> - **1:1** — 方形 / Instagram / 头像配图
>
> 竖屏：
> - **9:16** — 手机全屏 / Story / 竖版海报
> - **2:5** — 竖版长图 / 手机壁纸
> - **9:21** — 竖版超长图 / 手机长截图
> - **3:4** — 竖版通用图 / 小红书"

### 第二步：内部分析（不输出给用户）

在脑中完成以下分析，**不要输出这个过程**：

- 提炼核心主题（1个最核心的概念）
- 筛选关键元素（只选 **3-5个**，宁少勿多）
- 识别元素关系（流程 / 对比 / 层级 / 循环 / 并列）
- 判断情感基调 → 推断配色
- 根据比例选择最优布局，**严禁单线挤压构图**——元素必须在水平和垂直两个轴向上都有分布

**配色参考：**

| 主题类型 | 背景色建议 |
|---------|-----------|
| 技术/开发 | 天空蓝 `#E3F2FD`、浅青 `#E0F7FA`、靛蓝雾 `#E8EAF6` |
| 商业/金融 | 暖米色 `#F5E6D3`、桃橙 `#FFDAB9`、琥珀奶 `#FFF3E0` |
| 创意/设计 | 薰衣草 `#E6E6FA`、玫瑰雾 `#FFE4E1`、紫罗兰 `#EDE7F6`、樱花粉 `#FCE4EC` |
| 教育/知识 | 奶油黄 `#FFF9E3`、黄油 `#FFFDE7` |
| 品牌/温暖 | 珊瑚 `#FBE9E7` |
| 通用/中性 | 暖米色 `#F5E6D3` |

**布局参考：**

⚠️ **核心铁律：禁止单线挤压**

宽图（16:9 / 5:2 / 21:9 / 4:3）所有元素水平一字排开，或竖图（9:16 / 2:5 / 9:21 / 3:4）所有元素垂直一字堆叠——这两种"单轴布局"会导致：

- 元素被迫缩小（垂直/水平方向只占画布 30%）
- 上下或左右出现大片空白（每边浪费 30-35%）
- 关键图标看不清，表达不清晰

**只要元素 ≤ 4 个，几乎从不应该用纯单轴布局。**正确做法是让元素**同时在两个轴向上分布**——主角放大占据一侧，配角错落分布另一侧的不同高度／宽度位置。

| 比例 | 推荐布局（按填充优先级排序，⭐ 优先选） | 元素上限 |
|------|------------|---------|
| 16:9 | ⭐ 主角居左放大（占左 1/3 高度近满）+ 配角散布右侧上下两层 / ⭐ 对角线构图（左上→右下，元素错落）/ ⭐ 四象限布局（4 个元素各占一角，标题居中）/ ⭐ 左重右轻分区（大元素占左 1/3，右侧 2/3 分上下）/ 水平流程（**仅当元素 ≥ 4 且强顺序关系**） | 5个 |
| 5:2  | ⭐ 主角居左放大 + 右侧分上下两层 / ⭐ 三段错落（每段元素垂直位置不同，避免一条直线） | 5-6个 |
| 21:9 | ⭐ 三段分区 + 每段内部上下错位 / ⭐ 辐射构图（中心放射） | 4个 |
| 4:3  | ⭐ 主角居中 + 卫星散布四周 / ⭐ 对角线构图 / 左右分区 | 5个 |
| 1:1  | ⭐ 居中辐射型 / ⭐ 四象限 / 居中对称 | 4个 |
| 9:16 | ⭐ 主角居上放大 + 下方多元素左右并排 / ⭐ 错落堆叠（左右交替偏移，破直线感）/ 垂直分层（**仅当元素 ≥ 4 且强顺序关系**） | 5个 |
| 2:5  | ⭐ 错落分层（左右交替偏移） / ⭐ 主角居上 + 下方分组并排 | 5-6个 |
| 9:21 | ⭐ 错落分层 + 左右交替偏移 / 分段构图 | 6个 |
| 3:4  | ⭐ 主角居上 + 卫星左右下散布 / ⭐ 错落分层 | 5个 |

**布局选择决策树：**

1. 元素只有 **3 个或更少** → **强制使用主角+卫星 / 对角线 / 错落分层**，禁止单轴排列
2. 元素 **4 个以上** + 强顺序关系（步骤 1→2→3→4）→ 才能考虑流程型，但仍优先错落形式
3. 一个明显主角 + 多个配角 → 主角放大居一侧 + 配角散布另一侧不同高度
4. 多个等重元素 → 四象限 / 多区分布 / 对角线
5. 循环关系 → 辐射 / 环形

**自检标准（生成前必须确认）：**

- [ ] 元素是否分布在画布的"上中下"至少两层？（宽图必查）
- [ ] 元素是否分布在画布的"左中右"至少两区？（竖图必查）
- [ ] 是否有任何一个元素位于画布边角（不只是中线）？
- [ ] 主角是否被放大到至少占画布短边的 30% 以上？

**任何一项答 No，重新选布局。**

### 第三步：输出给用户

**只输出以下两部分，不输出其他任何内容：**

```
[一行设计摘要：背景色 + 构图类型 + 元素数量，例如：暖米色背景，水平三步流程，3个元素]

[final_prompt 正文]
```

---

## Final Prompt 规范

### 必须包含的内容

1. **比例参数**（根据工具格式）
   - Midjourney：结尾加 `--ar 16:9`（或对应比例）
   - 通用描述：开头写 `16:9 horizontal composition` 或 `9:16 vertical composition`
   - 默认同时写通用描述 + Midjourney 参数，兼容两种工具

2. **视觉风格**（固定不变）：
   - `minimalist hand-drawn illustration`
   - `bold marker illustration, chunky brush-pen style`
   - `very thick black outlines, heavy stroke weight, bold chunky lines like a childrenΓÇÖs book illustration`

3. **笔触质感**（必须详细描述）：
   - `dry brush texture with tiny gaps in ink coverage`
   - `organic slightly rough edges`
   - `natural line weight variation but always heavy and bold`
   - `imperfect circles and slightly wobbly lines`
   - `warm handmade feel, NOT perfect vector lines, NOT thin lines — bold chunky strokes only`

4. **配色**：背景色（含色号）+ `black #000000` 主色 + 强调色（如有）

5. **构图与元素**：
   - 布局方式 + 每个元素的视觉描述 + 连接方式
   - **每个元素必须带显式空间位置**（如 `upper-left`、`center-right`、`bottom-center`、`occupying left 1/3`）
   - 必须包含 `elements distributed across full canvas area, occupying both horizontal and vertical space, NOT compressed to a single line`
   - 主角元素必须显式放大：`main subject enlarged, taking 30%+ of canvas`

6. **简洁性关键词**：
   - `minimalist`, `extremely simple`, `clean`, `uncluttered`
   - `generous whitespace`, `only 3-5 elements total`
   - `minimal text`, `1-3 words per label`

7. **排版**：`rounded handwritten-style font, casual and friendly`

### Final Prompt 模板结构

```
[比例] [构图类型] composition. Elements distributed across the FULL canvas area, occupying both horizontal AND vertical space, NOT compressed to a single horizontal/vertical line. [背景色描述]. Only [N] elements with explicit spatial positioning: [元素1描述 + 位置如"on the upper-left"], [元素2描述 + 位置如"enlarged in the center taking 35% of canvas"], [元素3描述 + 位置如"on the lower-right"]. [连接方式描述]. Bold marker illustration, chunky brush-pen style, very thick black outlines with heavy stroke weight — like a fat-tipped marker, bold chunky lines. Dry brush texture with tiny gaps in ink coverage, organic slightly rough edges, natural line weight variation, imperfect circles and slightly wobbly lines, warm handmade feel — NOT perfect vector lines. [配色描述]. Minimal text labels only: [标签列表]. Generous whitespace BUT well-distributed (no large empty bands at top/bottom or left/right), clean and uncluttered, flat illustration with no shadows or gradients, rounded handwritten-style font. --ar [X:Y]
```

**关键差异（务必区分）：**
- ✅ `generous whitespace BUT well-distributed` — 留白要均匀分布在元素之间
- ❌ `generous whitespace` 单独使用 — 会被理解成"画布上下/左右大片空白也行"

## 语言规则

- 设计摘要跟随用户语言
- `final_prompt` **始终使用英文**
