proc sql;
  create table t1 as
  select barn1, count(distinct barn2) as n
  from x3
  group by barn1
  where outcome='ASD'
  ;


data sib1;
  set x3(where=((barn1=1565529 or barn1=21 or barn2=1565529 or barn2=21) and outcome='ASD')
         keep=barn1 barn2 outcome ft entry exit cens famid);
run;
data cos1;
  set x3_cousins(where=((barn1=1565529 or barn1=21 or barn2=1565529 or barn2=21) and outcome='ASD')
         keep=barn1 barn2 outcome entry exit cens famid);
run;

proc sort data=sib1;by famid barn1 entry exit barn2;run;
proc sort data=cos1;by barn1 barn2 entry exit barn2;run;

data chk1;
  set x3(where=((barn2=3434607 or barn2=8113533 or barn2=9972664) and outcome='ASD')
         keep=barn1 barn2 outcome ft entry exit cens famid);
run;


proc sql;
  create table chk2 as
  select barn1, count(distinct barn2) as antal
  from x3_cousins
  where outcome='ASD'
  group by barn1
  ;

proc freq;
table antal;
run;
