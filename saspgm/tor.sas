*------------------------------------------------------------------------------------------;
* Updated:                                                                                 ;
* -------                                                                                  ;
* 2002-12-09 : 1) Now when CLASS and VAR both empty all variables are transferred to CSV   ;
*              2) Check for format COMMA since this will result in problems.               ;
*              3) There will still be problems when format $kk. is used or kk.             ;
*              4) Version set to 1.1                                                       ;
* 2003-04-30 : 1) Send file to /other directory when DIR is empty. Now DIR is by default   ;
*                 empty.                                                                   ;
*              2) Added log message for saving the R-data                                  ;
*              3) Now default file is blank. When blank the same name as DATA is used      ;
*                                                                                          ;
* 2003-05-12 : 1) The same path for the read.csv command for all operating systems         ;
*              2) Warn about the as.numeric command                                        ;
*                                                                                          ;
* 2004-03-03 : 1) Added the parameter RFILE                                                ;
*              2) Now missing codes .A to .Z are recoded to .                              ;
*              3) Welcome message to the SAS log                                           ;
*              4) Version changed to 1.3                                                   ;
*                                                                                          ;
* 2004-03-09 : 1) CLASS variables with SAS format associated will be read as blank levels  ;
*                 in R. Now, additional R commands are printed to replace these blanks     ;
*                 with NA and also remove the blanks from the R levels associated.         ;
*              2) Source command is now printed with slash instead of back-slash           ;
*              3) Version set to 1.4                                                       ;
*                                                                                          ;
* 2004-09-13 : 1) Added dframe parameter                                                   ;
*              2) Version set to 1.5                                                       ;
*                                                                                          ;
* 2004-12-02 : 1) Fix to accept longer VAR and CLASS input using bquote                    ;
*              2) Version set to 1.6                                                       ;
*                                                                                          ;
* 2005-02-03 : 1) Changed length of txt variable in the M3 dataset from 1000 to 5000. Also ;
*                 declared length statements in the data _null_. See comment in code.      ;
*              2) Version set to 1.7                                                       ;
*                                                                                          ;
* 2005-02-03 : 1) Added the DATESHIFT parameter and management of date variables.          ;
*              2) Version set to 2.0                                                       ;
*                                                                                          ;
* 2005-02-21   1) Change "Warning: Recoding missing codes .A to .Z to . on variable" to    ;
*                 "Note: ..." instead                                                      ;
*                                                                                          ;
* 2005-04-29   1) Changed macro variable resolution to avoid SAS log message WARNING: The  ;
*                 quoted string currently being processed has become more than 262         ;
*                 characters long.... See comment "updated 29apr2005". This problem did    ;
*                 occur only when a large number of class variables were being processed   ;
*              2) Version set to 2.1                                                       ;
*                                                                                          ;
* 2005-06-07   1) Now valid for AIX as well                                                ;
*                                                                                          ;
* 2009-03-23   1) Now using directory R-Stata instead of other. If R-Stata not exist then  ;
*                 tries with other                                                         ;
*              2) utility macro sca2util replaced with ssutil                              ;
*                                                                                          ;
* 2009-03-24   1) Now called SS macro everywhere                                           ;
*                                                                                          ;
* 2010-06-01   1) Updated for Linux 64                                                     ;
*                                                                                          ;
* 2013-02-26   1) Added the save parameter and compress=T in R save function               ;
*              2) Temporarly changed length to $100 in m3 dataset. Takes too long time     ;
*                 for huge datasets                                                        ;
*              3) Version set to 2.5                                                       ;
*                                                                                          ;
*------------------------------------------------------------------------------------------;


