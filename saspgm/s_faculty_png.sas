* file: s_faculty_png.sas;

*-- 2014-03-20 (a) Changed place on the cases and refcases in the input dataset ;
*              (b) Replaced RR with RRR for relative recurrence risk            ;
*              (c) Now label the figures _v2                                    ;

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
  x=95; y=98.5; function='move  '; output;
  function='label'; text='RRR  (95% CI)'; style='Thorndale/Bold AMT'; output;
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
17  ASD  Family Types              MZ Twin          6273.5  26.8      130720       96     152.952   56.677  412.767
16  ASD  Family Types              DZ Twin          805.1   54.5      385521      869       8.222    3.744   18.058
15  ASD  Family Types              Full Sib         829.0   48.8    35486922    76481      10.268    9.366   11.257
14  ASD  Family Types              MH Sib           491.6   94.1     4641500    16273       3.281    2.571    4.188
13  ASD  Family Types              PH Sib           370.9   84.7     4651888    15638       2.864    2.205    3.721
12  ASD  Family Types              Cousin           154.6   48.6   148053914   313739       2.008    1.809    2.229
10  ASD  Birth cohorts             1982-86          463.1   26.3     8750181    14467       7.336    5.905    9.113
 9  ASD  Birth cohorts             1987-91          728.2   45.4    12268494    24580       6.618    5.634    7.775
 8  ASD  Birth cohorts             1992-96          1013.9  62.8     8650801    21206       7.296    6.347    8.387
 7  ASD  Birth cohorts             1997-2001        962     71.1     4116561    11743       8.129    6.857    9.637
 6  ASD  Birth cohorts             2002-2006        1337.8  64.4     1700884     4485      10.402    8.262   13.096
 4  ASD  Gender risk               Male-Male        1035.5  67.2     9378760    28587       9.423    8.255   10.756
 3  ASD  Gender risk               Male-Female      512     28.2     8871116    27527      10.424    8.702   12.487
 2  ASD  Gender risk               Female-Male      1254.4  67.9     8878053    10045      11.116    9.199   13.433
 1  ASD  Gender risk               Female-Female    687.8   29.8     8358993    10323      12.541    9.632   16.331
;
run;

data annot3;
  length function $12;
  retain xsys ysys '2' hsys '2' size 0.8;
  set asd1(keep=sorder lower jamatxt rename=(sorder=y lower=x jamatxt=text));
/*
  function='move';  x=x*0.90; y=y-0.1; output;
  function='label'; position='8'; output;
*/
run;

data annot4;
  set annot1 ;
  if annot3 then do;
    size=0.37;
  end;
run;


filename  epsgraf "&slask1/faculty_Fig2_v2.png";
*options reset=all device=eps14x16 /*device=psepsf*/   display gsfname=epsgraf gsfmode=replace rotate=p
         ftext="Times-Roman"
         lfactor=4 htext=2.1 fontres=presentation noborder;
goptions reset=all device=png300 display gsfname=epsgraf gsfmode=replace rotate=p
         htext=1.6 ftext="Thorndale AMT";


%inc saspgm(ssciplt3);
%ssciplt(data=asd1, order=sorder, gout=gseg, annotate=annot4,
type=2, boxwidth=0.4, hsymbol=1.10, boxcolor=LIGB,
label=lbl, labelposition=LEFTMOST, hlabel=2.6, alabel=90, flabel=Thorndale/Bold AMT,
sublabel=sub, hsublabel=2.2, digits=5.1, fsublabel=Helvetica,
citext=RIGHTMOST, hcitext=2.2, xformat=myx.,
lower_offset=6, upper_offset=4, left_offset=3, right_offset=12,
xorder= %str(0.5 ,1, 2, 4, 8, 16, 32, 64, 128, 256, 512),
href=1 whref=2, vref=5 11 lvref=(2 2) wvref=(1 1));

filename epsgraf clear;
goptions reset=all;
