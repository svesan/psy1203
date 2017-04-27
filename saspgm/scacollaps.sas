%macro scacollaps(data=, var=, event=, missing=N, out=, obs=0, subject=, within=);
options nonotes;

  %if %bquote(&subject)= %then %do;
    %put ERROR: Parameter SUBJECT= is empty. Macro aborts.;
    %goto exit;
  %end;
  %if %bquote(&within)= %then %do;
    %put ERROR: Parameter WITHIN= is empty (ordering within SUBJECT). Macro aborts.;
    %goto exit;
  %end;
  %if %bquote(&event)= %then %do;
    %put ERROR: Parameter EVENT= is empty. Macro aborts.;
    %goto exit;
  %end;

  %if &obs>0 %then %let obs=obs=&obs;
  %else %let obs=;

  %put Note: Exclude all records with missing value on ANY of the VAR= variables;
  data __mcrtmp1;
  set &data(&obs keep=&subject &var &event &within);

  if "&missing"="N" then do;
    if &event LE .z
    %do i=1 %to 999;
      %let _x_=%scan(%bquote(&var), &i);
      %if %bquote(&_x_)^= %then %str( OR &_x_ LE .z);
      %else %if %bquote(&_x_)= %then %let i=999;
    %end;
    then delete;
  end;
  run;

%put Note: Now sorting the data in the by &subject, &within ....;
proc sort data=__mcrtmp1;by &subject &within;run;

data __mcrtmp2(drop=zfam) __mcrtmp3(keep=&subject zfam);
  length zfam $500;
  length order 3;
  retain order 0 zfam '';
  set __mcrtmp1;by &subject &within;
  if first.&subject then order=1;else order=order+1;

  if first.&subject then zfam='_';

  %do i=1 %to 999;
    %let _x_=%scan(%bquote(&event &var), &i);
    %if %bquote(&_x_)^= and &i=1 %then %str(zfam=trim(zfam)||compress(put(&_x_, z2.)) );
    %else %if %bquote(&_x_)^= and &i>1 %then %str(||compress(put(&_x_, z2.)) );
    %else %if %bquote(&_x_)= %then %let i=999;
  %end;
  ;

if length(left(trim(zfam)))>498 then put 'ERROR: Too many levels with SUBJECT';

  output __mcrtmp2;

  if last.&subject then output __mcrtmp3;

*  if order>10 then put "Warning: >10 within &subject levels. Please check." _n_= &subject= &within= order=;

run;

proc sort data=__mcrtmp3;by zfam;run;
data __mcrtmp4;
  length nfam 5;
  retain nfam 0;
  set __mcrtmp3;by zfam;
  if first.zfam then nfam=nfam+1;
run;
proc sort data=__mcrtmp4(keep=&subject nfam) out=__mcrtmp5 nodupkey;by &subject;run;

%put Note: Now combining the new subject variable NFAM with the original data;
data __mcrtmp6;
  merge __mcrtmp2 __mcrtmp5;
  by &subject;
run;

%put Note: Now collapsing and creating output dataset &out;
proc summary data=__mcrtmp6 nway;
  var &event;
  class nfam order &event &var;
  output out=&out(drop=_type_ _freq_) n=antal sum=sum_diag;
run;

proc datasets lib=work mt=data nolist;
  delete __mcrtmp1 - __mcrtmp6;
quit;

%exit:
%put Note: Macro finished execution;

options notes;
%mend;
