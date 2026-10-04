-- source: luadraw-v3.5/luadraw/doc/src/body-en/luadraw-doc2d-en-section-7-Adding-Your-Own-Methods.tex (Luacode block)
-- luadraw_fields.lua
-- added methods to the graph class of the luadraw package
-- to draw vector or gradient fields
local ld = luadraw
local graph = ld.graph
local cpx = ld.cpx
local Z = cpx.Z

function ld.field(f,x1,x2,y1,y2,grid,long)  -- mathematical function, independent of the graph
-- calculates a vector field in the tile [x1,x2]x[y1,y2]
-- f function of two variables with values ​​in R^2
-- grid = {nbx, nby} : number of vectors along x and along y
-- long = length of a vector
    if grid == nil then grid = {25,25} end
    local deltax, deltay = (x2-x1)/(grid[1]-1), (y2-y1)/(grid[2]-1) -- x and y step
    if long == nil then long = math.min(deltax,deltay) end -- default length
    local vectors = {} -- will contain the list of vectors
    local x, y, v = x1 
    for _ = 1, grid[1] do -- a loop on x
        y = y1
        for _ = 1, grid[2] do -- a loop on y
            v = f(x,y) -- we assume that v is well defined
            v = Z(v[1],v[2]) -- to complex number
            v = cpx.normalize(v)
            if v ~= nil then
                table.insert(vectors, {Z(x,y)-long/2*v, Z(x,y)+long/2*v} ) -- we add the vector
            end
            y = y+deltay
        end
        x = x+deltax
    end
    return vectors -- we return the result (polygonal line)
end

function graph:Dvectorfield(f,args) -- added a method to the graph class
-- draws a vector field
-- f is a function of two variables with values ​​in R^2
-- args is a 4-field table:
-- { view={x1,x2,y1,y2}, grid={nbx,nby}, long=, draw_options=""}
    args = args or {}
    local view = args.view or {self:Xinf(),self:Xsup(),self:Yinf(),self:Ysup()} -- default user reference
    local vectors = ld.field(f,view[1],view[2],view[3],view[4],args.grid,args.long) -- field calculation
    self:Dpolyline(vectors,false,args.draw_options) -- the drawing (non-closed polygonal line)
end

function graph:Dgradientfield(f,args) -- added another method to the graph class
-- draws a gradient field
-- f is a function of two variables with values ​​in R
-- args is a 4-field table:
-- { view={x1,x2,y1,y2}, grid={nbx,nby}, long=, draw_options=""}
    local h = 1e-6
    local grad_f = function(x,y) -- gradient function of f
        return { (f(x+h,y)-f(x-h,y))/(2*h), (f(x,y+h)-f(x,y-h))/(2*h) }
    end
    self:Dvectorfield(grad_f,args) -- we use the previous method
end
