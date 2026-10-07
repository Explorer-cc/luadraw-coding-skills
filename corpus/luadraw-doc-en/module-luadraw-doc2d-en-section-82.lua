-- source: luadraw-v3.5/luadraw/doc/src/body-en/luadraw-doc2d-en-section-7-Adding-Your-Own-Methods.tex (Luacode block)
local ld = luadraw
local cpx = ld.cpx
local Z = cpx.Z

function ld.graph:DplotXY(X,Y,draw_options)
-- X is a list of real numbers or strings
-- Y is a list of real numbers of the same length as X
    local L = {} -- list of points to draw
    if type(X[1]) == "number" then -- list of real numbers
        for k,x in ipairs(X) do
            table.insert(L,Z(x,Y[k]))
        end
    else
        local noms = {} -- list of labels to place
        for k = 1, #X do
            table.insert(L,Z(k,Y[k]))
            insert(noms,{X[k],k,{pos="E",node_options="rotate=-90"}})
        end
        self:Dlabel(table.unpack(noms)) -- drawing labels
    end
    self:Dpolyline(L,draw_options) -- drawing the curve
end
