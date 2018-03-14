int: n; % number of court members
set of int: COURT = 1..n;
int: emperor = 1;
array[COURT] of int: rank;
array[COURT] of int: ability;

int: m; % number of horses
set of int: HORSE = 1..m;
array[HORSE] of int: beauty;
array[HORSE] of int: speed;

array[COURT,HORSE] of int: enjoy;

include "globals.mzn";

array[COURT] of var 0..m: horse;
array[HORSE] of var 0..n: member;

% bijection function
constraint forall(c in COURT, h in HORSE)(
  horse[c] = h <-> member[h] = c
);


% court try to ride as many horses as possible.
constraint sum([horse[x] > 0 | x in COURT]) = min(m, n);

% verify the court can ride a horse.
constraint forall(i in COURT)(
  horse[i] > 0 -> enjoy[i, horse[i]] >= 0
);

% emperor enjoy than anybody else
constraint forall(i in 2..n)(
  horse[i] > 0 -> enjoy[emperor, horse[emperor]] > enjoy[i, horse[i]]
);

% higher rank get prettier horse
constraint forall(i in COURT, j in COURT)(
  rank[i] > rank[j] -> (
    horse[j] = 0 \/
    beauty[horse[i]] >= beauty[horse[j]]
  )
);

var int: penalty;
constraint penalty = sum(i in HORSE, j in HORSE)(bool2int(not
  (
    speed[i] > speed[j] -> (
      member[i] = 0 \/
      ability[ member[i] ] >= ability[ member[j] ]
    )
  )
)) * 100;



var int: obj;
constraint obj = sum(i in COURT)(
  if horse[i] > 0 then enjoy[i, horse[i]] else 0 endif
) - penalty;

solve maximize obj;

output ["horse = \(horse);" ++ "\nobj = \(obj);"];


