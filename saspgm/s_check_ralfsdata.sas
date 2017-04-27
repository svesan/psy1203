/* Below I check the data: Since one subject can go into several analyses. For the calculation
of heritability and pick the first pair only. This avoid any problem since for h2 calculation
each child is used only once */
proc sql;
  create table a as
  select barn1, count(distinct ft) as antal_ft
  from sasperm.ralf2
  where outcome='ASD' and ft ne 'C' and child_pair_order=1
  group by barn1
  ;

  create table c1 as
  select distinct barn1, ft, 1 as one
  from sasperm.ralf2
  where outcome='ASD' and ft ne 'C'  and child_pair_order=1
  order by barn1, ft
  ;
proc sql;
  create table c2 as
  select a.*, b.antal_ft
  from c1 as a join a as b on a.barn1=b.barn1;

proc transpose data=c2 out=c3;
  var one;
  id ft;
  by barn1 antal_ft;
run;
proc freq data=c3;
table antal_ft;
run;
