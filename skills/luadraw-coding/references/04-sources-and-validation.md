# Sources and validation

Canonical full text: `00-guide-en.md`.

## Source priority

1. Installed manual: `luadraw-doc-en.pdf` and `src/body-en/` (see `SKILL.md`,
   Resources) — official documentation;
2. Installed Luadraw source (directory of `luadraw.sty`, plus `extensions/`) —
   implementation and extension APIs;
3. `corpus/luadraw-doc-en/` — complete official demos (optional archive);
4. `corpus/stackexchange/` — author answers, with score as a quality signal
   (optional archive);
5. `corpus/github-discussions/` — discussion examples and fixes (optional
   archive).

Items 3–5 are an archive that this skill does not ship; items 1–2 suffice. An
archived snippet may be useful as an API reference without being a standalone
compilable document.

## Asset conventions

- `.tex`: LaTeX/LuaLaTeX document or Luadraw environment; source comment uses `%`.
- `.lua`: pure Lua module or code block; source comment uses `--`.
- `.pov`: POV-Ray SDL; source comment uses `//`.
- `.obj`: Wavefront OBJ data; source comment uses `#`.
- `.txt`: terminal output or prose; source comment uses `#`.

Cite Luadraw source as `file:line` relative to the directory of `luadraw.sty`;
treat line numbers as navigational hints for v3.5. After moving or editing an
asset, recheck every reference to it.

## Verification levels

- Lua-only change: `luac -p path/to/file.lua`.
- Luadraw code change: compile a representative LuaLaTeX document.
- Rendering change: inspect the generated PDF or image, not only logs.
- Animation change: exercise at least the first, middle, and final frame.
- Reference-only change: check that every cited file exists and cited lines are
  still within the file.

A successful syntax check does not prove that a Luadraw method exists or that
TikZ options render correctly. Report the actual check performed.

## Option defaults

Before omitting or writing an option, open the method in
the installed Luadraw source (directory of `luadraw.sty`) and read the current code, plus the matching manual
section. Report the file and line used. Experience, memory and example code are
not evidence of a default. Header comments can be stale; the code is
authoritative.

## Full checklist

The complete submission checklist is the appendix of
`00-guide-en.md`.
