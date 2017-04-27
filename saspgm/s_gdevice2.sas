*-----------------------------------------------------------------------------;
* Study.......: PSY1001                                                       ;
* Name........: s_gdevice2.sas                                                ;
* Date........: 2012-01-17                                                    ;
* Author......: svesan                                                        ;
* Purpose.....: Create SAS EPS device                                         ;
* Note........: 140307 chaned original device to psepsf                       ;
*-----------------------------------------------------------------------------;
* Data used...:                                                               ;
* Data created:                                                               ;
*-----------------------------------------------------------------------------;
* OP..........: Linux/ SAS ver 9.03.01M0P060711                               ;
*-----------------------------------------------------------------------------;

*-- External programs --------------------------------------------------------;

*-- SAS macros ---------------------------------------------------------------;

*-- SAS formats --------------------------------------------------------------;

*-- Main program -------------------------------------------------------------;
proc sql noprint;
  select xpath into : slask1
  from sashelp.vextfl where upcase(fileref)='RESULT';
quit;
%let slask1=&slask1;

libname gdevice0 "&slask1";
filename grf "&slask1";

proc catalog cat=gdevice0.devices et=dev;
  delete eps14x12 eps13x12 eps14x16 eps20x16;
run;quit;

proc datasets lib=gdevice0 mt=cat nolist;
  delete devices;
run;quit;

data _null_;
  * xpix = (xmax/2.54)*DPI;
  xpix=(13.0/2.54)*1200; ypix=(12/2.54)*1200;put xpix= '   ' ypix=;
run;

proc gdevice nofs catalog=gdevice0.devices;
  copy psepsf from=sashelp.devices newname=eps14x12;
  modify eps14x12
    description='12*14 (x*y) cm gray EPS'
    hsize  = 13.70cm  vsize  =11.75cm
    horigin=  0.25cm  vorigin= 0.25cm
    xmax   = 14.00cm  ymax   =12.00cm
    xpixels= 7559     ypixels=6614
;

  copy psepsf from=sashelp.devices newname=eps13x12;
  modify eps13x12
    description='13*12 (x*y) cm gray EPS'
    hsize  = 12.70cm  vsize  =11.75cm
    horigin=  0.25cm  vorigin= 0.25cm
    xmax   = 13.00cm  ymax   =12.00cm
    xpixels= 6142     ypixels=5669
;

  copy psepsf from=sashelp.devices newname=eps20x16;
  modify eps20x16
    description='16*20 (x*y) cm color EPS'
    hsize  = 20.00cm  vsize  =16.00cm
    horigin=  0.45cm  vorigin= 0.45cm
    xmax   = 20.50cm  ymax   =16.50cm
    xpixels= 7559     ypixels=9448
;

  copy psepsf from=sashelp.devices newname=eps14x16;
   modify eps14x16
    description='14*16 (x*y) cm gray EPS'
     hsize  =13.75cm  vsize  = 15.70cm
     horigin= 0.45cm  vorigin=  0.45cm
     xmax   =14.25cm  ymax   = 16.25cm
     xpixels=6614     ypixels= 7559
;

quit;



*-- Cleanup ------------------------------------------------------------------;
title1;footnote;
proc datasets lib=work mt=data nolist;
delete _null_;
quit;

*-- End of File --------------------------------------------------------------;
