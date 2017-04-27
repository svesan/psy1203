%inc saspgm(s_gdevice2);

%inc saspgm(ssciplt3);

*-- SAS macros ---------------------------------------------------------------;

*-- SAS formats --------------------------------------------------------------;
proc format;
  value myx 0.03125='0.031' 0.0625='0.062' 0.125='0.125' 0.25='0.25' 0.5='0.5' 1='1'
  ;
run;

%let slask1=%qsysfunc(pathname(result));

*-- annotate dataset to add in RR (95% CI) on top of left most column;
data annot1;
  length function $12 text  $50;
  retain xsys ysys '3' hsys '3' color 'black' size 2.00;
  x=93; y=98.5; function='move  '; output;
  function='label'; text='RR  (95% CI)'; style='Times-Bold'; output;
run;

*=============================================================;
* START WITH ASD                                              ;
*=============================================================;

data asd1;
drop n ref_n cases refcases;
input sorder outcome $ 5-8 lbl $ 10-34 sub $ 36-49 cases refcases n ref_n estimate lower upper ;
can_txt='A';

if outcome='AD' and sorder=6 then delete;
else jamatxt='(Rate='||compress(put(cases, 8.))||' vs '||compress(put(refcases,8.))||
             ', P-Year='||compress(put(n, 12.))||' vs '||compress(put(ref_n,8.))||')';

cards;
17  ASD  Family Types              MZ Twin         26.8   6273.5      130720       96     152.952   56.677  412.767
16  ASD  Family Types              DZ Twin         54.5   805.1       385521      869       8.222    3.744   18.058
15  ASD  Family Types              Full Sib        48.8   829.0     35486922    76481      10.268    9.366   11.257
14  ASD  Family Types              MH Sib          94.1   491.6      4641500    16273       3.281    2.571    4.188
13  ASD  Family Types              PH Sib          84.7   370.9      4651888    15638       2.864    2.205    3.721
12  ASD  Family Types              Cousin          48.6   154.6    148053914   313739       2.008    1.809    2.229
10  ASD  Birth cohorts (Full Sibs) 1982-86         26.3    463.1     8750181    14467       7.336    5.905    9.113
 9  ASD  Birth cohorts (Full Sibs) 1987-91         45.4    728.2    12268494    24580       6.618    5.634    7.775
 8  ASD  Birth cohorts (Full Sibs) 1992-96         62.8    1013.9    8650801    21206       7.296    6.347    8.387
 7  ASD  Birth cohorts (Full Sibs) 1997-2001       71.1    962       4116561    11743       8.129    6.857    9.637
 6  ASD  Birth cohorts (Full Sibs) 2002-2006       64.4    1337.8    1700884    4485       10.402    8.262   13.096
 4  ASD  Gender risk (Full Sibs)   Male-Male       67.2    1035.5    9378760    28587       9.423    8.255   10.756
 3  ASD  Gender risk (Full Sibs)   Male-Female     28.2    512       8871116    27527      10.424    8.702   12.487
 2  ASD  Gender risk (Full Sibs)   Female-Male     67.9    1254.4    8878053    10045      11.116    9.199   13.433
 1  ASD  Gender risk (Full Sibs)   Female-Female   29.8    687.8     8358993    10323      12.541    9.632   16.331
;
run;

data annot3;
  length function $12;
  retain xsys ysys '2' hsys '2' size 0.9;
  set asd1(keep=sorder lower jamatxt rename=(sorder=y lower=x jamatxt=text));

  function='move';  x=x*0.90; y=y-0.1; output;
  function='label'; position='8'; output;
run;

data annot4;
  set annot1 annot3(in=annot3);
  if annot3 then do;
    size=0.37;
  end;
run;


filename  epsgraf "&slask1/JAMA_Fig2.eps";
goptions reset=all device=eps14x16 /*device=psepsf*/   display gsfname=epsgraf gsfmode=replace rotate=p
         ftext="Times-Roman"
         lfactor=4 htext=2.1 fontres=presentation noborder;

*itle1 'ASD';

