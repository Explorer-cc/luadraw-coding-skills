# luadraw Coding Style & Practical Tricks (based on the full assets corpus)

> **Corpus**: three groups of complete code under `assets/`, 816 files in total; this document does not distinguish sources and summarizes directly over all the code:
> `assets/luadraw-doc-en/` (125), `assets/stackexchange/` (281), `assets/github-discussions/` (410).
> Naming/indexing rules are in `assets/README.md`. All links in this document are repository-relative paths; `file:line` refers to the line number of the code in the file (the first line is the source comment).
> The conventions and example code in this document are written strictly against the **v3.5 API**; cited files serve only as sources of ideas and references.

## 1. The Agent's Eight Shames and Eight Honors

It is a shame to guess at interfaces blindly; it is an honor to consult documentation carefully.
It is a shame to execute vaguely; it is an honor to seek confirmation.
It is a shame to imagine the business blindly; it is an honor to have humans confirm.
**It is a shame to invent interfaces; it is an honor to reuse what exists.**
It is a shame to skip verification; it is an honor to test proactively.
It is a shame to break the architecture; it is an honor to follow conventions.
It is a shame to pretend to understand; it is an honor to be honestly ignorant.
It is a shame to modify blindly; it is an honor to refactor carefully.

> Engineering orientation in one sentence: **it is an honor to simplify and reuse code; it is a shame to over-engineer and reinvent the wheel**. Every chapter below is an elaboration of this principle.

## 2. Reference Code Examples (corpus guide)

| Directory                       | Content                                                                                                                                                                                                                                                               | How to use                                                                     |
| ------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| `assets/luadraw-doc-en/`        | All demos from the official manual (`champ.tex`, `orthocentre.tex`, `Dandelin.tex`, `torus.tex`, `palettes.tex`, `Pythagore.tex`...) plus the full sources of the extension modules (`module-*.lua`; e.g. `module-luadraw-doc2d-en-section-81.lua` is the teaching version of `luadraw_fields.lua`) | Each file's name is the `name=` of the luadraw environment; search by topic |
| `assets/stackexchange/`         | The author's 236 answers on tex.stackexchange, 281 code blocks                                                                                                                                                                                                        | `a<answer>-q<question>-s<score>-b<block>.tex`; sorting by score = sorting by quality |
| `assets/github-discussions/`    | The author's 410 code blocks from 246 threads of the official Discussions                                                                                                                                                                                             | `d<thread#>-<title>-c<comment#>-b<block>.tex`                                  |

Recommended entry path: `champ.tex` (2D skeleton) → `orthocentre.tex` (geometric construction) → `assets/luadraw-doc-en/torus.tex` (rotcurve+addWall, a condensed lesson in rendering-route decisions) → `d137-*-c14894434-b1.tex` (multi-view + GIF).

The official manual's conventions for presenting examples (copy them when writing documentation): code listed with minted + figure + `\captionof{figure}` + `\label`; API descriptions always follow "signature line (optional parameters in `[...]`) → option by option `option=default` → return-value shape"; pitfalls in bold **WARNING/Caution/NB** paragraphs.

## 3. The Fixed Skeleton Template

Almost all code shares the same skeleton; examples should not deviate from it:

```latex
\documentclass[border=5pt]{standalone}% compile with lualatex only   ← engine reminder
\usepackage[svgnames]{xcolor}                                        ← color prerequisite
\usepackage[3d]{luadraw}                                             ← remove 3d for 2D
\usepackage{fourier-otf}                                             ← default font
% <problem/source-link comment; when quoting someone else's code add a Source/Posted by/License header>
\begin{document}
\begin{luadraw}{name=a-meaningful-figure-name}   -- 1. name is mandatory; add exec=true for expensive recomputation
local ld = luadraw                        -- 2. opening shortcuts (see §4)
local g = ld.graph3d:new{ window3d=..., size={10,10}, viewdir={30,60} }  -- 3. create the graph; the object is called g, declared local
local f = function(t) ... end             -- 4. mathematical definition (anonymous local)
local S = ld.surface(f, ...)              -- 5. geometric computation (pure ld.*)
g:Dboxaxes3d{grid=true}                   -- 6. drawing (painter's order)
g:Dfacet(S, {usepalette={ld.palRainbow,"z"}})
g:Show()                                  -- 7. the ending is always Show() (or Save())
\end{luadraw}
\end{document}
```

- The constructor takes a single options table; graph objects other than `g` get semantic names (`graphview`, see `assets/github-discussions/d053-*-c14203101-b1.tex:12`).
- Environment options: `exec=true` forces recomputation (by default it reruns only when the source changes), `auto=false` turns off automatic recomputation (prevents accidental deletion/rebuild of shell-escape by-products such as .eps/.png): `\begin{luadraw}{name=x, exec=true, auto=false}` (`a762792-q762786-s07-b1.tex:14`, `d104-*-c14977791-b1.tex:8`); `margin={l,r,t,b}` in cm controls the figure margins, `bbox=false` hugs the content (`a754607-q754600-s10-b1.tex:8`).
- Environment variants: `\begin{luadraw*}` does not add the tikzpicture wrapper automatically (use it when nesting inside another tikzpicture, `a763306-q268159-s02-b1.tex`); within a single luadraw block you can rebuild `g = graph3d:new{...}` several times in a row combined with `Savetofile` to output multiple figures (`a749232-q432511-s05-b1.tex:26-40`). Naming consensus for the graph object: `g` (587 occurrences) > semantic names `graphview`/`graphzone` (for multiple figures or auxiliary viewports).
- Animation skeleton (template-level; the three `-- do not modify` spots are framework code):

