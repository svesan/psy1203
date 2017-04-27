*-----------------------------------------------------------------------------;
* Study.......: PSY1001                                                       ;
* Name........: s_ciplt1.sas                                                  ;
* Date........: 2013-02-13                                                    ;
* Author......: svesan                                                        ;
* Purpose.....: Plot of RR and confidence intervals                           ;
* Note........:                                                               ;
* ............:                                                               ;
*-----------------------------------------------------------------------------;
* Data used...: comb_ivc_all comb_ivc_notwin                                  ;
* Data created:                                                               ;
*-----------------------------------------------------------------------------;
* OP..........: Linux/ SAS ver 9.03.01M0P060711                               ;
*-----------------------------------------------------------------------------;

*-- External programs --------------------------------------------------------;
%inc saspgm(s_gdevice);

%inc saspgm(ssciplt2);

*-- SAS macros ---------------------------------------------------------------;

*-- SAS formats --------------------------------------------------------------;

*-- Main program -------------------------------------------------------------;

%let slask1=/home/svesan/ki/AAA/AAA_Research/sasproj/PSY/PSY1203/sasout;

*-------------------------------------;
* ASD                                 ;
*-------------------------------------;
data asd1;
drop txt slask1 slask2;
length lbl sub $30;
retain can_txt 'A' sub '';
informat txt $40.;
input txt 1-35 slask1 slask2 estimate lower upper;
lbl=scan(txt,1,'*');
sub=scan(txt,2,'*');
order=25-_n_;
if index(lowcase(txt),'twin')>0 then delete;
cards;
Overall * Full and half sib        26688      1.32    10.82        9.97     11.75
Overall * Full sibs                18140      1.31   14.37        13.13     15.74
Overall * Full-Adj                 18140      1.31    10.44        9.52     11.43
Half sibs * MH                      4500       1.2      4.93        3.87     6.28
Half sibs * PH                      4048      1.03       4.3        3.31     5.58
Half sibs * MH Adj                  4500       1.2      3.34        2.62     4.26
Half sibs * PH Adj                  4048         1      2.92        2.26     3.78
Full Sib by Sex * Male-Male         6673      1.25     9.99        8.77     11.38
Full Sib by Sex * Male-Female       2684       1.1     10.89        9.1     13.03
Full Sib by Sex * Female-Male       6206      1.15    11.98        9.92     14.48
Full Sib by Sex * Female-Female     2577      1.23   13.43        10.33     17.45
MH by Sex * Male-Male               1675      1.43      4.21        2.83     6.25
MH by Sex * Male-Female              671      0.97       4.73        2.94     7.6
MH by Sex * Female-Male             1517      1.03      5.06        3.02     8.47
MH by Sex * Female-Female            637      1.09     9.02        4.97     16.38
PH by Sex * Male-Male               1454      1.04      3.93        2.66     5.79
PH by Sex * Male-Female              630      0.99       3.4        1.83     6.34
PH by Sex * Female-Male             1363      1.11      5.21        3.05     8.92
PH by Sex * Female-Female            601      0.98      5.87        2.8     12.29
Birth Cohorts * Full Sib 1982-86    3559      1.07      7.88        6.36     9.77
Birth Cohorts * Full Sib 1987-91    8162      1.28       7.1        6.06     8.34
Birth Cohorts * Full Sib 1992-96    8508      1.18       7.75        6.75     8.9
Birth Cohorts * Full Sib 1997-2001  4642      1.13      8.33        7.02     9.88
Birth Cohorts * Full Sib 2002-2006  1817      1.04       11        8.79     13.78
;
run;



filename  epsgraf "&slask1/ci_asd_2.eps";
goptions reset=all device=eps14x16 display gsfname=epsgraf gsfmode=replace rotate=p
         ftext="hwpsl005"
         lfactor=4 htext=2.0 fontres=presentation noborder;

title1 'Recurrence risk ASD';