%macro tor(__func__, data=_last_, class=, var=, dir=, file=, rfile=, dname=, dateshift=-3653,
           delete=Y, save=N) / des='SS macro TOR v2.5';

  %if %upcase(&__func__)=HELP %then %do;
    %put ;
    %put %str(----------------------------------------------------------------------------------------------);
    %put %str(Help on the SS utility macro TOR ver 2.3 at 2009-03-23);
    %put %str(----------------------------------------------------------------------------------------------);
    %put %str(The macro will assist in transfer SAS data to the R software. The macro will);
    %put %str(create a CSV file in the specified directory and print R code to the SAS log. Running the);
    %put %str(printed R code in R will read the CSV data into R. The resulting R object will);
    %put %str(be a data frame.);
    %put ;
    %put %str(The macro is defined with the following set of parameters:);
    %put %str( );
    %put %str(DATA.....= Mandatory. SAS dataset name to transfer to R);
    %put %str(CLASS....= Optional. SAS variables to transfer to R factor objects);
    %put %str(VAR......= Optional. SAS variables to transfer to R num or char objects);
    %put %str(DIR......= Mandatory. A operating system directory name where the CSV file will be stored);
    %put %str(FILE.....= Mandatory. A name for the CSV file);
    %put %str(RFILE....= Optional. A name for a file where the R-commands are stored. In the DIR directory);
    %put %str(DNAME....= Optional. A name for the R data frame);
    %put %str(DATESHIFT= Optional. Shift DATE variables. Variables in VAR= list with SAS formats DATE, YYMMDD);
    %put %str(                     or DDYYMM are shifted with this amount. When using the RFILE parameter this);
    %put %str(                     variable will then be set to Date class and treated as a date variable.);
    %put %str(                     Default DATESHIFT=-3653 since SAS count days since 01jan1960 and R count days);
    %put %str(                     since 01JAN1970.);
    %put %str( );
    %put %str(Example: '%tor(data=cost, class=mountper veh_type, var=lxacc_cost, dir=d:\slask\, file=cost.csv)' );
    %put %str(----------------------------------------------------------------------------------------------);
    %put ;
    %goto exit;
  %end;

  %local __rfile2 _slask_ _slask2_ __nc__ __nv__ i _antnvr_;

  %ssutil(___mn___=TOR, ___mt___=SS, ___mv___=2.5);

  %ssutil(__dsn__=&data, _exist_=Y,
            __lst__=&class &var, _vexist_=Y);

  %if &__err__=ERROR %then %goto exit;

  options nonotes;

  %if %bquote(&dir)= %then %do;
    %put Note: Parameter DIR is blank. Trying to use default directory.;
    data _null_;
      length x $1000;
      if fexist("saspgm") then do;
        x=tranwrd(pathname("saspgm"),'saspgm','R-Stata');

        if fileexist(x)=0 then do;
          put 'Error: Directory ' x ' not found. Trying with sub-directory "other".';
          x=tranwrd(pathname("saspgm"),'saspgm','other');
        end;

        if fileexist(x)=0 then do;
          put 'Error: Directory ' x ' not found. Macro aborts.';
          call symput('__err__','ERROR');
        end;
        else do;
          put 'Note: Sending .CSV file to directory ' x;
          call symput('dir',trim(x));
        end;
      end;
      else do;
        put 'Error: Fileref SASPGM is not allocated or associated directory not found. Macro aborts.';
        call symput('__err__','ERROR');
      end;
    run;
  %end;
  %if "&__err__"="ERROR" %then %goto exit;


  %if "&sysscp"="WIN" %then %do;
    %if "%substr(%qsysfunc(reverse(&dir)),1,1)" ne "\" %then %let dir=&dir\;
  %end;
  %else %if "&sysscp"="LINUX" or "&sysscp"="SUN 4" or "&sysscpl"="AIX" or "&sysscp"="LIN X64" %then %do;
    %if "%substr(%qsysfunc(reverse(&dir)),1,1)" ne "/" %then %let dir=&dir/;
  %end;

  *-- Check the CVS output file ;
  %if %bquote(&file) ne  %then %do;
    %if %scan(&file,2,.)= %then %do;
      %put;
      %put Warning: File extension not specified FILE=(&file). Extension DAT will be used (FILE=&file..DAT);
      %put;
      %let file=&file..DAT;
    %end;
  %end;
  %else %do;
    %put Note: FILE is empty. Using the DATA= as file name;
    %let file=&data..csv;
  %end;

  *-- Check the R commands file;
  %if %bquote(&rfile) ne  %then %do;
    %if %scan(&rfile,2,.)= %then %do;
      %put;
      %put Warning: File extension not specified FILE=(&file). Extension r will be used (FILE=&file..DAT);
      %put;
      %let rfile=&rfile..r;
    %end;
    %let __rfile2=file "&dir.&rfile" mod;
  %end;
  %else %let __rfile2=;

  %ssutil(___mc___=&class);

  proc contents data=&data(keep=&class &var) out=m0(keep=name type format) noprint;run;
  proc sql;
    create table m1 as select upcase(name) as name, type, format from m0;
  quit;

  %if %bquote(&class)= and %bquote(&var)= %then %do;
    %put Note: VAR and CLASS both empty. Transfer all variables.;
    data _null_;
      length vars $ 2000;
      retain vars '';
      set m1 end=eof;
      vars=trim(vars)||' '||trim(left(name));

      if eof then call symput('VAR',trim(vars));
    run;
  %end;

  data _null_;
    length txt $200 g1 $5 g2 $3;
    set m1 end=eof;
    if type=1 and format in ('DATE','DDMMYY','YYMMDD') then do;
      put 'Warning: Check that variable ' name ' is converted to proper date value in R';
    end;

    name=lowcase(name);

    if _n_=1 then g1='';
    else g1='","||';
    g2="'"||'"'||"'";

    if format='COMMA' then do;
      put 'WARNING: Format COMMA for variable ' name 'may result in problems'
          '         reading the data from Excel, R, OpenOffice or similar programs'
          '         The program may interpret the , as a new column. Running PROC DATASETS'
          '         to remove or change this format will solve the problem.' /;
    end;


    if format in ('DATE','DDMMYY','YYMMDD') then do;
      txt=g1||'trim(left(put('||trim(name)||' &dateshift ,best23.12)))';
    end;
    else if format ne '' then do;
      txt=g1||g2||'||trim(left(put('||trim(name)||','||trim(format)||'.)))||'||g2;
    end;
    else if type=2 then do;
      *-- character variable ;
      txt=g1||g2||'||trim(left('||trim(name)||'))||'||g2;
    end;
    else if type=1 then do;
      *-- numeric variable ;
      txt=g1||'trim(left(put('||trim(name)||',best23.12)))';
    end;
    else abort;

    call symput('__f'||compress(put(_n_,8.)), trim(txt) );

    call symput('__v'||compress(put(_n_,8.)), trim(tranwrd(name,'_','.')) );

    if eof then call symput('_antv_',compress(put(_n_,8.)) );

  run;

  *-- Recode missing codes to missing . values ;
  data _null_;
    retain _c_ 0;
    set m1(keep=name type) end=eof;
    if type=1 then do;
      put 'Note: Recoding missing codes .A to .Z to . on variable ' name;
      name=lowcase(name);
      _c_=_c_+1;

      __fmv='if '||trim(name)||' le .z then '||trim(name)||'=.;';
      call symput('__fmv'||compress(put(_c_,8.)), trim(__fmv));
    end;
    if eof then call symput('_antnvr_',compress(put(_c_,8.)));
  run;

  *-- Create the output. Stored in text variable to be outputted later;
  options missing='';
  data m3;
    keep txt;
    length txt $180;
    set &data(keep=&class &var);

    %if &_antnvr_>0 %then %do i=1 %to &_antnvr_;
      &&__fmv&i;
    %end;

    if _n_=1 then do;
      txt='"'||"&&__v1"||'"'
      %do i=2 %to &_antv_;
        ||',"'||"&&__v&i"||'"'
      %end;;
      output;
    end;

    txt=&&__f1
    %do i=2 %to &_antv_;
      || &&__f&i
    %end;;
    output;
  run;
  options missing='.';

  /*** The same syntax for both Linux, Unix and WIN svesan 030512
  %if "&sysscp"="WIN" %then %do;
    %let _slask_=%qsysfunc(tranwrd(&dir.&file,/,\));
    %let _slask2_=%qsysfunc(tranwrd(&dir.%qsysfunc(scan(&file,1,'.')).RData,/,\));
  %end;
  %else %if "&sysscp"="LINUX" or "&sysscp"="SUN 4" %then %do;
    %let _slask_=%qsysfunc(tranwrd(&dir.&file,\,/));
    %let _slask2_=%qsysfunc(tranwrd(&dir.%qsysfunc(scan(&file,1,'.')).RData,\,/));
  %end;
  ***/
  %let _slask_=%qsysfunc(tranwrd(&dir.&file,\,/));
  %let _slask2_=%qsysfunc(tranwrd(&dir.%qsysfunc(scan(&file,1,'.')).RData,\,/));

  *--------------------------------------------------------------------------------;
  * Output R code defining proper object type                                      ;
  *--------------------------------------------------------------------------------;

  %ssutil(___mc___=&class); %let __nc__=&_nmvar_;
  %ssutil(___mc___=&var);   %let __nv__=&_nmvar_;

  data m2;
    set m1(keep=name obs=1);
    %if &__nc__>0 %then %do i=1 %to &__nc__;
      name="%scan(&class,&i)"; name=upcase(name); intyp='class'; output;
    %end;
    %if &__nv__>0 %then %do i=1 %to &__nv__;
      name="%scan(&var,  &i)"; name=upcase(name); intyp='var  '; output;
    %end;
  run;

  proc sql;
    create table m4 as
    select lowcase(a.name) as name, a.type, a.format, b.intyp
      from m1 as a
      left join m2 as b
      on a.name = b.name
      order by b.intyp, name;
  quit;

  *-- Assign name for the R data frame name (not containing _);
  data _null_;
    if "&dname" ne "" then call symput('rdata',trim("&dname"));
    else call symput('rdata',trim(translate("&data",'.','_')));
  run;

  *-- Commands for reading the data in R;
  data _null_;
    length dt $9;
    %if %bquote(&rfile)^= %then %do;
      %put Note: Storing R commands in &dir.&rfile;
      file "&dir.&rfile";
      dt=put(date(),date9.);

      put "#--------------------------------------------------------------------";
      put "# File...: &dir.&rfile ";
      put "# Date...: " dt;
      put "# Purpose: Read the SAS dataset &data into R";
      put "#--------------------------------------------------------------------";
      put "&rdata <- read.csv(file=" '"' "&_slask_" '")';
    %end;

    %put Note: Include the data into R by running the code /;
    %put &rdata <- read.csv(file="&_slask_");
  run;

  data _null_;
    length txt $1000;  *-- Line added 03feb05 ;
    retain _chk_ 0;
    &__rfile2;;
    set m4;
    name=translate(name,'.','_');
    if intyp='class' then do;
      if format in ('DATE','DDMMYY','YYMMDD') then do;
        txt="class(&rdata.$"||trim(name)||') <- "Date"';
        put txt;
      end;
      txt="&rdata.$"||trim(name)||" <- as.factor(&rdata.$"||trim(name)||')';
      put txt;
    end;
    else if intyp='var' then do;
      if format ne '' and type=1 and "&rfile" eq "" then put 'WARNING: Treat ' name ' as numeric ? Format assigned. ' format=;

      if type=1 then do;
        if _chk_=0 then do;
          put ;
          put '#-- Warning: as.numeric may not translate to num as expected';
        end;
        txt="&rdata.$"||trim(name)||" <- as.numeric(&rdata.$"||trim(name)||')';
        put txt;
        if format in ('DATE','DDMMYY','YYMMDD') then do;
          txt="class(&rdata.$"||trim(name)||') <- "Date"';
          put txt;
        end;
      end;
      else if type=2 then do;
        txt="&rdata.$"||trim(name)||" <- as.character(&rdata.$"||trim(name)||')';
        put txt;
      end;
    end;

  run;


  *-- Now R class-variables will have blanks not NA. Fix this !;
  %if %bquote(class)^= %then %do;
    ** Row before updated 29apr2005 by SSANDIN ;

    data _null_;
      length gnu $60 txt $1000; *-- Added txt $1000 03feb05 ;
      &__rfile2;;
      set m4;
      if intyp='class' then do;
        name=translate(name,'.','_');
        gnu ='a$'||trim(name);
        txt=trim(gnu)||'['||trim(gnu)||'==" "] <- NA';
        txt=tranwrd(txt,'a$',"&rdata.$");
        put / txt;

        txt='levels('||trim(gnu)||')[levels('||trim(gnu)||')==" "] <- NA';
        txt=tranwrd(txt,'a$',"&rdata.$");
        put txt;
      end;
    run;

  %end;


  %if %bquote(&save)=Y %then %let save=;
  %else %let save=#;

  data _null_;
    &__rfile2;;
    put "&save.save(" "&rdata" ', file="' "&_slask2_" '", compress=T)';
  run;

  data _null_;
    file "&dir.&file" lrecl=24000;
    set m3;
    put txt;
  run;

  %*-- Now check how many rows were actually written ;
  data _null_;
    retain c 0;
    infile "&dir.&file" end=eof;
    informat txt $1.;
    input txt;
    if eof then do;
      put 'Note: ' c 'data lines and one line of column names have been written to output file';
    end;
    else c=c+1;
  run;


  *-- Change back slash to slash since needed by R ;
  data _null_;
    call symput('dir',trim(translate("&dir",'/','\')));
  run;


  %if %bquote(&rfile)^= %then %do;
    %put Note: Execute the R codes from R by issuing the command;
    %put %str(      source(file="&dir.&rfile"));
  %end;


  %if "&delete"="Y" %then %do;
    proc datasets lib=work mt=data nolist;
      delete m0 m1-m4;
    quit;
  %end;

  %EXIT:
    %put Note: Macro TOR finished execution;
    options notes;
%mend;
