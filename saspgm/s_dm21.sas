*-----------------------------------------------------------------------------;
* Study.......: PSY1203                                                       ;
* Name........: s_dm21.sas                                                    ;
* Date........: 2013-05-23                                                    ;
* Author......: svesan                                                        ;
* Purpose.....: Create the analysis datasets                                  ;
* Note........: 130523 added the ft MZ and DZ variables                       ;
* Note........: 130603 changed to using the s_dmcousin3 program instead of    ;
* ............: s_dmcousin2.                                                  ;
*-----------------------------------------------------------------------------;
* Data used...:                                                               ;
* Data created:                                                               ;
*-----------------------------------------------------------------------------;
* OP..........: Linux/ SAS ver 9.03.01M2P081512                               ;
*-----------------------------------------------------------------------------;

*-- External programs --------------------------------------------------------;

*-- SAS macros ---------------------------------------------------------------;

*-- SAS formats --------------------------------------------------------------;

*-- Main program -------------------------------------------------------------;
options stimer;

libname sw slibref=work server=skjold;

%inc saspgm(tor)/nosource;

options nofmterr;
proc copy in=tmpdsn out=work;
  select asd_diag mfr1 twins father;
run;
*data mfr1;
*  set tmpdsn.mfr1(rename=(lopnrbarn=barn lopnrfar=far lopnrmor=mor));
*run;

proc format;
  value $ sexfmt  '1'='Male'  '2'='Female';
  value $ sexfmts '1'='M'     '2'='F';
  value   sex      1 ='Male'   2 ='Female';
  value $ cyesno  '1'='Yes'   '0'='No';
  value   yesno    1 ='Yes'    0 ='No';
  value   nt       1 ='F'      2 ='MH' 3='PH' 4='C';
  value   bcfmt    1='82-86' 2='87-91' 3='92-96' 4='97-01' 5='02-06';
run;

*------------------------------------------------------------------------;
* twins. Move to separate file later;
*------------------------------------------------------------------------;
/*
data tmpdsn.twins;
  keep barn monozyg;
  attrib monozyg length=$1 format=$cyesno. label='Monozygotic (Y/N)';
  set crime2.v_str_mgr(keep=lopnr bestzyg birthdate rename=(lopnr=barn) where=(birthdate>'01jan1982'd));

  if bestzyg = 1 then monozyg='1';
  else if bestzyg = 3 then delete;
  else if bestzyg in (2,4) then monozyg='0';
  else abort;
run;
proc sql;
  create table v_individual as
  select a.far as lopnr, b.fodelsedatum
  from mfr1 as a
  left join crime2.v_individual as b
  on a.far=b.lopnr
  where a.far is not null
  ;

proc sql;
  create table tmpdsn.father as
  select a.far, a.barn,
         ((a.child_bdat-input(trim(b.fodelsedatum)||'15',yymmdd8.))/365.25) > 40 as oldpa length=3,
         ceil(((a.child_bdat-input(trim(b.fodelsedatum)||'15',yymmdd8.))/365.25)) as page length=4
  from mfr1 as a
  left join crime2.v_individual as b
  on a.far=b.lopnr
  where a.far is not null
  ;
quit;

*/


