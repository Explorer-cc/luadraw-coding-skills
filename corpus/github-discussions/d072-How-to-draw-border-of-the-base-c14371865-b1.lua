-- source: https://github.com/pfradin/luadraw/discussions/72#discussioncomment-14371865 (pfradin, block 1)
g:Dscene3d(
    g:addPoly(cone(O,I,R,100),{color="orange",backcull=true,contrast=0.5}),
    g:addPolyline(facetedges(pyramid({A,B,C},O)),{hidden=true}), -- only edges of pyramid
    g:addPolyline({O,I},{hidden=true})
)
