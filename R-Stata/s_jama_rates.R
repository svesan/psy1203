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

recur.x1 = recur.x1[(names(recur.x1) %in% c("asd.exp", "cens", "entry", "exit", "pyear", "ft", "outcome"))==TRUE]
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



#--------------------
#  Now do AD
#--------------------
recur.x3=subset(recur.x1, subset=outcome=="AD");

#-- Cases, Person year and Rate by 100,000 for each family type
lapplyBy(~ft, data=recur.x3, function(d) c(sum(1-d$cens),sum(d$pyear),round(100000*sum(1-d$cens)/sum(d$pyear),digits=1) ))

#-- Cases, Person year and Rate by 100,000 for each family type
v = lapplyBy(~ft+asd.exp, data=recur.x3, function(d) c(sum(1-d$cens),sum(d$exit-d$entry),round(100000*sum(1-d$cens)/sum(d$exit-d$entry),digits=1) ))

v

v$"MZ|1"[3]/v$"MZ|0"[3]
v$"DZ|1"[3]/v$"DZ|0"[3]
v$"F|1"[3]/v$"F|0"[3]
v$"MH|1"[3]/v$"MH|0"[3]
v$"PH|1"[3]/v$"PH|0"[3]


#-- results below


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
