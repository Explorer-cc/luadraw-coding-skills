---
name: luadraw-coding
version: 0.1.0
description: >
  Use when writing, reviewing, debugging, or explaining LuaLaTeX code that
  uses the luadraw v3.5 package for 2D or 3D drawings, geometric figures,
  visibility, rendering routes, animations, or Luadraw extension modules.
---

# Luadraw coding skill

Use this skill for Luadraw v3.5 work. The complete corpus guide remains at
`luadraw-coding-guide-en.md`; the files under `references/` are the operational
split by concern.

## Scope

- Target API: Luadraw v3.5.
- Target document engine: LuaLaTeX.
- Target surfaces: 2D, 3D, animations, visibility/occlusion, and Luadraw
  extension modules.
- Do not silently substitute generic TikZ, PGFPlots, or another Luadraw
  version.

## Required workflow

1. Classify the task as 2D, 3D, animation, extension-module, rendering, or
   TeX-integration work.
2. Read the relevant topic in `references/`.
3. Search `luadraw-v3.5/` and `assets/luadraw-doc-en/` before inventing an API.
4. Use StackExchange and GitHub Discussion assets only when the official
   documentation does not answer the question.
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
- Do not present an unverified code fragment as a complete example.

## Rendering-route defaults

- Ordinary facets or surfaces: `Dfacet`/`Dmixfacet`.
- Real solid intersections and partition walls: `Dscene3d` with `addWall`.
- Spherical drawings: `luadraw_spherical`.
- Very large point/facet sets: consider `luadraw_pdfliteral`.
- CSG, complex transparency, or heavy rendering: consider the POV-Ray route.
- Hidden lines: separate visible and hidden paths before resorting to
  translucent overlays.

## Reference selection

- Skeleton, animation, and state handling: `references/01-skeleton-and-workflow.md`.
- Options, naming, math, and encapsulation: `references/02-style-and-state.md`.
- Rendering routes and reusable patterns: `references/03-rendering-and-patterns.md`.
- Corpus navigation and validation: `references/04-sources-and-validation.md`.
- Full prose and complete checklist: `luadraw-coding-guide-en.md`.
