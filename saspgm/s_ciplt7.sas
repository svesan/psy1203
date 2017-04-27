*-----------------------------------------------------------------------------;
* Study.......: PSY1001                                                       ;
* Name........: s_ciplt7.sas                                                  ;
* Date........: 2013-12-19                                                    ;
* Author......: svesan                                                        ;
* Purpose.....: Plot of RR and confidence intervals                           ;
* Note........: 130910 changed to PNG output. Removed crude.                  ;
* ............:                                                               ;
* Note........: 131219 added EPS figures again                                ;
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
/*
Crude   * Full Sib                 17973     1.313     14.333      13.085      15.7
Crude   * DZ Twin                    219     1.077    12.235      5.584      26.808
Crude     * MH Sib                  4448       1.2      4.979      3.906      6.347
Crude     * PH Sib                  4003     1.027      4.229      3.251      5.501
Crude * Cousin                      72436      1.39  2.723     2.45      3.025
*/
data p0;
drop txt slask1 slask2;
length lbl sub $30;
retain can_txt 'A' sub '';
informat txt $40.;
input txt 1-35 slask1 slask2 estimate lower upper;
lbl=scan(txt,1,'*');
sub=scan(txt,2,'*');
order=27-_n_;
cards;
Adjusted * Full Sib                17961     1.315    10.407     9.495      11.407
Adjusted * DZ Twin                 99999     99999     8.40382     3.85836   18.3042
Adjusted * MH Sib                  4446     1.207      3.295     2.581      4.205
Adjusted * PH Sib                  3999     1.012        2.87     2.21      3.728
Adjusted * Cousin                   72436     1.364    2.014     1.814      2.236
Full by Sex * Male-Male             6596      1.25    10.003     8.775      11.404
Full by Sex * Male-Female           2645     1.097    11.042     9.235      13.201
Full by Sex * Female-Male           6154     1.156      11.97     9.896      14.48
Full by Sex * Female-Female         2566     1.225    13.294     10.23      17.277
MH by Sex * Male-Male               1642     1.437       4.19     2.802      6.264
MH by Sex * Male-Female              669     0.967      4.732     2.943      7.608
MH by Sex * Female-Male             1503     1.029       5.35     3.244      8.822
MH by Sex * Female-Female            632     1.086     9.042     4.981      16.411
PH by Sex * Male-Male               1440     1.037      3.926     2.663      5.789
PH by Sex * Male-Female              623     0.984      3.063     1.594      5.888
PH by Sex * Female-Male             1345     1.111      5.214     3.048      8.919
PH by Sex * Female-Female            591     0.982     5.948     2.842      12.451
Cousins * Male-Male                26092     1.247     2.142     1.863      2.464
Cousins * Male-Female              11198     1.189      1.938     1.57      2.393
Cousins * Female-Male              24463     1.163     1.945     1.554      2.435
Cousins * Female-Female            10683     1.229     2.021     1.455      2.807
Birth Cohorts * Full Sib 1982-86     3554     1.072      7.955     6.421      9.856
Birth Cohorts * Full Sib 1987-91     8123     1.276      7.074     6.029      8.299
Birth Cohorts * Full Sib 1992-96     8520     1.185      7.808     6.807      8.956
Birth Cohorts * Full Sib 1997-2001   4661     1.128     8.559     7.233      10.129
Birth Cohorts * Full Sib 2002-2006   1806     1.043    11.188     8.944      13.994
;
run;

filename  pnggraf "&slask1/ci_asd_7.png";
goptions reset=all;
goptions dev=png300 xmax=12cm ymax=14cm xpixels=2200 ypixels=2600 lfactor=1.8
         display gsfname=pnggraf gsfmode=replace
         ftext="Thorndale AMT"
         htext=1 noborder;

*title1 'ASD Singletons and DZ Twins';

%ssciplt(data=p0, order=order, gout=gseg,
type=2, boxwidth=0.3, hsymbol=1.25,
label=lbl, labelposition=LEFTMOST, hlabel=2.0, flabel=Thorndale AMT/bold, alabel=90,
sublabel=sub, hsublabel=1.9, digits=4.2,
citext=RIGHTMOST, hcitext=1.8,
lower_offset=2, upper_offset=2, left_offset=12, right_offset=12,
xorder= %str(0.5, 1, 2, 4, 8, 16, 32),
vref=5.5  9.5 13.5 17.5 21.5 lvref=(2 2 2 2 2 2) wvref=(1 1 1 1 1 1));

filename pnggraf clear;
goptions reset=all;


*-- 131219 create eps files (again) for the jama submission ;
filename  epsgraf "&slask1/ci_asd_7.eps";
goptions reset=all device=eps14x16 display gsfname=epsgraf gsfmode=replace rotate=p
         ftext="hwpsl005"
         lfactor=4 htext=2.0 fontres=presentation noborder;

%ssciplt(data=p0, order=order, gout=gseg, /* annotate=cilabel, */
type=2, boxwidth=0.3, hsymbol=1.50,
label=lbl, labelposition=LEFTMOST, hlabel=2.1, flabel=hwpsl007, alabel=90,
sublabel=sub, hsublabel=1.8, digits=4.2, /* fsublabel=hwpsl005, */
citext=RIGHTMOST, hcitext=1.8,
lower_offset=2, upper_offset=2, left_offset=12, right_offset=12,
xorder= %str(0.5, 1, 2, 4, 8, 16, 32),
vref=5.5  9.5 13.5 17.5 21.5 lvref=(2 2 2 2 2 2) wvref=(1 1 1 1 1 1));