*------------------------------------------------------------------------;
* Data selection                                                         ;
* + All birth after 1982-01-01                                           ;
* - Exclude dead born                                                    ;
* - Exclude multiple birth (bordf2)                                      ;
*                                                                        ;
* deadborn 1: Dead bef birth, 2: Not stillborn or missing, 3: Dead during;
* kon_barn 1: boy, 2: girl, 3:unknown                                    ;
*------------------------------------------------------------------------;
/**
proc sql;
  connect to oracle (user=svesan pw="{SAS002}1EA5152055A835B6561F91FA343842795497A910" path=UNIVERSE);
  execute (alter session set current_schema=mgrcrime2 ) by oracle;

  create table mfr1 as
  select lopnrbarn as barn length=6, lopnrmor as mor length=6, lopnrfar as far length=6, bordf2,
         paritet length=3 label='Parity',
         case when dodfod in ('1','2') then '1' else '0' end as dead_born length=1 format=$cyesno. label='Dead born',
         case kon_barn when '1' then '1' when '2' then '2' else '' end as sex length=1 format=$sexfmt. label='Sex',
         input(x_bfoddat, yymmdd8.) as child_bdat length=4 format=yymmdd10. label='Child birth date',
         input(x_mfoddat, yymmdd8.) as mo_bdat length=4 format=yymmdd10. label='Mother birth date'

  from connection to oracle(

     select a.lopnrbarn, a.lopnrmor, b.lopnrfar, a.dodfod, a.x_bfoddat, a.bordf2,
            a.kon_barn, a.x_bfoddat, a.x_mfoddat, a.paritet
     from v_mfr_base a
     left join v_parent b
       on a.lopnrmor=b.lopnrmor and a.lopnrbarn=b.lopnr
       where a.lopnrmor is not null and a.lopnrbarn is not null and a.x_bfoddat >= '19820101'
     left join v_str_mgr as c
       on a.lopnrbarn=.lopnrmor and a.lopnrbarn=b.lopnr
  );
  disconnect from oracle;
run;quit;

data tmpdsn.emig(label='Emigration since 1982');
  attrib emig_dat length=4 format=yymmdd6. label='Date of Emigration';
  drop posttyp mdat;
  set crime2.v_migration(keep=lopnr posttyp mdat where=(posttyp and mdat>='19820101'));
  emig_dat = input(mdat, yymmdd8.);
run;
data tmpdsn.death(label='Death since 1982');
  attrib death_dat length=4 format=yymmdd6. label='Date of Death';
  drop dodsdatum;
  set crime2.v_death_date(keep=lopnr dodsdatum where=(dodsdatum>='19820101'));
  death_dat = input(dodsdatum, yymmdd8.);
run;
data twins;
  keep barn monozyg;
  attrib monozyg length=$1 format=$cyesno. label='Monozygotic (Y/N)';
  set crime2.v_str_mgr(keep=lopnr bestzyg birthdate rename=(lopnr=barn) where=(birthdate>'01jan1982'd));

  if bestzyg = 1 then monozyg='1';
  else if bestzyg = 3 then delete;
  else if bestzyg in (2,4) then monozyg='0';
  else abort;
run;

***/
*----------------------------------------------------;
* Remove duplicates on children IDs in MFR           ;
*----------------------------------------------------;
proc sql;
  create table dups as
  select barn, count(*) as antal
  from mfr1
  group by barn
  having antal>1
  order by barn
  ;

  create table mfr1_nodup as
  select a.*
  from mfr1 as a
  left join dups as b
  on a.barn=b.barn
  having b.antal<1
  ;
quit;


*----------------------------------------------------;
* Exclusions (with nice log)                         ;
* - Multiple birth                                   ;
* - Families with only one child (mo or fa half ??)  ;
*----------------------------------------------------;
proc sort data=tmpdsn.death out=deem1;by lopnr;run;
proc sort data=tmpdsn.emig  out=deem2;by lopnr;run;
data deem3;
  drop death_dat emig_dat;
  rename lopnr=barn;
  attrib deem_dat length=4 format=yymmdd10. label='Date of emigration or death';
  merge deem1(in=deem1) deem2(in=deem2);by lopnr;
  if deem1 and deem2 then deem_dat=min(death_dat, emig_dat);
  else if deem1 then deem_dat=death_dat;
  else if deem2 then deem_dat=emig_dat;
run;
proc sort data=deem3;by barn deem_dat;run;
proc sort data=deem3 out=deem nodupkey;by barn;run;

data mfr2(where=(mark=0));
  length mark 3;
  drop _c_ _d_ _e_ _f_ _g_ _h_ _cpct_ _dpct_ _epct_ _fpct_ _gpct_ _hpct_ totmark;
  retain _c_ _d_ _e_ _f_ _g_ _h_ totmark 0;

  merge mfr1_nodup(in=mfr) deem end=eof;by barn;

  if mfr then do;
    mark=0;

    *-- Count multiple birth;
    if bordf2 = '2' then do;_c_=_c_+1; mark=0; end;

    *-- Count mother id missing;
    if mor le .z then do;_d_=_d_+1;  mark=1; end;

    *-- Count father id missing;
    if far le .z then do;_e_=_e_+1;  mark=1; end;

    *-- Born after 31-Dec-2006 (being < 3 years at end of follow-up);
    if child_bdat>'31DEC2006'd then do;_f_=_f_+1; mark=1; end;

    *-- Dead born ;
    if dead_born='1' then do;_g_=_g_+1; mark=1; end;

    *-- Born after 31-Dec-2006 (being < 3 years at end of follow-up);
    if deem_dat>.z and dead_born ne '1' and deem_dat < child_bdat + 365 then do;_h_=_h_+1; mark=1; end;

    totmark=totmark+mark;

    if eof then do;
      _cpct_=round(100*_c_/_n_, 0.1);
      _dpct_=round(100*_d_/_n_, 0.1);
      _epct_=round(100*_e_/_n_, 0.1);
      _fpct_=round(100*_f_/_n_, 0.1);
      _gpct_=round(100*_g_/_n_, 0.1);
      _hpct_=round(100*_h_/_n_, 0.1);

      put 'Warning: ' _c_  'multiple birth. ' _cpct_ 'percent (not deleted)';
      put 'Warning: ' _d_  'missing mother ID. ' _dpct_ 'percent';
      put 'Warning: ' _e_  'missing father ID. ' _epct_ 'percent';
      put 'Warning: ' _f_  'born after 31-Dec-2006 ' _fpct_ 'percent';
      put 'Warning: ' _g_  'dead born ' _gpct_ 'percent';
      put 'Warning: ' _h_  'dead or emigrated before age 1 ' _hpct_ 'percent';
      put / 'Warning: ' totmark  'records deleted ';
    end;
  end;
