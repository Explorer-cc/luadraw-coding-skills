# luadraw 代码风格与实战技巧（面向 assets 全量语料）

> **语料**：`assets/` 下三组完整代码，共 816 个文件，本文不区分来源、直接面向全部代码归纳：
> `assets/luadraw-doc-en/`（125 个）、`assets/stackexchange/`（281 个）、`assets/github-discussions/`（410 个）。
> 命名/索引规则见 `assets/README.md`。文中链接均为仓库相对路径，`文件:行` 指代码在文件中的行号（首行为来源注释）。
> 本文规范与示例代码一律按 **v3.5 API** 书写；引用文件仅作思路与出处。

## 1. Agent 八荣八耻

以暗猜接口为耻，以认真查阅为荣。
以模糊执行为耻，以寻求确认为荣。
以盲想业务为耻，以人类确认为荣。
**以创造接口为耻，以复用现有为荣。**
以跳过验证为耻，以主动测试为荣。
以破坏架构为耻，以遵循规范为荣。
以假装理解为耻，以诚实无知为荣。
以盲目修改为耻，以谨慎重构为荣。

> 工程取向一句话：**以简化、复用代码为荣，以过度设计、自己造轮子为耻**。以下全部章节都是这条的展开。

## 2. 参考代码示例（语料导读）

| 目录                           | 内容                                                                                                                                                                                                                                                    | 怎么用                                                    |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| `assets/luadraw-doc-en/`     | 官方手册全部 demo（`champ.tex`、`orthocentre.tex`、`Dandelin.tex`、`torus.tex`、`palettes.tex`、`Pythagore.tex`…）以及扩展模块完整源（`module-*.lua`，如 `module-luadraw-doc2d-en-section-81.lua` 是 `luadraw_fields.lua` 的教学版） | 每个文件的名称即`luadraw` 的 `name=`，按主题检索      |
| `assets/stackexchange/`      | 作者在 tex.stackexchange 的 236 个回答、281 个代码块                                                                                                                                                                                                    | `a<回答>-q<问题>-s<票数>-b<块>.tex`，票数排序即质量排序 |
| `assets/github-discussions/` | 官方 Discussions 246 帖中作者的 410 个代码块                                                                                                                                                                                                            | `d<帖号>-<标题>-c<评论>-b<块>.tex`                      |

入门路线建议：`champ.tex`（2D 骨架）→ `orthocentre.tex`（几何构造）→ `assets/luadraw-doc-en/torus.tex`（rotcurve+addWall，渲染路线决策的浓缩）→ `d137-*-c14894434-b1.tex`（多视图+GIF）。

官方手册呈现示例的规范（写文档时照抄）：代码用 minted 列出 + 图 + `\captionof{figure}` + `\label`；API 描述固定为"签名行（可选参数 `[...]`）→ 逐选项 `option=default` → 返回值形状"；陷阱用加粗 **WARNING/Caution/NB** 段。

## 3. 固定骨架模板

几乎所有代码都是同一副骨架，写示例不应偏离：

```latex
\documentclass[border=5pt]{standalone}% compile with lualatex only   ← 引擎提醒
\usepackage[svgnames]{xcolor}                                        ← 颜色前提
\usepackage[3d]{luadraw}                                             ← 2 去掉 3d
\usepackage{fourier-otf}                                             ← 默认字体
% <问题/来源链接注释；引用他人代码加 Source/Posted by/License 头>
\begin{document}
\begin{luadraw}{name=有语义的图名}          -- 1. name 必写；重算贵的图配 exec=true
local ld = luadraw                        -- 2. 开场白（见 §4）
local g = ld.graph3d:new{ window3d=..., size={10,10}, viewdir={30,60} }  -- 3. 建图，对象叫 g、local
local f = function(t) ... end             -- 4. 数学定义（匿名 local）
local S = ld.surface(f, ...)              -- 5. 几何计算（纯 ld.*）
g:Dboxaxes3d{grid=true}                   -- 6. 绘制（画家顺序）
g:Dfacet(S, {usepalette={ld.palRainbow,"z"}})
g:Show()                                  -- 7. 收尾永远是 Show()（或 Save()）
\end{luadraw}
\end{document}
```

- 构造器只吃一个 options 表；`g` 以外的图对象用语义名（`graphview`，见 `assets/github-discussions/d053-*-c14203101-b1.tex:12`）。
- 环境选项：`exec=true` 强制重算（默认仅源码变化才重跑）、`auto=false` 关掉自动重算（配 shell-escape 副产物如 .eps/.png 时防误删重建）：`\begin{luadraw}{name=x, exec=true, auto=false}`（`a762792-q762786-s07-b1.tex:14`、`d104-*-c14977791-b1.tex:8`）；`margin={l,r,t,b}` 单位 cm 控图边距，`bbox=false` 按内容紧贴（`a754607-q754600-s10-b1.tex:8`）。
- 环境变体：`\begin{luadraw*}` 不自动加 tikzpicture 外壳（嵌套进别的 tikzpicture 时用，`a763306-q268159-s02-b1.tex`）；同一 luadraw 块内可连续 `g = graph3d:new{...}` 重建多次配 `Savetofile` 输出多图（`a749232-q432511-s05-b1.tex:26-40`）。图对象命名共识：`g`（587 处）＞语义名 `graphview`/`graphzone`（多图或辅助视口时）。
- 动画骨架（模板级，`-- do not modify` 三处是框架代码）：

```latex
\begin{luacode*}
luadraw.nbimages = 36
local g = ld.graph3d:new{...}
-- declarations：所有重计算放帧循环外；帧函数只用 ld.makeframe（挂命名空间）
function ld.makeframe(k)  -- do not modify this line / must be global
    -- draw image number k here（帧内只做增量）
    g:Sendtotex()   -- do not modify
    g:Cleargraph()  -- do not modify
end
\end{luacode*}
\newcommand*{\nb}{\directlua{tex.print(luadraw.nbimages)}}%
\newcommand*{\makeframe}[1]{\directlua{luadraw.makeframe(#1)}}%
\begin{animateinline}[poster=first,controls,loop]{6}
\multiframe{\nb}{ik=1+1}{\makeframe{\ik}}%
\end{animateinline}
```

## 4. 开场白（shortcuts）样式

每个环境开头，按需取用、不多不少：

```lua
local ld = luadraw                    -- 命名空间别名，永远第一个
local cpx, pt3d = ld.cpx, ld.pt3d     -- 类
local Z, i = cpx.Z, cpx.I             -- 2D 用
local M, Mc, Ms = pt3d.M, pt3d.Mc, pt3d.Ms
local Origin, vecI, vecJ, vecK = pt3d.Origin, pt3d.vecI, pt3d.vecJ, pt3d.vecK
local cos, sin, sqrt, pi = math.cos, math.sin, math.sqrt, math.pi  -- 用到的 math.* 全部在此 local
```

- **正文零 `math.`**：凡用到的 `math.*` 函数/常量（cos/sin/tan/sqrt/exp/log/abs/pi…）一律在开场白先 local，正文直接用短名，避免满屏 `math.` 前缀。
- 3D 标准开头三件套（`Linejoin("round")` 几乎必设）：`g:Linejoin("round"); g:Linewidth(n); ld.Hiddenlinestyle = "dashed"`（见 `assets/stackexchange/a763385-q691984-s05-b1.tex:61-63`）。
- 重复出现时可做成 TeX 宏 `\shortcuts` 复用：`assets/github-discussions/d243-*-c16843523-b2.tex:7-11`；跨 luacode/luadraw 的全局数据挂 `luadraw.` 命名空间（`luadraw.nbimages`、`luadraw.param`）。

## 5. 状态管理（保存/恢复）

**每个 Save 必有配对 Restore**，否则编译错误：

| 开                                                | 关                                      | 保护范围                 |
| ------------------------------------------------- | --------------------------------------- | ------------------------ |
| `g:Saveattr([scope_options])`                   | `g:Restoreattr()`                     | 视图 + 绘制属性          |
| `g:Savematrix()` / `g:Savematrix3d`           | `g:Restorematrix()`                   | 变换矩阵（递归分形标配） |
| `g:Beginclip(path)`                             | `g:Endclip()`                         | 裁剪                     |
| `g:BeginOnPlane(...)` / `g:Beginlogview(...)` | `g:EndOnPlane()` / `g:Endlogview()` | 平面/对数坐标            |

衍生模式：

- **多子图四宫格**：`Saveattr → Viewport → Coordsystem → draw() → Restoreattr` ×4，中间 `g:Setviewdir(...)` 换投影（`assets/luadraw-doc-en/tangent_from.tex:253-256`）。
- **并排两图用 `g:Shift`，不用视口**：两幅图并排只需 `g:Shift(-4)` / `g:Shift(8)`（需要时再 `g:IDmatrix3d()` 复位）。`Saveattr → Viewport → Coordsystem → Restoreattr` 留给真正独立的面板（窗口或视角不同）；两个并排面板用它，只会多出一对必须配对的状态和一套坐标系。
- **局部换视角不换窗**：`draw(theta,phi)` 参数化局部函数 + `g:Shift3d(-重心)`（换 viewdir 是绕原点转，先居中）：`assets/github-discussions/d137-*-c15051622-b1.tex:14-39`。
- **多视图批量导出**：循环内 `g:Savetofile(basename..k..".tkz"); g:Cleargraph()`，正文 `\input`：`assets/github-discussions/d137-*-c14894434-b1.tex:37-41`（附 GIF 命令 `convert -delay 20 -loop 0 -density 300 -scale 50% in.pdf out.gif`）。
- 矩阵用完复位 `g:IDmatrix()` / `g:IDmatrix3d()`；`Shift` 排版子图后逐次复位（`d311-*-c18076867-b1.tex:18-38` 的 `g:Shift3d(3*vecJ)` 连跳）。

## 6. 代码风格约定（代码样式设计）

> 本章吸收了语料中所有"不算 trick"的写法：凡是关于**怎么写代码**（选项、分层、数值、组织、注释、数学表达）的规范都在这里。

### 6.1 选项与参数设计

- **不写默认值**：只传与默认不同的项。`g:Dfacet(S,{mode=ld.mShadedOnly})` 而非把 `contrast=1, twoside=true, opacity=1` 全抄一遍；对比 `assets/luadraw-doc-en/Dcontour.tex`（只写 `view/colors` 两项）。
- **默认值必须现场查文档和源码，不能凭经验、记忆或例子代码**：每次因为"这是默认值"而省略某个选项，或因为"需要"而写出某个选项，都要打开 `luadraw-v3.5/luadraw/files/` 里的该方法（及 `luadraw-v3.5/luadraw/doc/src/body-en/` 中对应的手册小节），读当前版本怎么处理 `args`。规则：
  - 默认值按方法逐个读取，不能把一个方法的默认值搬到另一个方法，也不能沿用上个项目的印象。
  - 方法头部注释与代码不一致时，以代码为准。例：`luadraw_graph3d.lua:1453` 的 `args` 头部注释写 `hiddenstyle="dotted"`、`twoside=false`，而 `:1467` 的代码用的是 `ld.Hiddenlinestyle`，`:1469` 在 nil 时把 `twoside` 设为 `true`。
  - 默认值可能是会被别处改动的全局量。`ld.Hiddenlinestyle` 初始为 `"dotted"`（`ld.Hiddenlines = false`、`ld.Hiddenlinescale = 2/3`；`luadraw_graph3d.lua:46-48`），`luadraw_spherical.lua` 等扩展会临时重设它。要确认当前文档或扩展有没有改动过。
  - 本指南里引用的数值只是 v3.5 的示例，不是查找表，每次都要重新读源码。
  - 查不到默认值时，显式传入该选项，或询问用户，不要假设。
  - 对隐藏线的推论：要么全局设一次 `ld.Hiddenlinestyle`，要么逐次设 `hiddenstyle`，不要两者并用，它们会互相抵消。
