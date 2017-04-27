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

load("psy1203_B.RData")


#-----------------------------------------------------------
# ASD singletons
#-----------------------------------------------------------
recur.x0 = subset(psy1203B, subset=outcome=="ASD")

#-- Remove multiple birth among F and half sibs
recur.x1 = subset(recur.x0, subset=(multiple=="Yes" & ft=="F")==F)
recur.x1 = subset(recur.x1, subset=(multiple=="Yes" & ft=="PH")==F)
recur.x1 = subset(recur.x1, subset=(multiple=="Yes" & ft=="MH")==F)

recur.x1 = recur.x1[(names(recur.x1) %in% c("outcome", "multiple", "monozyg1", "monozyg2"))==FALSE]


#table(recur.x0$ft,recur.x0$multiple)

rm(psy1203B,recur.x0);gc()

table(recur.x1$cens)

write("Average age at diagnosis")
hepp=subset(recur.x1,recur.x1$cens<1)
by(hepp$exit, hepp$ft, mean)

write("Number of ASD")
hepp=subset(recur.x1,recur.x1$cens<1)
by(hepp$cens, hepp$ft, table)

f1.F =coxph(Surv(entry,exit,cens==0)~asd.exp + cluster(famid),data=recur.x1, subset=ft=="F")
f1.MH=coxph(Surv(entry,exit,cens==0)~asd.exp + cluster(famid),data=recur.x1, subset=ft=="MH")
f1.PH=coxph(Surv(entry,exit,cens==0)~asd.exp + cluster(famid),data=recur.x1, subset=ft=="PH")
f1.mz=coxph(Surv(entry,exit,cens==0)~asd.exp + cluster(famid),data=recur.x1, subset=ft=="MZ")
f1.dz=coxph(Surv(entry,exit,cens==0)~asd.exp + cluster(famid),data=recur.x1, subset=ft=="DZ")

f1.F.adj1 =update(f1.F, ~ . + bc)
f1.F.adj2 =update(f1.F.adj1, ~ . + sex1 + sex2)
f1.F.adj3 =update(f1.F.adj2, ~ .  + mor.psych + far.psych)
f1.F.adj4 =update(f1.F.adj2, ~ .  + mor.psych + far.psych + oldma +oldpa)
f1.MH.adj1=update(f1.MH, ~ . + bc)
f1.MH.adj2=update(f1.MH.adj1, ~ . + sex1 + sex2)
f1.MH.adj3=update(f1.MH.adj2, ~ .  + mor.psych + far.psych)
f1.MH.adj4=update(f1.MH.adj2, ~ .  + mor.psych + far.psych + oldma +oldpa)
f1.PH.adj1=update(f1.PH, ~ . + bc)
f1.PH.adj2=update(f1.PH.adj1, ~ . + sex1 + sex2)
f1.PH.adj3=update(f1.PH.adj2, ~ .  + mor.psych + far.psych)
f1.PH.adj4=update(f1.PH.adj2, ~ .  + mor.psych + far.psych + oldma +oldpa)

#-- These do not converge
f1.mz.adj3=update(f1.mz, ~ . + as.numeric(bc) + mor.psych + far.psych)
f1.dz.adj3=update(f1.dz, ~ . + bc + mor.psych + far.psych)
f1.mz.adj4=update(f1.mz, ~ . + as.numeric(bc) + mor.psych + far.psych+ far.psych + oldma +oldpa)
f1.dz.adj4=update(f1.dz, ~ . + bc + mor.psych + far.psych+ far.psych + oldma +oldpa)

f1.F.bc1=update(f1.F , ~ . + sex1 + sex2 + mor.psych + far.psych + oldma +oldpa, subset= bc %in% c("82-86"))
f1.F.bc2=update(f1.F , ~ . + sex1 + sex2 + mor.psych + far.psych + oldma +oldpa, subset= bc %in% c("87-91"))
f1.F.bc3=update(f1.F , ~ . + sex1 + sex2 + mor.psych + far.psych + oldma +oldpa, subset= bc %in% c("92-96"))
f1.F.bc4=update(f1.F , ~ . + sex1 + sex2 + mor.psych + far.psych + oldma +oldpa, subset= bc %in% c("97-01"))
f1.F.bc5=update(f1.F , ~ . + sex1 + sex2 + mor.psych + far.psych + oldma +oldpa, subset= bc %in% c("02-06"))


