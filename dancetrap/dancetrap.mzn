% Beauty Trap
% Perform the most seductive dance

enum LEGS = {spin, leap, waltz, curtsey, prep, stand};
enum ARMS = {beckon, out, up, wrapped, neutral};
enum FACE = {smile, wink, batt, think, glow, blank};

int: maxlen;
set of int: STEP = 1..maxlen;
array[LEGS] of int: maxlegs;
array[ARMS] of int: maxarms;
array[FACE] of int: maxface;
constraint assert(maxlegs[stand] >= maxlen, "maxlegs[stand] smaller than maxlen");
constraint assert(maxarms[neutral] >= maxlen, "maxarms[neutral] smaller than maxlen");
constraint assert(maxface[blank] >= maxlen, "maxface[blank] smaller than maxlen");
array[LEGS,ARMS] of int: dance_value;
array[ARMS,FACE] of int: entice_value;
constraint assert(dance_value[stand,neutral] = 0, "incorrect dance_value array");
constraint assert(entice_value[neutral,blank] = 0, "incorrect entice_value array");
int: boredom; % how bored each step make the viewer

var STEP: len;
array[STEP] of var LEGS: legs;
array[STEP] of var ARMS: arms;
array[STEP] of var FACE: face;


include "regular.mzn";
include "atmost.mzn";

% LEGS, the states are: 
% spin, leap, waltz, curtsey, prep, stand, prepw, leapw, spinw, init
%   1,   2,     3,     4,       5,    6,     7,     8,     9,    10

constraint regular(legs, 10, 6, dl, 10, {6});
array[1..10, LEGS] of 0..10: dl = 
  [| 0, 0, 0, 4, 5, 6,
   | 1, 0, 3, 0, 0, 6,
   | 0, 0, 3, 0, 0, 0,
   | 1, 0, 3, 4, 5, 6,
   | 1, 2, 3, 4, 5, 6,
   | 1, 0, 3, 4, 5, 6,
   | 0, 0, 3, 0, 0, 6, 
   | 0, 0, 3, 0, 0, 6, 
   | 0, 0, 0, 0, 0, 6,
   | 1, 0, 3, 4, 5, 6, |];


% She can waltz at most three times in a row, aka not all waltz in four.
constraint forall(i in 1..len-3)(
  sum(x in i..i+3)(legs[x] = waltz) <= 3
);

% ARM: the states are:
% beckon, out, up, wrapped, neutral, init
%   1,     2,   3,    4,      5,      6

constraint regular(arms, 6, 5, da, 6, {5});
array[1..6, ARMS] of 0..5: da = 
  [| 0, 2, 3, 4, 5,
   | 1, 0, 3, 0, 5,
   | 1, 2, 0, 0, 5,
   | 0, 2, 3, 0, 5,
   | 0, 2, 3, 4, 5,
   | 0, 2, 3, 4, 5, |];


% FACE
constraint forall(i in 1..maxlen-1)(
  face[i] != face[i+1] \/  face[i] = blank
);

constraint forall(i in 1..maxlen-1)(
  face[i] = smile \/  face[i] = batt -> face[i+1] != think
);


% combination constraints
constraint forall(i in 1..maxlen)(dance_value[ legs[i], arms[i] ] >= 0);
constraint forall(i in 1..maxlen)(entice_value[ arms[i], face[i] ] >= 0);

constraint forall(x in LEGS)( at_most(maxlegs[x], legs, x ));
constraint forall(x in ARMS)( at_most(maxarms[x], arms, x ));
constraint forall(x in FACE)( at_most(maxface[x], face, x ));


constraint forall(i in len+1..maxlen)(legs[i] = stand);
constraint forall(i in len+1..maxlen)(arms[i] = neutral);
constraint forall(i in len+1..maxlen)(face[i] = blank);

var int: obj;
constraint obj = sum(i in 1..len)(dance_value[ legs[i], arms[i] ]) + 
  sum(i in 1..len)(entice_value[ arms[i], face[i] ])  - len * boredom;
  
solve maximize obj;