- **两层选项**：结构选项进 Lua 表 `{t={t1,t2}, nbdots=40}`；TikZ 外观进字符串 `"red, line width=0.8pt"`（字段名固定 `draw_options`，反斜杠双写 `"\\draw"`）。
- **nil 即保持当前值**：`g:Lineoptions(nil,"red",8)` 只改色；nil 也是可选参数的哨兵（`x = x or 默认`）。
- `g:Lineoptions(nil,"red",8)`等全局切换样式的命令不要频繁使用，如果需要使用的次数较少，把绘制的样式写入绘制命令内，而不是在正文中反复切换全局的样式。
- **`out=` 惯用法**：绘制方法把计算副产品带回：`g:DScircle(P,{out=ends}); local A,B = table.unpack(ends)`（`assets/stackexchange/a762276-q762274-s09-b2.tex:17-21`）。
- **单位**：线宽 ×0.1pt（`8` = 0.8pt）；高层角度一律度；长度 cm。
- **线宽优先 TikZ 简写**：粗细落在简写档位上时**必须写简写**，且尽量把线宽选到档位上——`ultra thin(0.1pt)/very thin(0.2pt)/thin(0.4pt)/semithick(0.6pt)/thick(0.8pt)/very thick(1.2pt)/ultra thick(1.6pt)`。即 `"thick"` 不写 `"line width=0.8pt"`（语料 148 处简写 vs 手写 `line width=` 仅在非档位值时出现）；档位之间的小数才用 `line width=0.6pt` 数字形式。
- **面片绘制八模式**（`ld.m*` 常量，源 `luadraw_graph3d.lua:50`）：`mWireframe(0)`只棱、`mFlat(1)/mFlatHidden(2)`平涂、`mShaded(3)/mShadedHidden(4)`明暗+棱、`mShadedOnly(5)`只明暗面；配套 `edge=true, edgecolor=, edgewidth=, edgestyle=` 一组棱线选项、`contrast∈[0,1]` 明暗强度、`backcull=true` 背面剔除、`twoside=false` 只染外側、`hiddencolor=` 隐藏棱换色（`d054-*-c14222093-b1.tex:14-16 与 b2:14-15` 双模式对比）。
- **图元专用模式**：`ld.mGrid`（=1，柱/球/锥的网格）与 `ld.mBorder`（=2，仅球的轮廓）定义在 `luadraw_graph3d.lua:51-52`；`Dsphere(O,R,{mode=ld.mBorder,…})` 得到可填充的外形。`hiddenstyle="noline"` 整体取消隐藏棱（`Dedges`、`Dcylinder`、`Dcone` 内以 `args.hiddenstyle ~= "noline"` 判断）：`d238-*-c16527526-b1.tex:17`。
- 标签字号全局一次设：`g:Labelsize("footnotesize")`（可空串复原），比逐标签 `node_options` 加 size 干净（`a762950-q729190-s05-b2.tex:16`）。
- **标签锚定参数**：`anchor1d=t∈[0,1]` 沿线段/弧按比例放标签（51 处使用，`Dseg3d({A,B},{label="$d$",anchor1d=0.5})`）、`anchor2d=Z(x,y)` 曲线上取点锚定、`dist=` 径向距离、`dir={u,v}` 标签平面基向——几何标注三件套（`a764335-q386030-s04-b1.tex:41-46` 集中示范）；`g:Arrows("->")` 全局箭头样式 + `arrowscale=0.75` 缩放（`d054-*-c14222106-b1.tex:16-17`）。

### 6.2 分层设计：计算与绘制分离，复用优先于造轮子

- `ld.*` 纯数学层（`ld.solve/interD*/proj3d/cutfacet/odesolve/...`）不吃图对象；`g:D*` 薄绘制层。**动手前先翻手册找现成函数**；确无再自己写（需要先用ask方法询问用户，并给出**非造轮子不可**的理由，同时给出造轮子的思路和用户一起探讨）。
- 新的可复用能力按同构两层设计：`ld.foo`（算，独立于图）+ `graph/graph3d:Dfoo`（画）。标准范本：`assets/luadraw-doc-en/module-luadraw-doc2d-en-section-81.lua`（`ld.field` + `graph:Dvectorfield`）。
- 方法体内部一律 `self:Dxxx(...)` 而非 `g:`；参数兜底 `args = args or {}`、`options.visibletrace = options.visibletrace or ""`。
- 挂在 `luadraw.` 命名空间下供全文档复用：`function luadraw.create_stacks(...)`（`assets/stackexchange/a763040-q715320-s06-b1.tex`）、`luadraw.param/luadraw.x1t` 传参给 luadraw 环境（`d346-*-c18664344-b1.tex:22-33`）。
- **覆写/增强已有方法时保留旧引用**（装饰器式包装）：`local old = ld.graph3d.Dsphere; function ld.graph3d:Dsphere(...) ... old(self,...) end`（`d276-*-c17211790-b1.tex:16-20`）。
- 输入规范化而非报错：`if pt3d.isPoint3d(L[1]) then L = {L} end`；防御性早退 `if (L==nil) or (type(L)~="table") then return end`（`d057-*-c14247256-b1.tex:23`）；可选实参双签名判 `if not pt3d.isPoint3d(H) then H = V; V = H-B end`（`d294-*-c17686075-b1.tex:41-43`）。

### 6.3 数值样式

- **绝对数值取 0.5 的整倍数**（0.5/1/1.5/2/2.5/3/3.5/4…）：`window={-5,5,-5,5}`、`size={10,10}`、半径 `2.5`、`dist=0.25` 全语料占绝对多数；非半整数只在数学必需时出现。
- **角度取 5 的倍数**：`viewdir={30,60}`、`rotate3d(...,15/20/45/90,...)`、`theta=50*ld.deg`；微调才用 22.5 这类值。
- **角度换算一律 `ld.deg`/`ld.rad`**：`Mc(3, t*ld.deg, ...)` 度→弧度；`angle*ld.rad` 弧度→度（`a766258-q586948-s06-b1.tex:16` 的 `70*ld.deg`）。绝不手写 `*math.pi/180`。
- 数值微分标准式：`local h = 1e-6; (f(x+h)-f(x-h))/(2*h)`；二阶 `(f(x+h)+f(x-h)-2*f(x))/h^2`。
- 求根后必兜 nil：`local T = ld.solve(f,a,b); if T == nil then T = {} end`。

### 6.4 组织与封装样式

- 调用逗号后不加空格：`g:Dpolyline(L,true,"red")`；同族短语句用 `;` 串联：`g:Ddots(S,"Crimson"); g:Dlabel(...)`。
- `(text, anchor, options)` 三元组按行排，一条 `g:Dlabel3d` 装下全部标签。
- **不要给单个 luadraw 调用套局部封装**：`local label = function(text,P,pos) g:Dlabel3d(text,P,{pos=pos,node_options="..."}) end` 既遮住了 API，又破坏整份代码统一的调用风格，还一行没省：把三元组直接交给一条 `g:Dlabel3d`，公共节点样式放进 `pictureoptions`。
- **(对象, 选项) 对收集进表再 `table.unpack`**：交替插入面片表与选项表，最后 `g:Dmixfacet(table.unpack(list))`——逐面着色/魔方/scene 通用（`assets/stackexchange/a748904-q161588-s07-b1.tex:20-26`）。
- **scene 元素增量收集**：`g:add*` 有返回值，`table.insert(scene, g:addPoly(...))` 边建边收，条件元素 `if construction then table.insert(scene, ...) end` 开关化，收尾 `g:Dscene3d(table.unpack(scene))`（`a765117-q53276-s07-b1.tex:35-38,103-105`）。
- **顶部调参区**集中视觉开关：`local c = 1 -- contrast`、`local bc = true -- backculling`、`local construction = true -- Construction lines or not`（`assets/stackexchange/a765117-q53276-s07-b1.tex:18-20`）。
- **参数化局部函数复用整图，但有门槛**：`draw_box(alpha,beta)`、`plot_hyperbola(opt,angle,...)` 默认参数 `x = x or ...`，定义一次多处调用（`d297-*-c17850496-b1.tex:15-27`）；嵌套局部函数（外层管平移定位、内层管单元细节）如 `Dcrossing` 内嵌 `Dcorner`（`a755346-q755343-s08-b1.tex:15-32`）。**门槛：要画三个及以上才封装；只有两个就把两块直接写出来，此时的封装只会把逻辑从调用处搬走。**
- **目标是代码足够短、可读性强，避免无效封装和过度封装**：只有当文件因此变短、调用处仍然好读时，封装才成立。省不了几行、遮住 API 调用、要靠回调或闭包才能工作、使用不足三次的封装，都通不过这个检验，直接内联。
- **封装的参数是数据，不是行为**：好的 helper 接收"变化的那个量"（`drawScene(solid)`），只读参数和开场白 local，只做一件事。坏的 helper 接收回调（`draw_common(shape)`），通过闭包捕获 `g`、`O`、`C`、`d`、`cube` 等一堆外层变量，先画盒子、坐标轴、尺寸、文字，最后才调用回调。参数若是"会画图的函数"，结构就是错的：直接内联，或把公共部分和变化部分拆开。
- **声明场景，不要脚本式作画**：先把几何定义成数据（`P`、`C`、`S`、`ld.facetedges(P)`），再交给渲染层（`Dscene3d` 配 `addPoly`/`addPolyline`，或 `Classifyfacet` 加有序 `Dfacet`），遮挡由库负责：`Classifyfacet` 负责拆面，顺序只是"后面 → 内部 → 前面"，不是手调的一串调用。手算标注偏移（`O+(5*d/6)*vecI+d*vecJ+(d/2)*vecK`）、对整个场景 `Rotate3d`、把包住物体的整个实体一次画完再画里面的东西，都是脚本式作画的信号。
- **只画被要求的内容**：没要求就不加坐标轴、尺寸箭头、图注或标注层；每多一层都会带来自己的 helper、偏移和状态。短小的玻璃盒脚本（skill 里的 `examples/glass-box-3d.tex`）是范本：几行数据定义，每张图一次渲染调用。
- **数据表驱动**：`{{x1,x2,y1,y2,h}, ...}` 行 → `mycube(table.unpack(b))` 循环建体，改数据不改代码（`d274-*-c17205141-b1.tex:15-31`）。
- **非必要不设中间变量**（开场白 local 之外）：选项字符串尤其不该拆——

  ```lua
  -- 反例：无用的中间封装
  local arrow = "arrows={-Stealth[scale=1.15]}"
  local axis = "Crimson,line width=1pt,"..arrow
  local measure = "SteelBlue,line width=0.8pt,"..arrow
  -- 正解：直接写在各自的 D 调用里
  g:Dseg3d({A,B}, "Crimson,line width=1pt,arrows={-Stealth[scale=1.15]}")
  ```

  判断标准：同一选项串**使用不足三次就地内联**；**超过三次优先改成循环或数据表驱动**（`for _,v in ipairs{{"Crimson",A,B},{"SteelBlue",C,D}} do g:Dseg3d({v[2],v[3]}, v[1]..公共部分) end`），而不是层层 local 拼接。总之除开场白外不单独声明选项类 local，保证整体整洁、不做无用封装。
- **选项复用的合法形态**仅两种：样式工厂（参数化成函数 `local style = function(color) return {...} end`，`a755801-q755458-s05-b1.tex`）与循环/表驱动（见上）；单纯"重复两次所以提个 local"是反模式。函数同理："画两次所以提个函数"也是反模式（见上面的门槛）。
- **手工画家排序**（需要时）：`table.sort(t, function(a,b) return pt3d.dot(a[1],g.Normal) < pt3d.dot(b[1],g.Normal) end)`（`a755346-q755343-s08-b1.tex:53`），或按 `g:Observer_distance` 排序（`a763930-q528631-s02-b1.tex`）。
- **通读全语料后对这些规则的修正**：上述规则在每个切片里都成立，发现的例外范围很窄。(1) 会**变换参数**且被复用的 helper（`Dcoord3d` 先格式化坐标再调一次 `Dlabel3d`，`d182`–`d185` 共 7 个文件使用）可以接受，纯转发的封装不行。(2) **返回数据**的 helper（`diamon` 构造整个双锥，`d060-*-c14261455-b1.tex:11-22`）每次调用能替代很多行时，用两次也可以：数省掉的行数，不数调用点；但它仍不接收绘图回调。(3) 只补一个默认 `dir` 的三个单调用封装 `draw_Xspectrum/Yspectrum/Zspectrum`（`d089-*-c14457144-b1.tex:74-84`）是要避免的写法：调用时直接传 `dir`。(4) 同一个 20 行 helper 被粘贴进 8 个文件（`frac`，`d182`–`d185`）后来提升到全局 `luacode*`：提升，不要粘贴。(5) 单个调用前后 `g:Linecolor("red"); g:Dcone(…); g:Linecolor("black")`（`d054-*-c14222139-b1.lua:2-4`）正是逐调用选项要取代的写法。(6) 窗口完全相同的四个面板用 `Saveattr/Viewport/Coordsystem`（`d221-*-c16034961-b1.tex:100-122`）应改为 `g:Shift`；只有每个面板有各自的 `Coordsystem` 时才用 `Viewport`（`d220-*-c16032116-b1.tex:14-47`）。(7) `"blue,line width=0.8"` 在四个同级函数里写了 8 次（`d217-*-c16178639-b1.tex`）属于"超过三次"：用一个循环或一个样式工厂。

### 6.5 注释样式

- **非必要不添加注释**：代码整体保持简洁，注释是例外不是默认。能靠命名、结构、一行公式说清的，一律不注释。
- **只在极其关键的 trick 步骤附近添加少量注释**：值得注释的只有三类——反直觉的数值魔术（`local r2 = r+0.01 -- enlarge r to avoid overlapping lines`）、性能陷阱（`g:addWall(wall) -- 2 facet cutouts with this instruction, and 529 without it`）、框架强制标记（`-- do not modify` / `-- must be global`，动画骨架三处）。
- 关键处的注释写"为什么"不写"是什么"：一行几何/数学意图（`-- plane whose section with the torus gives the lemniscate`），绝不复述 API 名。
- 数学推导步骤多时，推导结论一行注释带过即可（判别式=0 求公切线、特征分解换参），不逐步铺注释。
- 调试用可视化不删代码只注释掉：`--g:Dlabel(...)`，或直接用 `g:Dpolynames(P)` 显示面/顶点编号（`assets/luadraw-doc-en/show_facet_number.tex`）。

