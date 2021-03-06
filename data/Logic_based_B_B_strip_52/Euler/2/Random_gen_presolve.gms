$include seed.gms
*execseed =         14;

Set box number of boxes /1*5/
    k   disjunctions /1*10/
;
parameter boxes_param;
boxes_param=card(box);
Scalar heigth packing box height;
heigth=UniformInt(10,20);
*heigth=UniformInt(5,7);

Parameter
    h(box) heigth of boxes
    l(box) length of boxes;

loop(box$(ord(box)<=boxes_param),
   h(box) = UniformInt(2,5);
   l(box) = UniformInt(1,10);
);

Alias (box,j);
Alias (box,boxx,jj);

Set i disjuctive term /1*4/
    ij(box,j), ijk(box,j,i);

ij(box,j) = ord(box)<ord(j); ij(box,j)$(ord(box)>boxes_param or ord(j)>boxes_param)=no; ijk(ij,i) = yes;

Set ijX(box,j);
option ijX<ij;

display h,l,heigth;

set
    var variables /1*40/
    e   max number of equations per disjunction /1*3/
    ge  global constraints /1*20/
    ki(k,i)  set that contains disjunctions and terms
    kie(k,i,e) set that contains disjunctions terms and equations
    kv(k,var) set that contains disjunctions and variables
 ;

parameter term(k), eq_term(k,i), A(k,i,e,var), b(k,i,e), c(var), ub(var), lb(var), Aglob(ge,var), bglo(ge);
scalar cnt1 /1/
       cnt2 /1/
;


ki(k,i)=no;
loop(ij, ki(k,i)$(ord(k)=cnt1)=yes;cnt1=cnt1+1;);
cnt1=1;

kie(k,i,e)=no;
loop((k,i,e)$ki(k,i),
   if(ord(i)=1 or ord(i)=2, kie(k,i,'1')=yes;);
   if(ord(i)=3 or ord(i)=4, kie(k,i,e)=yes;);
);

display kie;

loop(ge$(ord(ge)<=boxes_param),
   Aglob(ge,var)$(ord(var)=ord(ge)) = 1;
   bglo(ge) = sum(box$(ord(box)=ord(ge)),l(box));
);


kv(k,var)=no;

loop(ij(box,j),
   b(k,'1','1')$(ord(k)=cnt1) = -l(box);
   A(k,'1','1',var)$(ord(k)=cnt1 and ord(var)=ord(box)) = 1;
   A(k,'1','1',var)$(ord(k)=cnt1 and ord(var)=ord(j))   = -1;

   b(k,'2','1')$(ord(k)=cnt1) = -l(j);
   A(k,'2','1',var)$(ord(k)=cnt1 and ord(var)=ord(box)) = -1;
   A(k,'2','1',var)$(ord(k)=cnt1 and ord(var)=ord(j))   = 1;

   b(k,'3','1')$(ord(k)=cnt1) = -h(box);
   A(k,'3','1',var)$(ord(k)=cnt1 and ord(var)=(ord(box)+boxes_param)) = -1;
   A(k,'3','1',var)$(ord(k)=cnt1 and ord(var)=(ord(j)+boxes_param))   = 1;

   b(k,'3','2')$(ord(k)=cnt1) = l(j)-1;
   A(k,'3','2',var)$(ord(k)=cnt1 and ord(var)=ord(box)) = 1;
   A(k,'3','2',var)$(ord(k)=cnt1 and ord(var)=ord(j))   = -1;

   b(k,'3','3')$(ord(k)=cnt1) = l(box)-1;
   A(k,'3','3',var)$(ord(k)=cnt1 and ord(var)=ord(box)) = -1;
   A(k,'3','3',var)$(ord(k)=cnt1 and ord(var)=ord(j))   = 1;

   b(k,'4','1')$(ord(k)=cnt1) = -h(j);
   A(k,'4','1',var)$(ord(k)=cnt1 and ord(var)=(ord(box)+boxes_param)) = 1;
   A(k,'4','1',var)$(ord(k)=cnt1 and ord(var)=(ord(j)+boxes_param))   = -1;

   b(k,'4','2')$(ord(k)=cnt1) = l(j)-1;
   A(k,'4','2',var)$(ord(k)=cnt1 and ord(var)=ord(box)) = 1;
   A(k,'4','2',var)$(ord(k)=cnt1 and ord(var)=ord(j))   = -1;

   b(k,'4','3')$(ord(k)=cnt1) = l(box)-1;
   A(k,'4','3',var)$(ord(k)=cnt1 and ord(var)=ord(box)) = -1;
   A(k,'4','3',var)$(ord(k)=cnt1 and ord(var)=ord(j))   = 1;

   cnt1=cnt1+1;
);

kv(k,var)$( sum((i,e)$(A(k,i,e,var)<>0),1)>=1 )=yes;

loop(box$(ord(box)<=boxes_param),
   ub(var)$(ord(var)=ord(box)) = sum(j, l(j));
   lb(var)$(ord(var)=ord(box)) = 0;
   ub(var)$(ord(var)=(ord(box)+boxes_param)) = heigth;
   lb(var)$(ord(var)=(ord(box)+boxes_param)) = h(box);
);

kie(k,i,e)$(ord(e)>1)=no;

kv(k,var)$( sum((i,e)$(A(k,i,e,var)<>0),1)>=1 )=yes;

execute_unload "prob_data_%seed%" A,Aglob,bglo,b,c,ub,lb,term;

$exit

