proc sql;
  create table tmp1 as
  select outcome, ft, barn1, barn2, child_bdat1, child_bdat2, entry, exit, pyear,
         hosp_dat1, hosp_dat2, cens
  from x3
  where child_bdat2> child_bdat1
  order by outcome, ft
  ;
quit;

data tmp2;
  length case1 case2 mark 3;
  set tmp1;
  case1=(hosp_dat1>.z);
  case2=(hosp_dat2>.z);

  *-- Mark children with at least 8 yrs follow-up;
  if child_bdat2 le '01jan2002'd then do;
    mark=1;
    * should exclude events > 8 yrs on both sibs if cens=0 and pyear>0  ;
    if cens=0 and pyear>8 then mark=0;

  end;
  else mark=0;

run;

*-- Tetrachoris correlations;
data tmp3;
  length ad_case1 ad_case2 3;
  set tmp2;
  if outcome='AD' and hosp_dat1>.z then ad_case1=1;else ad_case1=0;
  if outcome='AD' and hosp_dat2>.z then ad_case2=1;else ad_case2=0;
run;

ods output measures=mycorr1(where=(statistic="Tetrachoric Correlation"
                                   or statistic="Polychoric Correlation")
                             keep = statistic table value ft outcome ase);
ods listing close;
proc freq data=tmp2;
  table case1 * case2 / plcorr;
  by outcome ft;
run;
ods listing;

*-- And with restricted follow-up to 8 yrs;
ods output measures=mycorr2(where=(statistic="Tetrachoric Correlation"
                                   or statistic="Polychoric Correlation")
                             keep = statistic table value ft outcome ase);
ods listing close;
proc freq data=tmp2;
  where mark=1;
  table case1 * case2 / plcorr;
  by outcome ft;
run;
ods listing;

data mycorr3;
  length analysis $30;
  set mycorr1
      mycorr2(in=mycorr2)
  ;
  if mycorr2 then analysis='Restricted follow-up';
  else analysis='Full dataset';

  valtxt=put(value,4.2)||' (95% CI: '||put(value-1.96*ase,4.2)||'-'||
         put(value+1.96*ase,4.2)||')';

run;
proc sort data=mycorr3;by outcome ft analysis;run;

title1 'Table 3. Tetrachoric correlations';
proc print data=mycorr3 noobs label;
  var analysis valtxt;
  by outcome ft; id outcome ft;
  format value 8.2;
ruN;
