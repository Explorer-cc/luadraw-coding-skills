# Corpus techniques: look here before hand-writing geometry

Canonical full text: `../luadraw-coding-guide-en.md`, sections 7.10–7.15.
Found by re-reading every corpus file. Each name was checked in
the installed Luadraw v3.5 source (directory of `luadraw.sty`); re-read the function header before relying on an
argument order.

## Geometry as data (compute side, §7.10)

- Solids: `ld.cylinder`, `ld.cone`, `ld.frustum`, `ld.sphere`, `ld.parallelep`,
  `ld.tetra`, `ld.tetra_len`, `ld.prism`, `ld.pyramid`. They return polyhedra for
  `cutfacet`, `clip3d`, `Classifyfacet`, `Intersection3d`, `border`.
- Regular bases: `ld.polyreg(center,vertex,n)` lifted with
  `ld.map(pt3d.toPoint3d, …)`.
- Surfaces: `ld.cartesian3d`, `ld.surface`, `ld.cylindrical_surface`,
  `ld.rotline`, `ld.rotcurve`, `ld.curve2cylinder`. Loft two curves with
  `surface(function(u,v) return (1-v)*A(u)+v*B(u) end,…)`.
- Points: `Mc(r,theta,z)`, `Ms(R,theta,phi)` (radians), `cpx.Zp(r,theta)`.
- Open a solid with `table.remove(P.facets,n)` or keep faces with `ld.getfacet`.

## 3D drawing primitives (§7.11)

- `Dpath3d` / `ld.path3d` read the same flat code table as the 2D path, with
  `"c"`, `"ca"`, `"e"`, `"ea"`: one call fills a cap, sector, ring or pierced sphere.
- One call each: `Dcircle3d`, `Darc3d`, `Dangle3d`, `Dellipticarc3d`, `Dplane`,
  `Dline3d`, `Dballdots3d`, `Dcrossdots3d`, `Dboxaxes3d{grid=true,…}`.
- `usepalette={pal,"z"}` (or `"x"`, `"y"`, or a function of the facet) colours
  facets by position.
- `Dscene3d` elements: `addPoly`, `addPolyline`, `addFacet`, `addPlane`,
  `addLine`, `addDots`, `addLabel`, `addAxes`, `addAngle`, `addArc`, `addCircle`,
  `addWall`. Put axes, labels and circles in the scene so the renderer handles
  their occlusion.
- On a sphere build parallels and meridians from `Sphere_tangency`, never from a
  hand-made centre and offset.

## Visibility, sections, projection (§7.12)

- Set `ld.Hiddenlines=true; ld.Hiddenlinestyle="dashed"` once; override with
  `hidden=` on one element. Do not also pass `hiddenstyle` everywhere.
- `Classifyfacet` variants: V only, V/H layered, cut then classify, classify then
  cut, `border(V)` with a gradient.
- Curved surface: test `g:Cosine_incidence(N,A)>0` with a finite-difference
  normal, then `ld.split_points_by_visibility`.
- Sections: `Intersection3d` with `Dedges`; `ld.cutpolyline3d`,
  `ld.clippolyline3d(L,g:Box3d())`, `ld.merge3d`.
- Parallel section of a pyramid is `ld.scale3d(base,k,apex)`.
- Tangency: `Cone_tangency`, `Cylinder_tangency`, `Frustum_tangency`,
  `Sphere_tangency` and their `*_outline` twins; `ld.orthoframe`.
- Oblique views: `viewdir={"yz",0.65,50}`; also `"xz"`, `"xy"`, `"iso"`.
- Several views of one object: `g:Shift` plus `g:Setviewdir` per panel.

## 2D helpers, spherical module, options (§7.13–7.14)

- One call: `Dcartesian{discont=true}`, `Dparametric`, `Dtcurve`, `Dline`, `Dmed`,
  `Dcircle(A,B,C)`, `Dinequalities`, `Dimplicit`.
- Data: `ld.polyreg`, `ld.sss_triangle`, `ld.hom`, `ld.cutpolyline2`,
  `ld.line2strip`, `ld.delaunay`, `ld.voronoi`.
- `Filloptions` for hatching and gradients; `Labelangle` and `Labeldir` after a
  rotated system; `BeginOnPlane{labeldir="auto"}` for 2D axes on a 3D plane.
- Spherical: `Define_sphere{show=false}` as an invisible occluder;
  `DScircle({P,axis})`; `ld.sM`, `ld.toSphere`, `ld.projstereo`.
- Nets: `Dpolyhedron_net(P,{tabs=true,opening=,model=,facet_name=})`.
- `ld.matrix3dof(f)` plus `g:Composematrix3d(m)` turns an affine map into a matrix.

## Extension modules found in the corpus (§7.15)

Each needs its `require`. Try these before hand-writing the equivalent.

- `luadraw_shadedforms`: `Dshadedpolyline`, `Dshadedrectangle{values=,grid=}`,
  `Dshadedregion`.
- `luadraw_pdfliteral`: `Dliteralpolyline`, `Dliteraldots`, `Dliteralfacet` for
  very large data.
- `luadraw_linprog`: `DlinprogHalfPlanes`, `DlinprogRegion`,
  `DlinprogObjectiveLine`, `ld.linprogSolve3d`.
- `luadraw_log_axes`: `Beginlogview` then `Dlogpolyline`, `Dlogdots`, `Dlogline`,
  `Dloglabel`.
- `luadraw_coils_chains`: `Dcoil`, `Dcoil2`, `Dchain`, `Dchain2`.
- `luadraw_decorations`: after the `require`, `Darc` and `Darc3d` take an option
  table (`label`, `sector_options`, `ticks`).
- 2D: `Drectangle`, `Dwedge`, `DplotXY`. 3D: `ld.bezier3d`, `Dfrustum`,
  `Adjust_color` (shading used by `Dfacet`).

## Encapsulation exceptions seen in the corpus (§6.4)

- A helper that transforms its arguments and is reused is acceptable; a pure
  pass-through wrapper is not.
- A helper that returns data and replaces many lines may be used twice: count
  lines saved, not call sites. It never takes a drawing callback.
- Hoist a helper copied into many files; do not paste it.
- Panels with identical windows use `g:Shift`; `Viewport` only when each panel
  has its own `Coordsystem`.
- A string written more than three times becomes one loop or one style factory.