### 6.6 数学表达样式

- 运算符重载用满：中点 `(A+B)/2`、对称 `2*A1-H`、`4*M(1,0,-0.5)`、复数 `2+3*i`。
- 匿名函数 `local f = function(x,y) ... end`；实数直接参与（`{pi/2, pi/2+2*i, 2*i}`，API 层自动转换）。
- 数值循环 `for k = 1, n` + `table.insert`；数据遍历 `ipairs`；忽略下标 `_`；集合操作用库提供的 `ld.concat/ld.insert/ld.map/table.append`。
- TikZ 全局节点样式一次进构造器 `pictureoptions = "every node/.append style={fill=white,inner sep=1.75pt}"`，不在正文逐个 `node_options` 重复（`a760809-q760803-s07-b1.tex`、`d228-*-c16122879-b1.tex`）。
- 平方密集时定义微辅助 `local sqr = function(x) return x*x end`，比反复 `x^2` 更短更快（`assets/luadraw-doc-en/Dandelin.tex:10`）。
- **向量小函数词汇**（免手写循环）：`pt3d.prod(u,v)` 叉积、`pt3d.dot(u,v)` 点积、`pt3d.normalize(u)` 单位化(nil 零向量)、`pt3d.det(u,v,w)` 混合积、`pt3d.abs2/abs` 模方/模、`pt3d.isobar3d(F)` 面片重心、`pt3d.N1(u)` 模（判零 `if N1(u)<1e-12 then 换向量`）；复数侧 `cpx.normalize/det(u,v)` 有向面积、`cpx.isobar(L)` 折线重心——"轴线正交基"配方 `u=prod(n,vecJ); if N1(u)<1e-12 then u=prod(n,vecI) end; v=prod(n,u)`（`d059-*-c14255047-b1.tex:14-17`）。
- **矩阵三件套语义**：`ld.mtransform3d(L,M)` 点列整体换系（仿射全包）、`ld.mLtransform3d(L,M)` 只作用线性部分（向量/方向用这个，`luadraw_matrix3d.lua:69`）、`ld.invmatrix3d(M)` 逆；判单位阵省计算 `if not ld.isID3d(mat) then ... end`（30 处使用，`d288-*-c17625127-b1.tex:31-35`）。

---

## 7. 实战技巧（附代码位置）

> 收录标准：**能显著缩短代码或明显提高编程便利**的情境性知识；通用写法规范已在 §6。每条给出 assets 内的位置。

### 7.1 渲染路线怎么选（决策表）

| 场景                                 | 首选                                                                                                                                                                    | 依据                                                                                                                             |
| ------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| 普通多面体/曲面                      | `g:Dfacet` / `Dmixfacet`（画家算法+可选 `backcull=true`）                                                                                                         | `assets/luadraw-doc-en/tetra_coupe.tex`                                                                                        |
| 两立体相交、需要真正切割             | `g:Dscene3d` + `g:addWall` 分隔墙（面片切割数可从 2068 → 30）                                                                                                      | `assets/stackexchange/a759064-q759057-s16-b2.tex` torus；`assets/luadraw-doc-en/torus.tex:328`（`addwall=2` 构造时带上墙） |
| 只需外形光洁（球/柱/锥）             | 解析图元`Dsphere/Dcylinder/Dcone`，或 **轮廓+渐变**：`Classifyfacet` → `border` → `Dpolyline3d(border, "left color=..,right color=..,middle color=..")` | `assets/stackexchange/a762950-q729190-s05-b2.tex`（半球两种画法对比）                                                          |
| 手工控制先后                         | 收集`(对象,选项)` 对、排序后依次画（见 §6.4）                                                                                                                        | `assets/stackexchange/a755346-q755343-s08-b1.tex:53`                                                                           |
| 透明相交/隐式面/海量细节             | POV-Ray：`Pov_new → Pov_* → Pov_exec → Pov_show`，CSG 做 `difference/intersection/merge`                                                                         | `assets/github-discussions/d203-*-c15858811-b1.tex`（两圆柱相交+金属贴图）                                                     |
| 数万点/面                            | `luadraw_pdfliteral` 直写 PDF 流                                                                                                                                      | bifurcation（31275 点）示例在`assets/stackexchange/a761978-*` 系列                                                             |
| 球面上的图（大圆/球面区域/球面曲线） | `luadraw_spherical`：`Define_sphere → DS* 系列 → Dspherical()`                                                                                                    | `d054-*-c14222169-b1.tex` 全家福；`assets/luadraw-doc-en/spherical_strip.tex` 分层                                           |

- **球面作图家族**（`require 'luadraw_spherical'` 后）：画之前 `g:Define_sphere({radius=,color=,opacity=,show=})`，之后 `DSpolyline/DSseg/DSline/DSarc/DSbigcircle/DScircle/DScurve/DSfacet/DSregion/DSplane/DSaxes/DSlabel/DSdots/DSstars/DSangle` 随便用，最后 `g:Dspherical()` 一次性按球面遮挡输出；分层控制 `DSaddback/DSaddfront/DSaddinside`（路径先排队，背面/正面/穿球分别渲染），反球面变换对 `DSinvstereo_polyline/DSinvstereo_curve`（`d054-*-c14222169-b1.tex:14-27`、`assets/luadraw-doc-en/spherical_strip.tex:26-33`）。
- **POV-Ray 对象家族**（`require 'luadraw_povray'` 后）：图元 `Pov_sphere/cylinder/cone/torus/plane/circle/dots/polyline/facet/surface/implicit/axes`，CSG `Pov_union/difference/intersection/merge`，其他 `Pov_include/Pov_special`（写原生 POV 语句）；命名对象 `{name="s", render=false}` 先声明后组合，字符串里可带变换 `"cyl1 rotate 90*z"`（`assets/luadraw-doc-en/holes_in_hemisphere.tex:16-24`、`a763074-q763071-s07-b1.tex:12-21`）。

经验值：需要隐藏线时 `border(可见)+border(隐藏)` 分两色两次画，比面片透明叠更干净（`a762729-q360412-s06-b1.tex:15-21`）。

### 7.2 一行构造常见图形

