% assignment 2
% select a set of raiding warrior
enum WARRIOR;
WARRIOR: dummy; 
enum CLAN; % the clan they belong too

int: l; % minimum raid party size
int: u; % maximum raid party size
int: m; % limit of hatreds

array[WARRIOR] of int: strength;
array[WARRIOR] of CLAN: clan;

array[CLAN,CLAN] of 0..1: hates;

var set of WARRIOR: raid;
constraint card(raid) >= l /\ card(raid) <= u;
constraint not(dummy in raid);


constraint sum(i, j in raid where i < j)( hates[clan[i],clan[j]] ) <= m;


var int: obj;
constraint obj = sum(i in raid) (strength[i]);

solve
  ::int_search( strength, largest, indomain_random, complete )
  maximize obj;