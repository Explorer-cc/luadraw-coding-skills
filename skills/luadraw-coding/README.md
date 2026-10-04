# Luadraw coding skill v0.1.0

This directory is the executable-facing layer for the Luadraw v3.5 coding
knowledge in the repository.

## Source of truth

- Full guide: `../../luadraw-coding-guide-en.md`
- Official package and documentation: `../../luadraw-v3.5/`
- Curated code corpus: `../../assets/`

The root guide is intentionally left unchanged. The files here organize its
rules for skill use; they are not a replacement for the complete reference.

## Release metadata

- Version: `0.1.0` (`VERSION` and `SKILL.md` front matter).
- License: repository-level `../../LICENSE` (MIT License).
- Minimal compile example: `examples/minimal-2d.tex`.
- Structural validator: `scripts/check-skill.lua`.

## Dependencies

The skill targets Luadraw v3.5 and LuaLaTeX. The local `luadraw-v3.5/`
source tree is intentionally ignored by Git; install Luadraw separately or
provide it at the repository path documented in the root `README.md`.

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

## Maintenance rule

When the API or corpus changes, update the full guide first, then update the
relevant reference page and `SKILL.md` only when the operational rule changes.
Do not duplicate the full guide into this directory.
