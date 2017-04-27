 
#-----------------------------------------------------------------------------
# Study.......: PSY1203
# Name........: s_psy1203_cox_nocousins_07.R
# Date........: 2013-05-23
# Author......: svesan
# Purpose.....: Read the data from SAS and run the Cox regressions
# Note........: The results should be adjusted for robust standard errors
# Note........: 130610 changed psy1203A to psy1203B and inserted _B to make this clear
# Note........: 140203 updated for review by JAMA. Added older sibling analysis
# ............: and create fresh output since could not find earlier
#-----------------------------------------------------------------------------
# Data used...:
# Data created:
#-----------------------------------------------------------------------------

#-- Libraries ----------------------------------------------------------------
rm(list=ls());gc(TRUE)
library(survival)

#-- R functions --------------------------------------------------------------

#-- reptab function extract CIs from the coxph objects
reptab = function (model) {
  #-- 3: dataset, 4: subset
  b=round(summary(model)$conf.int[1,], 3)
  #b=round(summary(f1.F.adj)$conf.int[1,], 3)
  varratio = round(model$var[1,1] / model$naive.var[1,1], 3)
  ci = paste(b[1],' (',b[3], '-', b[4], ')')
  #as.character(model$call[[3]]),

  c(as.character(model$nevent), as.character(varratio), ci)
}

#-- Calling external programs ------------------------------------------------
#source(file="/home/workspace/projects/AAA/AAA_Research/sasproj/PSY/PSY1203/R-

#-- Main program -------------------------------------------------------------
# To-do
# a) Why are the confidence intervals so wide ????
# a) Check the same results are obtained using non-aggregated data
# a) Check AD vs ASD, AD vs AD and ASD vs AD relations
# b) Time trend....
# c) Do half-sibs have higher risk generally ? ..... socioeconomic ?


#setwd("/home/svesan/ki/AAA/AAA_Research/sasproj/PSY/PSY1203/R-Stata/")
setwd("/home/svesan/ki/ABS/mep/sasproj/PSY/PSY1203/R-Stata/")


rm(list=ls());gc(TRUE);gc()

reptab = function (model) {
  #-- 3: dataset, 4: subset
  b=round(summary(model)$conf.int[1,], 3)
  #b=round(summary(f1.F.adj)$conf.int[1,], 3)
  varratio = round(model$var[1,1] / model$naive.var[1,1], 3)
  ci = paste(b[1],' (',b[3], '-', b[4], ')')
  #as.character(model$call[[3]]),

  c(as.character(model$nevent), as.character(varratio), ci)
}


#setwd("/home/svesan/ki/AAA/AAA_Research/sasproj/PSY/PSY1203/R-Stata/")
#setwd("/home/svesan/ki/mep/sasproj/sasproj/PSY/PSY1203/R-Stata/")

load("psy1203_B.RData")

recur.x0 = subset(psy1203B, subset=outcome=="ASD" & oldsib=="Yes")

#-- Remove multiple birth among F and half sibs
recur.x1 = subset(recur.x0, subset=(multiple=="Yes" & ft=="F")==F)
recur.x1 = subset(recur.x1, subset=(multiple=="Yes" & ft=="PH")==F)
recur.x1 = subset(recur.x1, subset=(multiple=="Yes" & ft=="MH")==F)
recur.x1 = subset(recur.x1, subset=ft!="mz")
recur.x1 = subset(recur.x1, subset=ft!="dz")

recur.x1 = recur.x1[(names(recur.x1) %in% c("outcome", "multiple", "monozyg1", "monozyg2"))==FALSE]


#table(recur.x0$ft,recur.x0$multiple)

rm(psy1203B,recur.x0);gc()

table(recur.x1$cens)

write("Average age at diagnosis using older sibling as exposed")
hepp=subset(recur.x1,recur.x1$cens<1)
by(hepp$exit, hepp$ft, mean)

write("Number of ASD using older sibling as exposed")
hepp=subset(recur.x1,recur.x1$cens<1)
by(hepp$cens, hepp$ft, table)

f1.F =coxph(Surv(entry,exit,cens==0)~asd.exp + cluster(famid),data=recur.x1, subset=ft=="F")
f1.MH=coxph(Surv(entry,exit,cens==0)~asd.exp + cluster(famid),data=recur.x1, subset=ft=="MH")
f1.PH=coxph(Surv(entry,exit,cens==0)~asd.exp + cluster(famid),data=recur.x1, subset=ft=="PH")

f1.F.adj4 =update(f1.F, ~ .  + bc + sex1 + sex2 + mor.psych + far.psych + mor.psych + far.psych + oldma +oldpa)
f1.MH.adj4=update(f1.MH, ~ .  + bc + sex1 + sex2 + mor.psych + far.psych + mor.psych + far.psych + oldma +oldpa)
f1.PH.adj4=update(f1.PH, ~ .  + bc + sex1 + sex2 + mor.psych + far.psych + mor.psych + far.psych + oldma +oldpa)


sink("s_psy1203_cox_nocousins_07_OLDSIB.txt", split=T, append=FALSE)

summary(f1.F)
summary(f1.MH)
summary(f1.PH)

summary(f1.F.adj4)
summary(f1.MH.adj4)
summary(f1.PH.adj4)

sink()


#-- Cleanup ------------------------------------------------------------------
#rm(ls=c())

#-- End of File --------------------------------------------------------------
