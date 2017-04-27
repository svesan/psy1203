%inc saspgm(tor);

proc format;
  value $ sexfmt  '1'='Male'  '2'='Female';
  value $ sexfmts '1'='M'     '2'='F';
  value   sex      1 ='Male'   2 ='Female';
  value $ cyesno  '1'='Yes'   '0'='No';
  value   yesno    1 ='Yes'    0 ='No';
  value   nt       1 ='F'      2 ='MH' 3='PH' 4='C';
  value   bcfmt    1='82-86' 2='87-91' 3='92-96' 4='97-01' 5='02-06';
run;


options nofmterr;

* 130418: Modified code for selection into twins etc. Now create tmp0 before tmp1;
* 130418: Added variables sex1 and sex2 so data can be used by Ralph for heritability;
* Note: Must use dataset without timevarying variable since this include >1 record per subject;

* Collapse the time-varying dataset;
proc sql;
  create table tmp0 as
  select outcome, famid, ft, barn1, barn2, asd_exp, child_bdat1, child_bdat2, sex1, sex2, bc,
         entry as entry0, exit, hosp_dat1, hosp_dat2, cens, multiple, monozyg1, monozyg2
  from sasperm.x3
  where sex1 ne ''
  order by outcome, ft, barn1, barn2, entry
  ;
quit;

data tmp1 tmp1_twin slask1 slask2(label='Born the same day but not in twin reg');
  length bc86_1 bc91_1 bc96_1 bc01_1 bc06_1
         bc86_2 bc91_2 bc96_2 bc01_2 bc06_2 3
  ;
  set tmp0;
  bc86_1=0; bc91_1=0; bc96_1=0; bc01_1=0; bc06_1=0;
  bc86_2=0; bc91_2=0; bc96_2=0; bc01_2=0; bc06_2=0;


  if child_bdat1 LE '31DEC1986'd then bc86_1=1;
  else if child_bdat1 LE '31DEC1991'd then bc91_1=1;
  else if child_bdat1 LE '31DEC1996'd then bc96_1=1;
  else if child_bdat1 LE '31DEC2001'd then bc01_1=1;
  else if child_bdat1 LE '31DEC2006'd then bc06_1=1;
  else abort;

  if child_bdat2 LE '31DEC1986'd then bc86_2=1;
  else if child_bdat2 LE '31DEC1991'd then bc91_2=1;
  else if child_bdat2 LE '31DEC1996'd then bc96_2=1;
  else if child_bdat2 LE '31DEC2001'd then bc01_2=1;
  else if child_bdat2 LE '31DEC2006'd then bc06_2=1;
  else abort;

run;
/**************
proc freq data=tmp1;
  table  bc86_1 bc91_1 bc96_1 bc01_1 bc06_1
         bc86_2 bc91_2 bc96_2 bc01_2 bc06_2;
run;
*****************/
proc sort data=tmp1;by outcome ft barn1 barn2 entry0;run;

data tmp2;
  length entry case1 case2 discord 3;
  retain entry case1 case2 i random_pair 0  seed 24977;
  drop entry0 seed;

  set tmp1;
  by outcome ft barn1 barn2 entry0;

  *-- Random number for each sib pair so can select one if the same sib1 occur in several pairs;
  if first.barn1 then do;random_pair=uniform(seed); i=1;end;
  else if not first.barn1 and first.barn2 then do;random_pair=uniform(seed);i=i+1;end;

  if first.barn2 then do;
    entry=entry0;
    case1=0; case2=0;
  end;

  if asd_exp=1 then case1=1;
  if cens=0 then case2=1;

  if case1 ne case2 then discord=1;else discord=0;

  if last.barn2 then output;
run;


*-------------------------------------------------------------------------------------;
* Create order variable for sibling pairs. If one random is to be used then select =1 ;
*-------------------------------------------------------------------------------------;
proc sort data=tmp2;by outcome barn1 random_pair barn2;run;