```latex
\begin{luacode*}
luadraw.nbimages = 36
local g = ld.graph3d:new{...}
-- declarations: all heavy recomputation goes outside the frame loop; the frame function must be ld.makeframe (hung on the namespace)
function ld.makeframe(k)  -- do not modify this line / must be global
    -- draw image number k here (only increments inside a frame)
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

## 4. The Opening (shortcuts) Style

At the start of every environment, take exactly what you need, no more:

```lua
local ld = luadraw                    -- namespace alias, always first
local cpx, pt3d = ld.cpx, ld.pt3d     -- classes
local Z, i = cpx.Z, cpx.I             -- for 2D
local M, Mc, Ms = pt3d.M, pt3d.Mc, pt3d.Ms
local Origin, vecI, vecJ, vecK = pt3d.Origin, pt3d.vecI, pt3d.vecJ, pt3d.vecK
local cos, sin, sqrt, pi = math.cos, math.sin, math.sqrt, math.pi  -- localize every math.* you use here
```

- **Zero `math.` in the body**: every `math.*` function/constant used (cos/sin/tan/sqrt/exp/log/abs/pi...) is localized in the opening first, and the body uses the short names directly, avoiding `math.` prefixes all over the screen.
- The standard 3D opening trio (`Linejoin("round")` is almost always set): `g:Linejoin("round"); g:Linewidth(n); ld.Hiddenlinestyle = "dashed"` (see `assets/stackexchange/a763385-q691984-s05-b1.tex:61-63`).
- When it recurs, make it a reusable TeX macro `\shortcuts`: `assets/github-discussions/d243-*-c16843523-b2.tex:7-11`; global data crossing luacode/luadraw hangs on the `luadraw.` namespace (`luadraw.nbimages`, `luadraw.param`).

## 5. State Management (save/restore)

**Every Save must have a matching Restore**, otherwise the compilation errors out:

| Open                                              | Close                                     | Scope protected                      |
| ------------------------------------------------- | ----------------------------------------- | ------------------------------------ |
| `g:Saveattr([scope_options])`                    | `g:Restoreattr()`                         | view + drawing attributes            |
| `g:Savematrix()` / `g:Savematrix3d`              | `g:Restorematrix()`                       | transformation matrix (a staple of recursive fractals) |
| `g:Beginclip(path)`                              | `g:Endclip()`                             | clipping                             |
| `g:BeginOnPlane(...)` / `g:Beginlogview(...)`    | `g:EndOnPlane()` / `g:Endlogview()`       | plane/logarithmic coordinates        |

Derived patterns:

- **Four-panel subplot grid**: `Saveattr → Viewport → Coordsystem → draw() → Restoreattr` ×4, switching the projection in between with `g:Setviewdir(...)` (`assets/luadraw-doc-en/tangent_from.tex:253-256`).
- **Change the view angle locally without changing the window**: a parameterized local function `draw(theta,phi)` + `g:Shift3d(-centroid)` (changing viewdir rotates about the origin, so center first): `assets/github-discussions/d137-*-c15051622-b1.tex:14-39`.
- **Batch export of multiple views**: inside a loop `g:Savetofile(basename..k..".tkz"); g:Cleargraph()`, then `\input` in the body: `assets/github-discussions/d137-*-c14894434-b1.tex:37-41` (with the GIF command `convert -delay 20 -loop 0 -density 300 -scale 50% in.pdf out.gif`).
- Reset the matrix when done: `g:IDmatrix()` / `g:IDmatrix3d()`; after `Shift`-laying subplots, reset each time (`d311-*-c18076867-b1.tex:18-38`, the chained `g:Shift3d(3*vecJ)` hops).

## 6. Code Style Conventions (code style design)

> This chapter absorbs every pattern from the corpus that "doesn't count as a trick": all conventions about **how to write the code** (options, layering, numbers, organization, comments, mathematical expression) live here.

### 6.1 Options and Parameter Design

- **Do not write default values**: pass only items that differ from the defaults. `g:Dfacet(S,{mode=ld.mShadedOnly})` instead of copying out `contrast=1, twoside=true, opacity=1` in full; compare `assets/luadraw-doc-en/Dcontour.tex` (writes only the two items `view/colors`).
- **Two kinds of options**: structural options go into Lua tables `{t={t1,t2}, nbdots=40}`; TikZ appearance goes into strings `"red, line width=0.8pt"` (the field name is fixed: `draw_options`; backslashes are doubled `"\\draw"`).
- **nil means "keep the current value"**: `g:Lineoptions(nil,"red",8)` changes only the color; nil is also the sentinel for optional parameters (`x = x or default`).
- Commands that globally switch style such as `g:Lineoptions(nil,"red",8)` should not be used frequently; if you need them only a few times, write the drawing style into the drawing command itself instead of repeatedly switching global styles in the body.
- **The `out=` idiom**: drawing methods bring back computational by-products: `g:DScircle(P,{out=ends}); local A,B = table.unpack(ends)` (`assets/stackexchange/a762276-q762274-s09-b2.tex:17-21`).
- **Units**: line width ×0.1pt (`8` = 0.8pt); angles at the high level are always degrees; lengths are cm.
- **Line width prefers TikZ shorthands**: when the thickness lands on a shorthand step you **must write the shorthand**, and you should pick line widths on the steps whenever possible — `ultra thin(0.1pt)/very thin(0.2pt)/thin(0.4pt)/semithick(0.6pt)/thick(0.8pt)/very thick(1.2pt)/ultra thick(1.6pt)`. That is, write `"thick"`, not `"line width=0.8pt"` (148 shorthand occurrences in the corpus vs. handwritten `line width=` appearing only for off-step values); only off-step decimals use the numeric form `line width=0.6pt`.
- **The eight facet-drawing modes** (`ld.m*` constants, source `luadraw_graph3d.lua:50`): `mWireframe(0)` edges only, `mFlat(1)/mFlatHidden(2)` flat fill, `mShaded(3)/mShadedHidden(4)` shaded + edges, `mShadedOnly(5)` shaded faces only; accompanied by the edge-option group `edge=true, edgecolor=, edgewidth=, edgestyle=`, `contrast∈[0,1]` shading strength, `backcull=true` back-face culling, `twoside=false` dye the outer side only, `hiddencolor=` a different color for hidden edges (`d054-*-c14222093-b1.tex:14-16 and b2:14-15` compare two modes).
- Set the label font size once globally: `g:Labelsize("footnotesize")` (empty string restores it); cleaner than adding a size to every label's `node_options` (`a762950-q729190-s05-b2.tex:16`).
- **Label anchoring parameters**: `anchor1d=t∈[0,1]` places the label proportionally along a segment/arc (51 uses, `Dseg3d({A,B},{label="$d$",anchor1d=0.5})`), `anchor2d=Z(x,y)` anchors at a point taken on a curve, `dist=` radial distance, `dir={u,v}` basis vectors of the label plane — the annotation trio (`a764335-q386030-s04-b1.tex:41-46` is a concentrated demo); `g:Arrows("->")` global arrow style + `arrowscale=0.75` scaling (`d054-*-c14222106-b1.tex:16-17`).

### 6.2 Layered Design: Separate Computation from Drawing; Reuse over Reinvention

- `ld.*` is the pure math layer (`ld.solve/interD*/proj3d/cutfacet/odesolve/...`) that never touches the graph object; `g:D*` is the thin drawing layer. **Before you start, look through the manual for an existing function**; only write your own when there truly is none (you must first ask the user via the ask method, give the reason why **reinvention is unavoidable**, and discuss the design of the wheel with the user).
- New reusable capabilities follow the same two-layer design: `ld.foo` (compute, independent of the graph) + `graph/graph3d:Dfoo` (draw). Canonical template: `assets/luadraw-doc-en/module-luadraw-doc2d-en-section-81.lua` (`ld.field` + `graph:Dvectorfield`).
- Inside method bodies always use `self:Dxxx(...)` instead of `g:`; parameter fallbacks `args = args or {}`, `options.visibletrace = options.visibletrace or ""`.
- Hang things on the `luadraw.` namespace for reuse across the whole document: `function luadraw.create_stacks(...)` (`assets/stackexchange/a763040-q715320-s06-b1.tex`), `luadraw.param/luadraw.x1t` pass parameters into the luadraw environment (`d346-*-c18664344-b1.tex:22-33`).
- **When overriding/enhancing an existing method, keep the old reference** (decorator-style wrapper): `local old = ld.graph3d.Dsphere; function ld.graph3d:Dsphere(...) ... old(self,...) end` (`d276-*-c17211790-b1.tex:16-20`).
- Normalize inputs instead of raising errors: `if pt3d.isPoint3d(L[1]) then L = {L} end`; defensive early return `if (L==nil) or (type(L)~="table") then return end` (`d057-*-c14247256-b1.tex:23`); dual-signature optional arguments `if not pt3d.isPoint3d(H) then H = V; V = H-B end` (`d294-*-c17686075-b1.tex:41-43`).

### 6.3 Numeric Style

- **Absolute values are multiples of 0.5** (0.5/1/1.5/2/2.5/3/3.5/4...): `window={-5,5,-5,5}`, `size={10,10}`, radius `2.5`, `dist=0.25` dominate the whole corpus; non-half-integers appear only when the math demands them.
- **Angles are multiples of 5**: `viewdir={30,60}`, `rotate3d(...,15/20/45/90,...)`, `theta=50*ld.deg`; values like 22.5 only for fine-tuning.
- **Angle conversion always via `ld.deg`/`ld.rad`**: `Mc(3, t*ld.deg, ...)` degrees→radians; `angle*ld.rad` radians→degrees (`70*ld.deg` in `a766258-q586948-s06-b1.tex:16`). Never hand-write `*math.pi/180`.
- The standard numerical-derivative forms: `local h = 1e-6; (f(x+h)-f(x-h))/(2*h)`; second order `(f(x+h)+f(x-h)-2*f(x))/h^2`.
- Always guard nil after root-finding: `local T = ld.solve(f,a,b); if T == nil then T = {} end`.

### 6.4 Organization and Encapsulation Style

- No space after commas in calls: `g:Dpolyline(L,true,"red")`; chain same-family short statements with `;`: `g:Ddots(S,"Crimson"); g:Dlabel(...)`.
- `(text, anchor, options)` triples go one per line; a single `g:Dlabel3d` holds all the labels.
- **Collect (object, options) pairs into a table then `table.unpack`**: insert facet tables and option tables alternately, ending with `g:Dmixfacet(table.unpack(list))` — the generic pattern for per-face coloring / Rubik's cubes / scenes (`assets/stackexchange/a748904-q161588-s07-b1.tex:20-26`).
- **Incremental collection of scene elements**: `g:add*` returns a value; `table.insert(scene, g:addPoly(...))` collects while building, conditional elements become switches `if construction then table.insert(scene, ...) end`, and the ending is `g:Dscene3d(table.unpack(scene))` (`a765117-q53276-s07-b1.tex:35-38,103-105`).
- **A top tuning area** concentrates visual switches: `local c = 1 -- contrast`, `local bc = true -- backculling`, `local construction = true -- Construction lines or not` (`assets/stackexchange/a765117-q53276-s07-b1.tex:18-20`).
- **Parameterized local functions reuse whole figures**: `draw_box(alpha,beta)`, `plot_hyperbola(opt,angle,...)` with default parameters `x = x or ...`, defined once and called from several places (`d297-*-c17850496-b1.tex:15-27`); nested local functions (the outer one handles translation/positioning, the inner one unit details) such as `Dcrossing` embedding `Dcorner` (`a755346-q755343-s08-b1.tex:15-32`).
- **Data-table-driven**: rows `{{x1,x2,y1,y2,h}, ...}` → `mycube(table.unpack(b))` in a loop to build solids; change the data, not the code (`d274-*-c17205141-b1.tex:15-31`).
- **No intermediate variables unless necessary** (outside the opening locals): option strings in particular must not be split up —

  ```lua
  -- bad example: useless intermediate wrapping
  local arrow = "arrows={-Stealth[scale=1.15]}"
  local axis = "Crimson,line width=1pt,"..arrow
  local measure = "SteelBlue,line width=0.8pt,"..arrow
  -- correct: write it directly into each D call
  g:Dseg3d({A,B}, "Crimson,line width=1pt,arrows={-Stealth[scale=1.15]}")
  ```

  The criterion: an option string **used fewer than three times is inlined in place**; **more than three times should be turned into a loop or data-table-driven code** (`for _,v in ipairs{{"Crimson",A,B},{"SteelBlue",C,D}} do g:Dseg3d({v[2],v[3]}, v[1]..common_part) end`) rather than layer upon layer of local concatenation. In short: outside the opening, never declare option-type locals separately; keep the whole thing clean and do no useless wrapping.
- **The only legal forms of option reuse** are two: a style factory (parameterized into a function `local style = function(color) return {...} end`, `a755801-q755458-s05-b1.tex`) and loops/table-driven code (see above); "it repeats twice so let's extract a local" is an anti-pattern.
- **Hand-rolled painter's sorting** (when needed): `table.sort(t, function(a,b) return pt3d.dot(a[1],g.Normal) < pt3d.dot(b[1],g.Normal) end)` (`a755346-q755343-s08-b1.tex:53`), or sort by `g:Observer_distance` (`a763930-q528631-s02-b1.tex`).

### 6.5 Comment Style

- **No comments unless necessary**: keep the code as a whole concise; comments are the exception, not the default. Anything that naming, structure, or a one-line formula can explain gets no comment.
- **Add a few comments only near absolutely critical trick steps**: only three categories deserve comments — counter-intuitive numeric magic (`local r2 = r+0.01 -- enlarge r to avoid overlapping lines`), performance traps (`g:addWall(wall) -- 2 facet cutouts with this instruction, and 529 without it`), and framework-mandated markers (`-- do not modify` / `-- must be global`, the three spots in the animation skeleton).
- Comments at key spots write "why", not "what": one line of geometric/mathematical intent (`-- plane whose section with the torus gives the lemniscate`), never restating the API name.
- When a mathematical derivation has many steps, one comment line carrying the conclusion is enough (discriminant=0 for common tangents, eigendecomposition change of parameters); do not lay out comments step by step.
- For debug visualizations, comment them out instead of deleting them: `--g:Dlabel(...)`, or use `g:Dpolynames(P)` directly to display facet/vertex numbers (`assets/luadraw-doc-en/show_facet_number.tex`).

### 6.6 Mathematical Expression Style

- Use operator overloading to the fullest: midpoint `(A+B)/2`, symmetry `2*A1-H`, `4*M(1,0,-0.5)`, complex numbers `2+3*i`.
- Anonymous functions `local f = function(x,y) ... end`; real numbers participate directly (`{pi/2, pi/2+2*i, 2*i}`, the API layer converts automatically).
- Numeric loops `for k = 1, n` + `table.insert`; data traversal with `ipairs`; ignored index `_`; set operations with the library's `ld.concat/ld.insert/ld.map/table.append`.
- The TikZ global node style goes into the constructor once: `pictureoptions = "every node/.append style={fill=white,inner sep=1.75pt}"`, instead of repeating it per label via `node_options` (`a760809-q760803-s07-b1.tex`, `d228-*-c16122879-b1.tex`).
- When squares are dense, define the micro-helper `local sqr = function(x) return x*x end`, shorter and faster than repeated `x^2` (`assets/luadraw-doc-en/Dandelin.tex:10`).
- **The small vector-function vocabulary** (saves hand-written loops): `pt3d.prod(u,v)` cross product, `pt3d.dot(u,v)` dot product, `pt3d.normalize(u)` unit vector (nil for the zero vector), `pt3d.det(u,v,w)` triple product, `pt3d.abs2/abs` squared norm/norm, `pt3d.isobar3d(F)` facet centroid, `pt3d.N1(u)` norm (zero test `if N1(u)<1e-12 then pick another vector`); on the complex side `cpx.normalize/det(u,v)` signed area, `cpx.isobar(L)` polyline centroid — the "orthonormal basis from an axis" recipe `u=prod(n,vecJ); if N1(u)<1e-12 then u=prod(n,vecI) end; v=prod(n,u)` (`d059-*-c14255047-b1.tex:14-17`).
- **The matrix trio semantics**: `ld.mtransform3d(L,M)` moves a whole point list between frames (full affine), `ld.mLtransform3d(L,M)` applies only the linear part (use this for vectors/directions, `luadraw_matrix3d.lua:69`), `ld.invmatrix3d(M)` the inverse; the identity test saves computation `if not ld.isID3d(mat) then ... end` (30 uses, `d288-*-c17625127-b1.tex:31-35`).

---

## 7. Practical Tricks (with code locations)

> Inclusion criterion: situational knowledge that **visibly shortens code or clearly improves programming convenience**; general writing conventions are already in §6. Every item gives its location inside assets.

### 7.1 How to Choose the Rendering Route (decision table)

| Scenario                                                | First choice                                                                                                                                                                                            | Evidence                                                                                                                        |
| ------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------- |
| Ordinary polyhedra/surfaces                             | `g:Dfacet` / `Dmixfacet` (painter's algorithm + optional `backcull=true`)                                                                                                                               | `assets/luadraw-doc-en/tetra_coupe.tex`                                                                                         |
| Two solids intersecting, real cutting needed            | `g:Dscene3d` + `g:addWall` partition walls (facet cutouts can drop from 2068 → 30)                                                                                                                      | `assets/stackexchange/a759064-q759057-s16-b2.tex` torus; `assets/luadraw-doc-en/torus.tex:328` (`addwall=2` carries the walls at construction time) |
| Just a clean silhouette (sphere/cylinder/cone)          | analytic primitives `Dsphere/Dcylinder/Dcone`, or **outline + gradient**: `Classifyfacet` → `border` → `Dpolyline3d(border, "left color=..,right color=..,middle color=..")`                           | `assets/stackexchange/a762950-q729190-s05-b2.tex` (two ways to draw a hemisphere compared)                                      |
| Manual ordering                                         | collect `(object,options)` pairs, sort, then draw in order (see §6.4)                                                                                                                                   | `assets/stackexchange/a755346-q755343-s08-b1.tex:53`                                                                            |
| Transparent intersections/implicit surfaces/massive detail | POV-Ray: `Pov_new → Pov_* → Pov_exec → Pov_show`, CSG via `difference/intersection/merge`                                                                                                               | `assets/github-discussions/d203-*-c15858811-b1.tex` (two intersecting cylinders + metallic texture)                             |
| Tens of thousands of points/facets                      | `luadraw_pdfliteral` writes straight into the PDF stream                                                                                                                                               | the bifurcation (31275 points) examples live in the `assets/stackexchange/a761978-*` series                                     |
| Drawings on a sphere (great circles/spherical regions/spherical curves) | `luadraw_spherical`: `Define_sphere → DS* series → Dspherical()`                                                                                                        | `d054-*-c14222169-b1.tex` the whole family; `assets/luadraw-doc-en/spherical_strip.tex` layering                                |

- **The spherical drawing family** (after `require 'luadraw_spherical'`): before drawing, `g:Define_sphere({radius=,color=,opacity=,show=})`; then `DSpolyline/DSseg/DSline/DSarc/DSbigcircle/DScircle/DScurve/DSfacet/DSregion/DSplane/DSaxes/DSlabel/DSdots/DSstars/DSangle` are all free to use; finally `g:Dspherical()` outputs everything at once with spherical occlusion; layer control via `DSaddback/DSaddfront/DSaddinside` (paths queue up first, back/front/through-the-sphere are rendered separately), plus the inverse-stereographic pair `DSinvstereo_polyline/DSinvstereo_curve` (`d054-*-c14222169-b1.tex:14-27`, `assets/luadraw-doc-en/spherical_strip.tex:26-33`).
- **The POV-Ray object family** (after `require 'luadraw_povray'`): primitives `Pov_sphere/cylinder/cone/torus/plane/circle/dots/polyline/facet/surface/implicit/axes`, CSG `Pov_union/difference/intersection/merge`, plus `Pov_include/Pov_special` (raw POV statements); named objects `{name="s", render=false}` are declared first and combined later, and strings can carry transformations `"cyl1 rotate 90*z"` (`assets/luadraw-doc-en/holes_in_hemisphere.tex:16-24`, `a763074-q763071-s07-b1.tex:12-21`).

Rule of thumb: when hidden lines are needed, drawing `border(visible)+border(hidden)` twice in two colors is cleaner than stacking translucent facets (`a762729-q360412-s06-b1.tex:15-21`).

### 7.2 One-line Construction of Common Shapes

- **Torus / surface of revolution**: `rotcurve(f,t1,t2,{axis},360,0,{grid=.., addwall=2})` — a generating curve plus an axis is all it takes, and `addwall` throws in the partition walls for Dscene3d: `assets/stackexchange/a759064-q759057-s16-b1.tex:14-15`. For a piecewise generating curve (a solid of revolution with caps) use a `cutfacet` chain: `a755902-q755898-s16-b1.tex:14-16`.
- **Ellipsoid / axis-scaled solid**: `Savematrix; Setmatrix3d({Origin, 2*vecI, 3*vecJ, 4*vecK}); Dsphere(Origin,1)` reuses the sphere primitive: `a755902-q755898-s16-b1.tex:25-27`.
- **Hollow / pierced faces**: `concat` the outer contour with the inner hole then fill with `"even odd rule"`; `table.insert(path,2,"m")` is enough to open a hole in a polyline: `assets/stackexchange/a764687-q764678-s13-b1.tex`, `a752902-q625977-s06-b1.tex:29-31`.
- **Half / partial cylinder**: `cylinder → cutpoly(cutfacet) → g:Outline(Cyl)` takes the outline then applies a gradient: `assets/github-discussions/d102-*-c14513457-b1.tex:14-19`.
- **Regular polyhedra**: `require 'luadraw_polyhedrons'`, `poly.tetrahedron(C,S,true)` returns `P,V,E,F1,F2` in one call: `assets/luadraw-doc-en/polyhedrons.tex`.
- **Nets (unfoldings)**: `require 'luadraw_cvx_polyhedra_nets'`, `unfold_polyhedron(P)` + `Dpolyhedron_net(P,{tabs=true})`: `assets/luadraw-doc-en/parallelep_net*.tex`.
- **Only certain facets**: `getfacet(P,{1,3,4})` selects faces directly, sparing the hidden-line handling: `d053-*-c14204188-b1.tex:20`.
- **The window as a ready-made polygon**: `g:Box2d()`/`g:Box3d()` use the current window directly as a polygon/parallelepiped — inequality regions are carved out of the window by repeated `cutpolyline(Box2d(),D,true)` (`d298-*-c17916655-b1.tex:48-57`); the 3D window box serves as a clipping solid `ld.clip3d(S,g:Box3d())` (same idea as `assets/luadraw-doc-en/lecture_obj.tex`).
- **A plane frame in one line**: `local C,u,v = ld.orthoframe(P)` hands you an orthonormal basis of the plane — no more hand computation for rectangular planes/texture mapping/local frames (`d182-*-c15630885-b1.tex:17`, also used in `d319-*-c18204595-b1.tex`).
- **Cutting a solid yields three things at once**: `local Bottom, Above, section = ld.cutpoly(C, P)` returns the kept half, the discarded half, and the section polyline (`close=true` additionally caps the solid); moving and splicing is just `ld.shift3d(Right, vector)` (`d243-*-c16843523-b2.tex:30-37,60`).
- **Drawing a line from its equation**: `g:DlineEq(a,b,c,"style")` draws `ax+by=c` directly; pair it with `ld.lineEq` to get the line object (`assets/luadraw-doc-en/sequence.tex:19`).
- **Integer sequences and discrete steps**: `ld.range(a,b[,step])` generates an equally spaced table directly (contour levels `Lz = ld.range(1,10)`, shared loop parameterization); pair with `ld.getpalette(pal, N)` for N evenly spaced colors (`assets/luadraw-doc-en/Dcontour.tex:8-9`).
- **A ready-made palette legend**: `g:Dgradbox({position},{legend={"$x$","$y$"}, grid=true, title=".."})` draws color strip + ticks + title in one line; with `Dcontour(f,Lz,{colors=Colors})` it is the contour-plot standard kit (`assets/luadraw-doc-en/Dcontour.tex:10-11`).
- **The true section curve of a solid**: `g:Intersection3d(solid, plane)` returns the intersection curve in one line (an ellipsoid cutting a cone gives an ellipse), and `Plane2facet(plane,scale)` draws the cutting plane: `assets/luadraw-doc-en/Dandelin.tex:29-32,45`.
- **2D→3D lifting**: `ld.map(function(z) return M(x0,z.re,z.im) end, I[1])` pastes the result of the planar implicit curve `ld.implicit` onto a 3D plane (`assets/luadraw-doc-en/torus.tex:24-25`).
- **Four window-bound accessors**: `g:Xinf()/Xsup()/Yinf()/Ysup()` give the current window bounds, so field/grid loops `for y = g:Yinf(), g:Ysup(), dy do` need not repeat the window numbers (`assets/luadraw-doc-en/champ.tex:14-15`).
- **Drawing ODE integral curves directly**: `g:Dodesolve(f, x0, y0, {t={t1,t2}, draw_options=})` computes and draws in one call (`assets/luadraw-doc-en/champ.tex:26`).
- **The path mini-language draws complex shapes in one line**: `g:Dpath(p)` takes a flat table mixing coordinates and instruction strings — `"m"` move, `"l"` line, `"b"` bezier, `"ca"` circular arc, `"e"` ellipse, `"s"` spline, `"la"` rounded line, `"cl"` close; a complex fill contour fits in one table (`assets/luadraw-doc-en/path_spline.tex:6-8`).
- **A spline through points in one line**: `g:Dspline({A,B,C,D,E}, nil, -5*i)` — the end-tangent constraints may be nil, and a smooth curve needs no parameterization (`assets/luadraw-doc-en/path_spline.tex:11`).
- **Extrusion / revolution / parallelepipeds**: one-line variants from a base curve — `ld.prism(arc, axis, false)` extrudes along an axis, `ld.rotline(arc, {C,axis}, 0, 90, {nbdots=n})` a partial surface of revolution (the angle span may be a segment), `ld.parallelep(O, L*vecI, W*vecJ, H*vecK)` hands you the box, `ld.facet2plane(F)` the plane of a facet (feed it to `addWall`): `a765117-q53276-s07-b1.tex:34,48,56,71`.
- **The intersection family** (check here before solving equations by hand): 2D `interL/interD/interP/interDL/interDC/interCC`; 3D `interDP/interPP/interDD/interPS` (plane∩sphere→circle)/`interSS` (sphere∩sphere)/`interDS` (line∩sphere)/`interCS`/`interSSS` (three-sphere localization), all nil-safe (defined in `luadraw_lines.lua:616-`, `luadraw_lines3d.lua:364-`; usage example `d294-*-c17686075-b1.tex:84`).
- **Planes in one step, two ways**: `ld.plane(A,B,C)` the plane through three points, `ld.planeEq(a,b,c,d)` the plane of equation `ax+by+cz+d=0` (`assets/luadraw-doc-en/parallelep_net3.tex:10`, `a748774-q728955-s02-b1.tex:15`).
- **The geometric-construction family**: `ld.tetra_len(ab,ac,ad,bc,bd,cd)` a tetrahedron from six edge lengths (`assets/luadraw-doc-en/tetra_len.tex:12`); `ld.sss_triangle3d(ab,bc,ac)` a triangle from three sides (`d120-*-c14663053-b1.tex`); `ld.circumcircle3d/incircle3d(A,B,C)` circumcircle/incircle, `ld.circumsphere/insphere(A,B,C,D)` circumsphere/insphere (`a752142-q752135-b10-b1.tex:20-23`, `a750962-q612735-s02-b1.tex:17`); `ld.pyramid(base, apex)` a pyramid (`assets/luadraw-doc-en/test.tex`); a regular pyramid `ld.regular_pyramid(n,a,h,open,center)` (`d115-*-c14617462-b1.tex`).
- **Solids from arbitrary generating curves**: `ld.curve2cylinder(f,t1,t2,V)` extrudes an arbitrary closed curve into a cylinder, `ld.curve2cone(f,t1,t2,O)` into a cone (`assets/luadraw-doc-en/curve2cylinder.tex:12-13`); `ld.line2tube(L, r, {nbfacet=8})` turns a polyline into a tube, `ld.section2tube(section, L, {hollow=true})` sweeps an arbitrary cross-section along a path (`assets/luadraw-doc-en/line2tube_section2tube.tex:22-24`); `ld.cylindrical_surface(r,z,u1,u2,v1,v2,grid,"v")` a cylindrical-coordinate surface with its wall included (`assets/luadraw-doc-en/surface_with_addWall.tex:31`).
- **A convex hull in one line**: `ld.cvx_hull3d(L)` maps a point list to a facet list, `ld.facet2poly(V)` converts back to a polyhedron; 2D `ld.cvx_hull2d` (`assets/luadraw-doc-en/cvx_hull3d.tex:13-14`, `a752696-q566807-s05-b1.tex:14`).
- **A ready-made cylinder decomposition**: `g:Cylinder_outline(A,R,B)` returns four groups of 3D paths `{section=, side=, visible=, hidden=}`; side wall, section circles, visible and hidden edges are drawn separately, each with its own gradient (`a766533-q766527-s03-b1.tex`).
- **Axis transport**: `ld.rotateaxe3d(S, K, N)` rotates a whole object from "K as axis" to "N as axis"; a tilted solid is computed in its canonical position first, then rotated once (`a764335-q386030-s04-b1.tex:27`, `d278-*-c17247327-b1.tex` the full tilted-cylinder routine); `ld.rotate3d({U,V}, ang, axe)` rotates a pair of vectors together (`d294-*-c17686075-b1.tex:46`).
- **Mirror completion**: `ld.sym3d(list, {P,n})` mirrors a whole point list through a plane (`d137-*-c14894434-b1.tex:23`); completing half a surface: `concat(S, reverse_face_orientation(sym3d(S,plane)))` (`a752224-q752218-s07-b1.tex:17-18`).
- **Regions via set operations**: `ld.set(center, angle)` constructs, `ld.cap/cup/setminus` intersect/union/difference, `ld.path(A)` converts a set to a polyline (`assets/luadraw-doc-en/cap_and_cup.tex:8-15`, `a751952-q751879-s02-b1.tex:22-38`).
- **Data-table-driven CSV→surface**: `ld.read_csv_file(f, {header=,sep=,comment=})` + `ld.read_table3d(data, {bbox=true, func=4})` turns row data into facets directly, with `func=N` interpolating column N into a coloring function (`assets/luadraw-doc-en/read_table3d.tex:2-3`); `.obj` models via `ld.read_obj_file(f)` return `(P, bbox)` and `window3d=bbox` feeds straight in (`assets/luadraw-doc-en/lecture_obj.tex:1-2`).
- **Compute-side arc forms**: `ld.circle3db(C,R,normal)`/`ld.arc3db(B,A,C,R,sens,normal)` return point lists directly, to feed `path3d(...,100)` or `addPolyline` without drawing (`luadraw_lines3d.lua:151,197`; usage `d313-*-c18089286-b1.tex:12`).
- **The sphere's outline circle**: `g:Sphere_outline(O,R).data` hands you the outline circle `{I,r,n}` at once — no more hand computation for great circles and equators (`d325-*-c18293081-b1.tex:22`); pair it with `Cylinder_outline` (`luadraw_frustum_and_co.lua:78,249`).
- **Small toolbox**: `ld.rectangle(a,b,c)` a rectangle from three points (`luadraw_lines.lua:226`); `g:Getview()` the four bounds of the current viewport (`a749228-q749220-s08-b1.tex:35`); `g:Sortfacet(F)`/`Sortpolyfacet(P)` return facet lists sorted by distance so hand-rolled painter's algorithms can just iterate (`luadraw_graph3d.lua:792,816`; `d067-*-c14330300-b1.tex`); `g:Composematrix({O,u,v})` composes a 2D affine matrix directly from an origin and two basis vectors (`luadraw_calc.lua:65`).
- **The region-filling family**: `Ddomain1(f,{x=})` under a curve, `Ddomain2(f,h,{x=})` between two curves, `Ddomain3(f,h)` a closed domain, `Dinequalities({f,'>',h,'<'},{draw_options=})` functional-inequality regions, `Dimplicit_inequalities` the implicit version, `Dstepfunction` step lines — calculus/inequality illustrations with zero hand-written paths (`assets/luadraw-doc-en/courbe.tex:11-16`, `assets/luadraw-doc-en/Dinequalities.tex:10`, `a755221-q755217-s09-b1.tex:14`).
- **The annotation family**: `Dangle(B,A,C,r)` angle marks, `Dmarkseg/Dmarkarc` equal-division ticks, `DtangentC(f,x,len)` curve tangents, `Dtangent_from(P,f,t1,t2,style,S)` tangents from an external point (tangency points go into S), `Dhline(A,B)` half-lines, `Dbezier({p1,p2,p3,p4})` a single bezier segment, `Dlabeldot` dot-with-label, `Dgradline({a,b},{limits=,legend=})` a standalone graduated axis (`assets/luadraw-doc-en/orthocentre.tex:14-25` the full kit, `a766249-q496103-s05-b1.tex:24-26`, `assets/luadraw-doc-en/gradline.tex:5-8`).
- **The six projections**: `ld.pxy/pxz/pyz(A)` the projections of a point onto the three coordinate planes, `ld.px/py/pz(A)` onto the three axes — auxiliary dashed lines, face shadows on cubes, and coordinate read-off lines all rely on them (`a754855-q754846-s16-b1.tex:14-15` batch-projects with `concat(pxy(S),pxz(S),pyz(S))`; `d107-*-c14544282-b1.tex` projections with a cube).
- **A cut sphere in one line**: `g:Dcut_sphere(O, R, P, {color=, mode=, edgecolor=, visibletrace=, hiddentrace=})` draws the plane-P section of a sphere directly; the trace options style the section outline (`assets/luadraw-doc-en/cut_sphere.tex:16-23`).
- **Extension-module quick reference**: `luadraw_fields` (fields: Dvectorfield/Dgradientfield/Dsurfacefield), `luadraw_shadedforms` (Dshaded* + Dcolorbar), `luadraw_palettes` (palette library + `getPal{extract=,shift=,reverse=}` + `mixpalette`), `luadraw_decorations` (decorated angles/ticked segments), `luadraw_coils_chains` (Dcoil/Dchain), `luadraw_compile_tex` (TeX→paths), `luadraw_linprog` (linear programming), `luadraw_log_axes` (Beginlogview/Dlog* logarithmic axes), `luadraw_polyhedrons`, `luadraw_cvx_polyhedra_nets`, `luadraw_povray`, `luadraw_pdfliteral`, `luadraw_spherical` — each module's demo lives in `assets/luadraw-doc-en/` under the same name.

### 7.3 Visual-Effect Tricks

- **Dashed + transparency = draw twice**: first the solid with solid lines and half transparency, then the hidden lines dashed on top; `mode=2 (outline only)+color+opacity` for the shell, `mode=0` dashed for the edges: `assets/stackexchange/a748590-q438320-s06-b1.tex:15-19`.
- **White-border occlusion (pseudo-3D lines)**: `"draw=white,double=black,double distance=0.6pt"` lets the near line "block" the far one; the canonical spiral drawing: `a750922-q750874-s11-b1.tex:23-24`; the equivalent option inside Dscene3d is `double={"white",6}`: `d281-*-c17305266-b1.tex:34`.
- **Clip for the correct shading**: `Beginclip(outline path) → Dsphere(...) → Endclip()` yields a locally gradient-shaded spherical cap: `a755902-q755898-s16-b1.tex:28-30`; `Beginclip(path, true)` clips inversely to take the outside.
- **Gradient direction**: `shading angle="..ld.strReal(g:Proj3dV(normal)*ld.rad)` (the angle computed by concatenation): `d278-*-c17247327-b1.tex:26-31`.
- **Borrowing TikZ assets**: `g:Writeln` injects arbitrary TikZ — decorative nodes `\\node[cloud,...] at..g:Coord(z)..";"` (`d158-*-c15147389-b1.tex:44-47`); after defining a custom arrow decoration `\\tikzset{->-/.style={decoration=...}}`, polylines can simply use `"->-=0.65,blue"` (`assets/luadraw-doc-en/sequence.tex:15-21`).
- **Central projection in one line**: `viewdir=perspective("central",30,60,20)` (θ, φ, camera distance), with `ld.camera` to change the reference point: `assets/stackexchange/a759064-q759057-s16-b1.tex:9`.
- **`mixcolor` instead of `fill opacity`**: mix with the base color before filling — transparency doesn't stack and color values are reproducible: `mixcolor(ld.palette(pal, idx, true), 0.5, ld.White, 0.5)` (`a752183-q752168-s07-b1.tex:45`, the comment's own words "to replace the fill opacity option").
- **Drawing 2D on an arbitrary plane in 3D**: after `g:Savematrix(); g:Setmatrix({g:Proj3d(A), g:Proj3dV(u), g:Proj3dV(v)})` you can use the full 2D toolkit (Daxes/Dellipse/Darc...), then `g:IDmatrix()` resets — the standard posture for embedding planar coordinate systems/field plots inside a 3D figure (`a749713-q749696-s08-b1.tex`, `a763154-q480263-s02-b1.tex:13`).
- **Fine-tuning facet shading**: `g:adjust_color(F, color, contrast, twoside)` computes light/dark colors from the angle between the normal and the line of sight (it is the kernel of mShaded mode); borrow it directly for custom per-face coloring (`d095-*-c14597160-b1.tex` defines it, `a759177-q759149-s05-b1.tex` uses it); `gradside={r,g,b}` and `gradsection=` on Dcylinder/Dcone give gradient colors directly to the side wall/section (`a766774-q487872-s06-b1.tex`).
- **Custom named gradients**: declare `\pgfdeclareradialshading{myname}{...}{...}` in the preamble, then reference it with the single word `shading=myname` in draw_options (`d226-*-c16087524-b1.tex:9-14,34-36`).
- **The intersection curve of two solids in one line**: `ld.border(ld.clip3d(C2, C1))` gives the boundary of C2 inside C1, i.e. the intersection curve; the complete two-cylinder Steinmetz template `table.append(S1, rotate3d(S1,180,axe))` + `border` (`d319-*-c18201340-b1.tex:33`, `a765262-q726438-s08-b2.tex:22-25`).
- **Contour lines = chained cutfacet slicing**: `for k=1,n do S1, S = ld.cutfacet(S, {M(0,0,k),-vecK}); insert(niv,{S1,{color=..}}) end` slices layer by layer, passing the remainder down, and finally `Dmixfacet(table.unpack(niv))` (`assets/luadraw-doc-en/courbes_niv.tex:17-24`; the striped cube uses the same method `a754826-q754821-s07-b1.tex:12-18`).