- **甜甜圈/旋转体**：`rotcurve(f,t1,t2,{轴},360,0,{grid=.., addwall=2})` 母线+轴即可，`addwall` 顺带给 Dscene3d 的分隔墙：`assets/stackexchange/a759064-q759057-s16-b1.tex:14-15`。分段母线（旋转体带盖）用 `cutfacet` 链：`a755902-q755898-s16-b1.tex:14-16`。
- **椭球/轴向缩放体**：`Savematrix; Setmatrix3d({Origin, 2*vecI, 3*vecJ, 4*vecK}); Dsphere(Origin,1)`，复用球图元：`a755902-q755898-s16-b1.tex:25-27`。
- **镂空/圆孔面**：外轮廓与内孔 `concat` 后 `"even odd rule"` 填充；`table.insert(path,2,"m")` 即可给折线开孔：`assets/stackexchange/a764687-q764678-s13-b1.tex`、`a752902-q625977-s06-b1.tex:29-31`。
- **半/部分圆柱**：`cylinder → cutpoly(cutfacet) → g:Outline(Cyl)` 取轮廓再渐变：`assets/github-discussions/d102-*-c14513457-b1.tex:14-19`。
- **正多面体**：`require 'luadraw_polyhedrons'`，`poly.tetrahedron(C,S,true)` 一次拿 `P,V,E,F1,F2`：`assets/luadraw-doc-en/polyhedrons.tex`。
- **展开图**：`require 'luadraw_cvx_polyhedra_nets'`，`unfold_polyhedron(P)` + `Dpolyhedron_net(P,{tabs=true})`：`assets/luadraw-doc-en/parallelep_net*.tex`。
- **只要某几个面**：`getfacet(P,{1,3,4})` 直接选面，省掉隐藏线处理：`d053-*-c14204188-b1.tex:20`。
- **现成窗口多边形**：`g:Box2d()`/`g:Box3d()` 直接把当前窗口当多边形/平行六面体用——不等式区域从窗口逐次 `cutpolyline(Box2d(),D,true)` 裁出（`d298-*-c17916655-b1.tex:48-57`）；3D 窗口盒做裁剪体 `ld.clip3d(S,g:Box3d())`（`assets/luadraw-doc-en/lecture_obj.tex` 思路同）。
- **平面标架一行取**：`local C,u,v = ld.orthoframe(P)` 直接给平面正交基，画矩形平面/贴图/建局部系不再手算（`d182-*-c15630885-b1.tex:17`、`d319-*-c18204595-b1.tex` 同用）。
- **切开立体一次拿三样**：`local Bottom, Above, section = ld.cutpoly(C, P)` 返回保留半、丢弃半、截面折线（还可 `close=true` 自动盖盖）；移动拼接直接 `ld.shift3d(Right, vector)`（`d243-*-c16843523-b2.tex:30-37,60`）。
- **直线按方程画**：`g:DlineEq(a,b,c,"样式")` 直接画 `ax+by=c`，配 `ld.lineEq` 拿线对象（`assets/luadraw-doc-en/sequence.tex:19`）。
- **整数序列与离散步进**：`ld.range(a,b[,step])` 直接生成等距表（等高线层级 `Lz = ld.range(1,10)`、循环参数化共用）；配 `ld.getpalette(pal, N)` 取 N 个均匀色（`assets/luadraw-doc-en/Dcontour.tex:8-9`）。
- **调色板图例现成画**：`g:Dgradbox({位置},{legend={"$x$","$y$"}, grid=true, title=".."})` 色带+刻度+标题一行，配 `Dcontour(f,Lz,{colors=Colors})` 是等值线图标配（`assets/luadraw-doc-en/Dcontour.tex:10-11`）。
- **立体的真实截线**：`g:Intersection3d(solid, plane)` 一行拿相交曲线（椭球截圆锥得椭圆），配 `Plane2facet(plane,scale)` 把切面画出来：`assets/luadraw-doc-en/Dandelin.tex:29-32,45`。
- **2D→3D 提升**：`ld.map(function(z) return M(x0,z.re,z.im) end, I[1])` 把平面隐式曲线 `ld.implicit` 的结果贴到 3D 平面上（`assets/luadraw-doc-en/torus.tex:24-25`）。
- **窗口边界四访问器**：`g:Xinf()/Xsup()/Yinf()/Ysup()` 直接拿当前窗口范围，场/网格循环 `for y = g:Yinf(), g:Ysup(), dy do` 不必重复抄 window 数字（`assets/luadraw-doc-en/champ.tex:14-15`）。
- **ODE 积分曲线直接画**：`g:Dodesolve(f, x0, y0, {t={t1,t2}, draw_options=})` 算画一体（`assets/luadraw-doc-en/champ.tex:26`）。
- **路径微语言一行画复杂形状**：`g:Dpath(p)` 扁平表里混坐标与指令串——`"m"移动 "l"线 "b"贝塞尔 "ca"圆弧 "e"椭圆 "s"样条 "la"圆角线 "cl"闭合`，复杂填充轮廓一表搞定（`assets/luadraw-doc-en/path_spline.tex:6-8`）。
- **样条过点一行画**：`g:Dspline({A,B,C,D,E}, nil, -5*i)` 两端切向约束可空，平滑曲线不用参数化（`assets/luadraw-doc-en/path_spline.tex:11`）。
- **挤出/旋转/平行六面体**：底面曲线一行变体——`ld.prism(arc, axis, false)` 沿轴挤出、`ld.rotline(arc, {C,axis}, 0, 90, {nbdots=n})` 部分旋转面（角度可只转一段）、`ld.parallelep(O, L*vecI, W*vecJ, H*vecK)` 直接给六面体、`ld.facet2plane(F)` 面片所在平面（喂 `addWall`）：`a765117-q53276-s07-b1.tex:34,48,56,71`。
- **交点/交线全家桶**（动手解方程前先查这里）：2D `interL/interD/interP/interDL/interDC/interCC`；3D `interDP/interPP/interDD/interPS`(平面∩球→圆)/`interSS`(球∩球)/`interDS`(线∩球)/`interCS`/`interSSS`(三球定位)，全部 nil 安全（定义在 `luadraw_lines.lua:616-`、`luadraw_lines3d.lua:364-`；用法例 `d294-*-c17686075-b1.tex:84`）。
- **平面两种一步给**：`ld.plane(A,B,C)` 三点定面、`ld.planeEq(a,b,c,d)` 方程 `ax+by+cz+d=0` 定面（`assets/luadraw-doc-en/parallelep_net3.tex:10`、`a748774-q728955-s02-b1.tex:15`）。
- **几何构造全家桶**：`ld.tetra_len(ab,ac,ad,bc,bd,cd)` 六棱长定四面体（`assets/luadraw-doc-en/tetra_len.tex:12`）；`ld.sss_triangle3d(ab,bc,ac)` 三边定三角形（`d120-*-c14663053-b1.tex`）；`ld.circumcircle3d/incircle3d(A,B,C)` 外接/内切圆、`ld.circumsphere/insphere(A,B,C,D)` 外接/内切球（`a752142-q752135-b10-b1.tex:20-23`、`a750962-q612735-s02-b1.tex:17`）；`ld.pyramid(base, apex)` 棱锥（`assets/luadraw-doc-en/test.tex`）；正棱锥 `ld.regular_pyramid(n,a,h,open,center)`（`d115-*-c14617462-b1.tex`）。
- **任意母线立体**：`ld.curve2cylinder(f,t1,t2,V)` 任意闭合曲线拉伸成柱、`ld.curve2cone(f,t1,t2,O)` 成锥（`assets/luadraw-doc-en/curve2cylinder.tex:12-13`）；`ld.line2tube(L, r, {nbfacet=8})` 折线变管、`ld.section2tube(section, L, {hollow=true})` 任意截面沿路径扫掠（`assets/luadraw-doc-en/line2tube_section2tube.tex:22-24`）；`ld.cylindrical_surface(r,z,u1,u2,v1,v2,grid,"v")` 柱坐标面自带墙（`assets/luadraw-doc-en/surface_with_addWall.tex:31`）。
- **凸包一行**：`ld.cvx_hull3d(L)` 点列表→面片列表，`ld.facet2poly(V)` 转回多面体；2D `ld.cvx_hull2d`（`assets/luadraw-doc-en/cvx_hull3d.tex:13-14`、`a752696-q566807-s05-b1.tex:14`）。
- **现成圆柱分解**：`g:Cylinder_outline(A,R,B)` 返回 `{section=, side=, visible=, hidden=}` 四组 3D 路径，侧壁/截面圆/可见棱/隐藏棱分开画各上各的渐变（`a766533-q766527-s03-b1.tex`）。
- **轴搬运**：`ld.rotateaxe3d(S, K, N)` 把整个对象从"K 为轴"旋到"N 为轴"，斜置立体先在规范位算好再一转（`a764335-q386030-s04-b1.tex:27`、`d278-*-c17247327-b1.tex` 斜柱全套路）；`ld.rotate3d({U,V}, ang, axe)` 向量对同转（`d294-*-c17686075-b1.tex:46`）。
- **镜像补全**：`ld.sym3d(list, {P,n})` 整列点对面镜像（`d137-*-c14894434-b1.tex:23`）；曲面补半 `concat(S, reverse_face_orientation(sym3d(S,plane)))`（`a752224-q752218-s07-b1.tex:17-18`）。
- **集合运算画区域**：`ld.set(center, angle)` 构造、`ld.cap/cup/setminus` 交并差、`ld.path(A)` 集合转折线（`assets/luadraw-doc-en/cap_and_cup.tex:8-15`、`a751952-q751879-s02-b1.tex:22-38`）。
- **数据表驱动 CSV→曲面**：`ld.read_csv_file(f, {header=,sep=,comment=})` + `ld.read_table3d(data, {bbox=true, func=4})` 行数据直接变面片，`func=N` 把第 N 列插值成着色函数（`assets/luadraw-doc-en/read_table3d.tex:2-3`）；`.obj` 模型 `ld.read_obj_file(f)` 返回 `(P, bbox)` 且 `window3d=bbox` 直接喂（`assets/luadraw-doc-en/lecture_obj.tex:1-2`）。
- **圆弧计算侧形态**：`ld.circle3db(C,R,normal)`/`ld.arc3db(B,A,C,R,sens,normal)` 直接返回点列，喂 `path3d(...,100)` 或 `addPolyline` 而不用画（`luadraw_lines3d.lua:151,197`；用法 `d313-*-c18089286-b1.tex:12`）。
- **球面轮廓圆**：`g:Sphere_outline(O,R).data` 一次拿轮廓圆 `{I,r,n}`，画大圆赤道不再手算（`d325-*-c18293081-b1.tex:22`）；配 `Cylinder_outline`（`luadraw_frustum_and_co.lua:78,249`）。
- **小工具集**：`ld.rectangle(a,b,c)` 三点定矩形（`luadraw_lines.lua:226`）；`g:Getview()` 拿当前视口四边界（`a749228-q749220-s08-b1.tex:35`）；`g:Sortfacet(F)`/`Sortpolyfacet(P)` 返回按远近排好序的面片列表，手写画家算法直接迭代（`luadraw_graph3d.lua:792,816`；`d067-*-c14330300-b1.tex`）；`g:Composematrix({O,u,v})` 由原点+两基向量直接合成 2D 仿射矩阵（`luadraw_calc.lua:65`）。
- **区域填充家族**：`Ddomain1(f,{x=})` 曲线下、`Ddomain2(f,h,{x=})` 两曲线之间、`Ddomain3(f,h)` 闭域、`Dinequalities({f,'>',h,'<'},{draw_options=})` 函数不等式区域、`Dimplicit_inequalities` 隐式版、`Dstepfunction` 阶梯线——微积分/不等式插图零手写路径（`assets/luadraw-doc-en/courbe.tex:11-16`、`assets/luadraw-doc-en/Dinequalities.tex:10`、`a755221-q755217-s09-b1.tex:14`）。
- **标注家族**：`Dangle(B,A,C,r)` 角标记、`Dmarkseg/Dmarkarc` 等分刻痕、`DtangentC(f,x,len)` 曲线切线、`Dtangent_from(P,f,t1,t2,style,S)` 外点切线（切点进 S）、`Dhline(A,B)` 半直线、`Dbezier({p1,p2,p3,p4})` 单段贝塞尔、`Dlabeldot` 带点标签、`Dgradline({a,b},{limits=,legend=})` 独立数轴（`assets/luadraw-doc-en/orthocentre.tex:14-25` 全套、`a766249-q496103-s05-b1.tex:24-26`、`assets/luadraw-doc-en/gradline.tex:5-8`）。
- **投影六件套**：`ld.pxy/pxz/pyz(A)` 点到三坐标面的投影点、`ld.px/py/pz(A)` 到三轴的投影点——画辅助虚线、立方体面上阴影、坐标读数线全靠它们（`a754855-q754846-s16-b1.tex:14-15` 连 `concat(pxy(S),pxz(S),pyz(S))` 批量投影；`d107-*-c14544282-b1.tex` 投影配立方体）。
- **切球一行**：`g:Dcut_sphere(O, R, P, {color=, mode=, edgecolor=, visibletrace=, hiddentrace=})` 平面 P 截球直接画，trace 选项给截面描边样式（`assets/luadraw-doc-en/cut_sphere.tex:16-23`）。
- **扩展模块速查**：`luadraw_fields`(场 Dvectorfield/Dgradientfield/Dsurfacefield)、`luadraw_shadedforms`(Dshaded* + Dcolorbar)、`luadraw_palettes`(调色板库 + `getPal{extract=,shift=,reverse=}` + `mixpalette`)、`luadraw_decorations`(装饰角/刻度线段)、`luadraw_coils_chains`(Dcoil/Dchain)、`luadraw_compile_tex`(TeX→路径)、`luadraw_linprog`(线性规划)、`luadraw_log_axes`(Beginlogview/Dlog* 对数轴)、`luadraw_polyhedrons`、`luadraw_cvx_polyhedra_nets`、`luadraw_povray`、`luadraw_pdfliteral`、`luadraw_spherical`——各模块 demo 均在 `assets/luadraw-doc-en/` 同名 tex。

### 7.3 视觉效果技巧

- **虚线 + 透明度 = 画两次**：先实线半透明实体，再把隐藏线虚线叠画；`mode=2(纯轮廓)+color+opacity` 画壳、`mode=0` 虚线画棱：`assets/stackexchange/a748590-q438320-s06-b1.tex:15-19`。
- **物体放进透明盒子（玻璃盒效果）**：`local V,H = g:Classifyfacet(P)` 返回可见面和不可见面（`luadraw_graph3d.lua:776-790`）；先画 `H`，再画实体，最后以低不透明度画 `V`：`g:Dfacet(H,{...}); g:Dcylinder(...); g:Dfacet(V,{...})`。也可用一次 `g:Dscene3d(g:addPoly(solid,{...}), g:addPolyline(ld.facetedges(P),{hidden=true,hiddenstyle="dashed",...}))`。两种都让渲染层决定谁遮挡谁。来源：tex.stackexchange 回答 766923（问题 174930）。
- **白边遮挡（伪 3D 线）**：`"draw=white,double=black,double distance=0.6pt"` 让后线被前线"挡住"；螺线标准画法：`a750922-q750874-s11-b1.tex:23-24`；Dscene3d 内等价选项 `double={"white",6}`：`d281-*-c17305266-b1.tex:34`。
- **裁剪出正确着色**：`Beginclip(轮廓 path) → Dsphere(...) → Endclip()` 得到局部渐变球冠：`a755902-q755898-s16-b1.tex:28-30`；`Beginclip(path, true)` 反向裁剪取外部。
- **渐变朝向**：`shading angle="..ld.strReal(g:Proj3dV(法向)*ld.rad)`（拼接算角度）：`d278-*-c17247327-b1.tex:26-31`。
- **借 TikZ 资产**：`g:Writeln` 注入任意 TikZ——装饰节点 `\\node[cloud,...] at..g:Coord(z)..";"`（`d158-*-c15147389-b1.tex:44-47`）；自定义箭头装饰 `\\tikzset{->-/.style={decoration=...}}` 后折线直接 `"->-=0.65,blue"`（`assets/luadraw-doc-en/sequence.tex:15-21`）。
- **中心投影一行开**：`viewdir=perspective("central",30,60,20)`（θ,φ,视距），配 `ld.camera` 换参照点：`assets/stackexchange/a759064-q759057-s16-b1.tex:9`。
- **`mixcolor` 代替 `fill opacity`**：混合底色后再填，透明不叠加、色值可复现：`mixcolor(ld.palette(pal, idx, true), 0.5, ld.White, 0.5)`（`a752183-q752168-s07-b1.tex:45` 注释原话 "to replace the fill opacity option"）。
- **在 3D 任意平面上画 2D**：`g:Savematrix(); g:Setmatrix({g:Proj3d(A), g:Proj3dV(u), g:Proj3dV(v)})` 后直接用全套 2D 方法（Daxes/Dellipse/Darc…），`g:IDmatrix()` 复位——3D 图里嵌平面坐标系/场图的标准姿势（`a749713-q749696-s08-b1.tex`、`a763154-q480263-s02-b1.tex:13`）。
- **面片明暗微调**：`g:adjust_color(F, color, contrast, twoside)` 按法向与视线夹角算出深浅色（即 mShaded 模式内核），自定义逐面上色时直接借用（`d095-*-c14597160-b1.tex` 定义、`a759177-q759149-s05-b1.tex` 用法）；Dcylinder/Dcone 的 `gradside={r,g,b}`、`gradsection=` 直接给侧壁/截面渐变色（`a766774-q487872-s06-b1.tex`）。
- **自定义命名渐变**：导言区 `\pgfdeclareradialshading{myname}{...}{...}`，画图时 draw_options 里 `shading=myname` 一词引用（`d226-*-c16087524-b1.tex:9-14,34-36`）。
- **两立体交线一行**：`ld.border(ld.clip3d(C2, C1))` 拿到 C2 在 C1 内的边界即交线；两圆柱 Steinmetz 完整范本 `table.append(S1, rotate3d(S1,180,axe))` + `border`（`d319-*-c18201340-b1.tex:33`、`a765262-q726438-s08-b2.tex:22-25`）。
- **等高线 = cutfacet 链式切片**：`for k=1,n do S1, S = ld.cutfacet(S, {M(0,0,k),-vecK}); insert(niv,{S1,{color=..}}) end` 逐层截下、剩余下传，最后 `Dmixfacet(table.unpack(niv))`（`assets/luadraw-doc-en/courbes_niv.tex:17-24`；条纹立方体同法 `a754826-q754821-s07-b1.tex:12-18`）。

### 7.4 数值与求解技巧

