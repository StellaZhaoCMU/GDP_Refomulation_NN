positive variables it(t), f(t,r), ix(t,r);
Variables
     cost        objective variable
     x(var);
Binary variable y(k,i);

Equations
     obj
     eq2
     eq3
     eq4
     eq5
     sum_bin
     disj_ineq

;

obj.. cost =e= sum(t,IC(t)*it(t)) + sum(map_var_c(var,t,r),x(var));
eq2(t).. it(t) =e= sum(r,ix(t,r));
eq3(t,r).. - f(t,r) =l= -D(t,r);
eq4(t,r).. ix(t,r) =e= ix(t-1,r)$(ord(t)>1) + sum(map_var_x(var,t,r),x(var)) - f(t,r);
eq5(t,r)$(ord(t)>=2)..  sum((k,i)$logic_left(t,r,k,i),y(k,i)) =e= sum((tt,k,i)$logic_right(t,r,k,tt,i),y(k,i));


disj_ineq(kie(ki(k,i),e)).. sum(var$(A(k,i,e,var)<>0),A(kie,var)*x(var)) =l= b(kie) + opt_bigm(k,i,e)*(1-y(ki));
sum_bin(k).. sum(ki(k,i),y(ki)) =e= 1;

model prob / obj, eq2, eq3, eq4, eq5, sum_bin,disj_ineq /;

x.up(var) = ub(var);
x.lo(var) = lb(var);
*y.fx(k,'11')=1;

option optcr = 0.001
       reslim = 72000
*       mip=BDMLP
*       mip=CBC
*       mip=SCIP
*       rmip=CBC
  ;
*prob.nodlim=1000000;

prob.optfile = 1;

x.lo(var) = lb(var);
x.up(var) = ub(var);

*y.fx(k,'1')$(ord(k)<=10)=1;
*y.fx(k,'14')=1;

$include max_time_ref

scalar rel,sol,nodes,time,cpu,LBL,const,vars,bin;

solve prob using rmip min cost;
rel = prob.objval;
bin=sum(ki,1);

solve prob using mip min cost;
sol = prob.objval;
time = prob.etsolve;
cpu = prob.resUsd;
nodes = prob.nodusd;
LBL  = prob.objest;
const = prob.numequ;
vars = prob.numvar;

execute_unload "res_prob" rel,sol,nodes,time,cpu,LBL,const,vars,bin;

execute_unload "BigM"