### 7.4 Numerical and Solving Tricks

- **Root-finding as drawing**: tangency points/inflection points/equal-arc-length points are all `ld.solve`, with nil guarded before the loop; the complete discriminant-method template for common tangents of ellipses: `a754350-q754333-s13-b1.tex:45-60`.
- **Singularities**: shrink the endpoints by `±1e-6/±1e-8`; `ld.linspace` with multiple segments densifies near singularities (`-4,0.25,50, 5,20`); slightly widen coincident lines `r+0.01`: `a759064-q759057-s16-b1.tex:14`, `a761682-q761676-s11-b1.tex:21`.
- **Compute in another frame, draw in the original**: `invmatrix` reduces to canonical form to solve, `g:Setmatrix(matrix)` returns to the original frame to draw (`a754350-q754333-s13-b1.tex:45-60`); eigendecomposition for reparameterization + `mtransform3d` back to the original frame (`a763941-q584173-s02-b1.tex:24-40`).
- **Rotation/symmetry splicing**: `S = concat(S1, rotate3d(S1,180,axe))`; remember `reverse_face_orientation` when completing by symmetry: `a752224-q752218-s07-b1.tex:17-18`; **mirroring a whole point list** is just `sym3d({A,…,G},{point,normal})` completing the other half's vertices in one line: `d137-*-c14894434-b1.tex:23`.
- **Reproducible randomness**: `math.randomseed(42)` (`a763110-q763098-s14-b1.tex`).
- **Iterated sequences in one line**: `ld.sequence(f, u0, n)` returns `u, f(u), f²(u)...`; the cobweb-diagram staircase is just a `table.insert(seg,{z,L[k]})` loop (`assets/luadraw-doc-en/sequence.tex:9-14`).
- **Definite integrals numerically in one line**: `ld.int(f, a, b)`; treating the upper limit as the unknown turns it into an implicit function `G(x,y)=ld.int(h,x,y)-1` (`assets/luadraw-doc-en/int_solve.tex:6,9`); `ld.evalf(f,x[,y])` evaluates nil-safely (`a763996-q130802-s03-b1.tex:31`).
- **Arc-length parameterization**: after `f = ld.curvilinear_param(L, close)`, `ld.map(f, ld.linspace(0,1,n))` samples equidistantly and `Dparametric(f,{t={..}})` draws arrowed segments (`assets/luadraw-doc-en/curvilinear_param.tex:12-21`).
- **The canonical-position method for tilted solids**: compute a tilted cylinder/cone by first rotating it about an auxiliary axis to the vertical position (get the angle with `pt3d.angle(C-A,vecK)*ld.rad` then `rotate3d`); when drawing, compute the shading angle with `cpx.arg(g:Proj3dV(cyl_normal))*ld.rad` (`d278-*-c17247327-b1.tex:19-30`).
- **Adaptive windows**: `x1,x2,y1,y2 = ld.getbounds(L)` / `ld.getbounds3d(points)` for the bounds, `window={x1-dx,x2+dx,...}` adds margin, and in 3D just `adjust2d=true` lets the package compute the 2D window (`a758597-q758581-s05-b1.tex:5-7`, `d180-*-c15599080-b1.tex:10-11`).
- **Exact fraction strings**: `ld.nearest/simplifyFrac` turn floating-point coordinates into reduced fractions; a 20-line `frac()` helper outputs `\frac{a}{b}` TeX strings (`d183-*-c15647828-b1.tex:4-25`).

