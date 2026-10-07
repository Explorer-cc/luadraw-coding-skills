-- source: https://github.com/pfradin/luadraw/discussions/162#discussioncomment-18412544 (pfradin, block 1)
local P = ld.regular_pyramid(n, a, h, false, M(0,0,-h))
local points = P.vertices
local S = points[n + 1]
