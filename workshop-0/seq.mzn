int: n;
array[1..n] of var int: x;

constraint forall(i in 1..n) (x[i] <= 3);
constraint forall(i in 1..n) (x[i] >= 0);
constraint x[1] = 0;
constraint x[n] = 3;
constraint forall(i in 1..n-1) (x[i] + x[i+1] <= 3);
constraint forall(i in 1..n) (if i mod 3 = 0 then x[i] >= 2 else true endif);

solve maximize sum(x);
output [show(sum(x)), " = ", show(x)];