### 7.5 Visibility and Occlusion Tricks

- The general test: visible ⟺ `pt3d.dot(A-reference, g.Normal) > 0` (for central projection use `ld.camera-A` instead).
- **Splitting a curve's visibility on a cylinder/sphere**: `ld.split_points_by_visibility(curve, visible_function)`; the `visible_function` uses `dproj3d` onto the axis followed by a dot product; a directly reusable full `Curve_on_cylinder` implementation: `d319-*-c18204595-b1.tex:21-31` (the two-cylinder intersection tests both axes at once).
- **Facet pre-filtering saves computation**: first a local `sortfacet()` separates the facets that need no clipping before `clip3d`: `a759151-q714248-s11-b1.tex:16-28`.
- **Screen vectors ready-made**: `g:ScreenX()/g:ScreenY()` give the screen-plane direction vectors, sparing hand projections when drawing diameters/symmetric outlines/attaching labels (`a752902-q625977-s06-b1.tex` uses `O±R*g:ScreenX()` for the sphere outline endpoints).
- **The tangency series**: `g:Sphere_tangency/Cylinder_tangency/...` give the viewing tangency points directly; combined with `out=` you get the outline-arc endpoints: `d294-*-c17686075-b1.tex:40-70` (a replicable set of implementations).
- **Drawing section curves**: the return value of `Intersection3d` carries `.visible/.hidden` lists — `ld.concat(I.visible, I.hidden)` merges them, `I_shifted = ld.shift3d(I_combined, v)` reuses them translated; no hand-written visibility function needed (`d243-*-c16843523-b2.tex:29-33`); to draw, `g:Dedges(I,{hidden=false})` draws only the visible segments, and `{hidden=true, hiddenstyle="solid", visible=false}` takes only the hidden segments (`a748590-q438320-s06-b1.tex:15-19`).
- **Separating a polyhedron's edges**: `g:Edges(P)` (capital E) returns `{visible=, hidden=}` at once (`d114-*-c14601743-b1.tex:12-14`); a solid's outline `g:Outline(C)` is the same shape (`d102-*-c14513457-b1.tex:14-19`); single-facet test `g:Isvisible(F)` (`assets/luadraw-doc-en/plans.tex:20`).
- **Preventing z-fighting for lines on facets**: for lines drawn flush against facets, `ld.scale3d(L, 1.01)` slightly scales them 1% from the axis to "peel" them off the surface and remove the visual coincidence (`d087-*-c14434252-b1.tex:14-15`).

