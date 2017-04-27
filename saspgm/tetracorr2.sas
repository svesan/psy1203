*-- Tetrachoris correlations;
proc sort data=fam3(keep=ft hosp_dat1 hosp_dat2  ad_hosp_dat1 ad_hosp_dat2) out=tetra0;
  by ft;
run;
data tetra1;
   set tetra0;
  case1=(hosp_dat1>.z);
  case2=(hosp_dat2>.z);
run;

data tetra2;
  set tetra1;
  if case1 and ad_hosp_dat1>.z then ad_case1=1;else ad_case1=0;
  if case2 and ad_hosp_dat2>.z then ad_case2=1;else ad_case2=0;
run;

ods output measures=mycorr1(where=(statistic="Tetrachoric Correlation"
                                   or statistic="Polychoric Correlation")
                             keep = statistic table value ft);
ods listing close;
proc freq data=tetra2;
  table case1 * case2 / plcorr;
  table ad_case1 * ad_case2 / plcorr;
  by ft;
run;
ods listing;

data mycorr2;
  set mycorr1;
  if index(table,'AD_CASE')>0 then outcome='AD ';else outcome='ASD';
run;
proc sort data=mycorr2;by ft outcome;run;

title1 'Table 3. Tetrachoric correlations';
proc print data=mycorr2 noobs label;
  var outcome value;
  by ft; id ft;
  format value 8.2;
ruN;
