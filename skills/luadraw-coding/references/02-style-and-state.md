# Style and state rules

Canonical full text: `../../luadraw-coding-guide-en.md`, section 6.

## Options and objects

- Write only options that differ from defaults.
- Put structural options in Lua tables.
- Put TikZ appearance in `draw_options` or the method's documented style
  string.
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

## Comments and structure

- Comments explain why, not what.
- Keep comments for numerical tricks, performance traps, and framework markers.
- Separate computation from rendering.
- Collect `(object, options)` pairs and unpack them at the drawing boundary
  when that is the established API pattern.
- Balance all state and environment pairs before considering visual refinements.