### 7.6 Encapsulation Tricks That Shorten Code

- **A string is a constraint**: `ld.constraint('a*x+b*y<c')` compiles the coefficients with `load("return function(x,y,z) return "..expr.." end")` → `lineEq`; looping `cutpolyline(Box2d(),D,true)` yields the solution region — linear programming shrinks from 30 lines to 3: `d298-*-c17916655-b1.tex:41-57`.
- **Interpolation as a function**: the parabola through three points `ld.parabola(A,B,C)` returns the Lagrange function directly: `d249-*-c16927920-b1.tex:25-33`.
- **A complex function is a matrix**: `ld.matrixof(f)` extracts the affine matrix from a complex map directly — recursive fractals need no hand-derived coefficients (`assets/luadraw-doc-en/Pythagore.tex:9-12`).
- **Results into TeX macros**: `function defmac(name,body) token.set_macro(name,body,"global") end`; inside the figure `defmac("SA", dist(S,A))`, in the body `\SA`: `d184-*-c15659408-b1.tex:219-221`; luacas exact solutions → `luadraw.x1t = "$"..r[1]:tolatex().."$"`, numeric solutions → `load("return "..temp)()`: `d346-*-c18664344-b1.tex:18-21`.
- **One-stop axis annotation**: `g:Daxes({0,pi/2,1}, {labeltext={"\\pi",""}, labelden={2,1}, nbsubdiv={3,1}, gradlimits=, xyticks={0,0}, myxlabels/myylabels={position,"$label$",...}, labelshift=, originpos=, legend=, legendpos=, legendsep=})` — π/√2 mathematical ticks, sparse custom ticks, and legend placement all in one options table (`assets/luadraw-doc-en/axes_grid.tex:6`, `d228-*-c16122879-b1.tex:15-33`); for a non-orthonormal ratio use the third element of `size={12,9,8/pi}`.
- **The TeX↔Lua peripheral bridge**: `\def\Sequence#1#2#3{\directlua{Sequence(function(#2) return #1 end,#3)}}` lets the body write formulas that Lua executes (`a754686-q754620-s05-b1.tex:38`); `tex.sprint` spits TeX straight from a Lua loop (the palette catalog `d095-*-c14653471-b1.tex`); footer/per-page background figures via `\cfoot{\directlua{do_cfoot()}}`, `\AddToHook{shipout/background}` (`a760676-q760668-s08-b1.tex`, `a761442-q761440-s08-b2.tex`); embedded data via `\begin{filecontents*}{data.csv}` (`a757330-q757325-s13-b1.tex`); the `.tkz` output directory via `\def\luadrawTkzDir{tikz/}` (`d049-*-c14153982-b1.txt`); the external-process bridge `io.open + os.execute("python3 gen.py")` generates data that `read_csv_file` then reads (`a751587-q751568-s12-b2.tex:14-36`).

