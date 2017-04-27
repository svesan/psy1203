proc sql;
  create table a as
  select barn,count(ft) as x
  from t1
  where outcome='ASD' and ft ne 'C'
  group by barn;


proc sql;
  create table b1 as
  select barn, ft, 1 as one
  from t1
  where outcome='ASD' and ft ne 'C'
  order by barn, ft
  ;

proc sql;
  create table b2 as
  select a.*, b.x
  from b1 as a join a as b on a.barn=b.barn;

proc transpose data=b2 out=b3;
  var one;
  id ft;
  by barn x;
run;
