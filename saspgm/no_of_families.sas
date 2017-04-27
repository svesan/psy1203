proc sql;
create table t1 as
select distinct ft, famid, mor1, far1, barn1, barn2
from sasperm.x3
where outcome='AD'
;
proc sort data=t1;
by ft famid mor1 far1 barn1 barn2;
run;

data t2;
  set t1;
  by ft famid mor1 far1 barn1 barn2;

  if first.mor1 or first.far1;
run;

proc sql;
select count(distinct barn1) as n
from t1
;
