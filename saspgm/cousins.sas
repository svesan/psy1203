proc transpose data=grandparents out=gp1(drop=_label_);
  var mormor morfar farmor farfar;
  by barn;
run;

data gp2;
  rename col1=flopnr;
  drop _name_;
  attrib fmember length=$2 label='Family member type';
  set gp1(where=(col1>.z));
  if _name_='MORMOR' then fmember='mm';
  else if _name_='MORFAR' then fmember='mf';
  else if _name_='FARMOR' then fmember='fm';
  else if _name_='FARFAR' then fmember='ff';
  else abort;
run;
proc sort data=gp2;by flopnr barn;run;

data gp3;
  set gp2(obs=5);
run;

proc sql;
  create table gp4 as
  select a.flopnr, a.barn as b1, b.barn as b2
  from gp3 as a
  join gp3 as b
  on a.flopnr=b.flopnr
  where a.barn ne b.barn
  order by a.flopnr, a.barn, b.barn
  ;
quit;
