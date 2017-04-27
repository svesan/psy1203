*=========================================================================;
* Now, join in the baseline data: sex, psychiatric history, parental age  ;
*=========================================================================;


%put ERROR: Check this. I should not need to use distinct!!! Should be distinct anyway;
proc sql;
  *-- Select first psych diagnosis of the mothers;
  create table mor_first_diag as
  select distinct a.mor, a.barn,
         case
           when b.hosp_dat>.z and b.hosp_dat LE a.child_bdat+10 then '1'
           else '0'
         end as mor_psych
  from mfr2 as a
  join tmpdsn.psych_first_diag(where=(mor_diag='1')) as b
  on a.mor = b.lopnr
  ;

  *-- Select first psych diagnosis of the fathers;
  create table far_first_diag as
  select distinct a.far, a.barn,
         case
           when b.hosp_dat>.z and b.hosp_dat LE a.child_bdat+10 then '1'
           else '0'
         end as far_psych
  from mfr2 as a
  join tmpdsn.psych_first_diag(where=(far_diag='1')) as b
  on a.far = b.lopnr
  ;

quit;

*-- Paternal psych hist and parental age
proc sql;
  create table x2 as
  select a.*,
         b.sex as sex1, c.sex as sex2,
         (a.child_bdat2-c.mo_bdat)/365.25 > 35 as oldma length=3, d.oldpa,
         case when e.mor_psych='1' then '1' else '0' end as mor_psych length=1,
         case when f.far_psych='1' then '1' else '0' end as far_psych length=1,
         case
           when a.child_bdat2 le .z then .u
           when a.child_bdat2 LE '31DEC1986'd then 1
           when a.child_bdat2 LE '31DEC1991'd then 2
           when a.child_bdat2 LE '31DEC1996'd then 3
           when a.child_bdat2 LE '31DEC2001'd then 4
           when a.child_bdat2 LE '31DEC2006'd then 5
         end as bc length=3 format=bcfmt.
  from x1 as a
  left join mfr2 as b
    on a.barn1=b.barn
  left join mfr2 as c
    on a.barn2=c.barn
  left join tmpdsn.father as d
    on a.barn2=d.barn
  left join mor_first_diag as e
    on a.barn2=e.barn
  left join far_first_diag as f
    on a.barn2=f.barn
  ;


proc sql;
create table check as
select barn, count(*) as n from mfr2 group by barn having n>1;



  create table s3 as
  select a.barn, b.hosp_dat as mor_psych_dat,
         case when b.hosp_dat>.z and b.hosp_dat LE min(a.child_bdat1,a.child_bdat2)+10 then '1'
              else '0'
         end as mor_psych length=1 format=$cyesno. label='Maternal psych history'
  from fam1 as a
  left join mor_first_diag b
  on a.mor1 = b.lopnr
  ;

  create table s3 as
  select a.barn2, b.hosp_dat as far_psych_dat,
         case when b.hosp_dat>.z and b.hosp_dat LE min(a.child_bdat1,a.child_bdat2)+10 then '1'
              else '0'
         end as far_psych length=1 format=$cyesno. label='Paternal psych history'
  from fam1 as a
  left join far_first_diag b
  on a.far1 = b.lopnr
  ;
quit;



  attrib case1 length=3 label='ASD case child 1'
         case2 length=3 label='ASD case child 2'
         bc    length=3 label='Birth cohort' format=bcfmt.
  ;
  drop   _c_ _d_ _e_ _f_ ;
  retain _c_ _d_ _e_ _f_ 0;
  set fam2 end=eof;

  if child_bdat2 le .z then bc=.u;
  else if child_bdat2 LE '31DEC1986'd then bc=1;
  else if child_bdat2 LE '31DEC1991'd then bc=2;
  else if child_bdat2 LE '31DEC1996'd then bc=3;
  else if child_bdat2 LE '31DEC2001'd then bc=4;
  else if child_bdat2 LE '31DEC2006'd then bc=5;

  case1=(hosp_dat1>.z);
  case2=(hosp_dat2>.z);





*-- Add paternal age and calculate maternal age;
proc sql;
  create table mfr5 as
  select a.*, (a.child_bdat-b.mo_bdat)/365.25 > 35 as oldma length=3, c.oldpa
  from ??? as a
  left join mfr1 as b
    on a.barn2 = b.barn and a.far=b.far
  left join father as c
    on a.barn2 = b.barn and a.far=b.far
  ;
quit;
