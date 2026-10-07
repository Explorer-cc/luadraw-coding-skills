# Luadraw coding skill

Luadraw coding skill `v0.1.0`：面向 Luadraw v3.5 的 LuaLaTeX 2D/3D 绘图、几何构造、可见性、动画和扩展模块。

## 目录

```text
skills/luadraw-coding/
├── SKILL.md                         # skill入口
├── VERSION                          # 0.1.0
├── README.md                        # skill内部说明
├── LICENSE                          # MIT License(与仓库根目录相同)
├── luadraw-coding-guide-en.md       # 完整英文指南(与仓库根目录副本一致)
├── examples/
│   ├── minimal-2d.tex               # 最小LuaLaTeX示例
│   └── glass-box-3d.tex             # 3D声明式场景示例(Classifyfacet + g:Shift)
├── references/                      # 按主题拆分的操作参考(01-05,05为全语料技巧索引)
└── scripts/
    └── check-skill.lua              # 结构与元数据检查
```

skill 目录自包含：引导文档和许可证的副本就在 `skills/luadraw-coding/` 内。仓库根目录的
`luadraw-coding-guide-en.md` 是源文件，修改后需要复制到 skill 目录，两份必须逐字节一致：

```bash
cp luadraw-coding-guide-en.md skills/luadraw-coding/luadraw-coding-guide-en.md
```

`skills/luadraw-coding/` 是供 agent 加载的操作层，完整指南是它的参考附件。

## 1. 发布仓库 README

本文件是仓库级发布说明。发布到 GitHub 或其他 Git 服务时，至少发布以下内容：

- `skills/luadraw-coding/`；
- `LICENSE`；
- `README.md`；
- `luadraw-coding-guide-en.md`；
- `assets/`（如果希望保留案例检索能力）。

建议发布标签：

```text
v0.1.0
```

当前版本尚未自动创建 Git tag；创建发布版本时执行：

```bash
git add .
git commit -m "Release Luadraw coding skill 0.1.0"
git tag -a v0.1.0 -m "Luadraw coding skill v0.1.0"
```

## 2. 版本号

版本号同时记录在：

```text
skills/luadraw-coding/VERSION
skills/luadraw-coding/SKILL.md  # front matter: version: 0.1.0
```

`0.1.0` 表示第一版可用 skill：入口、主题参考、验证脚本和最小示例已经具备，但 API 覆盖和独立打包流程仍可能继续扩展。

## 3. License

skill 自身使用 MIT License，许可证文件为：

```text
LICENSE
```

注意：Luadraw v3.5 源码、官方文档、第三方案例和资产可能分别拥有各自的版权或许可证。发布时不要把它们默认表述为本 skill 的原创内容；需要遵守对应来源的许可和署名要求。

## 4. Luadraw v3.5 依赖

skill 面向 Luadraw v3.5，编译示例需要：

- LuaLaTeX；
- `luadraw.sty`；
- Luadraw v3.5 的 Lua 模块；
- TikZ、`xcolor`、`luacode` 等 TeX 依赖。

skill 不打包 Luadraw 源码和手册，而是从 TeX 安装中读取：`kpsewhich luadraw.sty` 给出 Luadraw 源码目录，
手册位于同一 TeX 树的 `doc/lualatex/luadraw/`。`luadraw.sty` 必须声明 version 3.5。

仓库中的 `luadraw-v3.5/` 被 `.gitignore` 忽略，只是本地可选的源码副本，skill 不依赖它。
如需用它编译示例，见第 6 节的 `TEXINPUTS` 写法。

## 5. 安装与独立路径

### 从完整 Git 仓库使用

```bash
git clone <repository-url>
cd luadraw-skills
```

将 agent 的 skill 搜索目录指向：

```text
<repository>/skills/
```

入口文件是：

```text
<repository>/skills/luadraw-coding/SKILL.md
```

### 只安装 skill 目录

复制 `skills/luadraw-coding/` 即可，不需要仓库的其他内容。该目录内所有链接都指向目录内部，
`scripts/check-skill.lua` 会检查这一点。`assets/` 语料库是可选的，不随 skill 分发；
文档中出现的 `assets/...` 文件名只是来源标注，存在时才读取。

完整指南沿用上游仓库布局的路径（`luadraw-v3.5/luadraw/files/`、`assets/`），
`SKILL.md` 的 Resources 一节给出了到 TeX 安装的映射。

### ZIP 安装

打包时应保证解压后结构为：

```text
<skills-root>/luadraw-coding/SKILL.md
```

不要产生多余的嵌套目录：

```text
<skills-root>/luadraw-coding/luadraw-coding/SKILL.md  # 错误示例
```

## 6. 最小可运行示例

示例文件：

```text
skills/luadraw-coding/examples/minimal-2d.tex
skills/luadraw-coding/examples/glass-box-3d.tex
```

在完整仓库根目录执行：

```bash
mkdir -p build/minimal-2d
lualatex -interaction=nonstopmode -halt-on-error \\
  -output-directory=build/minimal-2d \\
  "$(pwd)/skills/luadraw-coding/examples/minimal-2d.tex"
```

上述命令使用 TeX Live 中已安装的 Luadraw。若使用仓库中被 `.gitignore` 忽略的本地 v3.5 源码，在 Git Bash 中设置本地 TeX 搜索路径：

```bash
TEXINPUTS="$(pwd)/luadraw-v3.5/luadraw/files//;" \\
  lualatex -interaction=nonstopmode -halt-on-error \\
  -output-directory=build/minimal-2d \\
  "$(pwd)/skills/luadraw-coding/examples/minimal-2d.tex"
```

Windows PowerShell 可使用：

```powershell
$env:TEXINPUTS = "$(Get-Location)\luadraw-v3.5\luadraw\files\;$env:TEXINPUTS"
lualatex -interaction=nonstopmode -halt-on-error `
  -output-directory=build/minimal-2d `
  skills/luadraw-coding/examples/minimal-2d.tex
```

示例应生成：

```text
build/minimal-2d/minimal-2d.pdf
```

## 7. 安装后的验证

### 结构验证

```bash
lua skills/luadraw-coding/scripts/check-skill.lua
```

预期输出：

```text
Luadraw skill layout: OK
```

### Lua 语法验证

```bash
luac -p skills/luadraw-coding/scripts/check-skill.lua
```

### 示例编译验证

```bash
lualatex -interaction=nonstopmode -halt-on-error \
  -output-directory=build/minimal-2d \
  skills/luadraw-coding/examples/minimal-2d.tex
```

### Agent 触发验证

安装后发送一个明确使用 Luadraw v3.5 的请求，例如：

```text
用 Luadraw v3.5 创建一个 LuaLaTeX 2D 圆和半径示例，
给出完整可编译代码，并说明使用的 API 和验证命令。
```

合格的响应应能够：

1. 识别 LuaLaTeX 和 Luadraw v3.5；
2. 使用 `local ld = luadraw` 和现有 API；
3. 给出完整的 `luadraw` 环境；
4. 避免凭空发明 API；
5. 说明实际执行的验证。

## 维护

修改 Luadraw API、案例或完整指南时：

1. 先更新根目录 `luadraw-coding-guide-en.md`；
2. 再更新对应的 `references/` 文件；
3. 只有入口规则变化时才更新 `SKILL.md`；
4. 运行结构检查、Lua 检查和受影响的 LuaLaTeX 示例；
5. 发布新版本时同步更新 `VERSION`、SKILL front matter 和 Git tag。