#- Sex specific full-sibs
f1.F.mm = update(f1.F, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=ft=="F" & sex1=="Male" & sex2=="Male")
f1.F.mf = update(f1.F, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=ft=="F" & sex1=="Male" & sex2=="Female")
f1.F.fm = update(f1.F, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=ft=="F" & sex1=="Female" & sex2=="Male")
f1.F.ff = update(f1.F, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=ft=="F" & sex1=="Female" & sex2=="Female")

#- Sex specific for maternal half-sibs MH
f1.MH.mm = update(f1.MH, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=ft=="MH" & sex1=="Male" & sex2=="Male")
f1.MH.mf = update(f1.MH, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=ft=="MH" & sex1=="Male" & sex2=="Female")
f1.MH.fm = update(f1.MH, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=ft=="MH" & sex1=="Female" & sex2=="Male")
f1.MH.ff = update(f1.MH, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=ft=="MH" & sex1=="Female" & sex2=="Female")

#- Sex specific for paternal half-sibs PH
f1.PH.mm = update(f1.PH, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=ft=="MH" & sex1=="Male" & sex2=="Male")
f1.PH.mf = update(f1.PH, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=ft=="MH" & sex1=="Male" & sex2=="Female")
f1.PH.fm = update(f1.PH, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=ft=="MH" & sex1=="Female" & sex2=="Male")
f1.PH.ff = update(f1.PH, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=ft=="MH" & sex1=="Female" & sex2=="Female")


#-- Check
f1.F$n - (f1.F.mm$n+f1.F.mf$n+f1.F.fm$n+f1.F.ff$n)

asd.list=list(f1.F, f1.MH, f1.PH, f1.mz, f1.dz,
              f1.F.adj1, f1.F.adj2, f1.F.adj3, f1.F.adj4,
              f1.MH.adj1, f1.MH.adj2, f1.MH.adj3, f1.MH.adj4,
              f1.PH.adj1, f1.PH.adj2, f1.PH.adj3, f1.PH.adj4, f1.mz.adj3, f1.dz.adj3, f1.mz.adj4, f1.dz.adj4,
              f1.F.bc1, f1.F.bc2, f1.F.bc3, f1.F.bc4, f1.F.bc5,
              f1.F.mm, f1.F.mf, f1.F.fm, f1.F.ff,
              f1.MH.mm, f1.MH.mf, f1.MH.fm, f1.MH.ff,
              f1.PH.mm, f1.PH.mf, f1.PH.fm, f1.PH.ff)


g1=lapply(asd.list, reptab)
g2=t(as.matrix(data.frame(g1)))
rownames(g2)=NULL
colnames(g2)=c("Cases","Var.Ratio","RR (95% CI)")
rownames(g2)=c("Full sib * Crude", "MH * Crude", "PH * Crude", "MZ * Crude", "DZ * Crude",
"Full-Adj1", "Full-Adj2", "Full-Adj3", "Full-Adj4",
"MH-Adj1", "MH-Adj2", "MH-Adj3", "MH-Adj4",
"PH-Adj1", "PH-Adj2", "PH-Adj3", "PH-Adj4", "MZ-Adj3", "DZ-Adj3", "MZ-Adj4", "DZ-Adj4",
"Full-Cohorts 1982-86", "Full-Cohorts 1987-91","Full-Cohorts 1992-96", "Full-Cohorts 1997-2001", "Full-Cohorts 2002-2006",
"Full * Male-Male", "Full * Male-Female", "Full * Female-Male", "Full * Female-Female",
"MH * Male-Male", "MH * Male-Female", "MH * Female-Male", "MH * Female-Female",
"PH * Male-Male", "PH * Male-Female", "PH * Female-Male", "PH * Female-Female")

cis.asd = data.frame(g2)

save(cis.asd, file="psy1203_estimates_nocousins_asd_C.RData", compress=T)
save(asd.list, file="psy1203_results_nocousins_asd_C.RData", compress=T)

#-- Output the results
sink("s_psy1203_cox_nocousins_06_ASD.txt", split=T, append=FALSE)

options(width=100)

table(recur.x1$cens)

write("Average age at diagnosis")
hepp=subset(recur.x1,recur.x1$cens<1)
by(hepp$exit, hepp$ft, mean)

write("Number of ASD")
hepp=subset(recur.x1,recur.x1$cens<1)
by(hepp$cens, hepp$ft, table)

lapply(asd.list, summary)

cis.asd

sink()


#-----------------------------------------------------------
# AD singletons
# Repeat code above
#-----------------------------------------------------------
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

recur.x0 = subset(psy1203B, subset=outcome=="AD")

