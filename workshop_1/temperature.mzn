array[int] of int: readings;
int: start;

enum ACTION = {heat, strongly_heat, cool, strongly_cool, do_nothing};
array[ACTION] of int: EFFECTS = [1, 4, -2, -5, 0];
array[ACTION] of int: COSTS = [1, 5, 3, 9, 0];

int: n = length(readings);
array[0..n] of var int: temp;
array[1..n] of var ACTION: choice;
var int: cost = sum([COSTS[choice[i]] | i in 1..n]);

constraint temp[0] = start;
constraint forall(i in 1..n) (temp[i] = EFFECTS[choice[i]] + (temp[i - 1] + readings[i]) div 2);
constraint forall(i in 1..n) (temp[i] <= 30);
constraint forall(i in 1..n) (temp[i] >= 25);

solve minimize cost;

output ["temp = ", show(temp), "\n"];
output ["choice = ", show(choice),  "\n"];
output ["cost = ", show(cost), "\n"];
