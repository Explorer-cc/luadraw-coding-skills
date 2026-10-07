# Luadraw coding skill v0.1.0

This directory is the executable-facing layer for the Luadraw v3.5 coding
knowledge in the repository.

## Source of truth

- Full guide: `luadraw-coding-guide-en.md` (byte-identical copy of the
  repository-root guide; it uses the upstream layout, see the path mapping in
  `SKILL.md`, Resources)
- Luadraw v3.5 package and manual: the TeX installation (`kpsewhich luadraw.sty`)
- Code corpus `assets/`: optional, not shipped with this skill

The files here organize the guide's rules for skill use; they are not a
replacement for the complete reference.

## Release metadata

- Version: `0.1.0` (`VERSION` and `SKILL.md` front matter).
- License: `LICENSE` (MIT License, copy of the repository-level file).
- Compile examples: `examples/minimal-2d.tex` (2D),
  `examples/glass-box-3d.tex` (3D, declarative scene, `g:Shift` layout).
- Structural validator: `scripts/check-skill.lua`.

## Dependencies

The skill targets Luadraw v3.5 and LuaLaTeX. It reads the Luadraw source and
manual from the TeX installation (`kpsewhich luadraw.sty`) and does not bundle
them. The `assets/` corpus is optional and not part of the skill.

## Files

- `SKILL.md`: activation scope, workflow, hard rules, and reference routing.
- `references/01-skeleton-and-workflow.md`: document skeleton, shortcuts,
  state management, and animation structure.
- `references/02-style-and-state.md`: options, naming, math, layering,
  encapsulation, and comment style.
- `references/03-rendering-and-patterns.md`: rendering-route decisions and
  common geometric patterns.
- `references/04-sources-and-validation.md`: source priority, asset naming,
  link conventions, and verification requirements.
- `references/05-corpus-techniques.md`: index of techniques found by re-reading
  the whole corpus (geometry as data, 3D primitives, scene elements,
  visibility and projection variants, 2D helpers).

## Maintenance rule

When the API or corpus changes, update the full guide first, then update the
relevant reference page and `SKILL.md` only when the operational rule changes.
`luadraw-coding-guide-en.md` here is a deliberate copy of the repository-root
guide so the skill is self-contained; copy it over after every change to the
root file and keep the two byte-identical. Do not copy other repository content
into this directory.
