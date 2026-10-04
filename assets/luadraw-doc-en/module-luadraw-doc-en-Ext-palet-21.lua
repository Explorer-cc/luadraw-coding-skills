-- source: luadraw-v3.5/luadraw/doc/src/body-en/luadraw-doc-en-Ext-palettes.tex (Luacode block)
local pal = require 'luadraw_palettes'
local color = pal.Blackbody
local BlackbodyTransformed = pal.getPal( -- returns a new palette
    color, -- a palette name
    {
    extract = {2, 5, 8, 9}, -- color numbers to extract
    shift = 1, -- offset among the extracted colors, which gives here: 5,8,9,2
    reverse = true -- reversing the order, which gives here: 2,9,8,5
    }
)
