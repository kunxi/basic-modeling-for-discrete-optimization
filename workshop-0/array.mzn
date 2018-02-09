int: n;
array[1..n] of var int: x;

constraint forall(i in 1..n) (x[i] <= 9);
constraint forall(i in 1..n) (x[i] >= 0);
% non-decreasing
constraint forall(i in 1..n-1) (x[i] <= x[i+1]);
constraint sum(x) = product(x);

solve satisfy;
output [show(x)];