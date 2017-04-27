options nofmterr;
proc copy in=tmpdsn out=work;
  select asd_diag mfr1;
run;

proc format;
  value $ sexfmt  '0'='Male' '1'='Female';
  value $ sexfmts '0'='M'    '1'='F';
  value $ cyesno  '1'='Yes'  '0'='No';
  value   yesno  1='Yes'  0='No';
run;

*------------------------------------------------------------------------;
* Data selection                                                         ;
* + All birth after 1982-01-01                                           ;
* - Exclude dead born                                                    ;
* - Exclude multiple birth (bordf2)                                      ;
*------------------------------------------------------------------------;
/**
proc sql;
  connect to oracle (user=svesan pw="{SAS002}1EA5152055A835B6561F91FA343842795497A910" path=UNIVERSE);
  execute (alter session set current_schema=mgrcrime2 ) by oracle;

  create table mfr1 as
  select lopnrbarn as barn length=6, lopnrmor as mor length=6, lopnrfar as far length=6, bordf2,
         paritet length=3 label='Parity',
         case when dodfod='' then '0' else '1' end as sex length=1 format=$sexfmt. label='Sex',
         input(x_bfoddat, yymmdd8.) as child_bdat length=4 format=yymmdd10. label='Child birth date',
         input(x_mfoddat, yymmdd8.) as mo_bdat length=4 format=yymmdd10. label='Mother birth date'

  from connection to oracle(

     select a.lopnrbarn, a.lopnrmor, b.lopnrfar, a.dodfod, a.x_bfoddat, a.bordf2,
            a.x_bfoddat, a.x_mfoddat, a.paritet
     from v_mfr_base a
     left join v_parent b
     on a.lopnrmor=b.lopnrmor and a.lopnrbarn=b.lopnr
     where a.lopnrmor is not null and a.lopnrbarn is not null and a.x_bfoddat >= '19820101'
  );
  disconnect from oracle;
run;quit;
***/
*----------------------------------------------------;
* Exclusions (with nice log)                         ;
* - Multiple birth                                   ;
* - Families with only one child (mo or fa half ??)  ;
*----------------------------------------------------;
data mfr2(where=(bordf2='1' and mor>.z and far>.z and child_bdat <= '31DEC2006'd));
  drop _c_ _d_ _e_ _f_ _cpct_ _dpct_ _epct_ ;
  retain _c_ _d_ _e_ _f_ 0;
  set mfr1 end=eof;

  *-- Count multiple birth;
  if bordf2 = '2' then _c_=_c_+1;

  *-- Count mother id missing;
  if mor le .z then _d_=_d_+1;

  *-- Count father id missing;
  if far le .z then _e_=_e_+1;

  *-- Born after 31-Dec-2006 (being < 3 years at end of follow-up);
  if child_bdat>'31DEC2006'd then _f_=_f_+1;

  if eof then do;
    _cpct_=round(100*_c_/_n_, 0.1);
    _dpct_=round(100*_d_/_n_, 0.1);
    _epct_=round(100*_e_/_n_, 0.1);
    _fpct_=round(100*_f_/_n_, 0.1);
    put 'Warning: ' _c_  'multiple birth excluded. ' _cpct_ 'percent';
    put 'Warning: ' _d_  'missing mother ID. ' _dpct_ 'percent';
    put 'Warning: ' _e_  'missing father ID. ' _epct_ 'percent';
    put 'Warning: ' _f_  'born after 31-Dec-2006 ' _fpct_ 'percent';
  end;
run;

*-- Add paternal parity variable;
proc sort data=mfr2; by far child_bdat;run;
data mfr3;
  attrib pparity length=3 label='Parity, paternal';
  retain pparity 0;
  set mfr2;by far child_bdat;
  if first.far then pparity=1;
  else pparity=pparity+1;
run;

*-- Add maternal parity variable;
proc sort data=mfr3; by mor child_bdat;run;
data mfr4 t1;
  attrib mparity length=3 label='Parity, maternal';
  retain mparity 0;
  set mfr3;by mor child_bdat;
  if first.mor then mparity=1;
  else mparity=mparity+1;
run;

data x1;
  set t1;*(where=(mor in (21155,71)));
run;

proc sql;
  create table full as
  select 'F' as ft length=2 label='Family type',
         a.mor as mor1, a.far as far1, a.barn as barn1, b.barn as barn2
  from x1 as a
  join x1 as b
  on a.mor=b.mor and a.far=b.far and a.barn ne b.barn
  ;
/*
  create table half_mother as
  select 'MH' as ft length=2 label='Family type',
         a.mor as mor1, a.far as far1, b.far as far2, a.barn as barn1, b.barn as barn2
  from t1 as a
  join t1 as b
  on a.mor=b.mor and a.far ne b.far and a.barn ne b.barn and b.mparity>a.mparity
  ;

  create table half_father as
  select 'PH' as ft length=2 label='Family type',
         a.far as far1, a.mor as mor1, b.mor as mor2, a.barn as barn1, b.barn as barn2
  from t1 as a
  join t1 as b
  on a.far=b.far and a.mor ne b.mor and a.barn ne b.barn and b.pparity>a.pparity
  ;
quit;

proc append base=full data=half_mother force;run;
proc append base=full data=half_father force;run;
*/
*-- Join in children birth date and date of ASD diagnosis and calculate age for both;
proc sort data=mfr4 nodupkey  out=tmp1;by barn;run;

