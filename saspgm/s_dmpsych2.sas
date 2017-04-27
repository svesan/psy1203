*-----------------------------------------------------------------------------;
* Study.......: PSY1203                                                       ;
* Name........: s_dmpsych2.sas                                                ;
* Date........: 2013-02-07                                                    ;
* Author......: svesan                                                        ;
* Purpose.....: Extract psychiatric diagnoses from Crime2 db                  ;
* Note........: The program should be run on skjold                           ;
* Note........: 130603 updated with new codes                                 ;
*-----------------------------------------------------------------------------;
* Data used...: crime2.v_patient_diag tmpdsn.mfr1                             ;
* Data created: psych_diag psych_first_diag                                   ;
*-----------------------------------------------------------------------------;
* OP..........: Linux/ SAS ver 9.03.01M2P081512                               ;
*-----------------------------------------------------------------------------;

*-- External programs --------------------------------------------------------;
* <the program creating tmpdsn.mfr1> ;

*-- SAS macros ---------------------------------------------------------------;

*-- SAS formats --------------------------------------------------------------;

*-- Main program -------------------------------------------------------------;
libname sw slibref=work server=skjold;

options stimer;

/**** These codes were replaced 2013-06-03
     where a.diag_nr<23
           and ((a.icd_nr=9 and substr(a.diagnos,1,3)='299') or
                (a.icd_nr=10 and substr(a.diagnos,1,1)='F')  or
                (a.icd_nr=8 and (a.diagnos>='290' and a.diagnos le '349')) )
********/

*-- First, select all psychiatric diagnosis from ICD 8/9/10 ;
proc sql;
  create table psych_diag(label='Psychiatric diagnoses - All subjects') as
  select lopnr length=6, diagnos length=4, diag_nr length=3, icd_nr length=3,
         put(source,1.) as source length=1,
         input(x_date, yymmdd8.) as hosp_dat length=4 format=yymmdd10. label='Admission date'
     from crime2.v_patient_diag as a
     where a.diag_nr<23
           and ((a.icd_nr=7 and substr(a.diagnosis,1,3) in ('300','301','302','309') ) or
                (a.icd_nr=8 and substr(a.diagnosis,1,3) in ('295','296','297','298','299')  )
                (a.icd_nr=9 and substr(a.diagnos,1,3)='299') or
                (a.icd_nr=10 and substr(a.diagnos,1,1)='F')  or
  order by lopnr, hosp_dat;
quit;



*-- Select first diagnosis of each subject;
data psych_diag_first(label='First psych diagnosis' sortedby=lopnr);
  set psych_diag;by lopnr hosp_dat;
  if first.lopnr;
run;

*-- Download the data from skjold;
proc download data=psych_diag;run;
proc download data=psych_diag_first;run;

*-- Join in info if diagnosis is for child, father or mother ;
proc copy in=tmpdsn out=work;select mfr1;run;

proc sql;
  create table tmpdsn.psych_first_diag(label='First psychiatric diagnosis') as
  select a.*,
         case when b.barn is null then '0' else '1' end as barn_diag length=1 format=$cyesno. label='Diagnosis for child',
         case when c.mor  is null then '0' else '1' end as mor_diag  length=1 format=$cyesno. label='Diagnosis for mother',
         case when d.far  is null then '0' else '1' end as far_diag  length=1 format=$cyesno. label='Diagnosis for father'
  from psych_diag_first as a
  left join mfr1 as b
    on a.lopnr = b.barn
  left join mfr1 as c
    on a.lopnr = c.mor
  left join mfr1 as d
    on a.lopnr = d.far
  ;

  create table tmpdsn.psych_diag(label='All psychiatric diagnoses') as
  select a.*,
         case when b.barn is null then '0' else '1' end as barn_diag length=1 format=$cyesno. label='Diagnosis for child',
         case when c.mor  is null then '0' else '1' end as mor_diag  length=1 format=$cyesno. label='Diagnosis for mother',
         case when d.far  is null then '0' else '1' end as far_diag  length=1 format=$cyesno. label='Diagnosis for father'
  from psych_diag as a
  left join mfr1 as b
    on a.lopnr = b.barn
  left join mfr1 as c
    on a.lopnr = c.mor
  left join mfr1 as d
    on a.lopnr = d.far
  ;
quit;

*-- Cleanup ------------------------------------------------------------------;
title1;footnote;
proc datasets lib=work mt=data nolist;
  delete _null_;
quit;

*-- End of File --------------------------------------------------------------;