run;


proc sql;
  create table full_sibs as
  select 'F' as ft length=2 label='Family type', .n as flopnr length=6,
         a.mor as mor1, a.far as far1, a.barn as barn1, b.barn as barn2
  from mfr2 as a
  join mfr2 as b
  on a.mor=b.mor and a.far=b.far and a.barn ne b.barn
  ;

  create table half_mother as
  select 'MH' as ft length=2 label='Family type',
         a.mor as mor1, a.far as far1, b.far as far2, a.barn as barn1, b.barn as barn2
  from mfr2 as a
  join mfr2 as b
  on a.mor=b.mor and a.far ne b.far and a.barn ne b.barn /* and b.mparity>a.mparity */
  ;

  create table half_father as
  select 'PH' as ft length=2 label='Family type',
         a.far as far1, a.mor as mor1, b.mor as mor2, a.barn as barn1, b.barn as barn2
  from mfr2 as a
  join mfr2 as b
  on a.far=b.far and a.mor ne b.mor and a.barn ne b.barn /*and b.pparity>a.pparity */
  ;
quit;

%inc saspgm(s_dmcousin3)/source;

*-- Remove cousins not in mfr2 dataset;
*-- Note: Family id is flopnr ;
proc sql;
  create table cousins2 as
  select a.*
  from full_cousins as a
  join (select distinct barn from mfr2) as b
  on a.barn1=b.barn
  ;
  create table cousins3 as
  select a.*
  from cousins2 as a
  join (select distinct barn from mfr2) as b
  on a.barn2=b.barn
  ;
quit;

proq sql;
  create table full as select * from full_sibs;
quit;

proc append base=full data=half_mother force;run;
proc append base=full data=half_father force;run;
proc append base=full data=cousins3 force;run;

*-- Join in children birth date and date of ASD diagnosis and calculate age for both;
proc sort data=mfr2 nodupkey  out=tmp1;by barn;run;

*-- Retain only the first ASD diagnosis ;
proc sort data=tmpdsn.asd_diag out=asd_diag nodupkey;by lopnr hosp_dat;run;
proc sort data=asd_diag nodupkey;by lopnr;run;


*-- Join in sex and and psych diag date for 1st sibling;

*-- First create dataset for AD diagnosis only (a subset of ASD dataset) ;
proc sort data=tmpdsn.asd_diag out=ad_diag0 nodupkey;by lopnr hosp_dat;run;
proc sql;
  create table ad_diag0 as
  select * from tmpdsn.asd_diag
  where (icd_nr= 9 and trim(left(diagnos)) in ('299','299B','299W','299X')) or
        (icd_nr=10 and trim(left(diagnos)) in ('F840'))
  order by lopnr, hosp_dat
  ;
quit;

*-- Only keep first diagnosis;
data ad_diag;
  set ad_diag0;by lopnr hosp_dat;
  if first.lopnr;
run;


proc sql;
  *-- ASD ;
  create table fam1 as
  select a.*, b.child_bdat as child_bdat1,
         c.hosp_dat as hosp_dat1 label='Date of ASD', d.hosp_dat as ad_hosp_dat1 label='Date of AD'
  from full as a
  left join tmp1 as b
    on a.barn1=b.barn
  left join asd_diag as c
    on a.barn1=c.lopnr
  left join ad_diag as d
    on a.barn1=d.lopnr
  ;
