*-----------------------------------------------------------------------------;
* Study.......: PSY1203                                                       ;
* Name........: s_dmgp1.sas                                                   ;
* Date........: 2013-06-11                                                    ;
* Author......: svesan                                                        ;
* Purpose.....: Create dataset with grand parents                             ;
* Note........:                                                               ;
*-----------------------------------------------------------------------------;
* Data used...: crime.v_mfr_base crime.v_parent                               ;
* Data created: tmpdsn.grandparents                                           ;
*-----------------------------------------------------------------------------;
* OP..........: Linux/ SAS ver 9.03.01M2P081512                               ;
*-----------------------------------------------------------------------------;

*-- External programs --------------------------------------------------------;

*-- SAS macros ---------------------------------------------------------------;

*-- SAS formats --------------------------------------------------------------;

*-- Main program -------------------------------------------------------------;
proc sql;
  connect to oracle (user=svesan pw="{SAS002}1EA5152055A835B6561F91FA343842795497A910" path=UNIVERSE);
  execute (alter session set current_schema=mgrcrime2 ) by oracle;

  *-- Select children and their parents (then their grand-parents....);
  create table grandparents as
  select lopnrbarn as barn length=6, lopnrmor as mor length=6, lopnrfar as far length=6,
         morfar length=6, mormor length=6, farfar length=6, farmor length=6
  from connection to oracle(

     select a.lopnrbarn, a.lopnrmor, b.lopnrfar, a.x_bfoddat,
            c.lopnrfar as morfar, d.lopnrmor as mormor,
            e.lopnrfar as farfar, f.lopnrmor as farmor

     from v_mfr_base a
       left join v_parent b
       on a.lopnrmor=b.lopnrmor and a.lopnrbarn=b.lopnr
     left join (select lopnr, lopnrfar from v_parent) c
       on c.lopnr=a.lopnrmor
     left join (select lopnr, lopnrmor from v_parent) d
       on d.lopnr=a.lopnrmor
     left join (select lopnr, lopnrfar from v_parent) e
       on e.lopnr=b.lopnrfar
     left join (select lopnr, lopnrmor from v_parent) f
       on f.lopnr=b.lopnrfar
     where a.lopnrmor is not null and a.lopnrbarn is not null and a.x_bfoddat >= '19820101' and a.x_bfoddat < '20070101'
  );
  disconnect from oracle;
run;quit;

*-- Sort and remove duplicates;
proc sort data=grandparents nodupkey;by barn mor far morfar mormor farmor farfar;run;

data tmpdsn.grandparents(label='Parents and grand parents to children born 19820101-20061231');
  set grandparents;
run;

*-- Cleanup ------------------------------------------------------------------;
title1;footnote;
proc datasets lib=work mt=data nolist;
  delete grandparents;
quit;

*-- End of File --------------------------------------------------------------;
