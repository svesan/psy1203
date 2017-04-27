*-----------------------------------------------------------------------------;
* Study.......: PSY1001                                                       ;
* Name........: s_ciplt4.sas                                                  ;
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
data p0;
drop txt slask1 slask2;
length lbl sub $30;
retain can_txt 'A' sub '';
informat txt $40.;
input txt 1-35 slask1 slask2 estimate lower upper;
lbl=scan(txt,1,'*');
sub=scan(txt,2,'*');
order=39-_n_;
cards;
Crude   * Full                     17973     1.313     14.333      13.085      15.7
Crude   * DZ Twin                    219     1.077    12.235      5.584      26.808
Crude     * MH                      4448       1.2      4.979      3.906      6.347
Crude     * PH                      4003     1.027      4.229      3.251      5.501
Crude * Cousin                      9999      9999      2.71        2.52     2.9
Adjusted * Full-Adj1                17973     1.295     10.773      9.84      11.794
Adjusted * Full-Adj2                17973     1.308    10.917      9.964      11.961
Adjusted * Full-Adj3                17973     1.318    10.452      9.536      11.457
Adjusted * Full-Adj4                17973     1.311     10.74      9.801      11.768
Adjusted * DZ-Adj                     219     1.055     8.502      3.902      18.526
Adjusted * MH Adj                   4448      1.18         3.537      2.78      4.5
Adjusted * PH Adj                   4003     1.014      3.017      2.323      3.919
Adjusted * Cousin                   9999     99999      1.98        1.84     2.13
Full by Sex * Male-Male         6604     1.249     10.018      8.79      11.418
Full by Sex * Male-Female       2648     1.098    10.927      9.134      13.073
Full by Sex * Female-Male       6159     1.157    11.967      9.893      14.477
Full by Sex * Female-Female     2562     1.225   13.356      10.277      17.357
MH by Sex * Male-Male               1648       1.4       2.994      2.024      4.43
MH by Sex * Male-Female              667     0.964      3.642      2.267      5.851
MH by Sex * Female-Male             1500     1.019      3.435      2.054      5.744
MH by Sex * Female-Female            633     1.086     6.497      3.578      11.799
PH by Sex * Male-Male               1440     1.023       2.79      1.897      4.104
PH by Sex * Male-Female              625     0.981        2.306      1.2      4.429
PH by Sex * Female-Male             1346     1.122      3.675      2.142      6.305
PH by Sex * Female-Female            592     0.971      4.192      2.009      8.746
Birth Cohorts * Full Sib 1982-86    2368     1.076    10.146      7.877      13.069
Birth Cohorts * Full Sib 1987-91    5760     1.301     9.681      8.164      11.481
Birth Cohorts * Full Sib 1992-96    5652     1.188    10.783      9.288      12.519
Birth Cohorts * Full Sib 1997-2001  3038     1.143     10.978      8.973      13.43
Birth Cohorts * Full Sib 2002-2006  1155     1.051    18.162      13.91      23.713
ParenalAge * Full Sib Old Fa        1928      1.14     9.899      7.898      12.407
ParenalAge * Full Sib Yng Fa       16045     1.309    10.774      9.765      11.887
ParenalAge * Full Sib Old Ma        2282      1.18    11.095      9.009      13.664
ParenalAge * Full Sib Yng Ma       15691     1.263    10.621      9.626      11.719
PsychHist * Full Sib Fa Psych        701     1.326      7.551      5.006      11.39
PsychHist * Full Sib Fa NoPsych    17272     1.294     10.831      9.87      11.885
PsychHist * Full Sib Ma Psych        869     1.358      9.397      6.87      12.855
PsychHist * Full Sib Ma NoPsych    17104     1.287    10.551      9.598      11.598
;
run;

filename  epsgraf "&slask1/ci_asd_4.eps";
goptions reset=all device=eps14x16 display gsfname=epsgraf gsfmode=replace rotate=p
         ftext="hwpsl005"
         lfactor=4 htext=2.0 fontres=presentation noborder;

title1 'ASD Singletons and DZ Twins';


%ssciplt(data=p0, order=order, gout=gseg, /* annotate=cilabel, */
type=2, boxwidth=0.3, hsymbol=1.50,
label=lbl, labelposition=LEFTMOST, hlabel=1.7, flabel=hwpsl007, alabel=90,
sublabel=sub, hsublabel=1.7, digits=4.2, /* fsublabel=hwpsl005, */
citext=RIGHTMOST, hcitext=1.7,
lower_offset=2, upper_offset=2, left_offset=12, right_offset=12,
xorder= %str(0.5, 1, 2, 4, 8, 16, 32),
vref=4.5 8.5 13.5 17.5 21.5 25.5 33.5 lvref=(2 2 2 2 2 2  2 2) wvref=(1 1 1 1 1 1 1 1));

filename epsgraf clear;
goptions reset=all;


