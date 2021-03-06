proc copy in=sasperm out=work;select formats;run;

data t0;
  drop outcome cens;
  length event discordant 3;
  set sasperm.x3(where=(outcome='ASD')
                 keep=outcome barn1 barn2 ft famid monozyg1 monozyg2 multiple asd_exp cens entry exit);
  event=1-cens;
  discordant=(asd_exp ne event);
  pyear=exit-entry;

  if ft in ('F','MH','PH') and multiple='1' then delete;
run;

*-- Add on the cousins;
data r1;
  length event discordant 3 ft $2;
  retain ft 'C';
  drop outcome cens;
  set sasperm.x3_cousins(where=(outcome='ASD')
                         keep=outcome barn1 barn2 famid monozyg1 monozyg2 multiple asd_exp cens entry exit);
  event=1-cens;
  discordant=(asd_exp ne event);
  pyear=exit-entry;

  if  multiple='1' then delete;
run;

proc datasets lib=work mt=data nolist;delete t1;quit;
proc append base=t1 data=t0;run;
proc append base=t1 data=r1;run;


proc sort data=t1;by ft barn1 barn2 entry exit;run;


*-- Sum person year etc within-pairs;
proc summary data=t1 nway;
  var asd_exp event discordant pyear;
  by ft barn1 barn2;
  output out=t2 max(asd_exp event discordant)=asd_exp_pairs event_pairs discordant_pairs sum(pyear)=pyear_pairs;
run;

*-- Sum over pairs;
proc summary data=t2 nway;
  var asd_exp_pairs event_pairs discordant_pairs pyear_pairs;
  by ft;
  output out=t3 n=pairs sum(asd_exp_pairs event_pairs discordant_pairs pyear_pairs)=;
run;


*-- Sum person year for unique subjects, that is unique exposed siblings. Sum by BARN2 (not barn1);
proc sql;
  create table t4 as
  select ft, barn2, max(asd_exp) as asd_exp_sib, max(event) as event_sib
  from t1
  group by ft, barn2
  ;
  *-- Here: Number of exposing siblings and number of ASD cases;
  create table t5 as
  select ft, sum(asd_exp_sib) as asd_exp_sib, sum(event_sib) as event_sib
  from t4
  group by ft
  ;
quit;



*-- Now we have unique children in the S1 dataset;
proc sort data=t1(keep=ft barn2) out=s1(rename=(barn2=subject)) nodupkey;by ft barn2;run;

proc sql;
  create table s2 as
  select count(distinct subject) as tot_n from s1
  ;
  create table s3 as
  select ft, count(distinct subject) as n from s1
  group by ft
  order by ft
  ;
  create table t6 as
  select a.*, b.n, c.tot_n, d.asd_exp_sib, d.event_sib
  from t3 as a
  left join s3 as b
    on a.ft=b.ft
  cross join s2 as c
  left join t5 as d
    on a.ft=d.ft
  ;
quit;

proc print data=t6 noobs label;
  label pairs='Unique Sibling Pairs' tot_n='Total number in entire study'
        n    ='Number of sibs in subgroups (one sib can be in more than one subgroup'
        event_pairs='Number of ASD cases, counting pairs ' asd_exp_pairs ='ASD in exposing sibs (probands), counting pairs'
        event_sib='Number of ASD cases, counting unique sibs' asd_exp_sib ='ASD in exposing sibs (probands), counting unique sibs'
        discordant_pairs ='Number of discordant pairs' pyear_pairs ='Person Years'
  ;
  var tot_n n asd_exp_sib event_sib pairs asd_exp_pairs event_pairs discordant_pairs pyear_pairs;
  format tot_n n asd_exp_sib event_sib pairs asd_exp_pairs  event_pairs discordant_pairs  pyear_pairs  comma12.;
  by ft;id ft;
run;

*-------------------------------------------;
* Below, do the confounder distributions    ;
*-------------------------------------------;

proc sql;
  *-- Unique siblings (outcome) among non-cousins;
  create table v1 as select distinct ft, subject as barn2 from s1;

  *-- Get the covariates;
  create table v3 as
  select distinct ft, barn2, sex2, mor_psych, far_psych, year(child_bdat2) as byr
  from sasperm.x3
  ;
  create table v4 as
  select distinct barn2, sex2, mor_psych, far_psych, year(child_bdat2) as byr, 'C' as ft length=2
  from sasperm.x3_cousins
  ;

  create table check as select ft, barn2, count(*) as n from v3 group by ft, barn2 having n>1;
  create table check as select ft, barn2, count(*) as n from v4 group by ft, barn2 having n>1;

  *-- Age at diagnosis;
  create table v5 as
  select ft, barn2, min(exit) as diag_age
  from sasperm.x3
  where cens=0
  group by ft, barn2
  ;
  create table v6 as
  select 'C ' as ft length=2, barn2, min(exit) as diag_age
  from sasperm.x3_cousins
  where cens=0
  group by barn2
  ;

  drop table v8, v9;
  ;
quit;

*-- Combine confounders for the siblings and cousins;
proc append base=v8 data=v3;run;
proc append base=v8 data=v4;run;

*-- Combine age at diagnosis for the siblings and cousins;
proc append base=v9 data=v5;run;
proc append base=v9 data=v6;run;


proc sql;
  create table check as select ft, barn2, count(*) as n from v1 group by ft, barn2 having n>1;
  create table check as select ft, barn2, count(*) as n from v8 group by ft, barn2 having n>1;

  *-- Add in the covariates;
  create table v10 as
  select a.ft, a.barn2, 2-input(b.sex2,8.) as sex length=3, input(b.mor_psych,8.) as mor_psych length=3,
         input(b.far_psych,8.) as far_psych length=3, b.byr, c.diag_age
  from v1 as a
  left join v8 as b
    on a.ft=b.ft and a.barn2=b.barn2
  left join v9 as c
    on a.ft=c.ft and a.barn2=c.barn2
  ;

  create table v11 as
  select ft, count(*) as n, 100*mean(sex) as pct_boys label='Pct Boys',
         sum(mor_psych) as n_mpsych label='N Mat. PsyHIST', 100*mean(mor_psych) as pct_mpsych label='Pct Mat. PsyHIST',
         sum(far_psych) as n_fpsych label='N Pat. PsyHIST', 100*mean(far_psych) as pct_ppsych label='Pct Pat. PsyHIST'
  from v10
  group by ft
  ;
quit;

proc summary data=v10 nway;
  var byr diag_age;
  class ft;
  output out=v12 median=byr_med diag_age_med p5=byr_p5 diag_age_p5 p95=byr_p95 diag_age_p95;
run;

/** Check
data s1_not_v10
     v10_not_s1;
merge s1(in=s1 keep=ft subject rename=(subject=barn2))
      v10(in=v10 keep=ft barn2);
by ft barn2;
if s1 and not v10 then output s1_not_v10;
else if v10 and not s1 then output v10_not_s1;
else delete;
ruN;
****/

*-- Do the person years;
proc sql;
  create table v13 as
  select a.ft, barn2, a.pyear
  from t1 a
  join s1 as b
  on a.ft=b.ft and a.barn2=b.subject;
quit;

proc summary data=v13 nway;
  var pyear;
  class ft;
  output out=v14 median=pyr_med p5=pyr_p5 p95=pyr_p95;
run;
