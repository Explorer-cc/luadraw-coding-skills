-- source: https://github.com/pfradin/luadraw/discussions/103#discussioncomment-14508903 (pfradin, block 1)
local wd = 4 -- line width
g:Dscene3d(
    g:addPoly(P1,{edge=true, color="LightBlue",edgewidth=wd}),
    g:addFacet({P,Q,R,Q3}, {color="green",edge=true,edgewidth=wd}),
    g:addFacet({P,Q1,R,Q2}, {color="orange",edge=true,edgewidth=wd}),
    g:addPolyline({{Q1,Q,Q3},{P,R},{Q1,Q3},{Q1,Q2},{P,Q1,R,Q2,P}},{width=wd})
)
