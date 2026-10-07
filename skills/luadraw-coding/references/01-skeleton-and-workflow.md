# Skeleton and workflow

Canonical full text: `../luadraw-coding-guide-en.md`, sections 2–5.

## Corpus entry path

Use the official demos first: the `luadraw` blocks in the manual source
(`src/body-en/*.tex`). The optional `assets/luadraw-doc-en/` archive holds them
one per file, named by `name=`. Recommended progression:

1. `champ` — 2D skeleton;
2. `orthocentre` — geometric construction;
3. `torus` — surface of revolution, `addWall`, and rendering-route decisions;
4. `d137-*-c14894434-b1.tex` in the optional `assets/github-discussions/`
   archive — multiple views and GIF export.

## Stable LuaLaTeX skeleton

```latex
\documentclass[border=5pt]{standalone}% compile with lualatex only
\usepackage[svgnames]{xcolor}
\usepackage[3d]{luadraw}% remove 3d for 2D
\usepackage{fourier-otf}
\begin{document}
\begin{luadraw}{name=meaningful-name}
local ld = luadraw
local g = ld.graph3d:new{window3d=...,size={10,10},viewdir={30,60}}
-- pure computation with ld.*
-- drawing with g:D* or g:add*
g:Show()
\end{luadraw}
\end{document}
```

Rules carried from the full guide:

- `name=` is mandatory and meaningful.
- Constructors receive one options table.
- Use `local ld = luadraw` first and localize only required shortcuts.
- Keep the graph object local, normally as `g`.
- Keep pure computation in `ld.*` and drawing in `g:D*`.
- End ordinary figures with `g:Show()` or `Save()`.

## State management

Every state-opening operation requires its matching close operation:

- `Saveattr` / `Restoreattr`;
- `Savematrix` or `Savematrix3d` / `Restorematrix`;
- `Beginclip` / `Endclip`;
- `BeginOnPlane` / `EndOnPlane`;
- `Beginlogview` / `Endlogview`.

Reset matrices after local transformations with `IDmatrix()` or
`IDmatrix3d()`.

## Side-by-side figures

Use `g:Shift(-4)` then `g:Shift(8)` for two figures next to each other. Reserve
`Saveattr` / `Viewport` / `Coordsystem` / `Restoreattr` for genuinely
independent panels (different windows or view directions).
For two figures it adds a paired state and a second coordinate system for
nothing.

## Animation

Move expensive geometry and declarations outside the frame function. Keep the
frame function global on the Luadraw namespace and preserve the framework calls:

```lua
function ld.makeframe(k) -- do not modify this line
    -- incremental drawing for frame k
g:Sendtotex()              -- do not modify
g:Cleargraph()             -- do not modify
end
```

Use the complete animation skeleton in the full guide before adding a custom
state machine.
