// source: https://tex.stackexchange.com/a/759151 (question 714248, score 11, block 2)
//options: +W640 +H640 +A +P +FN
global_settings { charset utf8
                  ambient_light rgb 1.5
                  assumed_gamma 1.8
}
background{color rgb<0.827450980392157,0.827450980392157,0.827450980392157>}
camera{ orthographic
        location 17320.5080756888*<-0.89253893528903,0.157378695624263,0.422618261740699>
        sky <0.416197740726783,-0.0733868910000382,0.90630778703665>
        up 10*y
        right 10*x
        look_at <0,0,0>
        translate <0,0,0>}
light_source { 17320.5080756888*<-0.757010952878731,-0.150700164744405,0.635786031277539> color rgb<1,1,1>}
// déclarations
#declare objet1 =
torus { 2.75,1
matrix <-1,0,0,
         0,6.12303176911189E-17,1,
         0,-1,6.12303176911189E-17,
         0,0,0>
        }
#declare objet2 =
cylinder { <3.75,0,0>
   <-3.75,0,0> 0.55
        open
     }
#declare objet3 =
cylinder { <1.875,-3.24759526419164,0>
   <-1.875,3.24759526419164,0> 0.55
        open
     }
#declare objet4 =
cylinder { <-1.875,-3.24759526419165,0>
   <1.875,3.24759526419165,0> 0.55
        open
     }
// rendu des objets
difference {
   difference {
      difference{
         object {objet1}
         object {objet2}
         }
     object {objet3}
     }
    object {objet4}
    texture{
       pigment{ color rgb<0.43921568627451,0.501960784313725,0.564705882352941>}
       finish{ ambient 0.35  diffuse 0.8  phong 0.5}
       }
    }
