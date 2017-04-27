*-----------------------------------------------------------------------------;
* Study.......: PSY1203                                                       ;
* Name........: s_dmhosp.sas                                                  ;
* Date........: 2013-06-03                                                    ;
* Author......: svesan                                                        ;
* Purpose.....: Create dataset with ASD diagnosis for children born from 1982 ;
* Note........:                                                               ;
*-----------------------------------------------------------------------------;
* Data used...: crime v_patient_diag and v_mfr_base                           ;
* Data created: tmpdsn.asd_diag                                               ;
*-----------------------------------------------------------------------------;
* OP..........: Linux/ SAS ver 9.03.01M2P081512                               ;
*-----------------------------------------------------------------------------;

*-- External programs --------------------------------------------------------;

*-- SAS macros ---------------------------------------------------------------;

*-- SAS formats --------------------------------------------------------------;

*-- Main program -------------------------------------------------------------;

options nofmterr;

proc sql;
  connect to oracle (user=svesan pw="{SAS002}1EA5152055A835B6561F91FA343842795497A910" path=UNIVERSE);
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

*-- Cleanup ------------------------------------------------------------------;
title1;footnote;
proc datasets lib=work mt=data nolist;
delete _null_;
quit;

*-- End of File --------------------------------------------------------------;
