[English](README_en.md)

# Claude Code Humanizer — 让 Claude Code 说人话的 output style

它让 Claude Code 像真实的人一样交流：直接、简单、容易理解。
没有学术化开场、没有晦涩的工程术语、没有大量 bullet 堆砌，也没有 “如果需要我可以继续展开” 这种机械式结尾。

它完整保留 Claude Code 原有的编码与 Agent 能力，包括工具调用、文件修改、测试、规划以及整个 Agent 循环。

它唯一改变的，只有 Claude 的说话方式。

本质就是一个 markdown 文件,放进 `~/.claude/output-styles/`。在会话开始时改写 Claude Code 的 system prompt,规则一次性烘焙进去,后续每轮都生效,不重复消耗 input token。

---

## 文件清单

- `plain.md` — output style 本体
- `install.sh` — 一键安装并设为全局默认
- `uninstall.sh` — 干净卸载
- `README_en.md` / `README_cn.md` — 英文版 / 中文版说明

---

## 从零开始(还没装 Claude Code?)

如果机器上还没装 Claude Code,先做下面三步。

### 1. 拿一个付费 Claude 账号

Claude Code 不包含在免费档里,需要下面任一种:

- **Claude Pro**($20/月)— 个人使用基本够用
- **Claude Max** — 高频用户,更高速率上限
- **Claude Team / Enterprise** — 团队账号
- **Anthropic Console + API credits** — 按量付费,API key 方式

### 2. 安装 Claude Code

官方从 2025 年 10 月起推荐使用 native installer,不依赖 Node.js,后台自动更新。

```bash
# macOS / Linux / WSL
curl -fsSL https://claude.ai/install.sh | bash

# Windows PowerShell
irm https://claude.ai/install.ps1 | iex

# Homebrew(macOS / Linux)
brew install --cask claude-code

# 旧 npm 方式(需要 Node.js 18+)
npm install -g @anthropic-ai/claude-code
```

验证:`claude --version` 应该返回版本号。如果提示 "command not found",关掉终端重开——installer 添加了 PATH,但当前 shell 还没刷新。

### 3. 首次登录认证

```bash
claude
```

会自动打开浏览器走 OAuth。登录 Claude 账号、授权 CLI、回到终端,就能开始用了。

如果用 Console API key 认证,首次启动流程里可以直接粘贴 key。

接下来继续看下面的「快速安装」。

---

## 快速安装

把所有文件放进同一目录,然后:

```bash
chmod +x install.sh && ./install.sh
```

脚本做两件事:

1. 复制 `plain.md` 到 `~/.claude/output-styles/plain.md`
2. 在 `~/.claude/settings.json` 写入 `"outputStyle": "plain"`(已有文件会备份成 `settings.json.bak`)

新开一个 Claude Code 会话,或者在现有会话里 `/clear`,新风格即生效。

## 手动安装

不想跑脚本的话:

```bash
mkdir -p ~/.claude/output-styles
cp plain.md ~/.claude/output-styles/
```

然后任选一种激活方式:

- **项目级**:在项目目录里打开 Claude Code,运行 `/output-style plain`。选择会写入该项目的 `.claude/settings.local.json`,只对这个项目生效。
- **全局默认**:在 `~/.claude/settings.json` 加上 `"outputStyle": "plain"`。所有新项目自动继承,除非项目级有自己的覆盖。

## 验证是否生效

在 Claude Code 里运行 `/output-style`,应该能看到 `plain` 处于激活状态。想直观验证行为,问一个开放性问题比如"解释一下依赖注入"——在 Plain 风格下,回答应该是 3–5 句散文,没有 markdown 标题、没有"很好的问题!"开场、没有结尾的"需要的话我可以详细展开"。

---

## `plain.md` 里都写了什么

每个规则段都是独立的——按需保留、修改、删除。文件由 YAML frontmatter 加若干规则段组成。

### Frontmatter

```yaml
---
name: Plain
description: Direct, concrete, no filler. ...
keep-coding-instructions: true
---
```

`keep-coding-instructions: true` 这行很关键。它告诉 Claude Code 把这个 style **叠加**在原本的编码指令之上——文件编辑、工具调用、测试验证这些行为全部保留。除非你想把 Claude Code 改造成非编程助手,否则别动这一行。

### Voice(语气定位)

设定角色:"资深工程师跟另一个工程师聊天,不是教科书。" 角色 framing 对 Claude 的隐式生成风格影响,比"请简洁一点"这类直接规则强得多。这是其他规则的地基,没有它,后面的规则力度都会打折。

### Banned openings(禁用开场白)

