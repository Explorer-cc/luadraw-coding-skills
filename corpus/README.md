# corpus/ — 三个来源的完整代码样例归档

仅存档，不需要编译。每个文件首行为来源注释。

| 子目录 | 来源 | 文件数 | 命名规则 |
|---|---|---|---|
| `luadraw-doc-en/` | 官方文档 `luadraw-v3.5/luadraw/doc/src/body-en/*.tex` 中的 demo/Luacode/TeXcode 完整代码块 | 122 | `<luadraw 的 name=>.tex`；模块级 Lua 块为 `module-*.lua` |
| `stackexchange/` | tex.stackexchange 用户 nidarfp（作者本人）全部 236 个回答中的代码块 | 281 | `a<回答id>-q<问题id>-s<票数>-b<块号>.<ext>` |
| `github-discussions/` | github.com/pfradin/luadraw/discussions 全部 246 个讨论中 pfradin 的评论代码块（673 条评论、410 个代码块） | 407 | `d<讨论号>-<标题slug>-c<评论id>-b<块号>.<ext>` |

扩展名约定（保证注释语法正确）：

- `.tex` — LaTeX/LuaLaTeX 文档或 luadraw 环境，头注释 `%`
- `.lua` — 纯 Lua 代码，头注释 `--`
- `.pov` — POV-Ray SDL，头注释 `//`
- `.obj` — Wavefront OBJ 数据，头注释 `#`
- `.txt` — 终端输出/纯文字说明，头注释 `#`
