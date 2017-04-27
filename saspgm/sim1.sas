data t1;
retain seed 23477;
do sib1=1 to 1000;
  event1=uniform(seed) < 0.2;
  event2=uniform(seed) < 0.2+event1*0.1;
  output;
end;
run;

proc freq;
table event1*event2/nocol nopercent;
run;

proc logistic data=t1;
  class event1;
  model event2 = event1;
  strata sib1;
run;
