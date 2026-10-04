-- source: https://github.com/pfradin/luadraw/discussions/81#discussioncomment-14370203 (pfradin, block 1)
function M(x,y,z)
    if z == nil then return complex:new(x,y)
    else return point3d:new(x,y,z)
    end
end

function Ms(r,theta,phi)
    if phi == nil then return Zp(r,theta)
    else 
        return point3d:new(r*math.cos(theta)*math.sin(phi), r*math.sin(theta)*math.sin(phi), r*math.cos(phi))
    end
end
