# Rendering routes and practical patterns

Canonical full text: `../../luadraw-coding-guide-en.md`, sections 7.1–7.9.

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

Every pattern above has complete examples in `assets/luadraw-doc-en/` or in
the source locations listed by the full guide. Search those examples before
creating a new abstraction.
