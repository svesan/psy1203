proc sql;
create table sexratio1 as
select distinct outcome, barn1, barn2, sex1, sex2, 1-cens as event length=3, asd_exp
from x3
;

proc freq;
table outcome * event / nocol nopercent;
run;

title1 'Sex distribution among ASD and AD cases';
proc freq data=sexratio1;
  where event=1;
  table outcome * sex2 / nocol nopercent;
run;