- **求根即画图**：切点/拐点/等弧长点全部 `ld.solve`，nil 兜底后循环；椭圆公切线判别式法完整范本 `a754350-q754333-s13-b1.tex:45-60`。
- **奇点处理**：端点收缩 `±1e-6/±1e-8`；`ld.linspace` 多段在奇点附近加密（`-4,0.25,50, 5,20`）；重合线微扩 `r+0.01`：`a759064-q759057-s16-b1.tex:14`、`a761682-q761676-s11-b1.tex:21`。
- **换系计算、原系绘制**：`invmatrix` 化归标准形解题，`g:Setmatrix(matrix)` 回原系画（`a754350-q754333-s13-b1.tex:45-60`）；特征分解换参数化 + `mtransform3d` 回原系（`a763941-q584173-s02-b1.tex:24-40`）。
- **旋转/对称拼接**：`S = concat(S1, rotate3d(S1,180,axe))`；对称补面记得 `reverse_face_orientation`：`a752224-q752218-s07-b1.tex:17-18`；**点列整体镜像**直接 `sym3d({A,…,G},{点,法向})` 一行补全另一半顶点：`d137-*-c14894434-b1.tex:23`。
- **可复现随机**：`math.randomseed(42)`（`a763110-q763098-s14-b1.tex`）。
- **迭代数列一行生成**：`ld.sequence(f, u0, n)` 返回 `u, f(u), f²(u)…`，蛛网图楼梯线循环 `table.insert(seg,{z,L[k]})` 即成（`assets/luadraw-doc-en/sequence.tex:9-14`）。
- **定积分数值一行**：`ld.int(f, a, b)`，积分上限当未知量就是隐函数 `G(x,y)=ld.int(h,x,y)-1`（`assets/luadraw-doc-en/int_solve.tex:6,9`）；`ld.evalf(f,x[,y])` 求值 nil 安全（`a763996-q130802-s03-b1.tex:31`）。
- **弧长参数化**：`f = ld.curvilinear_param(L, close)` 后 `ld.map(f, ld.linspace(0,1,n))` 等距取样、`Dparametric(f,{t={..}})` 分段画箭头（`assets/luadraw-doc-en/curvilinear_param.tex:12-21`）。
- **斜置立体规范位法**：斜柱/斜锥先绕辅助轴转到竖直位计算（`pt3d.angle(C-A,vecK)*ld.rad` 得角再 `rotate3d`），画时用 `cpx.arg(g:Proj3dV(cyl_normal))*ld.rad` 算 shading angle（`d278-*-c17247327-b1.tex:19-30`）。
- **自适应窗口**：`x1,x2,y1,y2 = ld.getbounds(L)` / `ld.getbounds3d(points)` 拿边界，`window={x1-dx,x2+dx,...}` 加余量，3D 直接 `adjust2d=true` 让包自动算 2D 窗（`a758597-q758581-s05-b1.tex:5-7`、`d180-*-c15599080-b1.tex:10-11`）。
- **精确分数串**：`ld.nearest/simplifyFrac` 把浮点坐标转最简分数，`frac()` 助手 20 行内输出 `\frac{a}{b}` TeX 串（`d183-*-c15647828-b1.tex:4-25`）。

### 7.5 可见性与遮挡技巧

- 通用判定：可见 ⟺ `pt3d.dot(A-参照, g.Normal) > 0`（中心投影换成 `ld.camera-A`）。
- **用 `g:Classifyfacet` 拆面，再按 后 → 前 分层画**：`local V,H = g:Classifyfacet(S)` 接受面片表或多面体，先套用当前 3D 矩阵，再返回可见面和不可见面（`luadraw_graph3d.lua:776-790`；代码在 `g:Det3d()` 不为正时会把两个表互换后返回）。谁在前面由数据决定，不靠手调的调用顺序。语料里的用法：(1) `local V = g:Classifyfacet(S)` 只留可见面，`border(V)` 即轮廓，用来填渐变（`d109-*-c14551123-b1.tex:12-15`、`a762947-q297399-s07-b1.tex:17-18`）；(2) `V,H` 分层：先画不可见部分，再画其后或其内的物体，最后画可见部分（`assets/luadraw-doc-en/rotcurve.tex:10-14`、`assets/luadraw-doc-en/spherical_strip.tex:22-25`、`d127-*-c14774246-b1.tex:19-30`、`a764304-q714696-s03-b1.tex:22-26`）；(3) 先切再分（`ld.cutfacet` → `Classifyfacet`：`d330-*-c18382355-b1.tex:69-75`），或先分再对 `V`、`H` 分别切（`assets/luadraw-doc-en/Dandelin.tex:35-37`、`a749232-q432511-s05-b1.tex:16-18`）。着色面片用 `Dfacet(H,…)`/`Dfacet(V,…)`，要干净的渐变外形用 `Dpolyline3d(border(H),"…color…")`。
- **曲线在柱/球上的可见分离**：`ld.split_points_by_visibility(curve, visible_function)`，`visible_function` 用 `dproj3d` 到轴再点积；可直接复刻的 `Curve_on_cylinder` 完整实现：`d319-*-c18204595-b1.tex:21-31`（双圆柱交线同时判两轴）。
- **面片预筛减计算**：先局部 `sortfacet()` 把不需裁剪的分开再 `clip3d`：`a759151-q714248-s11-b1.tex:16-28`。
- **屏幕向量现成取**：`g:ScreenX()/g:ScreenY()` 给屏幕平面方向向量，画直径/对称轮廓/贴标注时免去投影手算（`a752902-q625977-s06-b1.tex` 用 `O±R*g:ScreenX()` 取球轮廓端点）。
- **tangency 系列**：`g:Sphere_tangency/Cylinder_tangency/...` 直接给视切点，配合 `out=` 拿轮廓弧端点：`d294-*-c17686075-b1.tex:40-70`（一组可复刻的实现）。
- **截线画法**：`Intersection3d` 返回值自带 `.visible/.hidden` 两列表——`ld.concat(I.visible, I.hidden)` 合并、`I_shifted = ld.shift3d(I_combined, v)` 平移复用，无需手写可见性函数（`d243-*-c16843523-b2.tex:29-33`）；画法 `g:Dedges(I,{hidden=false})` 只画可见段，`{hidden=true, hiddenstyle="solid", visible=false}` 反向只要隐藏段（`a748590-q438320-s06-b1.tex:15-19`）。
- **多面体棱线分离**：`g:Edges(P)`（大写 E）一次拿 `{visible=, hidden=}`（`d114-*-c14601743-b1.tex:12-14`）；立体轮廓 `g:Outline(C)` 同构（`d102-*-c14513457-b1.tex:14-19`）；单面判断 `g:Isvisible(F)`（`assets/luadraw-doc-en/plans.tex:20`）。
- **贴面线防重叠**：贴着面片画的线用 `ld.scale3d(L, 1.01)` 从轴心微放大 1% 把线"剥"离表面，消除视觉重合（`d087-*-c14434252-b1.tex:14-15`）。

### 7.6 缩短代码的封装技巧

- **字符串即约束**：`ld.constraint('a*x+b*y<c')` 用 `load("return function(x,y,z) return "..expr.." end")` 编译求系数 → `lineEq`；循环 `cutpolyline(Box2d(),D,true)` 得解域——线性规划从 30 行缩到 3 行：`d298-*-c17916655-b1.tex:41-57`。
- **插值即函数**：过三点的抛物线 `ld.parabola(A,B,C)` 拉格朗日直接返回函数：`d249-*-c16927920-b1.tex:25-33`。
- **复函数即矩阵**：`ld.matrixof(f)` 从复映射直接提取仿射矩阵，递归分形不用手推系数（`assets/luadraw-doc-en/Pythagore.tex:9-12`）。
- **结果进 TeX 宏**：`function defmac(name,body) token.set_macro(name,body,"global") end`，图内 `defmac("SA", dist(S,A))` 正文 `\SA`：`d184-*-c15659408-b1.tex:219-221`；luacas 精确解→`luadraw.x1t = "$"..r[1]:tolatex().."$"`，数值解→`load("return "..temp)()`：`d346-*-c18664344-b1.tex:18-21`。
- **坐标轴标注一站式**：`g:Daxes({0,pi/2,1}, {labeltext={"\\pi",""}, labelden={2,1}, nbsubdiv={3,1}, gradlimits=, xyticks={0,0}, myxlabels/myylabels={位置,"$标签$",...}, labelshift=, originpos=, legend=, legendpos=, legendsep=})`——π/√2 数学刻度、稀疏自定义刻度、图例位置全在一张选项表（`assets/luadraw-doc-en/axes_grid.tex:6`、`d228-*-c16122879-b1.tex:15-33`）；非正交比用 `size={12,9,8/pi}` 第三项。
- **TeX↔Lua 外围桥**：`\def\Sequence#1#2#3{\directlua{Sequence(function(#2) return #1 end,#3)}}` 让正文写公式、Lua 执行（`a754686-q754620-s05-b1.tex:38`）；`tex.sprint` 从 Lua 循环直接吐 TeX（调色板目录 `d095-*-c14653471-b1.tex`）；页脚/每页背景图 `\cfoot{\directlua{do_cfoot()}}`、`\AddToHook{shipout/background}`（`a760676-q760668-s08-b1.tex`、`a761442-q761440-s08-b2.tex`）；内嵌数据 `\begin{filecontents*}{data.csv}`（`a757330-q757325-s13-b1.tex`）；`.tkz` 输出目录 `\def\luadrawTkzDir{tikz/}`（`d049-*-c14153982-b1.txt`）；外部进程桥 `io.open + os.execute("python3 gen.py")` 生成数据再 `read_csv_file`（`a751587-q751568-s12-b2.tex:14-36`）。

### 7.7 动画技巧

- 帧内增量绘制：轨迹增长 `table.insert(C1,a)`，`ld.nbimages = #C` 由数据定帧数：`a763431-q280206-s09-b1.tex`。
- 分段状态机叙事：`if k<=10 ... elseif k<=71 ... else ...` 控制"入场-演示-出场"：`a763033-q735114-s10-b1.tex:34-71`。
- `animateinline` 加 `palindrome` 往复；每帧 `Setviewdir` 换视角后 `IDmatrix3d()` 复位：`a762095-q762086-s11-b1.tex`。
- 导出 GIF：`Savetofile + Cleargraph` 循环 + ImageMagick；中间 `.tkz` 写进 `cachedir`（包选项设缓存目录，不污染源码目录）：`d137-*-c14894434-b1.tex:12,37-41,55-56`。
- **往复动画只渲染一半**：播放循环 `if i > nb then i = 2*nb-i end` 索引折返，nb 帧当 2nb-1 帧用；动画参数 `linspace(0,90,nb)` 一次生成：`d137-*-c14894434-b1.tex:34-35,46-48`。
- 标签随动 `pos` 用分段函数 `Tpos(x)` 按象限选 NW/NE/SW/SE：`d254-*-c16941054-b1.tex:54-68`。
- **跨帧累积状态**：闭包变量在 makeframe 间保持——切掉一半再切另一半 `poly,poly2 = cutpoly(poly,P,true)` 逐步剖切、粒子运动 `pos = pos+dt*V` 弹墙反射，全部只改状态不重建（`a763033-q735114-s10-b1.tex:34-71`、`a764547-q764528-s04-b1.tex:44-50`）。
- **帧内换视角两法**：`g:Rotate3d(theta[k],{Origin,vecK}) ... g:IDmatrix3d()` 转画面不转数据（`a762051-q762044-s08-b1.tex:23-24`）；多视图并排 `Saveattr/Viewport/Setviewdir("xOy")/Restoreattr` 直接写进 makeframe（`a762095-q762086-s11-b3.tex:48-54`）；`g:Defaultattr()` 开帧重置属性（`a754855-q754846-s16-b2.tex:22`）。

### 7.8 文字与外部内容上几何体

- **TeX 排版贴到曲面**：`compile_tex(text,"id")` → `Compiled_tex2path3d(L,{anchor=,dir={u,v},polyline=true})` → `ftransform3d` 缠绕到柱/球 → 可见性分离后填充；完整范本（含云朵）`d158-*-c15147389-b1.tex:54-66`。
- 本地覆写 `compile_tex` 支持中文/多语言（改 `usepackage` 与 `pdflatex` 命令）：`d158-*-c15404851-b1.tex:21-40`。
- **折线→路径桥**：`Beginclip(ld.polyline2path(C))` 把任意折线变可填充/可裁剪路径（29 处使用）；3D 对应 `polyline2path3d`，在填充要合并多条轮廓或弧线时需要：`Dpath3d(polyline2path3d(border(...)), "ball color=..,even odd rule")`（`d172-*-c15463972-b1.tex:17`、`a763510-q763505-s06-b1.tex:6`）。单条轮廓不必过桥：`Dpolyline3d(border(S),"ball color=blue, fill opacity=0.5")` 已经能带径向渐变（`d084-*-c14390226-b1.tex:20`）。
- **编译文本绘制选项**：`g:Dcompiled_tex(L,0,{scale=2, hollow=true, drawbox=true, dir={u,v}})` 空心填充/画包围盒/贴平面；`compile_tex(text,"id",true)` 第三参数把笔画变细条便于填充；变形链 `compiled_tex2polyline(L,{3,3}) → ftransform(L,f) → Dpath(polyline2path(L))` 波浪化示例（`assets/luadraw-doc-en/compile_tex2d.tex:10-19`）。
- **图像贴图选项**：`g:Dimage(f, Z, {pos="SE", matrix={0,-1,i}, graphics_options="width=4.5cm"})`——`matrix` 直接给对称/旋转（2×2 复矩阵），`graphics_options` 透传 `\includegraphics`（`assets/luadraw-doc-en/Dimage.tex:13-19`）；三角形面贴图 `Dmapimage(f, facet, {border_options=})`（`assets/luadraw-doc-en/Dmapimage.tex:15-16`）。
- **图像贴到任意平面/顶点**：`BeginOnPlane({A,U,W},{out=mat}) → Dimage(f,0,{matrix=mat})`：`d283-*-c17334343-b1.tex:36-41`。
- 地图上球：`(lon,lat) → ld.sM(lon, 90-lat)` + `DSregion/DScurve` 分层画海陆岸：`d320-*-c18219103-b1.tex:71-109`。

