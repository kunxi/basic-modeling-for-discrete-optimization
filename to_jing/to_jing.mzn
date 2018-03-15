% Liu Bei forsees that Yuan Shiu will be defeated by Cao Cao
% He needs to find a route to safety in Jin province before the defeat
% But Cao Cao's soldiers are everywhere

int: nrow;
set of int: ROW = 1..nrow;
int: ncol;
set of int: COL = 1..ncol;

% Plains, Mountain, Forest, City, River
enum TERRAIN = { P, M, F, C, R };
array[TERRAIN] of int: delay;
int: timelimit;

array[ROW,COL] of TERRAIN: terrain;
array[ROW,COL] of int: soldier;
array[ROW,COL] of bool: Jin;

int: start_row;
int: start_col;

int: maxstep;
set of int: STEP = 1..maxstep;
set of int: STEP0 = 0..maxstep;

var STEP: steps;
array[ROW,COL] of var STEP0: visit; % which step do we visit position or 0 if not visited

include "globals.mzn";

% start at start position
constraint visit[start_row,start_col] = 1;

% only use steps moves
constraint sum(r in ROW, c in COL)(visit[r,c] >= 1) <= steps;

% reach Jin province at the last step
constraint forall(r in ROW, c in COL)(visit[r,c] = steps -> Jin[r,c]);

% visit at most one city
constraint sum(r in ROW, c in COL)(visit[r,c] >= 1 /\ terrain[r,c] = C) <= 1;

% cant enter Mountain
constraint forall(r in ROW, c in COL)(terrain[r,c] = M -> visit[r,c] = 0);

% visit only one place in every step
constraint alldifferent_except_0([visit[r,c]| r in ROW, c in COL]);

% steps form a path: there exists the next step
% 4 corners
constraint let { var STEP0: s = visit[1,1]
} in (s >= 1 /\ s < steps) -> (visit[1,2] = s + 1 \/ visit[2,1] = s + 1);

constraint let { var STEP0: s = visit[nrow,1]
} in (s >= 1 /\ s < steps) -> (visit[nrow,2] = s + 1 \/ visit[nrow-1,1] = s + 1);


constraint let { var STEP0: s = visit[1,ncol]
} in (s >= 1 /\ s < steps) -> (visit[1,ncol-1] = s + 1 \/ visit[2,ncol] = s + 1);

constraint let { var STEP0: s = visit[nrow,ncol]
} in (s >= 1 /\ s < steps) -> (visit[nrow-1,ncol] = s + 1 \/ visit[nrow, ncol-1] = s + 1);

% 4 edges
% North
constraint forall(c in 2..ncol-1)
  ( let { int: r = 1, var STEP0: s = visit[r,c]
    } in (s >= 1 /\ s < steps) -> (
      visit[r, c+1] = s + 1 \/
      visit[r, c-1] = s + 1 \/
      visit[r+1, c] = s + 1
    )
  );

% South
constraint forall(c in 2..ncol-1)
  ( let { int: r = nrow, var STEP0: s = visit[r,c]
    } in (s >= 1 /\ s < steps) -> (
      visit[r, c+1] = s + 1 \/
      visit[r, c-1] = s + 1 \/
      visit[r-1, c] = s + 1
    )
  );

% West
constraint forall(r in 2..nrow-1)
  ( let { int: c = 1, var STEP0: s = visit[r,c]
    } in (s >= 1 /\ s < steps) -> (
      visit[r+1, c] = s + 1 \/
      visit[r-1, c] = s + 1 \/
      visit[r, c+1] = s + 1
    )
  );

% East
constraint forall(r in 2..nrow-1)
  ( let { int: c = ncol, var STEP0: s = visit[r,c]
    } in (s >= 1 /\ s < steps) -> (
      visit[r+1, c] = s + 1 \/
      visit[r-1, c] = s + 1 \/
      visit[r, c-1] = s + 1
    )
  );

% Central field
constraint forall(r in 2..nrow-1, c in 2..ncol-1)
  ( let { var STEP0: s = visit[r,c]
    } in (s >= 1 /\ s < steps) -> (
      visit[r, c+1] = s + 1 \/
      visit[r, c-1] = s + 1 \/
      visit[r+1, c] = s + 1 \/
      visit[r-1, c] = s + 1
    )
  );


% no shortcuts
constraint forall(r1,r2 in ROW, c1,c2 in COL)
                 (abs(r1-r2) + abs(c1-c2) = 1 ->
                  visit[r1,c1] = 0 \/ visit[r2,c2] = 0 \/
                  abs(visit[r1,c1] - visit[r2,c2]) = 1);


% not too much delay
constraint time <= timelimit;
var int: time = sum(r in ROW, c in COL)(delay[terrain[r,c]]*(visit[r,c] >= 1));

% minimize the number of soldiers traversed
solve minimize obj;
var int: obj = sum(r in ROW, c in COL)((visit[r,c] > 0)*soldier[r,c]);



array[TERRAIN] of string: ter = [".", "#", "^", "C", "~"];

output 
       ["%"] ++
       [ " " ++ ter[fix(terrain[r,c])] ++ if c = ncol then "\n%" else "" endif
       | r in ROW, c in COL ]
       ++ ["\n%"] ++
       [ if soldier[r,c] > 0 then show_int(2,soldier[r,c]) else " ." endif
         ++ if c = ncol then "\n%" else "" endif
       | r in ROW, c in COL ]
       ++ ["\n"] ++
       ["%"] ++
       [ if fix(visit[r,c]) > 0 then show_int(2,visit[r,c]) else " ." endif
         ++ if c = ncol then "\n%" else "" endif
       | r in ROW, c in COL ]
       ++ ["\nvisit = array2d(ROW,COL,\(visit));\nsteps = \(steps);\ntime = \(time);\nobj = \(obj);"]
       ;


