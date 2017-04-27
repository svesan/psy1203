proc sql;
  connect to oracle (user=svesan pw="8Unnikersti" path=UNIVERSE);
  execute (alter session set current_schema=mgrcrime2 ) by oracle;

  create table hosp1 as
  select lopnr length=6, diagnos, diag_nr length=3, icd_nr length=3, put(source,2.) as source length=2,
         input(x_date, yymmdd8.) as hosp_dat length=4 format=yymmdd10. label='Admission date'

  from connection to oracle(

     select a.lopnr, a.diag_nr, a.diagnos, a.icd_nr, a.x_date, a.source
     from v_patient_diag  a
     where a.x_date >= '19820101' and diag_nr<23
  );
  disconnect from oracle;
quit;

proc sql;
  connect to oracle (user=svesan pw="8Unnikersti" path=UNIVERSE);
  execute (alter session set current_schema=mgrcrime2 ) by oracle;

  select count(*)

  from connection to oracle(
     select a.x_date
     from v_patient_diag  a
     where a.x_date >= '19820101'
  );
  disconnect from oracle;
quit;


     where a.x_date >= '19820101'  AND
           (icd_nr=9 AND (diagnos >= 290 and diagnos <= 319)) or
           icd_nr=10


proc sql;
select count(*) as n format=comma12.
from crime2.v_patient_diag;

select count(*) as n format=comma12.
from crime2.v_patient_diag
where x_date >= '19820101'
;
quit;

proc sql;
select count(*) as n format=comma12.
from crime2.v_patient_diag
where icd_nr=8 or (icd_nr=9 and (diagnos>='290' or diagnos le '319'))
or (icd_nr=10 and (substr(left(diagnos),2,2)>='0' and substr(left(diagnos),2,2) <= '99'))
;
quit;


data _a_;
txt='abcdeg';
b=substr(txt,2,3);
c=substr(txt,2,4);
put b= c=;

run;


data t1;
retain seed 23479;
do group=1 to 2;
do patno=1 to 100000;
if group=1 then weight=1;else weight=0.2;
iw=1/weight;
y=group/16+normal(seed)*6;
output;
end;
end;
run;

ods select lsmeans diffs;
proc genmod data=t1;
  class group;
  model y=group;
*  weight weight;
  lsmeans group / diff;
run;

title1 'Full dataset';
ods select lsmeans diffs;
proc genmod data=t1;
  class group;
  model y=group;
*  weight weight;
  lsmeans group / diff;
run;

title1 'Subsample of controls. Upweight with w=5';
ods select lsmeans diffs;
proc genmod data=t1;
  where group=1 or (group=2 and patno<=20000);
  class group;
  model y=group;
  weight weight;
  lsmeans group / diff;
run;