### 7.9 bug 规避与热修

- **临时全局补丁用完置 nil**：`sss_triangle = ld.sss_triangle -- patch ... sss_triangle = nil`（绕旧版内部引用）：`d296-*-c17824348-b1.tex:15-31`。
- **包装覆写**修系统差异：`local old_exec = ld.graph3d.Pov_exec; function ld.graph3d:Pov_exec() ... old_exec(self, ...) end` 修 Windows 全路径：`d233-*-c16197966-b1.tex:11-24`。
- `Pov_show` 尺寸对不上时自算矩阵：`matrix={Z(0,0), Z(1/g.Xscale,0), Z(0,1/g.Yscale)}`：`d347-*-c18727946-b1.tex:26-33`。
- 需要某些元素最后画：`g:Begindeferred() ... g:Enddeferred()` 延迟到图尾：`d323-*-c18236397-b1.tex:26-28`。

### 7.10 计算侧构造器：几何即数据

> 由通读全部语料得到。下面每个名字都在 `luadraw-v3.5/luadraw/files/` 里核对过；依赖参数顺序前请重读函数头部（有几个函数接受两种调用顺序）。

- **立体是数据，不是图**：`ld.cylinder(A,V,R[,nb,open])`、`ld.cone(A,V,R[,nb,open])`、`ld.frustum(C,R,r,V,A[,nb,open])`、`ld.sphere(A,R[,nbu,nbv])` 返回多面体，可直接喂给 `cutfacet`、`clip3d`、`Classifyfacet`、`Intersection3d`、`border`；`g:Dcylinder/Dsphere/Dcone` 只负责画（`luadraw_build3d.lua:642-764`；`a762729-q360412-s06-b1.tex:13`、`a762827-q707966-s05-b1.tex:13-15`、`d319-*-c18204595-b1.tex:15-16`）。
- **多面体与正多边形底面**：`ld.parallelep(A,v1,v2,v3)`、`ld.tetra(S,v1,v2,v3)`、`ld.tetra_len(ab,ac,ad,bc,bd,cd)`（六条棱长）、`ld.prism(base,V[,open])`、`ld.pyramid(base,apex[,open])`；正多边形底面是 `ld.polyreg(center,vertex,n)` 再用 `ld.map(pt3d.toPoint3d, …)` 升到 3D（`frustum_pyramid.tex:10`、`d186-*-c15663971-b1.tex:18`、`a764066-q730348-s06-b1.tex:13`）。向量默认成右手系：用 `if pt3d.det(u,v,w)<0 then` 交换两个向量（`d325-*-c18295304-b1.tex:26-30`），棱柱则对底面 `reverse(base)`（`d127-*-c14774246-b1.tex:18`）。
- **开口与裁剪**：`table.remove(P.facets,n)` 去掉一个面（`boite_sucres.tex:44`、`d119-*-c14662370-b1.tex:15`、`a755874-q755843-s06-b1.tex:21`）；`ld.getfacet(P,{2,3,4,6})` 只留列出的面（`d083-*-c14382184-b1.tex:13`）。
- **曲面是数据**：`ld.cartesian3d(f,x1,x2,y1,y2[,grid,addWall])`（默认网格 `{25,25}`；`addWall` 取 `0`、`"x"`、`"y"`、`"xy"`，返回给 `Dscene3d` 用的分隔墙）、`ld.surface(p,u1,u2,v1,v2[,grid])`、`ld.cylindrical_surface(r,z,u1,u2,v1,v2[,grid,addWall])`（点为 `Mc(r(u,v),v,z(u,v))`）、`ld.rotline(L,axe,a1,a2,args)`（3D 点列扫出的曲面）、`ld.rotcurve`、`ld.curve2cylinder`（`luadraw_build3d.lua:861-896,1140,1185`）。当作普通 `ld.` 函数调用，再由一个 `g:D*` 调用画出结果（`a764634-q764630-s08-b1.tex:16`、`d212-*-c15889797-b1.tex:14`、莫比乌斯带 `d318-*-c18179650-b1.tex:13-22`）。
- **不用循环放样与扫掠**：`surface(function(u,v) return (1-v)*A(u)+v*B(u) end,0,1,0,1,{nu,2})` 连接两条曲线（`d216-*-c16031275-b1.tex:12`）；`ld.domain3(f,g,a,b)` 是两曲线之间的区域，升到 3D 后用 `ld.rotline` 旋转（`d307-*-c18041298-b1.tex:19-23`）。
- **自然坐标点**：`Mc(r,theta,z)` 柱坐标、`Ms(R,theta,phi)` 球坐标（弧度；`luadraw_point3d.lua:184,190`）、`cpx.Zp(r,theta)` 复数极坐标（`luadraw_complex.lua:294`）：参数曲面一行就写完（`a762163-q762158-s06-b1.tex:13-15`、`d216-*-c15983246-b1.tex:18`）。

### 7.11 3D 绘图图元与场景元素家族

> 已在 `luadraw_graph3d.lua`、`luadraw_lines3d.lua`、`luadraw_frustum_and_co.lua` 核对。优先用这些一次调用的写法，不手搭点列。

- **路径小语言在 3D 里也有。** `g:Dpath3d(L,draw_options)` 及其计算孪生 `ld.path3d(L,nbdots)` 读一张扁平表，里面是 3D 点、数字和指令码：`"m"` 移动、`"l"` 直线、`"b"` 贝塞尔、`"c"` 圆、`"ca"` 圆弧、`"e"` 椭圆、`"ea"` 椭圆弧、`"s"` 样条、`"cl"` 闭合（`luadraw_graph3d.lua:2087,2101`）。参数写在指令码之前：圆 `{P,center,normal,"c"}`；圆弧 `{B,center,C,r,sens,normal,"ca"}`（法向可省，`g.Normal` 给出轮廓弧）；椭圆 `{A,center,r1,r2,dir1,normal,"e"}`。一次调用就能填出半球冠、球面扇形、带孔球面（`concat(…,Cylborder)` 加 `"even odd rule"`）或圆环（`{…,"c"}` 子路径）：`d127-*-c14774246-b1.tex:23,30`、`a766810-q499733-s04-b1.tex:35-36`、`a762095-q762086-s11-b2.tex:21-27`、`d156-*-c15106943-b1.tex:17`。2D 的 `g:Dpath` 同样认识 `"ea"` 和圆角码 `"la"`/`"cla"`（`luadraw_graph.lua:1454-1455`）。
- **球面上的坑。** 纬线或经线要由切点构造：`local A,B = table.unpack(g:Sphere_tangency(C,R,{C,N}))` 再 `g:Dpath3d({A,C,B,R,sens,N,"ca"})`；手写圆心加偏移的圆弧是错的（`d312-*-c18080177-b1.tex:16-23`，原文把朴素写法注释掉并标为 wrong）。
- **圆、弧、角一次调用。** `g:Dcircle3d(C,R,normal[,opts])`（也接受 `{C,R,normal}`）、`g:Darc3d(B,A,C,R,sens[,normal][,opts])`（圆心是 `A`）、`g:Dangle3d(B,A,C[,r,opts])`（默认 `r=0.25`）、`g:Dellipticarc3d(B,A,C,r1,r2,sign,dir1,normal,opts)`。`normal` 位置上放字符串时被当作选项（`luadraw_graph3d.lua:525-630`）。启用 `luadraw_decorations` 扩展后，`Darc3d` 还接受带 `label`、`pos`、`sector_options`、`ticks` 的选项表（`decorated_arcs3D.tex:18-41`）。`Darc3d` 取 `sens=1` 与 `sens=-1` 画出圆的两半，可见与隐藏部分因此是两次调用：`d054-*-c14222166-b1.tex:19-25`。`normal=g.Normal` 时 `Dcircle3d` 就是球的视轮廓。
- **平面、直线、点。** `g:Dplane(P,V,L1,L2[,mode,opts])` 画平面 `{A,u}` 的一块有界区域（`mode=ld.left+ld.bottom` 只保留所选的边，默认 `ld.all`）；`g:Dline3d(A,B[,opts])` 或 `g:Dline3d({A,u})` 画整条直线；`g:Dballdots3d(L,color,scale)` 画球点；`g:Dcrossdots3d({P,normal},color,scale)` 在平面内画叉点（`Dplane.tex:12`、`Ddots3d.tex:13,24`、`d330-*-c18382355-b1.tex:33`）。
- **带网格的盒状坐标轴一次调用。** `g:Dboxaxes3d{grid=true,gridcolor=,fillcolor=,drawbox=,xyzstep=,xstep=,zstep=,xgradlimits=,zlabelsep=,labels=}`（默认值在 `luadraw_graph3d.lua:2121-2153`：`xyzstep=1`、`gridcolor="black"`，范围取自 3D 窗口）。这是常见的背景：`a751611-q751606-s15-b1.tex:18`、`a752719-q752634-s09-b1.tex:12`。
- **按位置上色。** `usepalette={pal,"z"}`（或 `"x"`、`"y"`，或面片的函数，再加可选的 `{min,max}`）被 `Dfacet`、`Dmixfacet`、`Dpoly` 的 mode 0、`addFacet`、`Pov_*` 接受（`luadraw_graph3d.lua:1138-1140,1282,1340,1453`）。函数接收面片：`function(f) local G=isobar3d(f) return -sqrt(abs(G.x)*abs(G.y)) end`（`d241-*-c16685879-b1.tex:18-37`）；`ld.getpalette(pal,n,true)` 对调色板取样（`d304-*-c17991115-b1.tex:21-45`）。
- **Dscene3d 元素家族。** 除 `addPoly`、`addPolyline`、`addWall` 外：`addFacet(facets,opts)`、`addPlane({A,n},opts+scale,rectangle)`、`addLine({A,u},opts)`、`addDots(P,opts)`、`addLabel(text,P,opts, …)`（三元组）、`addAxes(O,{arrows=,legend=,hidden=})`、`addAngle(B,A,C,r,opts)`、`addArc(B,A,C,r,sens,normal,opts)`、`addCircle(A,r,normal,opts)`（`luadraw_graph3d.lua:1449-1958`）。把坐标轴、标签、点和圆放进场景，遮挡就由渲染层处理，整张图是一次声明式调用：`a761682-q761676-s11-b1.tex:18-19`、`intersection_plans.tex:13-22`、`a747719-q747599-s11-b1.tex:11-22`、`d054-*-c14222074-b1.tex:15-20`。`addWall` 可接收循环里构造的墙列表（`a762910-q409950-s05-b1.tex:181-189`）。缺少的 `add*` 一行就能补：`function ld.graph3d:addArc(...) return self:addPolyline(ld.path3d(ld.arc3db(...),100),options) end`（`d313-*-c18089286-b1.tex:28-32`）。

### 7.12 可见性、截面与投影（语料变体）

> 扩展 §7.5。函数名已在 `luadraw_graph3d.lua`、`luadraw_frustum_and_co.lua`、`luadraw_lines3d.lua` 核对。

