* Note: Must use dataset without timevarying variable since this include >1 record per subject;

* Collapse the time-varying dataset;
proc sql;
  create table tmp1 as
  select outcome, ft, barn1, barn2, asd_exp, child_bdat1, child_bdat2,
         entry as entry0, exit, hosp_dat1, hosp_dat2, cens
  from x3
  where child_bdat2>child_bdat1 /*and outcome='ASD' */
  order by outcome, ft, barn1, barn2, entry
  ;
quit;


data tmp2;
  length case1 case2 discord 3;
  drop entry0;
  retain entry case1 case2;
  set tmp1;by outcome ft barn1 barn2 entry0;
  if first.barn2 then do;
    entry=entry0;
    case1=0; case2=0;
  end;

  if asd_exp=1 then case1=1;
  if cens=0 then case2=1;

  if case1 ne case2 then discord=1;else discord=0;

  if last.barn2 then output;
run;
proc sql;
  select ft, count(*) as N, sum(discord) as discordant_cases
  from tmp2
  group by ft;
quit;

proc freq data=tmp2;
  table case1*case2 / nopercent nocol;
  by outcome ft;
run;

*-- Truncate cases>8 yrs and mark subjects followed shorter than 8 yrs;
data tmp3;
  length mark 3;
  set tmp2;

  *  follow-up time for child 1;
  if hosp_dat1>.z then len=round((hosp_dat1-child_bdat1)/365.25, 0.1);
  if len>10 and asd_exp=1 then case1=0;

  *-- Mark children with at least 8 yrs follow-up but truncate events after 8 yrs;
  if child_bdat2 le '01jan2002'd then do;
    mark=1;
    * should exclude events > 8 yrs on both sibs if cens=0 and pyear>0  ;
    if case2=1 and exit-entry>10 then case2=0;
  end;
  else mark=0;

run;

proc freq data=tmp3;
  where mark=1 ;
  table case1*case2 / nopercent nocol;
  by outcome ft;
run;

*-- Tetrachoris correlations;
title1 'Full dataset';
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
title1 'Dataset restricted to 8 yrs follow-up';
ods output measures=mycorr2(where=(statistic="Tetrachoric Correlation"
                                   or statistic="Polychoric Correlation")
                             keep = statistic table value ft outcome ase);
ods listing close;
proc freq data=tmp3;
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
