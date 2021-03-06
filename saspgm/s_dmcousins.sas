*-----------------------------------------------------------------------------;
* Study.......: PSY1203                                                       ;
* Name........: s_dmcousin.sas                                                ;
* Date........: 2013-02-18                                                    ;
* Author......: svesan                                                        ;
* Purpose.....: Define cousins                                                ;
* Note........:                                                               ;
*-----------------------------------------------------------------------------;
* Data used...: tmpdsn.mfr2 tmpdsn.grandparents                               ;
* Data created: cousins                                                       ;
*-----------------------------------------------------------------------------;
* OP..........: Linux/ SAS ver 9.03.01M2P081512                               ;
*-----------------------------------------------------------------------------;

*-- External programs --------------------------------------------------------;

*-- SAS macros ---------------------------------------------------------------;

*-- SAS formats --------------------------------------------------------------;

*-- Main program -------------------------------------------------------------;

*-- First, get the grandparents to children in mfr1;
proc sort data=tmpdsn.grandparents out=gp1 nodupkey;
  by barn mormor morfar farmor farfar;
run;

*-- Transpose data to define familes                              ;
*-- (children with the same mormor OR morfar OR farmor OR farfar  ;
proc transpose data=gp1 out=gp2(drop=_label_);
  var mormor morfar farmor farfar;
  by barn;
run;

*-- Here all children charing the same grand parent is a potential cousin;
*-- (need to remove siblins as being done later) ;
data gp3;
  rename col1=flopnr;
  drop _name_;
  attrib fmember length=$2 label='Family member type';
  set gp2(where=(col1>.z));
  if _name_='MORMOR' then fmember='mm';
  else if _name_='MORFAR' then fmember='mf';
  else if _name_='FARMOR' then fmember='fm';
  else if _name_='FARFAR' then fmember='ff';
  else abort;
run;
proc sort data=gp3;by flopnr barn;run;

*-- Need the parents to children. To be cousin can not have the same parents;
proc sql;
  create table gp4 as
  select distinct a.barn, a.mor, a.far
  from tmpdsn.mfr1 as a
  join (select distinct barn from gp3) as b
  on a.barn=b.barn
  where a.child_bdat le '31Dec2006'd
  ;
  *-- Now join in parents with the grand parents;
  create table gp5 as select a.*, b.mor, b.far
  from gp3 as a
  join gp4 as b
    on a.barn=b.barn
  ;
quit;


*-- Remove twins ;
proc sql;
  create table gp6 as
  select a.*
  from gp5 as a
  left join twins as b
  on a.barn = b.barn
  where b.barn is null
  ;
quit;

*-- Now define the cousins ;
*-- If needed later type of cousing (e.g. paternal grand parent) can be joined in;
proc sql;
  create table cousins(label='Cousin identifiers') as
  select 'C' as ft length=2, a.flopnr label='Family ID for cousins',
         a.barn as barn1 label='Child 1', b.barn as barn2 label='Child 2'
  from gp5 as a
  join gp5 as b
    on a.flopnr=b.flopnr and a.barn ne b.barn and a.mor ne b.mor and a.far ne b.far

  order by a.flopnr, a.barn, b.barn
  ;
quit;

*-- Cleanup ------------------------------------------------------------------;
title1;footnote;
proc datasets lib=work mt=data nolist;
  delete gp1-gp5;
quit;

*-- End of File --------------------------------------------------------------;
