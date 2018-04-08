variables
z
v
;
positive variables
x1
x2
u
p1
p2
;

equations
obj1
obj2
c11
c12
c13
c2
c3
;

obj1.. z =e= - x1 - x2 ;
obj2.. z =e= - x1 - x2 +100*(p1+p2);
c11.. 4 =e= 1/2*(-u+(x1*x1)+(x2*x2)) +p2;
c12.. v =e= x2-x1 ;
c13.. u =e= (v*v)  +p1;
c2..  x1    =l= 6;
c3..     x2 =l= 4;

Model BL1 / all -obj2/;
Model BL2 / all -obj1/;

option nlp = minos
       optcr = 0
;
solve BL2 using NLP minimizing z;

option nlp = conopt;
solve BL2 using NLP minimizing z;