### 7.7 Animation Tricks

- Incremental drawing inside frames: a growing trace `table.insert(C1,a)`, with `ld.nbimages = #C` letting the data decide the frame count: `a763431-q280206-s09-b1.tex`.
- Segmented state-machine storytelling: `if k<=10 ... elseif k<=71 ... else ...` controls "enter — demonstrate — exit": `a763033-q735114-s10-b1.tex:34-71`.
- `animateinline` with `palindrome` for back-and-forth; per frame `Setviewdir` to change the view then `IDmatrix3d()` to reset: `a762095-q762086-s11-b1.tex`.
- Exporting a GIF: a `Savetofile + Cleargraph` loop + ImageMagick; intermediate `.tkz` files go into `cachedir` (set via a package option so the source directory stays clean): `d137-*-c14894434-b1.tex:12,37-41,55-56`.
- **Render only half of a palindrome animation**: the playback loop `if i > nb then i = 2*nb-i end` folds the index back, so nb frames serve as 2nb-1; the animation parameters `linspace(0,90,nb)` are generated once: `d137-*-c14894434-b1.tex:34-35,46-48`.
- Labels that follow along: `pos` via the piecewise function `Tpos(x)` choosing NW/NE/SW/SE by quadrant: `d254-*-c16941054-b1.tex:54-68`.
- **State accumulated across frames**: closure variables persist between makeframe calls — slicing off half then the other half `poly,poly2 = cutpoly(poly,P,true)` for progressive dissection, or particle motion `pos = pos+dt*V` with wall bouncing; all mutate state, never rebuild (`a763033-q735114-s10-b1.tex:34-71`, `a764547-q764528-s04-b1.tex:44-50`).
- **Two ways to change the view inside a frame**: `g:Rotate3d(theta[k],{Origin,vecK}) ... g:IDmatrix3d()` rotates the picture, not the data (`a762051-q762044-s08-b1.tex:23-24`); or multi-view side-by-side `Saveattr/Viewport/Setviewdir("xOy")/Restoreattr` written directly inside makeframe (`a762095-q762086-s11-b3.tex:48-54`); `g:Defaultattr()` resets attributes at frame start (`a754855-q754846-s16-b2.tex:22`).

