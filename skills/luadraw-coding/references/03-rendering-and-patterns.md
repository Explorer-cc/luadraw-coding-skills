# Rendering routes and practical patterns

Canonical full text: `00-guide-en.md`, sections 7.1–7.9.

## Route selection

- Ordinary polyhedra and surfaces: `Dfacet` or `Dmixfacet`.
- Real solid intersections: `Dscene3d` plus `addWall` where partition walls
  are needed.
- Clean analytic silhouettes: `Dsphere`, `Dcylinder`, `Dcone`, or an outline
  followed by a gradient.
- Spherical geometry: load `luadraw_spherical`, queue `DS*` elements, then call
  `Dspherical()`.
- Large point/facet sets: consider `luadraw_pdfliteral`.
- Complex CSG or rendering-heavy scenes: consider `luadraw_povray`.
- Manual painter ordering: collect, sort, then draw.

## Reusable patterns

- Surface of revolution: `rotcurve(...,{grid=...,addwall=2})`.
- Partial solids: construct, cut with `cutfacet`/`cutpoly`, then draw the
  resulting visible and hidden outlines separately.
- Sections: use `Intersection3d` instead of solving the intersection manually.
- Planar geometry in 3D: use `Savematrix`/`Setmatrix` or the documented plane
  frame helpers, then restore the matrix.
- Holes: combine outer and inner contours and use the documented even-odd fill
  convention.
- Convex polyhedra: use `luadraw_polyhedrons` and the existing polyhedron
  constructors.
- Unfoldings: use `luadraw_cvx_polyhedra_nets` and
  `unfold_polyhedron`/`Dpolyhedron_net`.
- Text on geometry: use the compile-TeX and compiled-path pipeline rather than
  hand-converting glyphs.

## Visibility and occlusion

- Prefer explicit visible/hidden path separation.
- Use `g:Edges(P)` or `g:Outline(C)` when the API provides the required split.
- Use `Intersection3d(...).visible` and `.hidden` rather than rebuilding a
  visibility test.
- For lines lying on facets, use the documented small geometric offset to
  avoid z-fighting.
- Use transparency only after the correct visible geometry has been selected.
- Declare the scene instead of scripting the painting: define geometry data,
  then render it with `Dscene3d`, or with `Classifyfacet` and an explicit
  back-to-front order. Never draw a whole enclosing solid in one call when
  objects inside it must show through or in front.
- Object inside a transparent box: `local V,H = g:Classifyfacet(P)`, then draw
  `H`, the solid, and `V` (low opacity) in that order. Alternative: one
  `g:Dscene3d(g:addPoly(solid,{...}), g:addPolyline(ld.facetedges(P),{hidden=true,...}))`.
  Complete example: `examples/glass-box-3d.tex`.
- Split a solid with `local V,H = g:Classifyfacet(S)` (facet list or polyhedron;
  it applies the current 3D matrix and returns visible and hidden facets).
  `local V = g:Classifyfacet(S)` keeps only the visible facets. Draw back to
  front: hidden part, objects behind or inside, visible part. Use
  `Dfacet(H/V,...)` for shaded facets, or `Dpolyline3d(border(H),"...color...")`
  for a gradient silhouette. For a cut solid, `ld.cutfacet` first, then
  classify each piece. Corpus (optional `corpus/` archive):
  `luadraw-doc-en/rotcurve.tex`, `spherical_strip.tex`, `Dandelin.tex`;
  `github-discussions/d127-*`, `d330-*`; `stackexchange/a764304-*`.

Every pattern above has complete examples in the manual source (`src/body-en/`),
in the optional `corpus/luadraw-doc-en/` archive, or in the source locations
listed by the full guide. Search those before creating a new abstraction.
