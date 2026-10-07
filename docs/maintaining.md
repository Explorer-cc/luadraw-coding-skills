# Maintenance guide

## Order of changes

When the Luadraw API, examples, or the full guide change:

1. Update `skills/luadraw-coding/references/00-guide-en.md`. It is the source of the English guide.
2. Copy it to `docs/guide-en.md`. The two files must stay byte-identical:

   ```bash
   cp skills/luadraw-coding/references/00-guide-en.md docs/guide-en.md
   ```

3. Update the matching `references/01-05` page.
4. Update `SKILL.md` only when an entry-level rule changes.
5. Run the structural check and the affected LuaLaTeX examples.
6. Update `docs/guide-cn.md` as needed.

## Local environment

`.local/` is git-ignored. Keep local Luadraw source copies there, for example
`.local/luadraw-v3.5/`. The skill does not depend on it. `build/` and `_luadraw/`
(Luadraw cache) are ignored as well.

## Verification

Structural check:

```bash
lua skills/luadraw-coding/scripts/check-skill.lua
luac -p skills/luadraw-coding/scripts/check-skill.lua
cmp skills/luadraw-coding/references/00-guide-en.md docs/guide-en.md
```

Compile an example against the Luadraw installed in TeX Live:

```bash
mkdir -p build/minimal-2d
lualatex -interaction=nonstopmode -halt-on-error \
  -output-directory=build/minimal-2d \
  skills/luadraw-coding/examples/minimal-2d.tex
```

To use a local source copy, in Git Bash:

```bash
TEXINPUTS="$(pwd)/.local/luadraw-v3.5/luadraw/files//;" \
  lualatex -interaction=nonstopmode -halt-on-error \
  -output-directory=build/minimal-2d \
  skills/luadraw-coding/examples/minimal-2d.tex
```

PowerShell:

```powershell
$env:TEXINPUTS = "$(Get-Location)\.local\luadraw-v3.5\luadraw\files\;$env:TEXINPUTS"
lualatex -interaction=nonstopmode -halt-on-error `
  -output-directory=build/minimal-2d `
  skills/luadraw-coding/examples/minimal-2d.tex
```

The 3D example is `examples/glass-box-3d.tex`; use the same commands.

## Agent trigger check

After installing, send a request that clearly asks for Luadraw v3.5, for example:
"Create a LuaLaTeX 2D circle-and-radius example with Luadraw v3.5. Give complete
compilable code and the verification command."

A good response:

- identifies LuaLaTeX and Luadraw v3.5;
- uses `local ld = luadraw` and existing APIs;
- gives a complete `luadraw` environment;
- does not invent APIs;
- states the verification actually run.

## Release

The version lives in the `version:` field of `skills/luadraw-coding/SKILL.md` and in the git tag.
`scripts/check-skill.lua` asserts the version too.

1. Update `version:` in `SKILL.md`, the assertion in `check-skill.lua`, and `CHANGELOG.md`.
2. Run the verification above.
3. Commit and tag:

   ```bash
   git tag -a vX.Y.Z -m "Luadraw coding skill vX.Y.Z"
   ```