- **全局隐藏线是最省事的路线。** 构造器之后设一次 `ld.Hiddenlines=true; ld.Hiddenlinestyle="dashed"`，之后每个 `Dscene3d`、`Dpoly`、`Dedges` 调用都会画出隐藏棱；单个 `add*` 元素上的 `hidden=false/true` 可覆盖。一个 37 个文件的问答串问的就是这个问题，答案也是这个（`d054-*-c14222074-b1.tex:8`、`d058-*-c14256814-b1.tex:26,37`）。
- **用重画顺序，不用透明度。** 先填实体（`mode=5`），画遮挡物，再 `Dpoly(P,{mode=0,edgestyle=ld.Hiddenlinestyle})` 重画，虚线棱就出现在正确的层：`d054-*-c14222093-b1.tex:14-16`、`d054-*-c14222156-b1.tex:24-27`。
- **§7.5 之外的 Classifyfacet 变体。** (a) `Classifyfacet` 后接 `cutfacet(V,plane)` 保留平面上方的可见部分，其 `border` 可填渐变（`a747734-q747688-s08-b2.tex:10-14`、`a749068-q749064-s12-b1.tex:17-23`）；(b) 在 `Dscene3d` 内用 `addPolyline(border(V),{hidden=true})`（`a749232-q432511-s05-b1.tex:16-21`）；(c) `border(V1)` 填 `"ball color=.."` 勾出球冠轮廓（`a749588-q729038-s04-b1.tex:33-35`）。弯曲图元的第三条轮廓路线：投影底圆，`T=tangent_from(A,function(t) return g:Proj3d(Mc(R,t,H)) end,-pi,pi)` 给出两条母线（`d224-*-c16080890-b1.tex:15-24`）。
- **法向变化时的可见性。** §7.5 的平面判别对曲面失效。用有限差分取法向（`N=pt3d.prod(B-A,C-A)`，`B=f(x+h,y)`，`C=f(x+h,y+h)`），测试 `g:Cosine_incidence(N,A)>0`，再 `Lv,Lh=ld.split_points_by_visibility(L,visible)`（`d291-*-c17657460-b1.tex:19-24,53-57`）。中心投影下 `Cosine_incidence` 使用相机位置（`luadraw_central_perspective.lua:119`），球的轮廓是 `ld.interSS({C,R},{(ld.camera+C)/2,abs(ld.camera-C)/2})`（`d295-*-c17753904-b1.tex:39-41`）。
- **用求解找轮廓。** `ld.solve(function(t) return pt3d.det(g.Normal,T+Mc(r,t,0),Mc(r,t+pi/2,0)) end,-pi,pi)` 给出圆与轮廓相交处的两个参数；把端点交给 `Darc3d` 或 `Dpath3d`（`d108-*-c14550040:22-24`、`d288-*-c17604343-b1.tex:20-27`）。
- **截面曲线。** `Intersection3d(solid,plane)` 返回带 `.visible/.hidden` 的边，用 `g:Dedges(I,{hidden=true,color=})` 画。球的三个大圆就是三个平面 `{O,vecI}`、`{O,vecJ}`、`{O,vecK}`，三行各用一种颜色画出（`a748039-q735927-s08-b1.tex:14-23`、`a749588-q729038-s04-b1.tex:26-39`）。`ld.cutpolyline3d(curve,{Origin,g.Normal})` 把开曲线分成前后两段；`ld.clippolyline3d(L,g:Box3d())` 把它裁到窗口内（`a765334-q765325-s04-b1.tex:28`、`a764420-q764412-s06-b1.tex:21`）。`ld.merge3d(lists)` 把若干段拼成一条可填充的轮廓（`d272-*-c17197290-b1.tex:41`）。
- **曲面上的闭曲线。** 用 `ld.pxy(P,z)` 投影平面多边形，`ld.prism(poly,M(0,0,4))` 拉伸，对曲面 `clip3d`，`ld.border(S2)` 就是边界曲线，一次 `Dpolyline3d`（`d291-*-c17646319-b1.tex:31-36`）。两条这样的边界之间的带，用 TikZ 奇偶规则一条路径即可：`Dpath3d(ld.concat(polyline2path3d(border(S2)),polyline2path3d(border(S1))),"even odd rule, fill=red, draw=none")`（`d291-*-c17650980-b1.tex:17-25`）。由几段拼成的闭曲线写成一个参数函数：`local tri=function(t) if t<1 then return fAB(t) elseif t<2 then return fBC(t-1) else return fCA(t-2) end end`，再 `g:Dparametric3d(tri,{t={0,3}})`。
- **平行截面 = 缩放。** 金字塔中平行于底面的截面是 `ld.scale3d(base,k,apex)`，不必切（`d225-*-c16407887-b1.tex:15-16`）。与墙面共面而 z-fighting 的面片，绕一点缩小并抬高，`scale3d(P,0.99,h/2*vecK)`（`d225-*-c16406372-b1.tex:17`）；两个切开的半块之间的接缝，在切平面上画一条白线段盖住（`d317-*-c18166438-b1.tex:23-34`）。
- **切点家族**（`luadraw_frustum_and_co.lua:270-292`）：`g:Cone_tangency(B,R,V,H)`、`g:Cylinder_tangency`、`g:Frustum_tangency(B,R,r,V,H)`、`g:Sphere_tangency(C,R,P)` 返回点列（圆柱返回 `{M1,M2,M1+V,M2+V}`）；各自有 `*_outline` 孪生，返回 `.side .section .visible .hidden .tangency .angle`，每个一条 `Dpath3d`、各带渐变（`a765584-q701093-s04-b1.tex:14-17`）。`ld.orthoframe({B,V})` 一次给出标架（`luadraw_build3d.lua:31`）。
- **阴影。** 用 `ld.proj3dO(A,{z0*vecK,vecK},A-light)` 投影，取 `cvx_hull3d(ftransform3d(P.vertices,proj))[1]`，构造光束 `pyramid(shadow,light,true)`，由 `Classifyfacet(beam)` 分层；`if not g:Isvisible(shadow) then shadow=reverse(shadow) end` 修正朝向（`d148-*-c14983235-b1.tex:24-47`）。球的阴影是把圆 `interSS(S,{(light+C)/2,abs(C-light)/2})` 投影得到（`d148-*-c14977225-b1.tex:15-23`）。
- **投影方式。** `viewdir={"yz",0.65,50}` 是 `yz` 平面上的斜二测（cavalier）视图，参数为比例和角度；`"xz"`、`"xy"`、`"iso"` 也存在（`luadraw_graph3d.lua:39-42,71-90,157-160`；`d262-*-c17115885-b1.tex:19`）。字符串或 `{字符串,k,alpha}` 走 `perspective`，`{theta,phi}` 是正投影。
- **同一物体多个视图。** 用 `g:Shift` 排版面板，每个面板设 `g:Setviewdir(…)`，朝向用 `Savematrix/Rotate3d/Restorematrix`：`a766533-q766527-s03-b2.tex:25-27`、`a766885-q212356-s04-b1.tex:50`。分解图是每个面板 `g:Shift(Z(tx,ty)); draw; g:Shift(-Z(tx,ty))`（`d306-*-c18021188-b1.tex:23-46`），连续 `g:Shift3d(3*vecJ)` 可把立体沿一条线摆开。
- **面片附带数据。** 在面片末尾附加数据，交给 `g:Sortfacet` 排序，再用 `table.remove(F)` 取回：`a766885-q212356-s04-b1.tex:26`、`d293-*-c17679729-b1.tex:17,24-29`。

### 7.13 2D 辅助函数、球面模块、展开图与构造器选项

> 名字已在 `luadraw_graph.lua`、`luadraw_lines.lua`、`luadraw_curves.lua`、`luadraw_spherical.lua`、`luadraw_cvx_polyhedra_nets.lua`、`luadraw_base.lua` 核对。

- **曲线一次调用。** `g:Dcartesian(f,{x={a,b},nbdots=,discont=true,nbdiv=,draw_options=,clip=})`；`discont=true` 在渐近线处（`1/x`、`tan`）断开折线，不必手工收缩定义域（`luadraw_graph.lua:617-619`；`a755221-q755217-s09-b1.tex:15`、`d344-*-c18581711-b1.tex:23`）。`Dparametric` 接受同样的键。`ld.cartesian`、`ld.parametric`、`ld.implicit` 是计算孪生，返回点列。`g:Dtcurve(L,{showdots=,draw_options=})`，`L={pt1,{t1,a1,t2,a2},pt2,…}`，是带指定切向长度与角度的曲线（`tcurve.tex:6-15`；`ld.tcurve` 是可供 `interDL` 使用的计算形式：`d285-*-c17452417-b1.tex:27-36`）。`ld.curvilinear_param(L)` 返回 `f:[0,1]->L`，于是 `Dparametric(f,{t={a,b}})` 能给路径的任意子段换样式（`a758842-q758837-s05-b1.tex:12-17`）。
- **区域即数据。** `ld.polyreg(center,vertex,n)` 正多边形；`ld.sss_triangle`、`ld.sas_triangle`、`ld.asa_triangle` 返回 `{A,B,C}`，`A=0`；`ld.hom(L,k,center)` 作用于整张列表，迭代函数系统就是 `T=ld.concat(hom(T,0.5,A),hom(T,0.5,B),hom(T,0.5,C))`（`Sierpinski.tex:10`）；任意映射的多份拷贝可用 `ftransform`（`d168-*-c15334856-b1.tex:15-25`）。`ld.cutpolyline2(R,f,"<",true)` 用函数曲线裁剪区域（`cutpolyline2.tex:8`）；`ld.domain3(f,g,a,b)` 是两曲线之间的轮廓；`ld.line2strip(L,wd,closed,ends,mode)` 是等宽带，容差边框就是外带 + 内带 + 填充（`a755089-q540697-s04-b1.tex:18-22`）；`ld.delaunay(points)` 给三角形，`ld.voronoi(points,window)` 给 `{site,cell}` 对（`delaunay.tex:8`、`voronoi.tex:8`）。
- **由点确定直线与圆。** `g:Dline(A,B,opts)` 是过两点的整条直线，`g:Dline({A,u})` 是点加方向；`g:Dmed(A,B,opts)` 中垂线；`g:Dcircle(A,B,C,opts)` 或 `Dcircle({A,B,C})` 过三点的圆；`g:Dsquare(a,b,sens,opts)`；`ld.perp(D,A)`、`ld.proj(P,D)`（`orthocentre.tex:8-22`、`a758274-q758255-s08-b1.tex:26`）。
- **填充样式。** `g:Filloptions(style,color,opacity,evenOdd)` 设置随后的填充：`"full"`、`"none"`、`"gradient"`（此时第二个参数是渐变样式），以及阴影线 `"horizontal"`、`"fdiag"`、`"bdiag"`，配 `Dpolyline(P,true,"draw=none")` 绘制；用 `Filloptions("none","black",1)` 复位（`luadraw_graph.lua:440`；`cutpolyline.tex:15-18`、`d113-*-c14597207:15-19`）。TikZ 图案也可直接放进 `draw_options`：`"pattern=north west lines,pattern color=gray"`。沿曲线的标记只需一个选项串：`"decorate,decoration={markings,mark=between positions 0 and 1 step 8mm with {\\fill circle (1.8pt);}}"`（`a751726-q751702-s04-b1.tex:79-82`）。
- **标签与旋转坐标系。** `g:Labelangle(a)` 让标签绕锚点旋转（`Restorematrix` 之后务必复位为 `0`）：`d297-*-c17843711-b1.tex:20,30`。`g:Labeldir({u,v})` 设置标签基向，在 3D 平面上画 2D 坐标轴时需要；更短的路线是 `g:BeginOnPlane({Origin,vecI,vecJ},{labeldir="auto"})` … `g:EndOnPlane()`（`luadraw_graph3d.lua:2406`；`d217-*-c15995179-b1.tex:16`，`d338-*-c18516339-b1.tex:21-30` 每个平面各带 `view={…}`）。`ld.defaultlabelshift=0` 去掉默认偏移，`ld.siunitx=true` 让刻度标签走 `\num{}`（`luadraw_graph2d.lua:21`、`luadraw_real.lua:17`）。`Daxes` 接受 `legendangle={deg,deg}`、`legendstyle={pos,anchor}`，以及单轴为 `"auto"` 的 `limits`（`d340-*-c18519151-b1.tex:11-19`）。
- **斜坐标轴。** 先 `g:Setmatrix({0,1,1+i})` 一次，之后 `Dgrid`、`Daxes`、`Dcartesian`、`Dcircle` 都按斜坐标渲染（`axes_non_ortho.tex:7-8`）。同一几何画两次是 `Dpath(C); Setmatrix(m); Dpath(C)`，不要再写第二份点列（`a749885-q749872-s09-b1.tex:11-13`）。
- **函数的矩阵。** `ld.matrix3dof(f)` 把仿射点映射变成矩阵，`g:Composematrix3d(m)` 把它复合到当前矩阵；`Shift3d`、`Rotate3d`、`Scale3d` 就是这样实现的（`luadraw_graph3d.lua:289-315`；`a764016-q359115-s04-b1.tex:29`）。用 `g:IDmatrix3d()` 复位。
- **球面模块细节。** 先 `g:Define_sphere{center=,radius=,color=,mode=,edgewidth=,hiddenstyle=,opacity=,show=}` 一次，再调用 `DS*`（`DScircle`、`DSarc`、`DSpolyline`、`DSfacet`、`DScurve`、`DSregion`、`DSdots`、`DSplane`），最后 `g:Dspherical()` 把分好前后层的部件一次输出。`show=false` 得到不可见遮挡体：`DS*` 元素被它遮挡，可见曲面另外绘制（`a759957-q759936-s06-b1.tex:15-19`）。`DScircle({P,axis})` 由一点和一个方向确定圆；`{out=t}` 返回它的两个切点（`d162-*-c15268110-b1.tex:20-21`、`d172-*-c15442327-b1.tex:19-26`）。`ld.sM(lon,lat)` 构造球面点，`ld.toSphere(A)` 把任意点抬到球面，`ld.map(ld.toSphere,L)` 处理整条曲线（`d295-*-c17736042-b1.tex:22-29`）；`ld.projstereo(L,{C,R},N,h)` 投影到平面，`ld.inv_projstereo` 是其逆。在整个 `DS*` 家族外套一个缩放矩阵（`Setmatrix3d({Origin,3*vecI,vecJ,vecK})`）即可画出椭球（`a757747-q655921-s04-b1.tex:12-16`）。
- **展开图。** `g:Dpolyhedron_net(P,{tabs=true,opening=,rotate=,model=,facet_name=,edge_name=,tabs_options=,facet_options=})`：`opening∈[0,1]` 半展开，`model` 指定展开顺序，`facet_options` 可以是字符串或选项表（`luadraw_cvx_polyhedra_nets.lua:116-130,335-347`；`parallelep_net.tex:10-11`、`parallelep_net3.tex:16-20`）。
- **构造器选项。** 除 `window`、`size`、`margin={top,right,bottom,left}`（给数字即四边相同）外，还有 `bg="color"` 与 `bbox=false`（`luadraw_base.lua:20-30`）；`luadraw_graph.lua:25` 的头注释里 `margin` 顺序不同，依赖顺序前先试。`luadraw-env` 的选项 `exec=false` 与 `auto=false,exec=true` 控制外部执行（`d319-*-c18201340-b1.tex:36`、`a759151-q714248-s11-b3.tex:8`）。
- **占用数据。** 在构造数据时就决定可见性：用 0/1 数组描述方块，只生成与空格相邻的面；剩下的交给 `backcull`，不需要任何隐藏线代码（`boite_sucres.tex:20-39`、`cubes_empiles.tex:26-49`）。

