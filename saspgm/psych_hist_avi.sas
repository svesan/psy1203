proc sql;
  create table check3 as
  select  icd_nr, diagnos
  from crime2.v_patient_diag as a
  ;

proc format;
  value psydia 1='Schizophrenia'       2='BiPolar' 3='Non Affective Psychosis'
               4='Other Diagnosis'     5='MR'      6='Drug'
               7='Affective Psychosis'
  ;
run;

data check4;
attrib psy_diag length=3 format=psydia. label='Psychiatric History';
set check3;

sub3=substr(left(diagnos),1,3);
sub4=substr(left(diagnos),1,4);
sub5=substr(left(diagnos),1,5);


if icd_nr=7 then do;
  if sub3 in ('300') then psy_diag=1;
  else if sub3 in ('301','302') then psy_diag=2;
  else if sub3 in ('309') then psy_diag=3;
  else if sub3 in ('303','310','311','312','313','314','315','316','317','318','320','321','322','323','324') then psy_diag=4;
  else if sub3 in ('301','302') then psy_diag=5;
  else if sub3 in ('325') then psy_diag=6;
end;
else if icd_nr=8 then do;
  if sub3 in ('295') then psy_diag=1;
  else if sub5='29810' or sub4='2981' or sub3='296' then psy_diag=2;
  else if sub5 in ('29820','29830','29890') or sub4 in ('2982','2983','2989') or sub3 in ('297','299') then psy_diag=3;
  else if sub3 in ('301') or
          sub4 in ('3000','3001','3002','3003','3004','3005','3006','3007','3008','3009') or
          diagnos in ('300') then psy_diag=4;
  else if sub3 in ('310','311','312','313','314','315') then psy_diag=5;
  else if sub3 in ('303','304','305') then psy_diag=6;
  else if sub5='30041' or sub4='2980' then psy_diag=7;
end;
else if icd_nr=9 then do;
  if sub3 in ('295') then psy_diag=1;
  else if sub4='298B' or sub3='296' then psy_diag=2;
  else if sub4 in ('298C','298E','298W','298X') or sub3 in ('297') or diagnos='298' then psy_diag=3;
  else if sub4 in ('300A','300B','300C','300D','300F','300G','300H','300W','300X') or
          sub3 in ('301','306','307','308','309','310','312','313','314','315','316') or diagnos='300' then psy_diag=4;
  else if sub4 in ('318A','318B','318C') or diagnos in ('317','318','319') then psy_diag=5;
  else if sub3 in ('303','304','305') then psy_diag=6;
  else if sub4 in ('298A','300E') or sub3 in ('311') then psy_diag=7;
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
  else if sub3 in ('F10','F11','F12','F13','F14','F15','F16','F17','F18','F19') then psy_diag=6;
  else if sub3 in ('F32','F33','F34','F38','F39') then psy_diag=7;
end;

run;

proc freq data=check4;
table psy_diag;
run;

libname crime2 oracle dbprompt=no path=UNIVERSE schema=mgrcrime2 connection=GLOBALREAD
user=svesan pw="{SAS002}1EA5152055A835B6561F91FA343842795497A910" readbuff=4000 updatebuff=40;
