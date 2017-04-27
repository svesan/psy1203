*-- Simulate a recurrence risk t1 and t2;
*-- On top of this, both t1 and t2 are exposed for an strong environmental risk. Then the RR is diluted in t3 and t4;

data t1;
retain seed 23477;

do i=1 to 10000;
  if uniform(seed)<0.1 then t1=1;else t1=0;

  if t1=1 and uniform(seed)<0.8 then t2=1;
  else if t1=0 and uniform(seed)<0.1 then t2=1;
  else t2=0;

  *-- Now t3 is inflated by an environmental risk;
  t3=t1; t4=t2;
  if uniform(seed)<0.6 then t3=1;
  if uniform(seed)<0.6 then t4=1;

  output;
end;
run;

proc freq data=t1;
  table t1*t2 / nopercent nocol or;
  table t3*t4 / nopercent nocol or;
run;
