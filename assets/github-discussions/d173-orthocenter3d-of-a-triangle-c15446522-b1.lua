-- source: https://github.com/pfradin/luadraw/discussions/173#discussioncomment-15446522 (pfradin, block 1)
function orthocenter3d(A,B,C)
-- return orthcenter of the triangle (A,B,C) 
    local I = circumcircle3d(A,B,C)
        if I ~= nil then
            return (A+B+C)-2*I
        end
end