quit;

*-- Join in sex and and psych diag date for 2nd sibling;
proc sql;
  create table fam2 as
  select a.*, b.child_bdat as child_bdat2,
         c.hosp_dat as hosp_dat2 label='Date of ASD', d.hosp_dat as ad_hosp_dat2 label='Date of AD'
  from fam1 as a
  left join tmp1 as b
    on a.barn2=b.barn
  left join asd_diag as c
    on a.barn2=c.lopnr
  left join ad_diag as d
    on a.barn2=d.lopnr
  order by ft
  ;
quit;


*-- Do not consider cases before the age 1;
data fam3;
  drop diag_age1 diag_age2 ad_diag_age1 ad_diag_age2;

  length diag_age1 diag_age2 ad_diag_age1 ad_diag_age2 5
  ;
  drop   _c_ _d_ _e_ _f_ diag_age1 diag_age2 ad_diag_age1 ad_diag_age2;
  retain _c_ _d_ _e_ _f_ 0;
  set fam2 end=eof;

  *-- 2013-02-20. Do not consider diagnosis before age 1;
  if hosp_dat1>.z then diag_age1   =round((hosp_dat1 - child_bdat1)/365,0.1);
  else diag_age1=.n;
  if hosp_dat2>.z then diag_age2   =round((hosp_dat2 - child_bdat2)/365,0.1);
  else diag_age2=.n;
  if ad_hosp_dat1>.z then ad_diag_age1=round((ad_hosp_dat1 - child_bdat1)/365,0.1);
  else ad_diag_age1=.n;
  if ad_hosp_dat2>.z then ad_diag_age2=round((ad_hosp_dat2 - child_bdat2)/365,0.1);
  else ad_diag_age2=.n;

  if (diag_age1>.z and diag_age1<1) then do;
    _c_=_c_+1; diag_age1=.; hosp_dat1=.;
  end;
  if (diag_age2>.z and diag_age2<1) then do;
    _d_=_e_+1; diag_age2=.; hosp_dat2=.;
  end;
  if (ad_diag_age1>.z and ad_diag_age1<1) then do;
    _e_=_e_+1; ad_diag_age1=.; ad_hosp_dat1=.;
  end;
  if (ad_diag_age2>.z and ad_diag_age2<1) then do;
    _f_=_f_+1; ad_diag_age2=.; ad_hosp_dat2=.;
  end;

* case1=(hosp_dat1>.z);
* case2=(hosp_dat2>.z);


  if eof then do;
    put 'Warning: ' _c_  'ASD diagnoses before age 1 in child 1 nullified';
    put 'Warning: ' _d_  'ASD diagnoses before age 1 in child 1 nullified';
    put 'Warning: ' _e_  'ASD diagnoses before age 1 in child 1 nullified';
    put 'Warning: ' _f_  'ASD diagnoses before age 1 in child 1 nullified';
  end;
run;



*---------------------------------------------------------;
* Dataset for censoring for death and emigration          ;
*---------------------------------------------------------;
proc sql;
  create table fam4 as
  select a.*, b.death_dat as deem_dat1, c.death_dat as deem_dat2
  from fam3 as a
  left join tmpdsn.death as b
    on a.barn1=b.lopnr
  left join tmpdsn.death as c
    on a.barn2=c.lopnr
  ;
quit;

*-- Create survival dataset without time varying covariates;
data rep1;
  drop _c_ deem_dat1 deem_dat2 cens_dat1 cens_dat2;
  attrib cens_dat length=4 format=yymmdd8. cens_dat1 length=4 format=yymmdd8.
         cens_dat2 length=4 format=yymmdd8. cens length=3;
  retain _c_ 0 ;
  set fam4(keep=ft flopnr mor1 far1 barn1 barn2 child_bdat1 child_bdat2 hosp_dat1 hosp_dat2
                deem_dat1 deem_dat2 ) end=eof;

  *-- First, date of exit (end of follow-up, emmigration or death or death or emigration in child before ASD diagnosis);
  if hosp_dat1 le .z and deem_dat1 > .z then cens_dat1=min('31dec2009'd, deem_dat1);

  if deem_dat2 > .z then cens_dat2=min(deem_dat2, '31dec2009'd);
  else cens_dat2='31dec2009'd;

  *-- Now, censor date (before considering ASD event) is the first of these two;
  if cens_dat1 > .z then cens_dat=min(cens_dat1, cens_dat2);
  else cens_dat=cens_dat2;

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


  *-- If proband dead before birth of sibling AND proband do not have ASD. Then delete;
  if deem_dat1>.z and deem_dat1<child_bdat2 and hosp_dat1 le .z then delete;

  *-- Now, if exit before entry then censored before birth of siblinb;
  if exit<entry and cens_dat>.z then delete;


  entry=round(entry,0.001);
  exit =round(exit ,0.001);

  if eof then put 'Warning: ' _c_ 'subjects removed since event happened before birth of exposing relative';
