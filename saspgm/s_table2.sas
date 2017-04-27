*-----------------------;
* Describe the cohort   ;
* Do not use pyear since there are one for each exposing child;
*-----------------------;

*-- ASD data;
data tmp1;
  drop outcome;
  set x3(keep=outcome ft barn1 barn2 child_bdat2 sex2 hosp_dat2
              mor_psych far_psych pyear bc oldma oldpa where=(outcome='ASD'))
      x3_cousins(keep=outcome barn1 barn2 child_bdat2 sex2 hosp_dat2
                     mor_psych far_psych pyear bc oldma oldpa in=x3_cousins where=(outcome='ASD'));
  if x3_cousins then ft='C';
run;

*-- AD data to join in AD cases, age of AD with the ASD data;
data tmp2;
  drop outcome;
  set x3(keep=outcome ft barn1 barn2 ad_hosp_dat2
              where=(outcome='AD' and ad_hosp_dat2>.z))
      x3_cousins(keep=outcome barn1 barn2 ad_hosp_dat2
                 where=(outcome='AD' and ad_hosp_dat2>.z) in=x3_cousins);
  if x3_cousins then ft='C';
run;

proc sql;
  create table tmp3 as
  select a.*, b.ad_hosp_dat2
  from tmp1 as a
  left join tmp2 as b
  on a.barn1=b.barn1 and a.barn2=b.barn2
  ;
quit;

proc sql;
  create table pairs as select distinct ft, barn1, barn2 from tmp1;
  create table t0 as select ft, count(*) as pairs from tmp1 group by pairs;

  create table tmp4 as
  select distinct a.ft, a.barn2 as barn, bc, year(a.child_bdat2) as byear length=4,
         (a.sex2='1') as sex length=3, a.hosp_dat2>.z as asd,
         (a.ad_hosp_dat2 > .z) as ad, (a.mor_psych='1') as mpsych length=3,
         (a.far_psych='1') as fpsych length=3,
         (hosp_dat2-child_bdat2)/365.25 as asd_age,
         (ad_hosp_dat2-child_bdat2)/365.25 as ad_age,
         a.pyear
  from tmp3 a
  order by a.barn2
  ;
quit;


proc summary data=tmp4 nway;
  var asd ad sex fpsych mpsych byear asd_age ad_age;
  class ft;
  output out=tmp5 sum = asd ad sex fpsych mpsych slask1 slask2 slask3
         median(byear asd_age ad_age)=median_byr median_asd median_ad
         p5(byear asd_age ad_age)  =p5_byr p5_asd p5_ad
         p95(byear asd_age ad_age) =p95_byr p95_asd p95_ad
  ;
run;

data tmp6;
  merge tmp5 t0;by ft;
  pairtxt=put(pairs,comma12.);
  antal  =put(_freq_,comma12.);
  boys   =put(100*(sex/_freq_),4.2)||'%';
  asdpct =put(asd,comma6.)||' ('||put(100*(asd/_freq_),4.2)||'%)';
  adpct  =put(ad,comma6.)||' ('||put(100*(ad/_freq_),4.2)||'%)';
  mpsytxt=put(mpsych,comma6.)||' ('||put(100*(mpsych/_freq_),4.2)||'%)';
  fpsytxt=put(fpsych,comma6.)||' ('||put(100*(fpsych/_freq_),4.2)||'%)';
  byrtxt =put(median_byr,4.)||' ('||put(p5_byr,4.)||'-'||put(p95_byr,4.)||')';
  asdage =put(median_asd,2.)||' ('||put(p5_asd,2.)||'-'||put(p95_asd,2.)||')';
  adage  =put(median_ad,2.)||' ('||put(p5_ad,2.)||'-'||put(p95_ad,2.)||')';
run;

proc transpose data=tmp6 out=tmp7;
  var antal boys adpct asdpct mpsytxt fpsytxt pairtxt byrtxt asdage adage;
  id ft;
ruN;

data _null_;
  set tmp7;
  if _n_=1 then put 'Table 1';
  put _name_ ';' f ';' mh ';' ph ';' c;
run;


*---------------------------------------------------------;
* Table 2                                                 ;
*---------------------------------------------------------;
proc sql;
  create table b1 as
  select distinct bc, barn, asd, ad
  from tmp4
  where ft ne 'C'
  ;
  create table b2 as
  select bc, sum(asd) as asd, sum(ad) as ad, count(*) as n
  from b1
  group by bc
  ;
  create table b3 as
  select *, 100*asd/n format=5.2 as asd_pct, 100*ad/n format=5.2 as ad_pct
  from b2;
quit;

data _null_;
  set b3;
  if _n_=1 then put 'Table 2. Cohort, Births, ASD cases, ASD percent, AD cases, AD percent';

  put bc ';' n ';' asd ';' asd_pct ';' ad ';' ad_pct;
run;




*- Count number of children, and sib and cousin pairs;
proc sql;
  select count(distinct barn2) as antal_sib_barn from tmp1 where ft ne 'C';
  select count(distinct barn2) as antal_cousin_barn from tmp1 where ft eq 'C';

  create table a1 as select distinct barn1, barn2 from tmp1 where ft ne 'C';
  select count(*) as antal_sib_pairs from a1;

  create table a2 as select distinct barn1, barn2 from tmp1 where ft eq 'C';
  select count(*) as antal_cousin_pairs from a2;
quit;


*-- Check the cousins;
proc sql;
  create table a3 as select distinct barn1, barn2, entry, exit, child_bdat1 as yyymm1, child_bdat2, cens
 from x3_cousins where outcome='ASD';
quit;
