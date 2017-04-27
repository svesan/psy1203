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
     where a.lopnrmor is not null and a.lopnrbarn is not null and a.x_bfoddat >= '19820101'
  );
  disconnect from oracle;
run;quit;

*-- Sort and remove duplicates;
proc sort data=grandparents nodupkey;by barn mor far morfar mormor farmor farfar;run;

proc means data=grandparents n nmiss;
  var barn mor far morfar mormor farfar farmor;
run;

data tmpdsn.grandparents;
  set grandparents;
run;
