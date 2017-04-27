libname crime2 oracle dbprompt=no path=UNIVERSE schema=mgrcrime2 connection=GLOBALREAD
user=svesan pw="{SAS002}1EA5152055A835B6561F91FA343842795497A910" readbuff=4000 updatebuff=40;


proc sql;
  create table hepp789 as
  select lopnr length=6, diagnos length=4, diag_nr length=3, icd_nr length=3,
         put(source,1.) as source length=1,
         input(x_date, yymmdd8.) as hosp_dat length=4 format=yymmdd10. label='Admission date'
     from crime2.v_patient_diag as a
     where a.diag_nr<23
           and ((a.icd_nr=7 and substr(a.diagnos,1,3) in ('300','301','302','309') ) or
                (a.icd_nr=8 and substr(a.diagnos,1,3) in ('295','296','297','298','299')  ) or
                (a.icd_nr=9 and substr(a.diagnos,1,3) in ('295','296','297','298','299','300') ))
     ;

proc sql;
  create table hepp10 as
  select lopnr length=6, diagnos length=4, diag_nr length=3, icd_nr length=3,
         put(source,1.) as source length=1,
         input(x_date, yymmdd8.) as hosp_dat length=4 format=yymmdd10. label='Admission date'
     from crime2.v_patient_diag as a
     where a.diag_nr<23 and a.icd_nr=10 and substr(a.diagnos,1,1)='F' and substr(a.diagnos,2,4) in
           ('20','21','22','23','24','25','28','28','29','30','31','32','33','34','38','39',
            '230','231','232','233','238','239');

data hepp;
set hepp789 hepp10;
run;

proc sort data=hepp;by icd_nr diagnos;run;

title1 'ICD7/8/9/10 diagnosis';
proc freq data=hepp order=internal;
table diagnos / nocum out=a;
by icd_nr;
run;

%scarep(data=a,var=icd_nr diagnos count,panels=3);

title1 'ICD10 diagnosis starting with F';
proc freq data=hepp order=internal;
table diagnos;
run;