run;

*-- Check data;
*data _null_;
*  set rep1(keep=barn1 child_bdat1 child_bdat2 hosp_dat1 hosp_dat2 cens_dat deem_dat1 deem_dat2 hosp_dat1 hosp_dat1 exit entry);
*  if exit<entry or exit<0;
*run;



*-- Repeat code above but for AD ;
data ad_rep1;
  drop _c_ deem_dat1 deem_dat2 cens_dat1 cens_dat2;
  attrib cens_dat length=4 format=yymmdd8. cens_dat1 length=4 format=yymmdd8.
         cens_dat2 length=4 format=yymmdd8. cens length=3;
  retain _c_ 0 ;
  set fam4(keep=ft flopnr mor1 far1 barn1 barn2 child_bdat1 child_bdat2 ad_hosp_dat1 ad_hosp_dat2
                deem_dat1 deem_dat2) end=eof;

  *-- First, date of exit (end of follow-up, emmigration or death or death or emigration in child before ASD diagnosis);
  if ad_hosp_dat1 le .z and deem_dat1 > .z then cens_dat1=min('31dec2009'd, deem_dat1);

  if deem_dat2 > .z then cens_dat2=min(deem_dat2, '31dec2009'd);
  else cens_dat2='31dec2009'd;

  *-- Now, censor date (before considering AD event) is the first of these two;
  if cens_dat1 > .z then cens_dat=min(cens_dat1, cens_dat2);
  else cens_dat=cens_dat2;

  cens=1;

  entry=max(0, (child_bdat1-child_bdat2)/365.25) ;

  if ad_hosp_dat2>.z then do;
    cens=0;
    exit =(ad_hosp_dat2-child_bdat2)/365.25;
  end;
  else exit=(cens_dat-child_bdat2)/365.25;

  *-- Check if child_bdat1>ad_hosp_dat2 (exposing sib born AFTER own disease). Then delete;
  if ad_hosp_dat2>.z and child_bdat1 > ad_hosp_dat2 then do;
    _c_=_c_+1;
    if eof then put 'Warning: ' _c_ 'subjects removed since event happened before birth of exposing relative';
    delete;
  end;


  *-- If proband dead before birth of sibling AND proband do not have ASD. Then delete;
  if deem_dat1>.z and deem_dat1<child_bdat2 and ad_hosp_dat1 le .z then delete;

  *-- Now, if exit before entry then censored before birth of siblinb;
  if exit<entry and cens_dat>.z then delete;


  entry=round(entry,0.001);
  exit =round(exit ,0.001);

  if eof then put 'Warning: ' _c_ 'subjects removed since event happened before birth of exposing relative';
run;


*-- Use hosp_dat1 to create varying covariates;
*-- (more general: join in date and value from external source);
data rep2;
  attrib asd_exp length=3 label='ASD in exposing sib';
  drop tmp_exit tmp_cens hosp_age1;

  set rep1;

  if hosp_dat1>.z then hosp_age1=(hosp_dat1-child_bdat2)/365.25;

  if hosp_dat1 le .z then do;             *- if proband do not have asd then never exposed;
    asd_exp=0; output;
  end;
  else if hosp_dat1<child_bdat2 then do;  *- if proband has asd before birth of sib then sib is exposed the entire life;
    asd_exp=1; output;
  end;
  else if hosp_age1 ge exit then do;       *- if proband has asd after sib exits, then sib is exposed the entire life;
    asd_exp=0; output;
  end;
  else if hosp_age1 lt exit then do;      *- if proband has asd between sib entry and exit;
    tmp_exit=exit; tmp_cens=cens;

    asd_exp=0; exit=hosp_age1; cens=1;  output;
    asd_exp=1; entry=exit; exit=tmp_exit; cens=tmp_cens; output;
  end;
run;