#-- Remove multiple birth among F and half sibs
recur.x1 = subset(recur.x0, subset=(multiple=="Yes" & ft=="F")==F)
recur.x1 = subset(recur.x1, subset=(multiple=="Yes" & ft=="PH")==F)
recur.x1 = subset(recur.x1, subset=(multiple=="Yes" & ft=="MH")==F)

recur.x1 = recur.x1[(names(recur.x1) %in% c("outcome", "multiple", "monozyg1", "monozyg2"))==FALSE]


#table(recur.x0$ft,recur.x0$multiple)

rm(psy1203B,recur.x0);gc()

table(recur.x1$cens)

write("Average age at diagnosis")
hepp=subset(recur.x1,recur.x1$cens<1)
by(hepp$exit, hepp$ft, mean)

write("Number of AD")
hepp=subset(recur.x1,recur.x1$cens<1)
by(hepp$cens, hepp$ft, table)

f1.F =coxph(Surv(entry,exit,cens==0)~asd.exp + cluster(famid),data=recur.x1, subset=ft=="F")
f1.MH=coxph(Surv(entry,exit,cens==0)~asd.exp + cluster(famid),data=recur.x1, subset=ft=="MH")
f1.PH=coxph(Surv(entry,exit,cens==0)~asd.exp + cluster(famid),data=recur.x1, subset=ft=="PH")
f1.mz=coxph(Surv(entry,exit,cens==0)~asd.exp + cluster(famid),data=recur.x1, subset=ft=="MZ")
f1.dz=coxph(Surv(entry,exit,cens==0)~asd.exp + cluster(famid),data=recur.x1, subset=ft=="DZ")

f1.F.adj1 =update(f1.F, ~ . + bc)
f1.F.adj2 =update(f1.F.adj1, ~ . + sex1 + sex2)
f1.F.adj3 =update(f1.F.adj2, ~ .  + mor.psych + far.psych)
f1.F.adj4 =update(f1.F.adj2, ~ .  + mor.psych + far.psych + oldma +oldpa)
f1.MH.adj1=update(f1.MH, ~ . + bc)
f1.MH.adj2=update(f1.MH.adj1, ~ . + sex1 + sex2)
f1.MH.adj3=update(f1.MH.adj2, ~ .  + mor.psych + far.psych)
f1.MH.adj4=update(f1.MH.adj2, ~ .  + mor.psych + far.psych + oldma +oldpa)
f1.PH.adj1=update(f1.PH, ~ . + bc)
f1.PH.adj2=update(f1.PH.adj1, ~ . + sex1 + sex2)
f1.PH.adj3=update(f1.PH.adj2, ~ .  + mor.psych + far.psych)
f1.PH.adj4=update(f1.PH.adj2, ~ .  + mor.psych + far.psych + oldma +oldpa)


#-- These do not converge
f1.mz.adj3=update(f1.mz, ~ . + as.numeric(bc) + mor.psych + far.psych + oldma + oldpa)
f1.dz.adj3=update(f1.dz, ~ . + bc + mor.psych + far.psych + oldma +oldpa)
f1.mz.adj4=update(f1.mz, ~ . + as.numeric(bc) + mor.psych + far.psych+ far.psych + oldma +oldpa)
f1.dz.adj4=update(f1.dz, ~ . + bc + mor.psych + far.psych+ far.psych + oldma +oldpa)


f1.F.bc1=update(f1.F , ~ . + sex1 + sex2 + mor.psych + far.psych + oldma +oldpa, subset= bc %in% c("82-86"))
f1.F.bc2=update(f1.F , ~ . + sex1 + sex2 + mor.psych + far.psych + oldma +oldpa, subset= bc %in% c("87-91"))
f1.F.bc3=update(f1.F , ~ . + sex1 + sex2 + mor.psych + far.psych + oldma +oldpa, subset= bc %in% c("92-96"))
f1.F.bc4=update(f1.F , ~ . + sex1 + sex2 + mor.psych + far.psych + oldma +oldpa, subset= bc %in% c("97-01"))
f1.F.bc5=update(f1.F , ~ . + sex1 + sex2 + mor.psych + far.psych + oldma +oldpa, subset= bc %in% c("02-06"))


#- Sex specific full-sibs
f1.F.mm = update(f1.F, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=ft=="F" & sex1=="Male" & sex2=="Male")
f1.F.mf = update(f1.F, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=ft=="F" & sex1=="Male" & sex2=="Female")
f1.F.fm = update(f1.F, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=ft=="F" & sex1=="Female" & sex2=="Male")
f1.F.ff = update(f1.F, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=ft=="F" & sex1=="Female" & sex2=="Female")