清掉"Great question"、"Let me"、"Certainly"、"You're right" 这类废话开头。这是可读性提升性价比最高的一条。如果你用 Claude Code 做教学或情感性场景(需要它先表达认同再回答),可以放宽这一段。

### Banned filler(禁用填充词)

一个 Claude 常用废词的黑名单:"fundamentally"、"essentially"、"leverage"(作动词)、"delve into"、"robust"、"holistic" 等等。Claude 偶尔会用同义词绕开黑名单——这条规则的作用是方向性引导,不是硬过滤——但整体废话密度会明显下降。

### Concrete before abstract(具体先于抽象)

影响的是推理结构,不是用词:先讲具体例子,再泛化。是"这个回答读起来像教科书"这类抱怨里单条最有效的规则。

### Prose by default(默认用散文)

抑制 Claude 把所有内容拆成 bullet 和嵌套标题的习惯。真正并列的内容(选项列表、步骤、条目)还是用 bullet,只是不再把本该是段落的东西拆成 bullet。

### Length matches stakes(篇幅匹配重要性)

阻止"每个回答都要有总结段"的反射。一行的问题给一行的回答。大问题该长还是长。

### Disagreement(分歧处理)

让 Claude 在你说错的时候直接说,不要用"你这个想法不错,不过..."开场。当你把 Claude Code 当 thinking partner 用、需要真实反馈的时候特别有用。

### Hedging(不确定性表达)

允许真正的不确定("我不确定"、"可能"),禁止反射式 hedge。"看情况"只在后面跟"看哪种情况"的时候才算有效回答。

---

## Output Styles 的工作原理

Claude Code 有三层机制影响它的行为:

| 层级 | 文件位置 | 作用范围 | 机制 |
|---|---|---|---|
| **Output style** | `~/.claude/output-styles/*.md` | 沟通风格、角色、格式 | 修改 system prompt |
| **CLAUDE.md** | `~/.claude/CLAUDE.md` 或 `<项目>/CLAUDE.md` | 项目规约、代码库事实 | 注入到 user-side memory |
| **Hooks** | `~/.claude/settings.json` 的 `hooks` 键 | 生命周期/工具事件 | 触发外部脚本 |

对于"改变沟通风格"这个具体目标,Output Style 是最对口的选择:

1. **System prompt 层级** — 比 user-side 上下文对 Claude 生成轨迹的拉力更强。Claude 是用教科书风格回答还是用同事风格回答,是在 token 0 之前就在它的自我设定里定死的。
2. **被缓存** — system prompt 命中 prompt caching,每轮零 token 成本。
3. **单文件** — 易于分享、版本管理、fork、替换。

技术上 hook 也可以在每条用户消息前注入风格提醒(`UserPromptSubmit` hook),但每轮都要重算 input token,拉力也更弱。Hook 适合做条件/动态注入(比如"当 prompt 里有 architecture 这个词时再加强一次"),不适合做默认机制。

---

## 自定义

直接编辑 `~/.claude/output-styles/plain.md`。下次会话启动或 `/clear` 之后生效。

常见修改:

- **放宽 banned openings** — 用 Claude Code 做教学或情感支持场景时,删掉这一段。
- **添加领域规则** — 追加一段 `## Project context` 描述特定领域的约定。但项目特定规则通常 `CLAUDE.md` 更合适——Output Style 是定义 Claude **怎么说话**的,不是 Claude **知道什么**的。
- **调整 voice** — 把"senior engineer talking to another engineer"换成更贴合你场景的角色:"Staff engineer reviewing a PR"、"tech lead in a standup"、"pair-programming partner"。角色 framing 是杠杆最大的旋钮。
- **增删 banned words** — 填充词列表是经验整理的、不完整。看到 Claude 总冒出来的词,自己加上。

改完之后,在现有 Claude Code 会话里跑 `/clear`,或者新开一个会话。Style 在会话启动时读一次、整个会话保持——会话进行中改文件不会立即生效。

---

## 切换风格

```
/output-style              # 交互式菜单,列出所有可用 style
/output-style plain        # 切换到 plain
/output-style default      # 恢复 Claude Code 内置默认风格
/output-style explanatory  # 内置:写代码时穿插教学性"Insights"
/output-style learning     # 内置:协作式,会让你自己写一部分代码
```

每次切换都会写入当前项目的 `.claude/settings.local.json`。用户级 `~/.claude/settings.json` 里的默认值,只对没设置过项目级 outputStyle 的项目起作用。

---

## 文件位置与优先级

设置在多层之间合并。对于 `outputStyle` 键,**列表越靠上优先级越高**:

