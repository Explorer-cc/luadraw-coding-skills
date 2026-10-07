// source: https://tex.stackexchange.com/a/759326 (question 759308, score 10, block 2)
//options: +W640 +H640 +A +P +FN +UA
global_settings { charset utf8
                  ambient_light rgb 1.5
                  assumed_gamma 1.8
}
background{color srgbt<0,0,0,1>}
camera{ orthographic
        location 17320.5080756888*<-0.556670399226419,-0.663413948168938,0.5>
        sky <0.32139380484327,0.383022221559489,0.866025403784439>
        up 3*y
        right 1.75*x
        look_at <0,0,0>
        translate <-0.157383972106092,0.784764477613576,0.866025403784439>}
light_source { 17320.5080756888*<-0.643138074688832,-0.453677463243883,0.616887490738901> color rgb<1,1,1>}
// déclarations des objets
#declare objet1 =
  isosurface{function{pow(x,3)+pow(y,3)-z}
    contained_by{ box{ <0,0,0> <1,1,2>}}
    open
evaluate 0.666666666666666,1.5,0.7
    matrix <-1,0,0,
         0,1,0,
         0,0,1,
         0,0,0>
     }
#declare objet2 =
  isosurface{function{z-pow(x*pow(1-pow(y,2),0.5)+y*pow(1-pow(x,2),0.5),3)}
    contained_by{ box{ <0,0,0> <0.999,0.999,2>}}
    open
evaluate 0.666666666666666,1.5,0.7
    matrix <-1,0,0,
         0,1,0,
         0,0,1,
         0,0,0>
     }
// rendu des objets
object{ objet1
        pigment{ color rgb<0.274509803921569,0.509803921568627,0.705882352941177>}
        finish{ ambient 0.35  diffuse 0.8 phong 0.5}
     }
object{ objet2
        pigment{ color rgb<0.862745098039216,0.0784313725490196,0.235294117647059>}
        finish{ ambient 0.35  diffuse 0.8 phong 0.5}
     }
