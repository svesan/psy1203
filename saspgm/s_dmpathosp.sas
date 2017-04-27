%inc saspgm(oracle);

options nofmterr;

proc sql;
  connect to oracle (user=svesan pw="8Unnikersti" path=UNIVERSE);
  execute (alter session set current_schema=mgrcrime2 ) by oracle;

  create table temp1 as
  select lopnr length=6, diagnos length=4, diag_nr length=3, icd_nr length=3,
         put(source,1.) as source length=1,
         input(x_date, yymmdd8.) as hosp_dat length=4 format=yymmdd10. label='Admission date'

  from connection to oracle(

     select a.lopnr, a.diag_nr, a.diagnos, a.icd_nr, a.x_date, a.source
     from v_patient_diag a
     join v_mfr_base b
     on a.lopnr = b.lopnrbarn
     where b.x_bfoddat >= '19820101' and a.diag_nr<23 and
           ((icd_nr=9 and substr(a.diagnos,1,3)='299')
             or (icd_nr=10 and a.diagnos in ('F840','F841','F845','F848','F849') ) )
  )
  order by lopnr, hosp_dat;

  disconnect from oracle;
quit;

proc sort data=temp1;by lopnr hosp_dat diag_nr;run;

data tmpdsn.asd_diag(label='ASD diagnosis' sortedby=lopnr hosp_dat diag_nr);
  attrib asd length=3 label='ASD' format=yesno.;
  retain asd 1;
  set temp1;by lopnr hosp_dat diag_nr;
  if first.lopnr then;
run;


proc sql;
  create table pat_id as select distinct far from mfr3;

  create table pat_psy as
  select a.far, b.diagnos, b.icd_nr,
         put(b.source,1.) as source length=1,
         input(b.x_date, yymmdd8.) as hosp_dat length=4 format=yymmdd10. label='Admission date'
  from pat_id as a
    join crime2.v_patient_diag as b
    on a.far=b.lopnr
    where b.diag_nr<23 and ((icd_nr=10 and substr(b.diagnos,1,1)='F')
         or (icd_nr=9 and (substr(b.diagnos,1,3)>='290' and substr(b.diagnos,1,3) le '359') )
         or (icd_nr=8 and (b.diagnos>='290' and b.diagnos le '349') ))
  ;
quit;

proc sql;
select count(*) as n format=comma16. from crime2.v_patient_diag;quit;