1. `<项目>/.claude/settings.local.json` — 本地、不入版本控制(每项目、每机器)
2. `<项目>/.claude/settings.json` — 入版本控制(每项目、团队共享)
3. `~/.claude/settings.json` — 用户级全局默认
4. Claude Code 内置默认

安装脚本写入的是 (3)。`/output-style` 命令写入的是 (1)。如果某个项目里 style 死活切换不过去,先去检查那个项目的 `.claude/settings.local.json`——它会覆盖一切全局设置。

Style 文件本身(`plain.md`)可以放在 `~/.claude/output-styles/`(全局可用)或 `<项目>/.claude/output-styles/`(项目专属)。安装脚本默认放在用户级目录。

---

## 团队分享

三种行得通的模式:

- **Gist + curl** — 把 `plain.md` 和 `install.sh` 放到 gist 上,分享一行命令:`curl -fsSL <gist-raw>/install.sh | bash`。个人分发用这个。
- **内部仓库** — 把文件丢进 `dotfiles` 或 `engineering-tools` 仓库,在 team onboarding 文档里说明安装命令。
- **项目级团队默认** — 把 `.claude/settings.json` 和 `.claude/output-styles/plain.md` 提交到项目仓库。任何人 clone 后在该目录打开 Claude Code,自动用 Plain 风格。

团队级分发场景下,**保留 `keep-coding-instructions: true`**——这一行确保 Claude Code 编码行为不丢,几乎所有情况下都是你想要的。

---

## 卸载

```bash
chmod +x uninstall.sh && ./uninstall.sh
```

脚本做的事:

1. 删除 `~/.claude/output-styles/plain.md`
2. 如果安装脚本留过 `.bak` 备份,直接还原 `~/.claude/settings.json` 到安装前的样子
3. 没有备份的话,只摘掉 `outputStyle` 这一个键,其他配置原样不动
4. 如果 `outputStyle` 当前值不是 `plain`(说明你后来手动改成了别的),拒绝改动——避免误删用户的自定义

执行完 `/clear` 或新开会话即恢复默认风格。

手动卸载版本:

```bash
rm ~/.claude/output-styles/plain.md
# 然后编辑 ~/.claude/settings.json,删掉 "outputStyle" 那一行
```

---

## 故障排查

**没看出任何变化。** 是否 `/clear` 过或重开了会话?Output style 一个会话只读一次。

**`/output-style` 列表里看不到 Plain。** 文件不在 Claude Code 找的位置。检查 `ls ~/.claude/output-styles/`——应该有 `plain.md`。路径区分大小写。

**有些禁用词还是出现了。** 正常。黑名单是强方向引导,不是硬过滤。某个词反复出现的话,加一条更尖锐的规则(比如"Never write the word 'leverage' — use 'use' instead")。

**有些项目生效、有些不生效。** 检查不生效那个项目的 `.claude/settings.local.json`——里面 `outputStyle` 可能被设成了别的值,覆盖了全局默认。改这个文件,或者在那个项目里跑一次 `/output-style plain`。

**`settings.json` 被搞坏了。** 安装脚本留了备份在 `~/.claude/settings.json.bak`。还原:`mv ~/.claude/settings.json.bak ~/.claude/settings.json`。

**装完之后 Claude Code 起不来了。** 几乎一定是 `settings.json` 的 JSON 格式坏了。校验:`python3 -m json.tool < ~/.claude/settings.json`。修复,或从 `.bak` 还原。

**`claude --version` 提示 command not found。** PATH 没刷新。关掉终端开新的。还是不行的话,installer 日志会写明 binary 装在哪——通常是 `~/.local/bin/claude`。

---

## 备注

- **install.sh / uninstall.sh 仅支持 macOS / Linux。** Windows 用户:走 WSL,或者用 PowerShell 手动跑安装步骤,把路径改成 `$HOME\.claude\...`。
- **多语言。** Style 文件本身是英文写的,但 Claude 跟随用户输入的语言。中文输入,中文输出。规则照样生效。
- **更新。** 拿到新版 `plain.md` 重新跑一次 `./install.sh` 即可——它会覆盖旧的 style 文件并重新确认 settings。
- **可与其他 style 共存。** `~/.claude/output-styles/` 里可以放任意多个 `.md` 文件,用 `/output-style` 切换。Plain 不会干扰其他 style。
- **不要随便删掉 `keep-coding-instructions: true`。** 删了之后 Claude Code 会丢掉内置的编码行为,完全依赖这个文件描述的指令——单凭这个文件不足以让它当一个合格的编码助手。
