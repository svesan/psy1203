*-----------------------------------------------------------------------------;
* Study.......: PSY1203                                                       ;
* Name........: s_dmpsych4.sas                                                ;
* Date........: 2013-02-07                                                    ;
* Author......: svesan                                                        ;
* Purpose.....: Extract psychiatric diagnoses from Crime2 db                  ;
* Note........: The program should be run on skjold                           ;
* Note........: 130603 updated with new codes                                 ;
* Note........: 130610 updated with new codes supplied by Avi                 ;
*-----------------------------------------------------------------------------;
* Data used...: crime2.v_patient_diag                                         ;
* Data created: psych_diag psych_first_diag                                   ;
*-----------------------------------------------------------------------------;
* OP..........: Linux/ SAS ver 9.03.01M2P081512                               ;
*-----------------------------------------------------------------------------;

*-- External programs --------------------------------------------------------;
* <the program creating tmpdsn.mfr1> ;

*-- SAS macros ---------------------------------------------------------------;

*-- SAS formats --------------------------------------------------------------;
proc format;
  value psydia 1='Schizophrenia'       2='BiPolar' 3='Non Affective Psychosis'
               4='Other Diagnosis'     5='MR'      6='Affective Psychosis'
               7='Drug'
  ;
run;

*-- Main program -------------------------------------------------------------;
options stimer;

*-- First, select all psychiatric diagnosis from ICD 8/9/10 ;
proc sql;
  create table t1 as
  select lopnr length=6, diagnos length=4, diag_nr length=3, icd_nr length=3,
         put(source,1.) as source length=1,
         input(x_date, yymmdd8.) as hosp_dat length=4 format=yymmdd10. label='Admission date'
     from crime2.v_patient_diag
     where diag_nr<23 and
           ((icd_nr GE 7 and icd_nr LE 9) and
            (substr(diagnos,1,2)='29' or substr(diagnos,1,1)='3') or
            (icd_nr=10 and substr(diagnos,1,1)='F'))
  order by lopnr, hosp_dat;
quit;

* NOT F26, F27 ;
data psych_diag(label='All psychiatric diagnoses');
drop sub3 sub4 sub5;
attrib psy_diag length=3 format=psydia. label='Psychiatric History';
set t1;

sub3=substr(left(diagnos),1,3);
sub4=substr(left(diagnos),1,4);
if length(compress(diagnos))>4 then sub5=substr(left(diagnos),1,5);


if icd_nr=7 then do;
  if sub3 in ('300') then psy_diag=1;
  else if sub3 in ('301','302') then psy_diag=2;
  else if sub3 in ('309') then psy_diag=3;
  else if sub3 in ('303','310','311','312','313','314','315','316','317','318','320','321','322','323','324') then psy_diag=4;
  else if sub3 in ('301','302') then psy_diag=5;
  else if sub3 in ('325') then psy_diag=7;
end;
else if icd_nr=8 then do;
  if sub3 in ('295') then psy_diag=1;
  else if sub5='29810' or sub4='2981' or sub3='296' then psy_diag=2;
  else if sub5 in ('29820','29830','29890') or sub4 in ('2982','2983','2989') or sub3 in ('297','299') then psy_diag=3;
  else if sub3 in ('301') or
          sub4 in ('3000','3001','3002','3003','3004','3005','3006','3007','3008','3009') or
          diagnos in ('300') then psy_diag=4;
  else if sub3 in ('310','311','312','313','314','315') then psy_diag=5;
  else if sub5='30041' or sub4='2980' then psy_diag=6;
  else if sub3 in ('303','304','305') then psy_diag=7;
end;
else if icd_nr=9 then do;
  if sub3 in ('295') then psy_diag=1;
  else if sub4='298B' or sub3='296' then psy_diag=2;
  else if sub4 in ('298C','298E','298W','298X') or sub3 in ('297') or diagnos='298' then psy_diag=3;
  else if sub4 in ('300A','300B','300C','300D','300F','300G','300H','300W','300X') or
          sub3 in ('301','306','307','308','309','310','312','313','314','315','316') or diagnos='300' then psy_diag=4;
  else if sub4 in ('318A','318B','318C') or diagnos in ('317','318','319') then psy_diag=5;
  else if sub4 in ('298A','300E') or sub3 in ('311') then psy_diag=6;
  else if sub3 in ('303','304','305') then psy_diag=7;
end;
else if icd_nr=10 then do;
  if sub4 in ('F231','F232') or sub3 in ('F20','F21','F25') then psy_diag=1;
  else if sub3 in ('F30','F31') then psy_diag=2;
  else if sub4 in ('F23.0','F23.3','F23.8','F23.9') or
          sub3 in ('F22','F24','F28','F29') or
          diagnos='F23' then psy_diag=3;

  else if sub3 in ('F40','F41','F42','F43','F44','F45','F46','F47','F48','F50','F51','F52','F53','F54',
                   'F55','F59','F60','F61','F62','F63','F64','F65','F66','F68','F69','F99') then psy_diag=4;

  else if sub3 in ('F70','F71','F72','F73','F78','F79') then psy_diag=5;
  else if sub3 in ('F32','F33','F34','F38','F39') then psy_diag=6;
  else if sub3 in ('F10','F11','F12','F13','F14','F15','F16','F17','F18','F19') then psy_diag=7;
end;


*-- Only keep records with psychiatric diagnoses to consider. Not drug related;
if psy_diag in (1,2,3,4,5,7);

run;


*-- Select first diagnosis of each subject;
data psych_diag_first(label='First psych diagnosis' sortedby=lopnr);
  set psych_diag;by lopnr hosp_dat;
  if first.lopnr;
run;


/***** This section moved to program s_dm22.sas 2013-06-10
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
*****/

*-- Cleanup ------------------------------------------------------------------;
title1;footnote;
proc datasets lib=work mt=data nolist;
  delete _null_;
quit;

*-- End of File --------------------------------------------------------------;