data sasperm.ralf2(label='Raw data for Ralfs calculations');
  length child_pair_order 3;
  retain child_pair_order 0;

  set tmp2;
  by outcome barn1 random_pair barn2;
  if first.barn1 then child_pair_order=1;
  else child_pair_order=child_pair_order+1;
run;


*------------------------------------------;
* Data to Ralph                            ;
*------------------------------------------;

*-- First select only then first child pair in each family;
proc sort data=sasperm.ralf2;by outcome famid child_pair_order;run;

data ralf_AD2(label='AD data to Ralf 05JUN2013')
     ralf_ASD2(label='ASD data to Ralf 05JUN2013');
  set sasperm.ralf2(keep=outcome famid ft barn1 case1 sex1 barn2 case2 sex2
                         child_pair_order
                         bc86_1 bc91_1 bc96_1 bc01_1 bc06_1
                         bc86_2 bc91_2 bc96_2 bc01_2 bc06_2);
  by outcome famid;

  if first.famid then do;
    if outcome='AD' then output ralf_AD2;
    else if outcome='ASD' then output ralf_ASD2;
  end;
run;

%tor(data=ralf_ad2, var=famid ft barn1 case1 sex1 barn2 case2 sex2 child_pair_order
     bc86_1 bc91_1 bc96_1 bc01_1 bc06_1 bc86_2 bc91_2 bc96_2 bc01_2 bc06_2,
     rfile=ralf_ad2.R, file=ralf_ad2.csv, dname=ralf_ad2, save=Y);


%tor(data=ralf_asd2, var=famid ft barn1 case1 sex1 barn2 case2 sex2 child_pair_order
     bc86_1 bc91_1 bc96_1 bc01_1 bc06_1 bc86_2 bc91_2 bc96_2 bc01_2 bc06_2,
     rfile=ralf_asd2.R, file=ralf_asd2.csv, dname=ralf_asd2, save=Y);



*-- Run R to create the R data frames;
data _null_;
  call system('R CMD BATCH /home/svesan/ki/AAA/AAA_Research/sasproj/PSY/PSY1203/R-Stata/ralf_ad2.R');
run;

*-- Run R to create the R data frames;
data _null_;
  call system('R CMD BATCH /home/svesan/ki/AAA/AAA_Research/sasproj/PSY/PSY1203/R-Stata/ralf_asd2.R');
run;


proc freq data=tmp0;
table sex1 / missing;
run;



*------------------------------------------;
* Tetrachoris correlations                 ;
*------------------------------------------;
title1 'Full dataset';
ods output measures=mycorr1(where=(statistic="Tetrachoric Correlation"
                                   or statistic="Polychoric Correlation")
                             keep = statistic table value ft outcome ase);
ods listing close;
proc freq data=tmp2;
  table case1 * case2 / plcorr;
  by outcome ft;
run;
ods listing;


*-- And with restricted follow-up to 8 yrs;
title1 'Dataset restricted to 8 yrs follow-up';
ods output measures=mycorr2(where=(statistic="Tetrachoric Correlation"
                                   or statistic="Polychoric Correlation")
                             keep = statistic table value ft outcome ase);
ods listing close;
proc freq data=tmp3;
  where mark=1;
  table case1 * case2 / plcorr;
  by outcome ft;
run;
ods listing;

data mycorr3;
  length analysis $30;
  set mycorr1
      mycorr2(in=mycorr2)
  ;
  if mycorr2 then analysis='Restricted follow-up';
  else analysis='Full dataset';

  valtxt=put(value,4.2)||' (95% CI: '||put(value-1.96*ase,4.2)||'-'||
         put(value+1.96*ase,4.2)||')';

run;
proc sort data=mycorr3;by outcome ft analysis;run;

title1 'Table 3. Tetrachoric correlations';
proc print data=mycorr3 noobs label;
  var analysis valtxt;
  by outcome ft; id outcome ft;
  format value 8.2;
ruN;
