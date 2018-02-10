array[int] of int: readings;
int: start;
int: n = length(readings);

array[0..n] of var int: temp;

constraint temp[0] = start;
constraint forall(i in 1..n) (temp[i] = (temp[i - 1] + readings[i]) div 2);

solve satisfy;
output ["temp = ", show(temp)];