filename epsgraf clear;
goptions reset=all;


*-------------------------------------;
* Infantile autism                    ;
*-------------------------------------;
/*
Crude   * Full Sib                 17973     1.313     24.177     20.656      28.297
Crude   * DZ Twin                    219     1.077     28.783     8.754      94.641
Crude     * MH Sib                  4448       1.2      7.604     4.426      13.062
Crude     * PH Sib                  4003     1.027      4.323     2.166      8.628
Crude * Cousin                      72436      1.39    3.351     2.649      4.239
*/

data a0;
drop txt slask1 slask2;
length lbl sub $30;
retain can_txt 'A' sub '';
informat txt $40.;
input txt 1-35 slask1 slask2 estimate lower upper;
lbl=scan(txt,1,'*');
sub=scan(txt,2,'*');
order=27-_n_;
cards;
Adjusted * Full Sib                17961     1.315    14.952     12.758      17.524
Adjusted * DZ Twin                 99999     99999    16.97175    5.20353  55.35475
Adjusted * MH Sib                  4446     1.207      4.391     2.543      7.581
Adjusted * PH Sib                  3999     1.012      2.932     1.461      5.887
Adjusted * Cousin                   72436     1.364    2.264     1.794      2.857
Full by Sex * Male-Male             6596      1.25    14.673     11.793      18.256
Full by Sex * Male-Female           2645     1.097     13.026     8.892      19.081
Full by Sex * Female-Male           6154     1.156    17.951     12.695      25.385
Full by Sex * Female-Female         2566     1.225    26.714     17.087      41.765
MH by Sex * Male-Male               1642     1.437      8.398     4.047      17.426
MH by Sex * Male-Female              669     0.967      4.546     1.137      18.169
MH by Sex * Female-Male             1503     1.029      8.255     2.655      25.668
MH by Sex * Female-Female            632     1.086       6.756     0.929      49.12
PH by Sex * Male-Male               1440     1.037      4.374     1.631      11.728
PH by Sex * Male-Female              623     0.984       5.202     1.316      20.57
PH by Sex * Female-Male             1345     1.111      5.003     1.238      20.224
PH by Sex * Female-Female            591     0.982                   0     0      0
Cousins * Male-Male                26092     1.247     2.792     2.098      3.715
Cousins * Male-Female              11198     1.189     2.196     1.326      3.637
Cousins * Female-Male              24463     1.163     1.439     0.774      2.674
Cousins * Female-Female            10683     1.229     1.431     0.543      3.776
Birth Cohorts * Full Sib 1982-86     3554     1.072      13.864     7.897      24.338
Birth Cohorts * Full Sib 1987-91     8123     1.276      11.053     7.823      15.617
Birth Cohorts * Full Sib 1992-96     8520     1.185      10.249     7.759      13.537
Birth Cohorts * Full Sib 1997-2001   4661     1.128      12.522     9.571      16.384
Birth Cohorts * Full Sib 2002-2006   1806     1.043     16.005     11.641      22.005
;
run;

filename  pnggraf "&slask1/ci_ad_7.png";
goptions reset=all;
goptions dev=png300 xmax=12cm ymax=14cm xpixels=2200 ypixels=2600 lfactor=1.8
         display gsfname=pnggraf gsfmode=replace
         ftext="Thorndale AMT"
         htext=1 noborder;

*title1 'AD Singletons and DZ Twins';


%ssciplt(data=a0, order=order, gout=gseg,
type=2, boxwidth=0.3, hsymbol=1.25,
label=lbl, labelposition=LEFTMOST, hlabel=2.0, flabel=Thorndale AMT/bold, alabel=90,
sublabel=sub, hsublabel=1.9, digits=4.2,
citext=RIGHTMOST, hcitext=1.8,
lower_offset=2, upper_offset=2, left_offset=12, right_offset=12,
xorder= %str(0.5, 1, 2, 4, 8, 16, 32, 64, 128),
vref=5.5  9.5 13.5 17.5 21.5 lvref=(2 2 2 2 2 2) wvref=(1 1 1 1 1 1) );

filename epsgraf clear;
goptions reset=all;


*-- 131219 create eps files (again) for the jama submission ;
filename  epsgraf "&slask1/ci_ad_7.eps";
goptions reset=all device=eps14x16 display gsfname=epsgraf gsfmode=replace rotate=p
         ftext="hwpsl005"
         lfactor=4 htext=2.0 fontres=presentation noborder;

%ssciplt(data=a0, order=order, gout=gseg, /* annotate=cilabel, */
type=2, boxwidth=0.3, hsymbol=1.5,
label=lbl, labelposition=LEFTMOST, hlabel=2.1, flabel=hwpsl007, alabel=90,
sublabel=sub, hsublabel=1.8, digits=4.2, /* fsublabel=hwpsl005, */
citext=RIGHTMOST, hcitext=1.8,
lower_offset=2, upper_offset=2, left_offset=12, right_offset=12,
xorder= %str(0.5, 1, 2, 4, 8, 16, 32, 64, 128),
vref=5.5  9.5 13.5 17.5 21.5 lvref=(2 2 2 2 2 2) wvref=(1 1 1 1 1 1));

filename epsgraf clear;
goptions reset=all;


*-- Cleanup ------------------------------------------------------------------;
title1;footnote;
proc datasets lib=work mt=data nolist;
  delete p1 p2 p2_ad p2_mr  q1 q2 q2_ad q2_mr cols;
quit;

*-- End of File --------------------------------------------------------------;