### 7.8 Text and External Content on Geometry

- **TeX typesetting pasted onto surfaces**: `compile_tex(text,"id")` → `Compiled_tex2path3d(L,{anchor=,dir={u,v},polyline=true})` → `ftransform3d` wraps it onto a cylinder/sphere → fill after visibility separation; a complete template (with a cloud): `d158-*-c15147389-b1.tex:54-66`.
- Locally overriding `compile_tex` for Chinese/multilingual support (change the `usepackage` and the `pdflatex` command): `d158-*-c15404851-b1.tex:21-40`.
- **The polyline→path bridge**: `Beginclip(ld.polyline2path(C))` turns any polyline into a fillable/clippable path (29 uses); the 3D counterpart is `polyline2path3d` — only `Dpath3d(polyline2path3d(border(...)), "ball color=..")` can carry radial gradients (`d172-*-c15463972-b1.tex:17`, `a763510-q763505-s06-b1.tex:6`).
- **Compiled-text drawing options**: `g:Dcompiled_tex(L,0,{scale=2, hollow=true, drawbox=true, dir={u,v}})` hollow filling/bounding box/plane pasting; `compile_tex(text,"id",true)` as the third argument turns strokes into thin strips for easier filling; the deformation chain `compiled_tex2polyline(L,{3,3}) → ftransform(L,f) → Dpath(polyline2path(L))` wavifies the text (`assets/luadraw-doc-en/compile_tex2d.tex:10-19`).
- **Image-mapping options**: `g:Dimage(f, Z, {pos="SE", matrix={0,-1,i}, graphics_options="width=4.5cm"})` — `matrix` directly gives symmetry/rotation (a 2×2 complex matrix), and `graphics_options` passes through to `\includegraphics` (`assets/luadraw-doc-en/Dimage.tex:13-19`); triangular-face texture mapping `Dmapimage(f, facet, {border_options=})` (`assets/luadraw-doc-en/Dmapimage.tex:15-16`).
- **Images on arbitrary planes/vertices**: `BeginOnPlane({A,U,W},{out=mat}) → Dimage(f,0,{matrix=mat})`: `d283-*-c17334343-b1.tex:36-41`.
- Maps on a sphere: `(lon,lat) → ld.sM(lon, 90-lat)` + `DSregion/DScurve` drawing sea/land/coast in layers: `d320-*-c18219103-b1.tex:71-109`.

