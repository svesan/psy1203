*-----------------------------------------------------------------------------;
* Study.......: PSY1203                                                       ;
* Name........:                                                               ;
* Date........: 2014-02-25                                                    ;
* Author......: svesan                                                        ;
* Purpose.....:                                                               ;
* Note........:                                                               ;
*-----------------------------------------------------------------------------;
* Data used...:                                                               ;
* Data created:                                                               ;
*-----------------------------------------------------------------------------;
* OP..........: Linux/ SAS ver 9.04.01M0P061913                               ;
*-----------------------------------------------------------------------------;
 
*-- External programs --------------------------------------------------------;
 
*-- SAS macros ---------------------------------------------------------------;
 
*-- SAS formats --------------------------------------------------------------;
 
*-- Main program -------------------------------------------------------------;
 
*-- Cleanup ------------------------------------------------------------------;
title1;footnote;
proc datasets lib=work mt=data nolist;
delete _null_;
quit;
 
*-- End of File --------------------------------------------------------------;