#- Sex specific for maternal half-sibs MH
f1.MH.mm = update(f1.MH, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=ft=="MH" & sex1=="Male" & sex2=="Male")
f1.MH.mf = update(f1.MH, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=ft=="MH" & sex1=="Male" & sex2=="Female")
f1.MH.fm = update(f1.MH, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=ft=="MH" & sex1=="Female" & sex2=="Male")
f1.MH.ff = update(f1.MH, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=ft=="MH" & sex1=="Female" & sex2=="Female")

#- Sex specific for paternal half-sibs PH
f1.PH.mm = update(f1.PH, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=ft=="MH" & sex1=="Male" & sex2=="Male")
f1.PH.mf = update(f1.PH, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=ft=="MH" & sex1=="Male" & sex2=="Female")
f1.PH.fm = update(f1.PH, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=ft=="MH" & sex1=="Female" & sex2=="Male")
f1.PH.ff = update(f1.PH, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=ft=="MH" & sex1=="Female" & sex2=="Female")


#-- Check
f1.F$n - (f1.F.mm$n+f1.F.mf$n+f1.F.fm$n+f1.F.ff$n)

ad.list=list(f1.F, f1.MH, f1.PH, f1.mz, f1.dz,
              f1.F.adj1, f1.F.adj2, f1.F.adj3, f1.F.adj4,
              f1.MH.adj1, f1.MH.adj2, f1.MH.adj3, f1.MH.adj4,
              f1.PH.adj1, f1.PH.adj2, f1.PH.adj3, f1.PH.adj4, f1.mz.adj3, f1.dz.adj3, f1.mz.adj4, f1.dz.adj4,
              f1.F.bc1, f1.F.bc2, f1.F.bc3, f1.F.bc4, f1.F.bc5,
              f1.F.mm, f1.F.mf, f1.F.fm, f1.F.ff,
              f1.MH.mm, f1.MH.mf, f1.MH.fm, f1.MH.ff,
              f1.PH.mm, f1.PH.mf, f1.PH.fm, f1.PH.ff)


g1=lapply(ad.list, reptab)
g2=t(as.matrix(data.frame(g1)))
rownames(g2)=NULL
colnames(g2)=c("Cases","Var.Ratio","RR (95% CI)")
rownames(g2)=c("Full sib * Crude", "MH * Crude", "PH * Crude", "MZ * Crude", "DZ * Crude",
"Full-Adj1", "Full-Adj2", "Full-Adj3", "Full-Adj4",
"MH-Adj1", "MH-Adj2", "MH-Adj3", "MH-Adj4",
"PH-Adj1", "PH-Adj2", "PH-Adj3", "PH-Adj4", "MZ-Adj3", "DZ-Adj3", "MZ-Adj4", "DZ-Adj4",
"Full-Cohorts 1982-86", "Full-Cohorts 1987-91","Full-Cohorts 1992-96", "Full-Cohorts 1997-2001", "Full-Cohorts 2002-2006",
"Full * Male-Male", "Full * Male-Female", "Full * Female-Male", "Full * Female-Female",
"MH * Male-Male", "MH * Male-Female", "MH * Female-Male", "MH * Female-Female",
"PH * Male-Male", "PH * Male-Female", "PH * Female-Male", "PH * Female-Female")


cis.ad = data.frame(g2)

save(cis.ad, file="psy1203_estimates_nocousins_ad_C.RData", compress=T)

save(ad.list, file="psy1203_results_nocousins_ad_C.RData", compress=T)

#-- Output the results
sink("s_psy1203_cox_nocousins_07_AD.txt", split=T, append=FALSE)

options(width=160)

table(recur.x1$cens)

write("Average age at diagnosis")
hepp=subset(recur.x1,recur.x1$cens<1)
by(hepp$exit, hepp$ft, mean)

write("Number of AD")
hepp=subset(recur.x1,recur.x1$cens<1)
by(hepp$cens, hepp$ft, table)

lapply(ad.list, summary)

cis.ad

sink()


#-----------------------------------------------------------
# Sibs exposed by older sibling
#-----------------------------------------------------------
rm(f1, f1.mz, f1.dz, f1.F, f1.MH, f1.PH, f1.F.adj, f1.MH.adj, f1.PH.adj, f1.F.mm,
   f1.F.mf, f1.F.fm, f1.F.ff, f1.MH.mm, f1.MH.mf, f1.MH.fm, f1.MH.ff, f1.PH.mm,
   f1.PH.mf, f1.PH.fm, f1.PH.ff, f1.F.bc1, f1.F.bc2, f1.F.bc3, f1.F.bc4, f1.F.bc5, g1, g2)
gc()

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
