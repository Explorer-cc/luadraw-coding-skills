// source: https://tex.stackexchange.com/a/755838 (question 755835, score 10, block 1)
//options: +W640 +H640 +A +P +FN
global_settings { charset utf8
                  ambient_light rgb 1.5
                  assumed_gamma 1.8
}
background{color rgb<0.827450980392157,0.827450980392157,0.827450980392157>}
camera{ orthographic
        location 6928.20323027551*<-0.75,0.433012701892219,0.5>
        sky <0.433012701892219,-0.25,0.866025403784439>
        up 4*y
        right 4*x
        look_at <0,0,0>
        translate <0,0,0>}
light_source { 6928.20323027551*<-0.650764527255524,0.0157334064411988,0.759116585240799> color rgb<1,1,1>}
// déclarations des objets
#declare objet1 =
  isosurface{function{pow(2.92*(x-1)*x*x*(x+1)+1.7*y*y,2)*pow(y*y-0.88,2)+pow(2.92*(y-1)*y*y*(y+1)+1.7*z*z,2)*pow(z*z-0.88,2)+pow(2.92*(z-1)*z*z*(z+1)+1.7*x*x,2)*pow(x*x-0.88,2)-0.02}
    contained_by{ box{ <-1,-1,-1> <1,1,1>}}
    open
evaluate 0.176805692020992,1.5,0.7
    matrix <-1,0,0,
         0,1,0,
         0,0,1,
         0,0,0>
     }
#declare objet2 =
union{
cone { <0,2,0> 0
   <0,1.875,0> 0.05}
cone { <-2,0,0> 0
   <-1.875,0,0> 0.05}
cone { <0,0,2> 0
   <0,0,1.875> 0.05}
cylinder { <0,-2,0>
   <0,1.875,0> 0.005}
cylinder { <2,0,0>
   <-1.875,0,0> 0.005}
cylinder { <0,0,-2>
   <0,0,1.875> 0.005}
}
// rendu des objets
object{ objet1
        pigment{ color rgb<0.43921568627451,0.501960784313725,0.564705882352941>}
        finish{ ambient 0.35  diffuse 0.8 phong 0.5}
     }
object{ objet2
        pigment{ color rgb<1,0.843137254901961,0>}
        finish{ ambient 0.35  diffuse 0.8 phong 0.5}
     }
