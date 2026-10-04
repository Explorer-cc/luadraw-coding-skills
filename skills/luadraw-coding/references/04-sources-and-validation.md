# Sources and validation

Canonical full text: `../../luadraw-coding-guide-en.md`.

## Source priority

1. `luadraw-v3.5/luadraw/doc/src/body-en/` — official documentation;
2. `luadraw-v3.5/luadraw/files/` and `extensions/` — implementation and
   extension APIs;
3. `assets/luadraw-doc-en/` — complete official demos;
4. `assets/stackexchange/` — author answers, with score as a quality signal;
5. `assets/github-discussions/` — discussion examples and fixes.

The assets are an archive. A short snippet may be useful as an API reference
without being a standalone compilable document.

## Asset conventions

- `.tex`: LaTeX/LuaLaTeX document or Luadraw environment; source comment uses `%`.
- `.lua`: pure Lua module or code block; source comment uses `--`.
- `.pov`: POV-Ray SDL; source comment uses `//`.
- `.obj`: Wavefront OBJ data; source comment uses `#`.
- `.txt`: terminal output or prose; source comment uses `#`.

Use repository-relative paths and treat `file:line` references as navigational
hints. After moving or editing an asset, recheck every reference to it.

## Verification levels

- Lua-only change: `luac -p path/to/file.lua`.
- Luadraw code change: compile a representative LuaLaTeX document.
- Rendering change: inspect the generated PDF or image, not only logs.
- Animation change: exercise at least the first, middle, and final frame.
- Reference-only change: check that every cited file exists and cited lines are
  still within the file.

A successful syntax check does not prove that a Luadraw method exists or that
TikZ options render correctly. Report the actual check performed.

## Full checklist

The complete submission checklist is the appendix of
`../../luadraw-coding-guide-en.md`.
