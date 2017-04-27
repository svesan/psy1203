#program build on jama_rev_2.R

library(doBy)

setwd("/home/svesan/ki/AAA/AAA_Research/sasproj/PSY/PSY1203/R-Stata/")
#setwd("/home/svesan/ki/ABS/mep/sasproj/PSY/PSY1203/R-Stata/")

load("psy1203_B.RData")


recur.x0 = subset(psy1203B)

#-- Remove multiple birth among F and half sibs
recur.x1 = subset(recur.x0, subset=(multiple=="Yes" & ft=="F")==F)
recur.x1 = subset(recur.x1, subset=(multiple=="Yes" & ft=="PH")==F)
recur.x1 = subset(recur.x1, subset=(multiple=="Yes" & ft=="MH")==F)

rm(recur.x0, psy1203B);gc();gc();

#- doBy require a factor and do not allow the factor() function to be applied in the call
recur.x1$asd.exp = factor(recur.x1$asd.exp)
recur.x1$pyear   = recur.x1$exit-recur.x1$entry

recur.x1 = recur.x1[(names(recur.x1) %in% c("asd.exp", "cens", "entry", "exit", "pyear", "ft", "outcome","bc","sex1","sex2"))==TRUE]
gc()

#lapply(splitBy(~outcome, data=recur.x1[,c(1,3,8)]) ,table(asd.exp,cens))
#lapplyBy(~ft, data=recur.x1, function(d) table(d$asd.exp,d$cens))
#lapplyBy(~ft, data=recur.x1, function(d) sum(1-d$cens))

recur.x2=subset(recur.x1, subset=outcome=="ASD");

#-- Cases, Person year and Rate by 100,000 for each family type
lapplyBy(~ft, data=recur.x2, function(d) c(sum(1-d$cens),sum(d$pyear),round(100000*sum(1-d$cens)/sum(d$pyear),digits=1) ))

#-- Cases, Person year and Rate by 100,000 for each family type
v = lapplyBy(~ft+asd.exp, data=recur.x2, function(d) c(sum(1-d$cens),sum(d$exit-d$entry),round(100000*sum(1-d$cens)/sum(d$exit-d$entry),digits=1) ))

v

v$"MZ|1"[3]/v$"MZ|0"[3]
v$"DZ|1"[3]/v$"DZ|0"[3]
v$"F|1"[3]/v$"F|0"[3]
v$"MH|1"[3]/v$"MH|0"[3]
v$"PH|1"[3]/v$"PH|0"[3]

#-- Results
#-- $F
#-- [1]    17961.0 35563403.2       50.5
#-- 
#-- $MH
#-- [1]    4446.0 4657773.2      95.5
#-- 
#-- $PH
#-- [1]    3999.0 4667526.5      85.7
#-- 
#-- $MZ
#-- [1]     41.0 130816.4     31.3
#-- 
#-- $DZ
#-- [1]    217.0 386390.6     56.2

#-----------------------------------------------------
# In sub-groups of sex and birth cohorts 
# All calculations in sub-groups are for full siblings 
#-----------------------------------------------------
recur.x3 = subset(recur.x2, subset=ft=="F")

subr = function(data=subs,txt) {
  writeLines(paste(txt))

  #-- Cases, Person year and Rate by 100,000 for each family type
  print(lapplyBy(~ft, data=data, function(d) c(sum(1-d$cens),sum(d$pyear),round(100000*sum(1-d$cens)/sum(d$pyear),digits=1) )), justify="left")

  #-- Cases, Person year and Rate by 100,000 for each family type
  v = lapplyBy(~ft+asd.exp, data=data, function(d) c(sum(1-d$cens),sum(d$exit-d$entry),round(100000*sum(1-d$cens)/sum(d$exit-d$entry),digits=1) ))

  print(v, justify="left")
}


subs1 = subset(recur.x3, subset=bc %in% c("82-86"))
subs2 = subset(recur.x3, subset=bc %in% c("87-91"))
subs3 = subset(recur.x3, subset=bc %in% c("92-96"))
subs4 = subset(recur.x3, subset=bc %in% c("97-01"))
subs5 = subset(recur.x3, subset=bc %in% c("02-06"))

subs6 = subset(recur.x3, subset= sex1=="Male" & sex2=="Male"    )
subs7 = subset(recur.x3, subset= sex1=="Male" & sex2=="Female"  )
subs8 = subset(recur.x3, subset= sex1=="Female" & sex2=="Male"  )
subs9 = subset(recur.x3, subset= sex1=="Female" & sex2=="Female")


subr(data=subs1, "Birth cohort 82-86")
subr(data=subs2, "Birth cohort 87-91")
subr(data=subs3, "Birth cohort 92-96")
subr(data=subs4, "Birth cohort 97-01")
subr(data=subs5, "Birth cohort 02-06")

subr(data=subs6, "Male-Male")
subr(data=subs7, "Male-Female")
subr(data=subs8, "Female-Male")
subr(data=subs9, "Female-Female")

rm(recur.x3,subs1,subs2, subs3, subs4, subs5, subs6, subs7, subs8, subs9)

#=================================================================
#  Now do AD
#=================================================================
recur.x4=subset(recur.x1, subset=outcome=="AD");

#-- Cases, Person year and Rate by 100,000 for each family type
lapplyBy(~ft, data=recur.x4, function(d) c(sum(1-d$cens),sum(d$pyear),round(100000*sum(1-d$cens)/sum(d$pyear),digits=1) ))