%ssciplt(data=asd1, order=order, gout=gseg, /* annotate=cilabel, */
type=2, boxwidth=0.3, hsymbol=1.60,
label=lbl, labelposition=LEFTMOST, hlabel=2.0, flabel=hwpsl007, alabel=90,
sublabel=sub, hsublabel=2.0, digits=4.2, /* fsublabel=hwpsl005, */
citext=RIGHTMOST, hcitext=2.0,
lower_offset=4, upper_offset=4, left_offset=2, right_offset=12,
xorder= %str(0.5 ,1, 2, 4, 8, 16, 32, 64),
vref=5.5 9.5 13.5 17.5 21.5 lvref=(2 2 2 2 2) wvref=(1 1 1 1 1));

filename epsgraf clear;
goptions reset=all;


*-------------------------------------;
* AD                                  ;
*-------------------------------------;
data ad1;
drop txt slask1 slask2;
length lbl sub $30;
retain can_txt 'A' sub '';
informat txt $40.;
input txt 1-35 slask1 slask2 estimate lower upper;
lbl=scan(txt,1,'*');
sub=scan(txt,2,'*');
order=25-_n_;
if index(lowcase(txt),'twin')>0 then delete;
cards;
Overall * Full and half sib          10414     1.04        18.13     15.65    20.99
Overall * Full sib                   7338      1.04        24.28     20.74    28.41
Overall * Full-Adj                   7338      1.05        15.06     12.85    17.64
Half sibs * MH                       1594      1.13        7.57     4.41    13
Half sibs * PH                       1482      0.98        4.31     2.16    8.58
Half sibs * MH Adj                   1594      1.13        4.49     2.62    7.72
Half sibs * PH Adj                   1482      0.99        2.95     1.47    5.89
Full Sib by Sex * Male-Male          2779      1           14.56     11.71    18.12
Full Sib by Sex * Male-Female        990       0.99        13.06     8.91    19.13
Full Sib by Sex * Female-Male        2610      1.07        17.96     12.7    25.4
Full Sib by Sex * Female-Female      959       1.01        27.07     17.31    42.33
MH by Sex * Male-Male                610       1.23        8.32     4.01    17.28
MH by Sex * Male-Female              234       0.99        4.45     1.11    17.77
MH by Sex * Female-Male              535       1           8.26     2.66    25.66
MH by Sex * Female-Female            215       1.02        6.84     0.94    49.75
PH by Sex * Male-Male                529       1           4.44     1.66    11.88
PH by Sex * Male-Female              217       0.97        5.22     1.32    20.63
PH by Sex * Female-Male              515       1.01        4.95     1.23    20.02
PH by Sex * Female-Female            221       0           0     0    0
Birth Cohorts * Full Sib 1982-86     824       0.97        12.69     7.05    22.82
Birth Cohorts * Full Sib 1987-91     2515      1.04        11.16     7.9    15.77
Birth Cohorts * Full Sib 1992-96     3332      1.03        10.38     7.86    13.71
Birth Cohorts * Full Sib 1997-2001   2477      0.98        11.7     8.86    15.46
Birth Cohorts * Full Sib 2002-2006   1266      1.07        16.07     11.69    22.1
;
run;



filename  epsgraf "&slask1/ci_ad_2.eps";
goptions reset=all device=eps14x16 display gsfname=epsgraf gsfmode=replace rotate=p
         ftext="hwpsl005"
         lfactor=4 htext=2.0 fontres=presentation noborder;

title1 'Recurrence risk AD';

%ssciplt(data=ad1, order=order, gout=gseg, /* annotate=cilabel, */
type=2, boxwidth=0.3, hsymbol=1.60,
label=lbl, labelposition=LEFTMOST, hlabel=2.0, flabel=hwpsl007, alabel=90,
sublabel=sub, hsublabel=2.0, digits=4.2, /* fsublabel=hwpsl005, */
citext=RIGHTMOST, hcitext=2.0,
lower_offset=4, upper_offset=4, left_offset=2, right_offset=12,
xorder= %str(0.5 ,1, 2, 4, 8, 16, 32, 64),
vref=5.5 9.5 13.5 17.5 21.5 lvref=(2 2 2 2 2) wvref=(1 1 1 1 1));