%inc saspgm(ssciplt3);
%ssciplt(data=asd1, order=sorder, gout=gseg, annotate=annot4,
type=2, boxwidth=0.035, hsymbol=1.50, boxcolor=black,
label=lbl, labelposition=LEFTMOST, hlabel=2.4, alabel=90, flabel=Times-Bold,
sublabel=sub, hsublabel=1.95, digits=5.1, fsublabel=Helvetica,
citext=RIGHTMOST, hcitext=2.0, xformat=myx.,
lower_offset=6, upper_offset=4, left_offset=12, right_offset=16,
xorder= %str(0.5 ,1, 2, 4, 8, 16, 32, 64, 128, 256, 512),
href=1 whref=2, vref=5 11 lvref=(2 2) wvref=(1 1));

filename epsgraf clear;
goptions reset=all;


*=============================================================;
* NOW DO AUTISTIC DISORDER                                    ;
*=============================================================;
data ad1;
drop n ref_n cases refcases;
input sorder outcome $ 5-8 lbl $ 10-34 sub $ 36-49 cases refcases n ref_n estimate lower upper ;
can_txt='A';

jamatxt='(Rate='||compress(put(cases, 8.))||' vs '||compress(put(refcases,8.))||
        ', P-Year='||compress(put(n, 12.))||' vs '||compress(put(ref_n,8.))||')';

cards;
17  AD   Family Types              MZ Twin         14.5  4748.3       130855       42     116.769   16.747   814.203
16  AD   Family Types              DZ Twin         24.8   775.8       386501      387      16.894    5.123    55.714
15  AD   Family Types              Full Sib        20.0   486.3     35574718    34138      14.616   12.466    17.138
14  AD   Family Types              MH Sib          33.4   240.0      4661940     6250       4.344    2.514     7.505
13  AD   Family Types              PH Sib          31.1   124.3      4670597     6436       2.934    1.461     5.892
12  AD   Family Types              Cousin          18.4    60.7    148418487   133335       2.255    1.787     2.847
10  AD   Birth cohorts (Full Sibs) 1982-86          6.6   139.1      8770373     5032      12.428    6.988    22.105
 9  AD   Birth cohorts (Full Sibs) 1987-91         14.5   362.3     12302896     9386       9.977    7.055    14.109
 8  AD   Birth cohorts (Full Sibs) 1992-96         26.5   439.7      8673579    10234       9.532    7.168    12.675
 7  AD   Birth cohorts (Full Sibs) 1997-2001       40.3   662.4      4124828     6642      11.881    9.065    15.573
 6  AD   Birth cohorts (Full Sibs) 2002-2006       45.9  1265.9      1703041     2844      14.752   10.642    20.45
 4  AD   Gender risk (Full Sibs)   Male-Male       28.3   646.8      9411567    12987      13.554   10.877    16.89
 3  AD   Gender risk (Full Sibs)   Male-Female     10.8   218.8      8892456    12343      12.168    8.278    17.884
 2  AD   Gender risk (Full Sibs)   Female-Male     28.7   791.5      8899609     4422      16.556   11.687    23.455
 1  AD   Gender risk (Full Sibs)   Female-Female   11.2   456.0      8371086     4386      24.743   15.724    38.936
;
run;

data annot3;
  length function $12;
  retain xsys ysys '2' hsys '2' size 0.9;
  set ad1(keep=sorder lower jamatxt rename=(sorder=y lower=x jamatxt=text));

  function='move';  x=x*0.90; y=y-0.1; output;
  function='label'; position='8'; output;
run;

data annot4;
  set annot1 annot3(in=annot3);
  if annot3 then do;
    size=0.37;
  end;
run;


filename  epsgraf "&slask1/JAMA_Fig3.eps";
goptions reset=all device=eps14x16 /*device=psepsf*/   display gsfname=epsgraf gsfmode=replace rotate=p
         ftext="Times-Roman"
         lfactor=4 htext=2.1 fontres=presentation noborder;


%inc saspgm(ssciplt3);
%ssciplt(data=ad1, order=sorder, gout=gseg, annotate=annot4, truncate=400,
type=2, boxwidth=0.035, hsymbol=1.50, boxcolor=black,
label=lbl, labelposition=LEFTMOST, hlabel=2.4, alabel=90, flabel=Times-Bold,
sublabel=sub, hsublabel=1.95, digits=5.1, fsublabel=Helvetica,
citext=RIGHTMOST, hcitext=2.0, xformat=myx.,
lower_offset=6, upper_offset=4, left_offset=12, right_offset=16,
xorder= %str(0.5 ,1, 2, 4, 8, 16, 32, 64, 128, 256, 512),
href=1 whref=2, vref=5 11 lvref=(2 2) wvref=(1 1));

filename epsgraf clear;
goptions reset=all;
