*-----------------------------------------------------------------------------;
* Study.......: PSY1203                                                       ;
* Name........: s_alv1.sas                                                    ;
* Date........: 2013-06-03                                                    ;
* Author......: svesan                                                        ;
* Purpose.....: Run all SAS programs needed for the study                     ;
* Note........: Cox regression analysis is done in R. Plotting of the HRs     ;
* ............: are then done in SAS                                          ;
*-----------------------------------------------------------------------------;
* Data used...:                                                               ;
* Data created:                                                               ;
*-----------------------------------------------------------------------------;
* OP..........: Linux/ SAS ver 9.03.01M2P081512                               ;
*-----------------------------------------------------------------------------;

*-- External programs --------------------------------------------------------;

*-- SAS macros ---------------------------------------------------------------;

*-- SAS formats --------------------------------------------------------------;

*-- Main program -------------------------------------------------------------;

*-----------------------------------------------------------------------------;
* Data management                                                             ;
*-----------------------------------------------------------------------------;
%inc saspgm(s_oracle);   *-- Create libname connection to Oracle;

%inc saspgm(s_fmt1);     *-- Create SAS formats                 ;

%inc saspgm(s_dmhosp);   *-- Create tmpdsn.asd_diag with ASD cases;

%inc saspgm(s_dmpsych4); *-- Create tmpdsn.psych_first_diag and tmpdsn.psych_diag
                             for psychiatric history ;

%inc saspgm(s_dmgp1);    *-- Create tmpdsn.grandparents;

*-- Note: s_dm21 call the program s_dmcousin3.sas ;
%inc saspgm(s_dm22);     *-- Create analysis datasets and R data frames ;



*-----------------------------------------------------------------------------;
* Summary statistics                                                          ;
*-----------------------------------------------------------------------------;
%inc saspgm(s_table1b);  *-- Data for table 1 ;


*-----------------------------------------------------------------------------;
* Create R data frames                                                        ;
*-----------------------------------------------------------------------------;
data _null_;
  call system('R CMD BATCH /home/svesan/ki/ABS/mep/sasproj/PSY/PSY1203/R-Stata/psy1203_B.R');
run;

data _null_;
  call system('R CMD BATCH /home/svesan/ki/ABS/mep/sasproj/PSY/PSY1203/R-Stata/psy1203_cousin_B.R');
run;

*-----------------------------------------------------------------------------;
* Run the R program for stratified cox regression                             ;
*-----------------------------------------------------------------------------;
data _null_;
  call system('R CMD BATCH /home/svesan/ki/ABS/mep/sasproj/PSY/PSY1203/R-Stata/s_psy1203_cox_nocousins_04.R');
run;


*-----------------------------------------------------------------------------;
* Calculate tetrachoric correlations and data for Ralfs heritability          ;
*-----------------------------------------------------------------------------;
%inc saspgm(s_dataralf130604); *-- Calculate tetrachoric correlations and data for Ralf ;


*-----------------------------------------------------------------------------;
* Figures                                                                     ;
*-----------------------------------------------------------------------------;
*%inc saspgm(s_gdevice);   *-- Create SAS graph device;

*%inc saspgm(s_ciplt2);    *-- Confidence interval bar charts. Note data in the program;

*-- Cleanup ------------------------------------------------------------------;
title1;footnote;
proc datasets lib=work mt=data nolist;
delete _null_;
quit;

*-- End of File --------------------------------------------------------------;
