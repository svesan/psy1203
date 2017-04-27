*-----------------------------------------------------------------------------;
* Study.......: PSY1203                                                       ;
* Name........: s_table1c.sas                                                 ;
* Date........: 2013-06-10                                                    ;
* Author......: svesan                                                        ;
* Purpose.....: Create data for manuscript table 1                            ;
* Note........: 130611 added cousins to table1b                               ;
*-----------------------------------------------------------------------------;
* Data used...: x3 x3_cousins                                                 ;
* Data created:                                                               ;
*-----------------------------------------------------------------------------;
* OP..........: Linux/ SAS ver 9.03.01M2P081512                               ;
*-----------------------------------------------------------------------------;

*-- External programs --------------------------------------------------------;

*-- SAS macros ---------------------------------------------------------------;

*-- SAS formats --------------------------------------------------------------;

*-- Main program -------------------------------------------------------------;

*----------------------------------------------------------------;
* Describe the cohort                                            ;
* Do not use pyear since there are one for each exposing child   ;
*----------------------------------------------------------------;
data temp1;
  set x3(keep=outcome ft barn2 child_bdat2 entry sex2 hosp_dat2 ad_hosp_dat2
              mor_psych far_psych cens exit pyear)
      x3_cousins(keep=outcome barn2 child_bdat2 entry sex2 hosp_dat2 ad_hosp_dat2
                      mor_psych far_psych cens exit pyear
                 in=x3_cousins)
  ;
  if x3_cousins then ft='C ';
run;

proc sql;
  create table t0 as select outcome, ft, count(*) as pairs from temp1 group by outcome,ft;

  create table t1 as
  select outcome, ft, a.barn2 as barn, year(a.child_bdat2) as byear length=4,  entry ,
         (a.sex2='1') as sex length=3, a.hosp_dat2>.z as asd,
         (a.ad_hosp_dat2 > .z) as ad, (a.mor_psych='1') as mpsych length=3,
         (a.far_psych='1') as fpsych length=3,
         a.pyear, 1-cens as case,
         case  when hosp_dat2>0 then exit else .u end as diag_age

  from temp1 as a
  order by outcome, ft, barn, entry
  ;
quit;


proc sort data=t1 out=t2 nodupkey;
  by outcome ft barn sex case fpsych mpsych;
run;

proc summary data=t1 nway;
  var case sex fpsych mpsych byear diag_age pyear;
  class outcome ft;
  output out=t2 sum =case sex fpsych mpsych slask1 slask2
         median(byear diag_age pyear)=median_byr median_dage median_pyr
         p5(byear diag_age pyear)  =p5_byr p5_dage p5_pyr
         p95(byear diag_age pyear) =p95_byr p95_dage p95_pyr
  ;
run;

*-- Number of children (not pair);
proc sql;
  create table t3 as
  select outcome, ft, count(*) as n1, count(distinct barn2) as antal_barn,
         count(*)/count(distinct barn2) as pairs_per_child
  from temp1
  group by outcome, ft
  ;
quit;

data t4;
  merge t2 t0 t3(keep=outcome ft antal_barn);by outcome ft;
  if pairs ne _freq_ then abort;

  pairtxt=put(pairs,comma12.);
  antal  =put(antal_barn,comma12.);
  boys   =put(100*(sex/_freq_),4.2)||'%';
  casetxt=put(case,comma6.)||' ('||put(100*(case/_freq_),4.2)||'%)';
  mpsytxt=put(mpsych,comma6.)||' ('||put(100*(mpsych/_freq_),4.2)||'%)';
  fpsytxt=put(fpsych,comma6.)||' ('||put(100*(fpsych/_freq_),4.2)||'%)';
  byrtxt =put(median_byr,4.)||' ('||put(p5_byr,4.)||'-'||put(p95_byr,4.)||')';
  agetxt =put(median_dage,2.)||' ('||put(p5_dage,2.)||'-'||put(p95_dage,2.)||')';
  pyrtxt =put(median_pyr,2.)||' ('||put(p5_pyr,2.)||'-'||put(p95_pyr,2.)||')';
run;

proc transpose data=t4 out=t5;
  where outcome='AD';
  var antal boys casetxt mpsytxt fpsytxt pairtxt byrtxt agetxt pyrtxt;
  id ft;
ruN;

proc transpose data=t4 out=t6;
  where outcome='ASD';
  var antal boys casetxt mpsytxt fpsytxt pairtxt byrtxt agetxt pyrtxt;
  id ft;
ruN;

data _null_;
  set t5;
  if _n_=1 then do;
    put 'Table 1. AD. Statistics for pairs not children';
    put 'variable;F;MH;PH;C';
  end;
  put _name_ ';' f ';' mh ';' ph ';' c;
run;


data _null_;
  set t6;
  if _n_=1 then do;
    put 'Table 1. ASD. Statistics for pairs not children';
    put 'variable;F;MH;PH;C';
  end;
  put _name_ ';' f ';' mh ';' ph ';' c;
run;


*-- Cleanup ------------------------------------------------------------------;
title1;footnote;
proc datasets lib=work mt=data nolist;
  delete t0 t1-t6 temp1;
quit;

*-- End of File --------------------------------------------------------------;