#-- Cases, Person year and Rate by 100,000 for each family type
v = lapplyBy(~ft+asd.exp, data=recur.x4, function(d) c(sum(1-d$cens),sum(d$exit-d$entry),round(100000*sum(1-d$cens)/sum(d$exit-d$entry),digits=1) ))

v

v$"MZ|1"[3]/v$"MZ|0"[3]
v$"DZ|1"[3]/v$"DZ|0"[3]
v$"F|1"[3]/v$"F|0"[3]
v$"MH|1"[3]/v$"MH|0"[3]
v$"PH|1"[3]/v$"PH|0"[3]

#-----------------------------------------------------
# In sub-groups of sex and birth cohorts 
# All calculations in sub-groups are for full siblings 
#-----------------------------------------------------
recur.x3 = subset(recur.x4, subset=ft=="F")

subr = function(data=subs,txt) {
  writeLines(paste(txt))

  #-- Cases, Person year and Rate by 100,000 for each family type
  print(lapplyBy(~ft, data=data, function(d) c(sum(1-d$cens),sum(d$pyear),round(100000*sum(1-d$cens)/sum(d$pyear),digits=1) )), justify="left")

  #-- Cases, Person year and Rate by 100,000 for each family type
  v = lapplyBy(~ft+asd.exp, data=data, function(d) c(sum(1-d$cens),sum(d$exit-d$entry),round(100000*sum(1-d$cens)/sum(d$exit-d$entry),digits=1) ))

  print(v, justify="left")
}


subs1 = subset(recur.x3, subset=bc %in% c("82-86"))
subs2 = subset(recur.x3, subset=bc %in% c("87-91"))
subs3 = subset(recur.x3, subset=bc %in% c("92-96"))
subs4 = subset(recur.x3, subset=bc %in% c("97-01"))
subs5 = subset(recur.x3, subset=bc %in% c("02-06"))

subs6 = subset(recur.x3, subset= sex1=="Male" & sex2=="Male"    )
subs7 = subset(recur.x3, subset= sex1=="Male" & sex2=="Female"  )
subs8 = subset(recur.x3, subset= sex1=="Female" & sex2=="Male"  )
subs9 = subset(recur.x3, subset= sex1=="Female" & sex2=="Female")


subr(data=subs1, "Birth cohort 82-86")
subr(data=subs2, "Birth cohort 87-91")
subr(data=subs3, "Birth cohort 92-96")
subr(data=subs4, "Birth cohort 97-01")
subr(data=subs5, "Birth cohort 02-06")

subr(data=subs6, "Male-Male")
subr(data=subs7, "Male-Female")
subr(data=subs8, "Female-Male")
subr(data=subs9, "Female-Female")

rm(recur.x3,subs1,subs2, subs3, subs4, subs5, subs6, subs7, subs8, subs9)



#===========================================================
#  NOW DO THE COUSINS
#===========================================================
library(doBy)
setwd("/home/svesan/ki/AAA/AAA_Research/sasproj/PSY/PSY1203/R-Stata/")

load("psy1203_cousin_B.RData")

#-----------------------------------------------------------
# ASD cousins
#-----------------------------------------------------------
recur.x0 = subset(psy1203cousinB, subset=outcome=="ASD")

#-- Remove multiple birth among F and half sibs
recur.x1 = subset(recur.x0, subset=(multiple=="Yes")==F)
rm(recur.x0, psy1203cousinB);gc();gc();

recur.x1$asd.exp = factor(recur.x1$asd.exp)
recur.x1$pyear   = recur.x1$exit-recur.x1$entry

recur.x1 = recur.x1[(names(recur.x1) %in% c("asd.exp", "cens", "entry", "exit", "pyear"))==TRUE]
gc()

w = lapplyBy(~asd.exp, data=recur.x1, function(d) c(sum(1-d$cens),sum(d$pyear),round(100000*sum(1-d$cens)/sum(d$pyear),digits=1) ))

w

w$"1"[3]/w$"0"[3]


#- Results below

#-----------------------------------------------------------
# AD cousins
#-----------------------------------------------------------
load("psy1203_cousin_B.RData")
recur.x0 = subset(psy1203cousinB, subset=outcome=="AD")

#-- Remove multiple birth among F and half sibs
recur.x1 = subset(recur.x0, subset=(multiple=="Yes")==F)
rm(recur.x0, psy1203cousinB);gc();gc();

recur.x1$asd.exp = factor(recur.x1$asd.exp)
recur.x1$pyear   = recur.x1$exit-recur.x1$entry

recur.x1 = recur.x1[(names(recur.x1) %in% c("asd.exp", "cens", "entry", "exit", "pyear"))==TRUE]
gc()

w = lapplyBy(~asd.exp, data=recur.x1, function(d) c(sum(1-d$cens),sum(d$pyear),round(100000*sum(1-d$cens)/sum(d$pyear),digits=1) ))

w

w$"1"[3]/w$"0"[3]

#- w$"1"[3]/w$"0"[3]
#- 
#- > w$"1"[3]/w$"0"[3]
#- [1] 3.298913
#- 
#- > w
#- $`0`
#- [1]     27271.0 148418486.6        18.4
#- 
#- $`1`
#- [1]     81.0 133335.5     60.7
