proc sort data=ralf_asd1;by outcome ft;run;
proc sort data=ralf_ad1;by outcome ft;run;

*-- Tetrachoris correlations;
ods output measures=mycorr1(where=(statistic="Tetrachoric Correlation"
                                   or statistic="Polychoric Correlation")
                             keep = statistic table value ft outcome ase);
ods listing close;
proc freq data=ralf_asd1;
  table case1 * case2 / plcorr;
  by outcome ft;
run;

ods output measures=mycorr2(where=(statistic="Tetrachoric Correlation"
                                   or statistic="Polychoric Correlation")
                             keep = statistic table value ft outcome ase);
proc freq data=ralf_ad1;
  table case1 * case2 / plcorr;
  by outcome ft;
run;
ods listing;


data mycorr3;
  length analysis $30;
  set mycorr1
      mycorr2(in=mycorr2)
  ;
  valtxt=put(value,4.2)||' (95% CI: '||put(value-1.96*ase,4.2)||'-'||
         put(value+1.96*ase,4.2)||')';

run;
proc sort data=mycorr3;by outcome ft analysis;run;

title1 'Table 3. Tetrachoric correlations using data sent to Ralf';
title2 'Note: (A) Older sib exposing younger, (B) One sib per family, (C) No restriction on years of follow-up';
proc print data=mycorr3 noobs label;
  var analysis valtxt;
  by outcome ft; id outcome ft;
  format value 8.2;
ruN;