filename epsgraf clear;
goptions reset=all;



*-------------------------------------;
* ASD exposure from older sib only    ;
*-------------------------------------;

data oldsib1;
drop txt slask1 slask2;
length lbl sub $30;
retain can_txt 'A' sub '';
informat txt $40.;
input txt 1-35 slask1 slask2 estimate lower upper;
lbl=scan(txt,1,'*');
sub=scan(txt,2,'*');
order=25-_n_;
if index(lowcase(txt),'twin')>0 then delete;
cards;
Overall * Full and half sib        12427      1.17   11.759      10.646      12.989
Overall * Full sib                  8303     1.164   15.898      14.225      17.768
Overall * Full-Adj                  8303     1.164   11.984      10.712      13.406
Half sibs * MH                      2150     1.144        4.49      3.316      6.08
Half sibs * PH                      1974     1.064      4.663      3.426      6.348
Half sibs * MH Adj                  2150     1.134      3.349      2.474      4.535
Half sibs * PH Adj                  1974     1.026      3.543      2.614      4.801
Full Sib by Sex * Male-Male         2997      1.15    12.28      10.478      14.393
Full Sib by Sex * Male-Female       1285      1.04     12.115      9.63      15.242
Full Sib by Sex * Female-Male       2817     1.076    12.487      9.737      16.012
Full Sib by Sex * Female-Female     1204     1.246   14.271      10.024      20.317
MH by Sex * Male-Male                843     1.237      4.797      3.154      7.296
MH by Sex * Male-Female              284     1.005      4.968      2.637      9.359
MH by Sex * Female-Male              747     1.027      3.139      1.475      6.677
MH by Sex * Female-Female            276     1.018     4.459      1.646      12.075
PH by Sex * Male-Male                718     1.034      4.796      3.114      7.387
PH by Sex * Male-Female              290     1.016       4.25      2.093      8.634
PH by Sex * Female-Male              701     1.175      4.563      2.317      8.984
PH by Sex * Female-Female            265     1.016     4.833      1.786      13.079
Birth Cohorts * Full Sib 1982-86     579     1.001    12.239      7.534      19.882
Birth Cohorts * Full Sib 1987-91    3190     1.081     8.567      6.908      10.623
Birth Cohorts * Full Sib 1992-96    4446     1.102      8.239      6.987      9.716
Birth Cohorts * Full Sib 1997-2001  2821     1.076     8.695      7.219      10.473
Birth Cohorts * Full Sib 2002-2006  1391     1.054    10.285      8.097      13.064
;
run;



filename  epsgraf "&slask1/ci_oldsib_2.eps";
goptions reset=all device=eps14x16 display gsfname=epsgraf gsfmode=replace rotate=p
         ftext="hwpsl005"
         lfactor=4 htext=2.0 fontres=presentation noborder;

title1 'Recurrence risk ASD. Older sibling only';


%ssciplt(data=oldsib1, order=order, gout=gseg, /* annotate=cilabel, */
type=2, boxwidth=0.3, hsymbol=1.60,
label=lbl, labelposition=LEFTMOST, hlabel=2.0, flabel=hwpsl007, alabel=90,
sublabel=sub, hsublabel=2.0, digits=4.2, /* fsublabel=hwpsl005, */
citext=RIGHTMOST, hcitext=2.0,
lower_offset=4, upper_offset=4, left_offset=2, right_offset=12,
xorder= %str(0.5 ,1, 2, 4, 8, 16, 32, 64),
vref=5.5 9.5 13.5 17.5 21.5 lvref=(2 2 2 2 2) wvref=(1 1 1 1 1));

filename epsgraf clear;
goptions reset=all;



*-- Cleanup ------------------------------------------------------------------;
title1;footnote;
proc datasets lib=work mt=data nolist;
  delete p1 p2 p2_ad p2_mr  q1 q2 q2_ad q2_mr cols;
quit;

*-- End of File --------------------------------------------------------------;