*-- Repeat code above but for AD ;
data ad_rep2;
  attrib ad_exp length=3 label='AD in exposing sib';
  drop tmp_exit tmp_cens ad_hosp_age1;

  set ad_rep1;

  if ad_hosp_dat1>.z then ad_hosp_age1=(ad_hosp_dat1-child_bdat2)/365.25;

  if ad_hosp_dat1 le .z then do;             *- if proband do not have ad then never exposed;
    ad_exp=0; output;
  end;
  else if ad_hosp_dat1<child_bdat2 then do;  *- if proband has ad before birth of sib then sib is exposed the entire life;
    ad_exp=1; output;
  end;
  else if ad_hosp_age1 ge exit then do;       *- if proband has ad after sib exits, then sib is exposed the entire life;
    ad_exp=0; output;
  end;
  else if ad_hosp_age1 lt exit then do;      *- if proband has ad between sib entry and exit;
    tmp_exit=exit; tmp_cens=cens;

    ad_exp=0; exit=ad_hosp_age1; cens=1;  output;
    ad_exp=1; entry=exit; exit=tmp_exit; cens=tmp_cens; output;
  end;
run;


*-- Logic checking and add derived variable pyear;
data rep3;
  drop flopnr;
  attrib outcome length=$3 label='Outcome (ASD/AD)';
  set rep2(in=asd_rep2)
      ad_rep2(in=ad_rep2)
  ;

  if asd_rep2 then outcome='ASD';else outcome='AD';

  *-- Calculate person year;
  pyear=round(exit-entry,0.1);

  entry=round(entry, 0.01);
  exit =round(exit,  0.01);


  *-- Create a generic family id;
  if ft in ('F','MH') then famid=mor1;
  else if ft = 'PH' then famid=far1;
  else if ft = 'C' then famid=flopnr;
  *-- Check data;
  if entry=exit then delete;
  if entry>exit then abort;
run;

*-- Sort with outcome last to have the same subject id for both AD and ASD;
proc sort data=rep3 out=rep4 nodupkey;by outcome ft famid barn1 barn2 entry exit;run;

*-- X1 can be useful analysing ASD and AD jointly. Combine the specific variables ;
data x1;
  attrib multiple length=$1 label='Multiple Birth (Y/N)' format=$cyesno.
  ;
  drop ad_exp ad_hosp_dat1 ad_hosp_dat1 inom;

  *- inom: if order variable within families is needed;
  retain inom 0;

  set rep4;by outcome ft famid barn1 barn2;

  if first.famid then inom=1;
  else inom=inom+1;

  *-- +-3 days between siblings ;
  if abs(child_bdat1-child_bdat2) le 3 then multiple='1';
  else multiple='0';

  if outcome='AD' then do;
    asd_exp   = ad_exp;
    hosp_dat1 = ad_hosp_dat1;
    hosp_dat2 = ad_hosp_dat2;
  end;

run;
/***
*-- Add info of multiple birth and zygosity;
proc sql;
  create table x3 as
  select a.*, b.monozyg as monozyg1, c.monozyg as monozyg2
  from x2 as a
  left join twins as b
    on a.barn1=b.barn
  left join twins as c
    on a.barn2=c.barn
  ;
quit;


*--------------------------------------------------------------------;
* a) Final datacheck                                                 ;
* b) use multiple varible to select singletons                       ;
* c) use monozyg1=monozyg2 and multiple for twins                    ;
*--------------------------------------------------------------------;
data x4(where=(ft ne 'C')) x4_cousin(where=(ft='C')) ;
  attrib multiple length=$1 format=$cyesno. label='Multiple birth'
         oldsib   length=$1 format=$cyesno. label='Valid for analysis of older sib'
         monozyg1 length=$1 format=$cyesno. label='Child 1 is mono zygotic'
         monozyg2 length=$1 format=$cyesno. label='Child 1 is mono zygotic'
  ;
  set x3;*(keep=monozyg1 monozyg2 multiple child_bdat1 child_bdat2);

  *-- Now since no abort above then combine zygosity to one variable;

  *-- if both sibs twins then from two different twinpairs. Mark as multiple;
  if monozyg1 ne '' and monozyg2 ne '' then multiple='1';

  *-- if child2 zygosity info then a twin. Mark as multiple;
  if monozyg2 ne '' then multiple='1';

  *-- Mark if valid for the older-sib analysis;
  if child_bdat2 > child_bdat1 then oldsib='1';else oldsib='0';

run;

data xx4;
  set x4_cousin(obs=1000);
run;

%tor(data=xx4,dname=x7, rfile=recur_x7.R, file=x7.csv, save=Y,
     class=outcome oldsib ft asd_exp bc sex1 sex2 mor_psych far_psych multiple monozyg1 monozyg2 oldpa oldma,
     var=famid entry exit cens);

%tor(data=xx4,dname=x7c, rfile=recur_x7c.R, file=x7c.csv, save=Y,
     class=outcome asd_exp bc sex1 sex2 mor_psych far_psych multiple monozyg1 monozyg2 oldpa oldma,
     var=famid entry exit cens);

data _null_;
  call system('R CMD BATCH /home/svesan/ki/slask/recur_x6.R');
run;
*****/

