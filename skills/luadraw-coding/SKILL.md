---
name: luadraw-coding
version: 0.1.0
description: >
  Use when writing, reviewing, debugging, or explaining LuaLaTeX code that
  uses the luadraw v3.5 package for 2D or 3D drawings, geometric figures,
  visibility, rendering routes, animations, or Luadraw extension modules.
---

# Luadraw coding skill

Use this skill for Luadraw v3.5 work. The complete corpus guide is
`references/00-guide-en.md`; the files under `references/` are the operational
split by concern.

## Scope

- Target API: Luadraw v3.5.
- Target document engine: LuaLaTeX.
- Target surfaces: 2D, 3D, animations, visibility/occlusion, and Luadraw
  extension modules.
- Do not silently substitute generic TikZ, PGFPlots, or another Luadraw
  version.

## Resources

Everything the workflow needs is in this directory or in the TeX installation
that compiles the document. Nothing outside the installed TeX tree is required.

- Luadraw source (Lua modules and `extensions/`): the directory that contains
  `luadraw.sty`; find it with `kpsewhich luadraw.sty`. Cite files as
  `luadraw_graph3d.lua:1453`, relative to that directory.
- Manual: `luadraw-doc-en.pdf` and its source `src/body-en/*.tex` in the
  `doc/lualatex/luadraw/` directory of the same TeX tree (replace `tex/` by
  `doc/` in the source directory's path).
- Full guide: `references/00-guide-en.md`.
- Version: `luadraw.sty` must declare version 3.5. If it does not, say so; do
  not silently use another version.
- Optional corpus archive `corpus/` (official demos, StackExchange answers,
  GitHub Discussions): not shipped with this skill. File names such as
  `corpus/luadraw-doc-en/torus.tex` are provenance; open them only if the
  archive exists in the repository that contains this skill. Without it, use
  the manual source and `references/05-corpus-techniques.md`.
- Path mapping for the full guide, which uses the upstream repository layout:
  `luadraw-v3.5/luadraw/files/` is the Luadraw source directory above,
  `luadraw-v3.5/luadraw/doc/src/body-en/` is the manual source, and `corpus/`
  is the optional archive.

## Required workflow

1. Classify the task as 2D, 3D, animation, extension-module, rendering, or
   TeX-integration work.
2. Read the relevant topic in `references/`.
3. Search the installed Luadraw manual and source (see Resources) before
   inventing an API; check `references/05-corpus-techniques.md` for an existing
   one-call form.
4. Use the optional `corpus/` archive (StackExchange answers, GitHub Discussions)
   only when it exists and the official documentation does not answer the
   question; otherwise skip this step.
5. Prefer the existing two-layer design: `ld.*` computes; `g:D*` draws.
6. Produce a complete LuaLaTeX example when the user asks for runnable code.
7. Check Lua syntax with `luac -p`; compile a representative LuaLaTeX example
   when the change affects package behavior, TeX integration, or rendering.
8. Report the source example and verification command used.

## Non-negotiable coding rules

- Start a Luadraw block with `local ld = luadraw` and localize only used
  shortcuts.
- Keep the graph object local, normally named `g`.
- Pass one options table to graph constructors.
- Keep computation in `ld.*` and drawing in `g:D*`/`g:add*`.
- Keep `Save`/`Restore` and `Begin`/`End` pairs balanced.
- Keep expensive geometry outside animation frame functions.
- End ordinary figures with `g:Show()` or `Save()`; animation frames end with
  `Sendtotex()` and `Cleargraph()`.
- Do not invent a function name when an official source can settle the API.
- Look option defaults up on the spot in the Luadraw manual and source
  (the installed Luadraw source, see Resources), per method, every time. Never rely on
  experience, memory or example code. When a header comment and the code
  disagree, the code wins. If a default cannot be found, pass the option
  explicitly or ask. Set `ld.Hiddenlinestyle` once or `hiddenstyle` per call,
  not both.
- The goal is short, readable code: avoid ineffective and excessive
  encapsulation. Inline any wrapper that does not make the file shorter.
- Encapsulate only when three or more things are drawn. A helper's parameter is
  data, never a drawing callback; never wrap a single Luadraw call
  (`Dlabel3d`) in a local helper.
- Define geometry as data, then render it declaratively (`Dscene3d`,
  `Classifyfacet`). Do not hand-compute annotation offsets, and do not draw a
  whole enclosing solid in one call when its back and front facets must sit on
  either side of the objects inside it.
- Place two figures side by side with `g:Shift`; use `Viewport` only for
  genuinely independent panels.
- Draw only what was requested; do not add axes, dimensions or captions unasked.
- Do not present an unverified code fragment as a complete example.

## Rendering-route defaults

- Ordinary facets or surfaces: `Dfacet`/`Dmixfacet`.
- Real solid intersections and partition walls: `Dscene3d` with `addWall`.
- Spherical drawings: `luadraw_spherical`.
- Very large point/facet sets: consider `luadraw_pdfliteral`.
- CSG, complex transparency, or heavy rendering: consider the POV-Ray route.
- Hidden lines: separate visible and hidden paths before resorting to
  translucent overlays.
- Object inside a transparent box: `Classifyfacet` (draw hidden facets, the
  solid, then visible facets) or one `Dscene3d`; see `examples/glass-box-3d.tex`.
- Split a solid with `g:Classifyfacet` into visible and hidden facets and draw
  back to front (hidden, inner objects, visible); details and corpus pointers in
  `references/03-rendering-and-patterns.md`.

## Reference selection

- Skeleton, animation, and state handling: `references/01-skeleton-and-workflow.md`.
- Options, naming, math, and encapsulation: `references/02-style-and-state.md`.
- Rendering routes and reusable patterns: `references/03-rendering-and-patterns.md`.
- Corpus navigation and validation: `references/04-sources-and-validation.md`.
- Compute-side constructors, 3D primitives, scene elements, projections, 2D
  helpers found by reading every corpus file: `references/05-corpus-techniques.md`.
- Full prose and complete checklist: `references/00-guide-en.md`.
