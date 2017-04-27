*-----------------------;
* Describe the cohort   ;
* Do not use pyear since there are one for each exposing child;
*-----------------------;
proc sql;
* create table t0 as select distinct barn2, pyear from x4;
  ;
  create table t0 as select put(nt,nt.) as ft, count(*) as pairs from x4 group by nt;
  create table t1 as
  select distinct a.ft, a.barn2 as barn, year(a.child_bdat2) as byear length=4,
         (a.sex2='1') as sex length=3, a.hosp_dat2>.z as asd,
         (a.ad_hosp_dat2 > .z) as ad, (a.mor_psych='1') as mpsych length=3,
         (a.far_psych='1') as fpsych length=3, diag_age2 as asd_age, ad_diag_age2 as ad_age,
         b.pyear
  from fam6 as a
  left join x4 as b
  on a.barn2=b.barn2
  order by a.barn2
  ;
quit;


proc sort data=t1 out=t2 nodupkey;
  by ft barn sex2 asd ad far_psych mor_psych;
run;

proc summary data=t1 nway;
  var asd ad sex fpsych mpsych byear asd_age ad_age;
  class ft;
  output out=t2 sum = asd ad sex fpsych mpsych slask1 slask2 slask3
         median(byear asd_age ad_age)=median_byr median_asd median_ad
         p5(byear asd_age ad_age)  =p5_byr p5_asd p5_ad
         p95(byear asd_age ad_age) =p95_byr p95_asd p95_ad
  ;
run;

data t3;
  merge t2 t0;by ft;
  pairtxt=put(pairs,comma12.);
  antal  =put(_freq_,comma12.);
  boys   =put(100*(sex/_freq_),4.2)||'%';
  adtxt  =put(ad,comma6.)||' ('||put(100*(ad/_freq_),4.2)||'%)';
  asdtxt =put(ad,comma6.)||' ('||put(100*(asd/_freq_),4.2)||'%)';
  mpsytxt=put(mpsych,comma6.)||' ('||put(100*(mpsych/_freq_),4.2)||'%)';
  fpsytxt=put(fpsych,comma6.)||' ('||put(100*(fpsych/_freq_),4.2)||'%)';
  byrtxt =put(median_byr,4.)||' ('||put(p5_byr,4.)||'-'||put(p95_byr,4.)||')';
  asdtxt =put(median_asd,2.)||' ('||put(p5_asd,2.)||'-'||put(p95_asd,2.)||')';
  adtxt  =put(median_ad,2.)||' ('||put(p5_ad,2.)||'-'||put(p95_ad,2.)||')';
run;

proc transpose data=t3 out=t4;
  var antal boys adtxt asdtxt mpsytxt fpsytxt pairtxt byrtxt asdtxt adtxt;
  id ft;
ruN;

data _null_;
set t4;
if _n_=1 then put 'Table 1';
put _name_ ';' f ';' mh ';' ph;
run;
