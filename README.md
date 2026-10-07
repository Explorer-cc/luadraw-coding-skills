# luadraw-skills

面向 Luadraw v3.5 的 agent skill：LuaLaTeX 2D/3D 绘图、几何构造、可见性、动画和扩展模块。

当前版本 `0.1.0`，变更见 [CHANGELOG.md](CHANGELOG.md)。

## 仓库结构

```text
luadraw-skills/
├── skills/luadraw-coding/     # skill 本体，自包含，可单独复制分发
│   ├── SKILL.md               # 入口；版本号只写在 front matter
│   ├── LICENSE
│   ├── references/            # 00 为完整英文指南，01-05 为按主题拆分的操作参考
│   ├── examples/              # 可编译的 LuaLaTeX 示例
│   └── scripts/check-skill.lua
├── docs/
│   ├── guide-cn.md            # 中文指南
│   ├── guide-en.md            # 英文指南，与 skill 内 references/00-guide-en.md 逐字节一致
│   └── maintaining.md         # 维护、验证、发布流程(英文)
├── corpus/                    # 可选的案例语料库(不随 skill 分发)
├── CHANGELOG.md
└── LICENSE
```

## 安装

把 agent 的 skill 搜索目录指向 `skills/`，或只复制 `skills/luadraw-coding/`。
解压或复制后的结构必须是 `<skills-root>/luadraw-coding/SKILL.md`，不要多嵌套一层。

skill 目录内所有链接都指向目录内部。`corpus/` 是可选的，文档里出现的 `corpus/...`
文件名只是来源标注，存在时才读取。

## 依赖

- LuaLaTeX
- Luadraw v3.5(`kpsewhich luadraw.sty` 必须能找到，且声明 version 3.5)
- TikZ、`xcolor`、`luacode`

skill 不打包 Luadraw 源码和手册，而是从 TeX 安装中读取。

## 快速验证

```bash
lua skills/luadraw-coding/scripts/check-skill.lua
```

预期输出 `Luadraw skill layout: OK`。示例编译和发布流程见 [docs/maintaining.md](docs/maintaining.md)。

## License

skill 自身使用 MIT License，见 [LICENSE](LICENSE)。Luadraw 源码、官方文档和第三方案例各自拥有
版权或许可证，`corpus/` 中的内容需遵守对应来源的许可和署名要求。
