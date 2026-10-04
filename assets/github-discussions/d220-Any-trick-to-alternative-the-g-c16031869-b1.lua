-- source: https://github.com/pfradin/luadraw/discussions/220#discussioncomment-16031869 (pfradin, block 1)
    g:Saveattr()
    g:Viewport(-5, 0, 0, 5)
    g:Coordsystem(-3, 3, -3, 3)
        g:Daxes({0,1,1},{
            limits={ {-2.5,2.5}, {-2.5,2.5} },
            gradlimits={ {-2,2}, {-2,2} },-- <- "-3" strange tick marks
            arrows="-Stealth"
        })