### 7.14 排版、约束列表与原生 TikZ

> 名字已在 `luadraw_graph.lua` 与 `luadraw_graph3d.lua` 核对。标 *线程内* 的是该讨论串作者自己定义的 helper，不是库函数。

- **不写布尔代码的半平面。** `g:Dinequalities({f1,">",f2,"<",…},args)` 返回区域；它为每个不等式开一个 `Beginclip`，窗口只画一次，再全部关闭，所以叠加的裁剪就是交集（`luadraw_graph.lua:883`；`d245-*-c16856324-b1.tex:34-39`）。线性规划：`ld.constraint('a*x+b*y<c')` 得到 `lineEq`，`g:Box2d()` 作初始多边形，每个约束 `ld.cutpolyline` 一次，`g:Dline(lineEq)` 画边界，标签文字取自约束字符串，标签侧用 `if math.abs(cpx.arg(dir))>pi/2 then dir=-dir; pos="S" end` 翻转（`d298-*-c17934295-b1.tex:44-48,66-85`）。带 `select("#",...)` 和尾部输出表的变参 `g:Dconstraints('expr',{opts},…)` 是*线程内*的（`d298-*-c17941344-b1.tex:55-58,100-110`）。
- **实数轴上的子集**（*线程内* `interval(x1,x2,y,left,right,opts)`）：该函数由位置参数演变为一个选项表 `{legend=,leftlabel=,rightlabel=,pattern=}`，使用了六次，过得了三次门槛；`g:Getview()` 返回窗口，`math.huge` 端点因此能夹到边缘，`0.25/g.Xscale` 把 cm 换算成用户单位给箭头留空间（`d299-*-c17871538-b1.tex:14-38`）。
- **画一次，摆多处。** 一条路径或一个图形作为数据，在两次绘制之间用 `Setmatrix`、`Shift` 或 `Scale`：逐层缩小的嵌套拷贝是 `for k=1,nb do g:Dpath(band,…); g:Scale(0.65) end`（`d138-*-c14899715-b1.tex:9-14`）；N 重对称是 `t=table.copy(C); for k=1,N-1 do t=ld.concat(t,ld.rotate3d(C,k*360/N,axis)) end`（`a759151-q714248-s11-b3.tex:31-34`）；平铺是 `concat(base,shift3d(base,k*vecI),shift3d(base,-k*vecI))` 再一次 `Dfacet`（`d140-*-c15060325-b1.tex:29-45`）。`ld.ftransform3d(path,f)` 在 `f` 里加 `isPoint3d` 判断后，可整体平移含指令字符串的路径（`a755346-q755343-s08-b1.tex:31-36`）。
- **按角点上色。** 用四个顶点颜色拼出 `"upper left=c1,upper right=c2,lower left=c3,lower right=c4"` 得到双线性色块；用键为 `x.."/"..y` 的记忆表存已算的值，`cutfacet` 新生成的顶点在未命中时重新计算（`d104-*-c14977791:26-39,62-79`、`d111-*-c14570983:20-39`）。
- **屏幕空间坐标轴。** 对 `g:Proj3dV(vecI)`（以及 `vecJ`、`vecK`）用 `g:Dgradline`，不用 `Daxes3d` 就得到带刻度的斜轴，配 `Dballdots3d` 画刻度点，每根轴各设 `Linecolor/Labelcolor/Labeldir`（`a757441-q757434-s08-b1.tex:18-20`、`a757478-q757445-s04-b1.tex:16-27`）。沿投影轴方向、距离固定的标签用 `kx=(R+1)/cpx.abs(g:Proj3d(vecI))`（`d110-*-c14559937:35-39`）。
- **库里没有对应调用时写原生 TikZ。** `g:Writeln("\\begin{scope}[cm=…]")` 再写 `"\\pgflowlevelsynccm%"`，在平面上打开一个 2D 坐标系；矩阵来自 `g:Proj3dV` 和 `Mtransform`；以 `"\\end{scope}"` 收尾（`d302-*-c17987406-b1.tex:13-39,58-60`）。图形背后放一张 PNG：`g:Writeln("\\node[…] at "..g:Coord(Z(..)).."{\\includegraphics{render.png}};")`，曲面交给 POV-Ray，清晰的曲线由 Luadraw 叠在上面（`a759326-q759308-s10-b1.tex:17`）。优先用 `BeginOnPlane`（§7.13）。
- **TeX 与数字。** 数据是合成的时，`luacode*` 块可用 `io.open` 写 CSV，再用 `string.gmatch('([^,]+)')` 读回（`a757330-q757325-s13-b1.tex:8-39`）。点的字段 `P.x`、`P.y`、`P.z` 可拼进标签字符串 `"$P("..I.x..","..I.y..")$"`。多图文档里一次性定义 `\def\shortcuts{local ld = luadraw …}`，每个块开头写 `\shortcuts`（`d185-*-c17998535-b1.tex:20`）。

### 7.15 语料中出现的扩展模块调用

> 签名读自 `luadraw-v3.5/luadraw/files/` 下的扩展源码（`extensions/` 放各模块，使用前需 `require`）。选项取自函数头部注释，头部注释可能过时：依赖某个选项前请重读代码。

- **2D 图形。** `g:Drectangle(a,b,c,opts)`（`a`、`b` 为相邻顶点，对边过 `c`）、`g:Dwedge(B,A,C,r,sens,opts)`（扇形，一条带 `"ca"` 的 `Dpath`）、`g:DplotXY(X,Y,opts,clip)`（穿过点 `(X[k],Y[k])` 的折线；`luadraw_fields` 版本的 `X` 还可以是标签）（`luadraw_graph.lua:718,1010,1709`；`luadraw_fields.lua:72`）。
- **平滑色彩填充（`luadraw_shadedforms`）。** `g:Dshadedpolyline(L,pal,opts)`、`g:Dshadedrectangle(x1,x2,y1,y2,pal,{grid=,values=,bar=,bardist=,baroptions=,out=})`（`values` 是函数 `(x,y)->数值`）、`g:Dshadedregion(path,pal,opts)`（选项同 `Dshadedrectangle`）（`luadraw_shadedforms.lua:19,164,258`）。
- **大数据量（`luadraw_pdfliteral`）。** `g:Dliteralpolyline(poly1,args1,poly2,args2,…)`，`args={fill=,draw=,close=}`（颜色为 RGB 表，`"none"` 表示关闭）、`g:Dliteraldots({dots1},{color=,width=},…)`、`ld.graph3d:Dliteralfacet(F1,args1,…)`（选项同 `Dmixfacet`）（`luadraw_pdfliteral.lua:104,177,242`）。
- **弹簧与链（`luadraw_coils_chains`）。** `g:Dcoil(list,R,opts)` 与 `g:Dcoil2`、`g:Dchain(list,link_length,opts)` 与 `g:Dchain2(L,R,opts)`；`list={start,nb1,end1,…}` 或 `{折线,圈数}`（`luadraw_coils_chains.lua:17,242,306,394`）。
- **线性规划（`luadraw_linprog`）。** `g:DlinprogHalfPlanes(constraint1,opts1,…)`，约束是字符串 `'a*x+b*y<c'`；`g:DlinprogRegion(constraints,opts,objectives,objective_opts)`、`g:DlinprogObjectiveLine(obj,opts)`；3D 用 `ld.linprogSolve3d(constraints,x1,x2,y1,y2,z1,z2,objectives)`（`luadraw_linprog.lua:80,146,201,285`）。手写 §7.14 的 `ld.constraint` 循环之前先试这些。
- **对数坐标（`luadraw_log_axes`）。** `g:Beginlogview("logx"|"logy"|"logxy",x1,x2,y1,y2,opts)` … 对应的结束调用，之后 `Dlogpolyline`、`Dlogdots`、`Dlogline`、`Dloglabel` 直接用数据坐标绘制（`luadraw_log_axes.lua:25,409-434`）。
- **带装饰的弧（`luadraw_decorations`）。** `graph.Ddecoratedarc = graph.Darc` 与 `graph3d.Ddecoratedarc3d = graph3d.Darc3d` 是装饰版本的别名，`require` 之后普通的 `Darc`/`Darc3d` 就接受选项表（`luadraw_decorations.lua:476,483,577`）。
- **小工具。** `ld.bezier3d(a,c1,c2,b,nbdots)` 对 3D 贝塞尔曲线取样；`g:Dfrustum(A,R,r,V,B,args)` 是线框圆台（面片版本是 `ld.frustum`）；`g:Adjust_color(F,color,contrast,twoside)` 返回 `Dfacet` 使用的明暗颜色、法向和系数，自定义面片要与 `Dfacet` 保持一致的着色就用它（`luadraw_lines3d.lua:579`；`luadraw_frustum_and_co.lua:482`；`luadraw_graph3d.lua:1079`）。

---

## 附：速查清单

- [ ] 第一行 `local ld = luadraw`；只 local 用到的快捷方式；用到的 `math.*` 已在开场白 local，正文零 `math.`
- [ ] 图对象 `g`（或语义名）且 `local`；构造只用一个 options 表；`name=` 必写
- [ ] 结构选项进 table、TikZ 外观进 `draw_options` 字符串；**只写非默认项**；nil=保持；样式切换少而集中
- [ ] 线宽 ×10；**落在档位上必须写 TikZ 简写**（thick/ultra thick/very thick/semithick/thin…）且优先选档位粗细；角度用度且取 5 的倍数；绝对值取 0.5 的倍数；换算只用 `ld.deg/ld.rad`
- [ ] 计算 `ld.*`、绘制 `g:D*`、场景 `g:add*`；动手前先查 API 有没有现成函数
- [ ] 写循环或手搭点列之前，先查 §7.10–7.15 有没有现成的计算侧构造器、一次调用的 `D*` 图元或 `Dscene3d` 元素
- [ ] Save/Restore、Begin/End 严格配对；矩阵用完 `IDmatrix*` 复位
- [ ] 画家顺序绘制；**非必要不加注释**，仅极关键 trick 旁少量注释且只写为什么；代码整体简洁
- [ ] 非必要不设中间变量：选项串不足三次就地内联、超过三次改循环/表驱动；除开场白外不声明选项类 local，不做无用封装
- [ ] 目标是代码短且可读：要画三个及以上且文件因此变短才封装；helper 的参数是数据，不是绘图回调；不闭包捕获一堆外层 local；不给单个 luadraw 调用（`Dlabel3d`）套局部封装
- [ ] 两图并排用 `g:Shift`；`Saveattr/Viewport/Coordsystem/Restoreattr` 只用于真正独立的面板
- [ ] 几何先定义成数据，再声明式渲染（`Dscene3d`、`Classifyfacet`）；不手写标注偏移，`viewdir` 够用就不 `Rotate3d`
- [ ] 选项默认值现场查手册和源码（代码优先于头部注释），不凭经验、记忆或例子推断；`ld.Hiddenlinestyle` 与逐次 `hiddenstyle` 不并用
- [ ] 同族短调用 `;` 串联；(text, anchor, options) 三元组按行；(对象,选项)对收集后 `table.unpack`
- [ ] 最后一行 `g:Show()`（或 `Save()`）；动画收尾 `Sendtotex(); Cleargraph()`
- [ ] 变量：数学单大写字母、语义角色小写英文；无法语残留；无漏 `local`
- [ ] 骨架带 `\usepackage{fourier-otf}`；提交前跑一遍：Lua 注释是 `--`