*-------------------------------------;
* Infantile autism                    ;
*-------------------------------------;
data a0;
drop txt slask1 slask2;
length lbl sub $30;
retain can_txt 'A' sub '';
informat txt $40.;
input txt 1-35 slask1 slask2 estimate lower upper;
lbl=scan(txt,1,'*');
sub=scan(txt,2,'*');
order=37-_n_;
cards;
Crude   * Full                      7275     1.043   24.178      20.658      28.299
Crude   * DZ Twin                    101      1.07    28.075      8.523      92.475
Crude     * MH                      1575     1.131     7.582      4.413      13.025
Crude     * PH                      1464     0.988      4.304      2.157      8.589
Adjusted * Full-Adj1                 7275     1.024   15.676      13.409      18.326
Adjusted * Full-Adj2                 7275     1.038   15.813      13.507      18.513
Adjusted * Full-Adj3                 7275     1.043     15.05      12.848      17.63
Adjusted * Full-Adj4                 7275     1.041   15.409      13.158      18.046
Adjusted * DZ-Adj                     101     1.054    17.029      5.205      55.715
Adjusted * MH Adj                    1575     1.119       4.935      2.88      8.457
Adjusted * PH Adj                   1464     0.992      2.996      1.499      5.987
Full by Sex * Male-Male             2745     1.001   14.661      11.786      18.237
Full by Sex * Male-Female            983      0.99    13.009      8.881      19.057
Full by Sex * Female-Male           2591     1.075   17.975      12.711      25.417
Full by Sex * Female-Female          956     1.012   26.773      17.124      41.859
MH by Sex * Male-Male                602     1.199     5.104      2.477      10.517
MH by Sex * Male-Female              230     0.962     3.212      0.819      12.602
MH by Sex * Female-Male              529     1.015     5.457      1.738      17.138
MH by Sex * Female-Female            214     1.023      4.634      0.634      33.86
PH by Sex * Male-Male                526      1.01      2.953      1.098      7.945
PH by Sex * Male-Female              216     0.987     3.768      0.943      15.057
PH by Sex * Female-Male              507     1.013     3.573      0.883      14.468
PH by Sex * Female-Female            215         0       .          0      0      0
Birth Cohorts * Full Sib 1982-86     587     0.947     13.762      6.65      28.481
Birth Cohorts * Full Sib 1987-91    1821     1.043    16.503      11.659      23.36
Birth Cohorts * Full Sib 1992-96    2344     1.028    12.979      9.616      17.519
Birth Cohorts * Full Sib 1997-2001  1706      0.99   15.472      11.479      20.854
Birth Cohorts * Full Sib 2002-2006   817     1.021   25.344      18.079      35.528
ParenalAge * Full Sib Old Fa         971     1.068    13.642      9.357      19.889
ParenalAge * Full Sib Yng Fa        6304     1.014    15.735      13.254      18.68
ParenalAge * Full Sib Old Ma        1107     1.059   16.883      11.982      23.789
ParenalAge * Full Sib Yng Ma        6168     0.984    15.219      12.803      18.09
PsychHist * Full Sib Fa Psych        268     1.007    12.437      6.122      25.267
PsychHist * Full Sib Fa NoPsych     7007     1.026     15.71      13.385      18.44
PsychHist * Full Sib Ma Psych        413     1.151      14.783      9.1      24.014
PsychHist * Full Sib Ma NoPsych     6862     1.017    15.03      12.734      17.741
;
run;


filename  epsgraf "&slask1/ci_ad_4.eps";
goptions reset=all device=eps14x16 display gsfname=epsgraf gsfmode=replace rotate=p
         ftext="hwpsl005"
         lfactor=4 htext=2.0 fontres=presentation noborder;

title1 'AD Singletons and DZ twins';

%ssciplt(data=a0, order=order, gout=gseg, /* annotate=cilabel, */
type=2, boxwidth=0.3, hsymbol=1.50,
label=lbl, labelposition=LEFTMOST, hlabel=1.7, flabel=hwpsl007, alabel=90,
sublabel=sub, hsublabel=1.7, digits=4.2, /* fsublabel=hwpsl005, */
citext=RIGHTMOST, hcitext=1.7,
lower_offset=2, upper_offset=2, left_offset=12, right_offset=12,
xorder= %str(0.5, 1, 2, 4, 8, 16, 32, 64), truncate=64,
vref=4.5 8.5 13.5 17.5 21.5 25.5 32.5 lvref=(2 2 2 2 2 2  2 2) wvref=(1 1 1 1 1 1 1 1));

filename epsgraf clear;
goptions reset=all;


*-- Cleanup ------------------------------------------------------------------;
title1;footnote;
proc datasets lib=work mt=data nolist;
  delete p1 p2 p2_ad p2_mr  q1 q2 q2_ad q2_mr cols;
quit;

*-- End of File --------------------------------------------------------------;
