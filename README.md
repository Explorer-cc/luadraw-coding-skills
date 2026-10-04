# Luadraw coding skill

Luadraw coding skill `v0.1.0`：面向 Luadraw v3.5 的 LuaLaTeX 2D/3D 绘图、几何构造、可见性、动画和扩展模块。

## 目录

```text
skills/luadraw-coding/
├── SKILL.md                         # skill入口
├── VERSION                          # 0.1.0
├── README.md                        # skill内部说明
├── LICENSE                          # MIT License
├── examples/
│   └── minimal-2d.tex               # 最小LuaLaTeX示例
├── references/                      # 按主题拆分的操作参考
└── scripts/
    └── check-skill.lua              # 结构与元数据检查
```

完整的原始英文指南仍保留在仓库根目录：

```text
luadraw-coding-guide-en.md
```

该文件是完整参考文档；`skills/luadraw-coding/` 是供 agent 加载的精简操作层。两者职责不同，避免把整篇长文直接作为每次调用的入口。

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

仓库中的 `luadraw-v3.5/` 被 `.gitignore` 忽略，不会因为普通 Git 提交自动发布。使用完整仓库时，应自行把 Luadraw v3.5 放到：

```text
luadraw-v3.5/luadraw/files/
```

如果使用系统 TeX Live 安装的 Luadraw，则不需要该本地目录；只要 `luadraw.sty` 和 Luadraw Lua 模块能被 LuaLaTeX 找到即可。

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

复制以下目录即可获得基本 skill 入口：

```text
skills/luadraw-coding/
```

但当前参考页中的路径是按完整仓库布局写的，例如：

```text
../../luadraw-coding-guide-en.md
../../assets/
../../luadraw-v3.5/
```

因此，若只复制 skill 目录，需要同时满足以下任一条件：

1. 保持它位于完整仓库的 `skills/` 下；
2. 将 `luadraw-coding-guide-en.md`、精选 `assets/` 和所需 Luadraw 源码复制到对应相对路径；
3. 将引用改写为安装包内部路径。

当前版本推荐使用方式 1，即从完整仓库加载。

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
