-- source: https://github.com/pfradin/luadraw/discussions/83#discussioncomment-14384563 (pfradin, block 1)
g:Dlabel3d(
    b.." in",M(0,b/2,h),{dir={vecJ,-vecI},pos="N"},
    a.." in",M(a/2,0,h),{dir={-vecI,-vecJ}}, -- the *pos* option does not change
    h.." in",M(a,0,h/2),{dir={vecK,vecI}}, --the *pos* option does not change
    c.." in",M(a+c/2,b,0),{dir={-vecI,-vecJ},pos="S"}, --the *pos* option changes
    a.." in",M(a+c,3*b/4,0),{dir={vecJ,-vecI}} --the *pos* option does not change
    ) 