*=========================================================================;
* Now, join in the baseline data: sex, psychiatric history, parental age  ;
*=========================================================================;

%put ERROR: Check this. I should not need to use distinct!!! Should be distinct anyway;
proc sql;
  *-- Select first psych diagnosis of the mothers;
  create table mor_first_diag as
  select distinct a.mor, a.barn,
         case
           when b.hosp_dat>.z and b.hosp_dat LE a.child_bdat+10 then '1'
           else '0'
         end as mor_psych
  from mfr2 as a
  join tmpdsn.psych_first_diag(where=(mor_diag='1')) as b
  on a.mor = b.lopnr
  ;

  *-- Select first psych diagnosis of the fathers;
  create table far_first_diag as
  select distinct a.far, a.barn,
         case
           when b.hosp_dat>.z and b.hosp_dat LE a.child_bdat+10 then '1'
           else '0'
         end as far_psych
  from mfr2 as a
  join tmpdsn.psych_first_diag(where=(far_diag='1')) as b
  on a.far = b.lopnr
  ;

quit;

*-- Paternal psych hist and parental age ;
proc sql;
  create table x2 as
  select a.*,
         b.sex as sex1, c.sex as sex2,
         (a.child_bdat2-c.mo_bdat)/365.25 > 35 as oldma length=3, d.oldpa,
         case when e.mor_psych='1' then '1' else '0' end as mor_psych length=1,
         case when f.far_psych='1' then '1' else '0' end as far_psych length=1,
         case
           when a.child_bdat2 le .z then .u
           when a.child_bdat2 LE '31DEC1986'd then 1
           when a.child_bdat2 LE '31DEC1991'd then 2
           when a.child_bdat2 LE '31DEC1996'd then 3
           when a.child_bdat2 LE '31DEC2001'd then 4
           when a.child_bdat2 LE '31DEC2006'd then 5
           else 6
         end as bc length=3 format=bcfmt.,
         g.monozyg as monozyg1, h.monozyg as monozyg2
  from x1 as a
  left join mfr2 as b
    on a.barn1=b.barn
  left join mfr2 as c
    on a.barn2=c.barn
  left join tmpdsn.father as d
    on a.barn2=d.barn
  left join mor_first_diag as e
    on a.barn2=e.barn
  left join far_first_diag as f
    on a.barn2=f.barn
  left join twins as g
    on a.barn1=g.barn
  left join twins as h
    on a.barn2=h.barn
  ;
  ;
quit;

data x3 x3_cousins(drop=ft mor1 far1) slask1 slask2 cslask2 slask3 cslask3;
  attrib multiple length=$1 format=$cyesno. label='Multiple birth'
         oldsib   length=$1 format=$cyesno. label='Valid for analysis of older sib'
         monozyg1 length=$1 format=$cyesno. label='Child 1 is mono zygotic'
         monozyg2 length=$1 format=$cyesno. label='Child 1 is mono zygotic'
  ;
  set x2;

  *-- if both sibs twins then from two different twinpairs. Mark as multiple;
  if monozyg1 ne '' and monozyg2 ne '' then multiple='1';

  *-- if child2 zygosity info then a twin. Mark as multiple;
  if monozyg2 ne '' then multiple='1';

  *-- Mark if valid for the older-sib analysis;
  if child_bdat2 > child_bdat1 then oldsib='1';else oldsib='0';

  *-- 130523 add twin-status to the ft variable;
  *-- Note: The ft code is here for the pair relation. Two sibs can be twins and not with each other!;
  if monozyg1 eq '1' and monozyg1=monozyg2 and ft='F' then ft='MZ';
  else if monozyg1 eq '0' and monozyg1=monozyg2 and ft='F' then ft='DZ';

  *-- Only keep siblings who exit after 1st birth year;
  if exit > 1 then do;

    if entry<1 then do;
      pyear = pyear - (1-entry);
      entry = 1;

      if ft='C' and multiple='0' then output x3_cousins;
      else if ft ne 'C' then output x3;
      else output slask1;
    end;
    else do;
      if ft='C' and multiple='0' then output x3_cousins;
      else if ft ne 'C' then output x3;
      else output slask1;
    end;
  end;
  else if ft='C' then output cslask3;
  else output slask3;