proc sort data=tmpdsn.asd_diag out=asd_diag nodupkey;by lopnr hosp_dat;run;
proc sort data=asd_diag nodupkey;by lopnr;run;

proc sql;
  create table fam1 as
  select a.*, b.child_bdat as child_bdat1, c.hosp_dat as hosp_dat1,
              round((c.hosp_dat - b.child_bdat)/365,0.1) as diag_age1 length=6,
              b.sex as sex1 label='Sex child 1'
  from full as a
  left join tmp1 as b
    on a.barn1=b.barn
  left join asd_diag as c
    on a.barn1=c.lopnr
  ;
quit;

proc sql;
  create table fam2 as
  select a.*, b.child_bdat as child_bdat2, c.hosp_dat as hosp_dat2,
              round((c.hosp_dat - b.child_bdat)/365,0.1) as diag_age2 length=6,
              b.sex as sex2 label='Sex child 2'
  from fam1 as a
  left join tmp1 as b
    on a.barn2=b.barn
  left join asd_diag as c
    on a.barn2=c.lopnr
  order by ft
  ;
quit;

*-- Add case status and birth cohort;
data fam3;
  attrib case1 length=3 label='ASD case child 1'
         case2 length=3 label='ASD case child 2'
         bc    length=3 label='Birth cohort'
  ;
  set fam2;

  case1=(hosp_dat1>.z);
  case2=(hosp_dat2>.z);

  if child_bdat2 le .z then bc=.u;
  else if child_bdat2 LE '31DEC1986'd then bc=1;
  else if child_bdat2 LE '31DEC1991'd then bc=2;
  else if child_bdat2 LE '31DEC1996'd then bc=3;
  else if child_bdat2 LE '31DEC2001'd then bc=4;
  else if child_bdat2 LE '31DEC2006'd then bc=5;

run;


*-------------------------------------------------------;
* Update                                                ;
* 1. Create dataset where no time varying               ;
* 2. Join in the time varying info and split time       ;
*                                                       ;
*-------------------------------------------------------;
proc sort data=fam3 force;by mor1 child_bdat1 child_bdat2 ;run;

*-- Create survival dataset without time varying covariates;
data rep1;
  drop _c_;
  format cens_dat yymmdd8.;
  retain _c_ 0 cens_dat '31dec2009'd; *- More general. Create this varaible external as study end, death or emig and join in;
  set fam3(keep=ft mor1 barn1 barn2 child_bdat1 child_bdat2 hosp_dat1 hosp_dat2 bc sex1 sex2) end=eof;
  cens=1;

  entry=max(0, (child_bdat1-child_bdat2)/365.25) ;

  if hosp_dat2>.z then do;
    cens=0;
    exit =(hosp_dat2-child_bdat2)/365.25;
  end;
  else exit=(cens_dat-child_bdat2)/365.25;

  *-- Check if child_bdat1>hosp_dat2 (exposing sib born AFTER own disease). Then delete;
  if hosp_dat2>.z and child_bdat1 > hosp_dat2 then do;
    _c_=_c_+1;
    if eof then put 'Warning: ' _c_ 'subjects removed since event happened before birth of exposing relative';
    delete;
  end;

  if eof then put 'Warning: ' _c_ 'subjects removed since event happened before birth of exposing relative';
run;

*-- Use hosp_dat1 to create varying covariates;
*-- (more general: join in date and value from external source);
data rep2;
  drop _x1 _x2 _x3;
  set rep1;

  if hosp_dat1 le .z then do;
    asd_exp=0; output;
  end;
  else if hosp_dat1<child_bdat2 then do;
    asd_exp=1; output;
  end;
  else do;
    *-- Time scale is age so rescale;
    _x1 =(hosp_dat1-child_bdat2)/365.25;
    if _x1 > entry and _x1 < exit then do;
      _x2    = exit; *-- Keep exit to next interval;
      exit   = _x1 ;
      asd_exp=0;
      *-- If time split is before failure then cens must be reset;
      _x3    = cens;
      cens   = 1;
      output;

      entry   = exit;
      exit    = _x2;
      asd_exp = 1;
      cens    = _x3;
      output;

    end;
  end;
run;

*-- Logic checking and add derived variable pyear;
data rep3;
  set rep2;
  pyear=round(exit-entry,0.1);

  *-- Check data;
  if entry=exit then abort;
  if entry>exit then abort;
run;


proc print data=rep2(obs=100) noobs uniform;
  by mor1;
  var barn1 barn2 child_bdat1 child_bdat2 hosp_dat1 hosp_dat2 entry exit asd_exp cens;
run;

title1 'Full cohort Full-siblings. Robust standard errors. Cluster is mother id';
ods exclude CensoredSummary;
ods output CensoredSummary=cs1 ContrastEstimate=est1;
ods trace on;
proc phreg data=rep3 covsandwich(aggregate);
  class asd_exp bc / param=glm;
  model (entry,exit)*cens(1) = bc asd_exp;
  contrast 'RR ASD | ASD sib' asd_exp2 1 -1 / alpha=0.05 estimate=exp test(all);
*  strata bc;
  id mor1;
run;


%tor(data=rep3,dname=recur.f, rfile=recur_f.R,
     class=ft asd_exp bc sex1 sex2,
     var=mor1 barn1 barn2 entry exit cens pyear);

proc upload data=rep3;run;