### 7.9 Bug Workarounds and Hot Fixes

- **Temporary global patches, nil when done**: `sss_triangle = ld.sss_triangle -- patch ... sss_triangle = nil` (bypasses an old-version internal reference): `d296-*-c17824348-b1.tex:15-31`.
- **Wrapper override** for system differences: `local old_exec = ld.graph3d.Pov_exec; function ld.graph3d:Pov_exec() ... old_exec(self, ...) end` fixes Windows full paths: `d233-*-c16197966-b1.tex:11-24`.
- When `Pov_show` sizes don't match, compute the matrix yourself: `matrix={Z(0,0), Z(1/g.Xscale,0), Z(0,1/g.Yscale)}`: `d347-*-c18727946-b1.tex:26-33`.
- When some elements must be drawn last: `g:Begindeferred() ... g:Enddeferred()` defers them to the end of the figure: `d323-*-c18236397-b1.tex:26-28`.

---

## Appendix: Quick Checklist

- [ ] First line `local ld = luadraw`; localize only the shortcuts you use; every `math.*` used is localized in the opening, zero `math.` in the body
- [ ] The graph object `g` (or a semantic name) and `local`; the constructor takes a single options table; `name=` is mandatory
- [ ] Structural options in tables, TikZ appearance in `draw_options` strings; **write only non-default items**; nil keeps; few and centralized style switches
- [ ] Line width ×10; **on a step you must write the TikZ shorthand** (thick/ultra thick/very thick/semithick/thin...) and prefer step widths; angles in degrees and multiples of 5; absolute values multiples of 0.5; conversions only via `ld.deg/ld.rad`
- [ ] Computation `ld.*`, drawing `g:D*`, scenes `g:add*`; check the API for an existing function before you start
- [ ] Save/Restore and Begin/End strictly paired; reset the matrix with `IDmatrix*` when done
- [ ] Painter's-order drawing; **no comments unless necessary**, only a few comments beside absolutely critical tricks and only the why; keep the code concise overall
- [ ] No intermediate variables unless necessary: option strings used fewer than three times are inlined, more than three become loops/table-driven; no option-type locals outside the opening, no useless wrapping
- [ ] Same-family short calls chained with `;`; (text, anchor, options) triples one per line; (object,options) pairs collected then `table.unpack`
- [ ] The last line is `g:Show()` (or `Save()`); animations end with `Sendtotex(); Cleargraph()`
- [ ] Variables: single capital letters for math, lowercase English for semantic roles; no French leftovers; no missing `local`
- [ ] The skeleton carries `\usepackage{fourier-otf}`; run it once before submitting: Lua comments are `--`, color names capitalized