run;


*-----------------------------------------------------------------------;
* Below send data to R where the Cox regerssion is done and the robust  ;
* standard errors are calculated. The R programs are called ???.R       ;
* The results are then sent back to SAS again for plotting using the    ;
* SAS program s_ciplt*.sas                                              ;
*                                                                       ;
* The X3 dataset is modified and sent to Ralf for heritability          ;
* calculations.                                                         ;
*-----------------------------------------------------------------------;

*-- Siblings including the full set of covariates;
%tor(data=x3,dname=psy1203A, rfile=psy1203_A.R, file=psy1203_A.csv, save=Y,
     class=outcome oldsib ft asd_exp bc sex1 sex2 mor_psych far_psych multiple monozyg1 monozyg2 oldpa oldma,
     var=famid entry exit cens);


*-- Cousins including the full set of covariates;
*-- Note: ft not included here;
%tor(data=x3_cousins, dname=psy1203cousin, rfile=psy1203_cousin.R, file=psy1203_cousin.csv, save=Y,
     class=outcome oldsib asd_exp bc sex1 sex2 mor_psych far_psych multiple monozyg1 monozyg2 oldpa oldma,
     var=famid entry exit cens);


*-- Run R to create the R data frames;
data _null_;
  call system('R CMD BATCH /home/svesan/ki/ABS/mep/sasproj/PSY/PSY1203/R-Stata/psy1203_A.R');
run;

data _null_;
  call system('R CMD BATCH /home/svesan/ki/ABS/mep/sasproj/PSY/PSY1203/R-Stata/psy1203cousin.R');
run;

data _null_;
  call system('R CMD BATCH /home/svesan/ki/AAA/AAA_Research/sasproj/PSY/PSY1203/R-Stata/recur_x8cb.R');
run;

/***
proc copy in=work out=sasperm;
select formats x3 x3_cousins;
run;

proc phreg data=x3_cousins;
  where outcome='ASD';
  class bc asd_exp;
  model (entry, exit)*cens(1) = bc asd_exp;
run;

proc phreg data=x3_cousins covs;
  where outcome='ASD';
  class bc asd_exp;
  model (entry, exit)*cens(1) = bc asd_exp
  id famid;
run;


proc contents data=x3_cousins;run;





data a1 a2 a3;
drop cens;
set x3(keep=entry exit pyear cens);
if cens=0 then event=1;else event=0;

if exit le 1 then output a1;
else if entry < 1 then output a2;
else output a3;

run;


title1 'X3';
proc freq data=x3;
where outcome="ASD";
  table ft * cens / nopercent nocol;
run;

title1 'slask1';
proc freq data=slask1;
where outcome="ASD";
  table ft * cens / nopercent nocol;
run;

title1 'slask2';
proc freq data=slask2;
where outcome="ASD";
  table ft * cens / nopercent nocol;
run;

title1 'slask3';
proc freq data=slask3;
where outcome="ASD";
  table ft * cens / nopercent nocol;
run;

proc sql;
  select count(distinct famid) as antal_familjer from x3;
  select count(distinct barn2) as antal_barn from x3;

  create table antal_cases as select distinct outcome, ft, barn2, max((cens=0)) as event from x3 group by outcome, ft, barn2;
  select outcome, ft, sum(event) as antal_fall from antal_cases group by outcome, ft;
  select outcome, sum(event) as antal_fall from antal_cases group by outcome;
quit;

proc copy in=work out=sasperm;
select x3 x3_cousins;
run;

data a;
set x3;
if multiple="1" and monozyg1=monozyg2 and monozyg1 ne '';
run;

options nofmterr;


proc sort data=x3(keep=barn2) out=barn2 nodupkey;by barn2;run;
proc sql;
create table check as
select a.*
from x3 as a
join barn2 as b
on a.barn1=b.barn2;
***/

*-- Cleanup ------------------------------------------------------------------;
title1;footnote;
proc datasets lib=work mt=data nolist;
delete _null_;
quit;

*-- End of File --------------------------------------------------------------;
