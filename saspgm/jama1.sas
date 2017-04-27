proc sort data=x3(keep=outcome famid ft barn1 barn2 entry) out=s1(where=(outcome='ASD'));
  by famid barn1 barn2 entry;
run;

*-- Remove duplicates, due to time varying events;
proc sort data=s1 out=s2 nodupkey;
  by famid barn1 barn2;
run;

proc freq data=s2;table ft;run;
