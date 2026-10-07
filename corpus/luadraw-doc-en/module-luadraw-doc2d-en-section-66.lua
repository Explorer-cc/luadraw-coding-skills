-- source: luadraw-v3.5/luadraw/doc/src/body-en/luadraw-doc2d-en-section-2-Graphics-Methods.tex (Luacode block)
function ld.num(x) -- x is a real, returns a string
    local rep = ld.strReal(x) -- conversion to string with digits decimals max
    if ld.siunitx then rep = "\\num{"..rep.."}" end --needs \usepackage{siunitx}
    return rep
end
