-- source: https://github.com/pfradin/luadraw/discussions/104#discussioncomment-14532806 (pfradin, block 1)
local gamma = function(x,y) -- approximation of gamma
-- $\Gamma(z) = \sum_{k=0}^{+\infty} \frac{(-1)^k}{k!(z+k)} + \int_1^{+\infty} t^{z-1}e^{-t}dt$
-- $\Gamma(z) = \sum_{k=0}^{+\infty} \frac{2k(z+2k+1)+1}{(2k+1)!(z+2k)(z+2k+1)} + \int_1^{+\infty} t^{z-1}e^{-t}dt$
    local den, z, p = 1, Z(x,y), 0
    local f, f1 = z, z+1
    local S = 1/(f*f1)
    for k = 1,10 do
        p = p+2; f = f+2; f1 = f1+2 -- p=2k, f=z+2k, f1=z+2k+1
        den = den*p*(p+1) -- den=(2k+1)!
        S = S + (p*f1+1)/(den*f*f1)
    end
    return S + int( function(t) return cpx.exp((z-1)*math.log(t)-t) end, 1,10)
end
