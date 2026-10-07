# Style and state rules

Canonical full text: `../luadraw-coding-guide-en.md`, section 6.

## Options and objects

- Write only options that differ from defaults.
- Look defaults up on the spot, per method, in the manual
  (`src/body-en/` in the installed documentation) and the installed Luadraw
  source (the directory of `luadraw.sty`). Never rely on experience, memory or example
  code, and never carry a default from one method to another.
- When a method's header comment and its code disagree, the code wins. For
  example `luadraw_graph3d.lua:1453` lists `hiddenstyle="dotted"` and
  `twoside=false`, but `:1467` and `:1469` use `ld.Hiddenlinestyle` and
  `twoside = true`.
- A default may be a global that other code changes: `ld.Hiddenlinestyle`
  starts as `"dotted"` (`luadraw_graph3d.lua:46-48`) and some extensions
  reassign it. The values quoted here are v3.5 illustrations, not a lookup
  table.
- If a default cannot be found, pass the option explicitly or ask. Set the
  global `ld.Hiddenlinestyle` once or `hiddenstyle` per call, not both.
- Put structural options in Lua tables.
- Put TikZ appearance in `draw_options` or the method's documented style
  string.
- Write a TikZ line width that lands on a shorthand step as the shorthand
  (`thick`, not `line width=0.8pt`); use the numeric form only off-step.
- Put the shared node style in the constructor
  (`pictureoptions="every node/.append style={fill=white,inner sep=1.75pt}"`),
  not in `node_options` on every label.
- Treat `nil` as the optional-argument sentinel when the API does so.
- Use semantic graph names only when multiple graph objects need distinction;
  otherwise use local `g`.
- Keep option strings inline when used fewer than three times. For repeated
  styles, use a style factory, loop, or data table.

## Computation and drawing layers

- `ld.*` is the computation layer and should not depend on a graph object.
- `g:D*` is the drawing layer.
- `g:add*` collects scene elements.
- Inside graph methods, use `self:Dxxx(...)`, not a captured `g:` object.
- Normalize optional inputs and guard nil results from numerical solvers.
- Search for an existing Luadraw function before writing a replacement.

## Numeric and geometric conventions

- High-level angles are degrees; use `ld.deg` and `ld.rad` for conversions.
- Use the package's vector and complex helpers: `pt3d.prod`, `pt3d.dot`,
  `pt3d.normalize`, `pt3d.abs`, `cpx.normalize`, and related functions.
- Prefer operator-overloaded geometry such as `(A+B)/2` and `2*A1-H`.
- Localize used `math.*` functions in the opening section; keep the body free
  of unnecessary `math.` prefixes.
- Guard root-finding results before iterating.
- Absolute values are multiples of 0.5 and angles multiples of 5, unless the
  mathematics requires otherwise.
- Chain same-family short statements with `;`; no space after commas in calls.

## Comments and structure

- Comments explain why, not what.
- Keep comments for numerical tricks, performance traps, and framework markers.
- Separate computation from rendering.
- Collect `(object, options)` pairs and unpack them at the drawing boundary
  when that is the established API pattern.
- Balance all state and environment pairs before considering visual refinements.

## Encapsulation and scene structure

The target shape is a short script that states what exists, not how to paint it.

- Define geometry as data first (`P`, `C`, `S`, `ld.facetedges(P)`), then hand
  it to the renderer (`Dscene3d`, or `Classifyfacet` plus ordered `Dfacet`).
  Let the library decide occlusion.
- The goal is short, readable code. Avoid ineffective and excessive
  encapsulation: inline any wrapper that does not make the file shorter.
- Wrap drawing code in a local function only when three or more things are
  drawn. With two, write both blocks out.
- A helper's parameter is data (`drawScene(solid)`). Never pass a drawing
  callback (`draw_common(shape)`), and never let a helper capture many outer
  locals through a closure.
- Never wrap one Luadraw call in a local helper (`label` around `Dlabel3d`).
  Pass `(text, anchor, options)` triples to one `g:Dlabel3d`; put the shared node
  style in `pictureoptions`.
- Do not hand-compute label or annotation offsets, and do not `Rotate3d` the
  whole scene when `viewdir` is enough.
- Draw only what was requested. Extra axes, dimension arrows and captions are
  added only on request.
