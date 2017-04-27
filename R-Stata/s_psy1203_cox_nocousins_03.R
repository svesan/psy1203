#-----------------------------------------------------------------------------
# Study.......: PSY1203
# Name........: s_psy1203_cox_nocousins_02.R
# Date........: 2013-05-23
# Author......: svesan
# Purpose.....: Read the data from SAS and run the Cox regressions
# Note........: The results should be adjusted for robust standard errors
#-----------------------------------------------------------------------------
# Data used...:
# Data created:
#-----------------------------------------------------------------------------

#-- Libraries ----------------------------------------------------------------
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


rm(list=ls())


#setwd("/home/svesan/ki/AAA/AAA_Research/sasproj/PSY/PSY1203/R-Stata/")
setwd("/home/svesan/ki/ABS/mep/sasproj/PSY/PSY1203/R-Stata/")

load("psy1203_A.RData")


#-----------------------------------------------------------
# ASD singletons
#-----------------------------------------------------------
recur.x0 = subset(psy1203A, subset=outcome=="ASD")

#-- Remove multiple birth among F and half sibs
recur.x1 = subset(recur.x0, subset=(multiple=="Yes" & ft=="F")==F)
recur.x1 = subset(recur.x1, subset=(multiple=="Yes" & ft=="PH")==F)
recur.x1 = subset(recur.x1, subset=(multiple=="Yes" & ft=="MH")==F)

recur.x1 = recur.x1[(names(recur.x1) %in% c("outcome", "multiple", "monozyg1", "monozyg2"))==FALSE]


#table(recur.x0$ft,recur.x0$multiple)

rm(psy1203A,recur.x0)

table(recur.x1$cens)

write("Average age at diagnosis")
hepp=subset(recur.x1,recur.x1$cens<1)
by(hepp$exit, hepp$ft, mean)

write("Number of ASD")
hepp=subset(recur.x1,recur.x1$cens<1)
by(hepp$cens, hepp$ft, table)

f1   =coxph(Surv(entry,exit,cens==0)~asd.exp+ bc + sex1 + sex2 + mor.psych + far.psych + cluster(famid),data=recur.x1)
f1.F =coxph(Surv(entry,exit,cens==0)~asd.exp + cluster(famid),data=recur.x1, subset=ft=="F")
f1.MH=coxph(Surv(entry,exit,cens==0)~asd.exp + cluster(famid),data=recur.x1, subset=ft=="MH")
f1.PH=coxph(Surv(entry,exit,cens==0)~asd.exp + cluster(famid),data=recur.x1, subset=ft=="PH")
f1.mz=coxph(Surv(entry,exit,cens==0)~asd.exp + cluster(famid),data=recur.x1, subset=ft=="MZ")
f1.dz=coxph(Surv(entry,exit,cens==0)~asd.exp + cluster(famid),data=recur.x1, subset=ft=="DZ")

f1.F.adj1 =update(f1.F, ~ . + bc)
f1.F.adj2 =update(f1.F.adj1, ~ . + sex1 + sex2)
f1.F.adj3 =update(f1.F.adj2, ~ .  + mor.psych + far.psych)
f1.MH.adj1=update(f1.MH, ~ . + bc)
f1.MH.adj2=update(f1.MH.adj1, ~ . + sex1 + sex2)
f1.MH.adj3=update(f1.MH.adj2, ~ .  + mor.psych + far.psych)
f1.PH.adj1=update(f1.PH, ~ . + bc)
f1.PH.adj2=update(f1.PH.adj1, ~ . + sex1 + sex2)
f1.PH.adj3=update(f1.PH.adj2, ~ .  + mor.psych + far.psych)

#f1.F.early    =update(f1.F , subset= bc %in% c("82-86","87-91"))
#f1.F.mid      =update(f1.F , subset= bc %in% c("92-96"))
#f1.F.late     =update(f1.F , subset= bc %in% c("97-01","02-06"))
#f1.F.adj.early=update(f1.F.adj, ~ . - bc , subset= bc %in% c("82-86","87-91"))
#f1.F.adj.late =update(f1.F.adj, ~ . - bc , subset= bc %in% c("97-01","02-06"))


f1.F.bc1=update(f1.F , subset= bc %in% c("82-86"))
f1.F.bc2=update(f1.F , subset= bc %in% c("87-91"))
f1.F.bc3=update(f1.F , subset= bc %in% c("92-96"))
f1.F.bc4=update(f1.F , subset= bc %in% c("97-01"))
f1.F.bc5=update(f1.F , subset= bc %in% c("02-06"))



#- Sex specific full-sibs
f1.F.mm = update(f1.F, ~ . + bc, subset=ft=="F" & sex1=="Male" & sex2=="Male")
f1.F.mf = update(f1.F, ~ . + bc, subset=ft=="F" & sex1=="Male" & sex2=="Female")
f1.F.fm = update(f1.F, ~ . + bc, subset=ft=="F" & sex1=="Female" & sex2=="Male")
f1.F.ff = update(f1.F, ~ . + bc, subset=ft=="F" & sex1=="Female" & sex2=="Female")

#- Sex specific for maternal half-sibs MH
f1.MH.mm = update(f1.MH, subset=ft=="MH" & sex1=="Male" & sex2=="Male")
f1.MH.mf = update(f1.MH, subset=ft=="MH" & sex1=="Male" & sex2=="Female")
f1.MH.fm = update(f1.MH, subset=ft=="MH" & sex1=="Female" & sex2=="Male")
f1.MH.ff = update(f1.MH, subset=ft=="MH" & sex1=="Female" & sex2=="Female")


#- Sex specific for paternal half-sibs PH
f1.PH.mm = update(f1.PH, subset=ft=="PH" & sex1=="Male" & sex2=="Male")
f1.PH.mf = update(f1.PH, subset=ft=="PH" & sex1=="Male" & sex2=="Female")
f1.PH.fm = update(f1.PH, subset=ft=="PH" & sex1=="Female" & sex2=="Male")
f1.PH.ff = update(f1.PH, subset=ft=="PH" & sex1=="Female" & sex2=="Female")

#-- Check
f1.F$n - (f1.F.mm$n+f1.F.mf$n+f1.F.fm$n+f1.F.ff$n)

asd.list=list(f1, f1.F, f1.F.adj1, f1.F.adj2, f1.F.adj3, f1.mz, f1.dz, f1.MH, f1.PH, f1.MH.adj3, f1.PH.adj3, f1.F.mm,
              f1.F.mf, f1.F.fm, f1.F.ff, f1.MH.mm, f1.MH.mf, f1.MH.fm, f1.MH.ff, f1.PH.mm,
              f1.PH.mf, f1.PH.fm, f1.PH.ff, f1.F.bc1, f1.F.bc2, f1.F.bc3, f1.F.bc4, f1.F.bc5)

g1=lapply(asd.list, reptab)
g2=t(as.matrix(data.frame(g1)))
rownames(g2)=NULL
colnames(g2)=c("Cases","Var.Ratio","RR (95% CI)")
rownames(g2)=c("Overall * Full and half sib", "Overall * Full sib", "Overall * Full-Adj1", "Overall * Full-Adj2", "Overall * Full-Adj3", "Overall * MZ Twins",
"Overall * DZ Twin", "Half sibs * MH","Half sibs * PH",
"Half sibs * MH Adj3","Half sibs * PH Adj3", "Full Sib by Sex * Male-Male",
"Full Sib by Sex * Male-Female", "Full Sib by Sex * Female-Male",
"Full Sib by Sex * Female-Female", "MH by Sex * Male-Male", "MH by Sex * Male-Female",
"MH by Sex * Female-Male", "MH by Sex * Female-Female", "PH by Sex * Male-Male",
"PH by Sex * Male-Female", "PH by Sex * Female-Male", "PH by Sex * Female-Female",
"Birth Cohorts * Full Sib 1982-86", "Birth Cohorts * Full Sib 1987-91","Birth Cohorts * Full Sib 1992-96",
"Birth Cohorts * Full Sib 1997-2001", "Birth Cohorts * Full Sib 2002-2006")

cis.asd = data.frame(g2)

cis.asd

save(asd.list, cis.asd, file="psy1203_results_asd.RData", compress=T)


#-----------------------------------------------------------
# AD singletons
# Repeat code above
#-----------------------------------------------------------
rm(f1,f1.mz, f1.dz, f1.F, f1.MH, f1.PH, f1.F.adj1, f1.F.adj2, f1.F.adj3, f1.MH.adj, f1.PH.adj, f1.F.mm,
   f1.F.mf, f1.F.fm, f1.F.ff, f1.MH.mm, f1.MH.mf, f1.MH.fm, f1.MH.ff, f1.PH.mm,
   f1.PH.mf, f1.PH.fm, f1.PH.ff, f1.F.bc1, f1.F.bc2, f1.F.bc3, f1.F.bc4, f1.F.bc5, g1, g2, recur.x1)


#setwd("/home/svesan/ki/AAA/AAA_Research/sasproj/PSY/PSY1203/R-Stata/")
setwd("/home/svesan/ki/mep/sasproj/sasproj/PSY/PSY1203/R-Stata/")

load("psy1203_A.RData")

recur.x0 = subset(psy1203A, subset=outcome=="AD")

#-- Remove multiple birth among F and half sibs
recur.x1 = subset(recur.x0, subset=(multiple=="Yes" & ft=="F")==F)
recur.x1 = subset(recur.x1, subset=(multiple=="Yes" & ft=="PH")==F)
recur.x1 = subset(recur.x1, subset=(multiple=="Yes" & ft=="MH")==F)

recur.x1 = recur.x1[(names(recur.x1) %in% c("outcome", "multiple", "monozyg1", "monozyg2"))==FALSE]

rm(psy1203A,recur.x0)


write("Average age at AD diagnosis")
hepp=subset(recur.x1,recur.x1$cens<1)
by(hepp$exit, hepp$ft, mean)

write("Number of AD")
hepp=subset(recur.x1,recur.x1$cens<1)
by(hepp$cens, hepp$ft, table)

f1   =coxph(Surv(entry,exit,cens==0)~asd.exp + cluster(famid),data=recur.x1)
f1.F =coxph(Surv(entry,exit,cens==0)~asd.exp + cluster(famid),data=recur.x1, subset=ft=="F")
f1.MH=coxph(Surv(entry,exit,cens==0)~asd.exp + cluster(famid),data=recur.x1, subset=ft=="MH")
f1.PH=coxph(Surv(entry,exit,cens==0)~asd.exp + cluster(famid),data=recur.x1, subset=ft=="PH")
f1.mz=coxph(Surv(entry,exit,cens==0)~asd.exp + cluster(famid),data=recur.x1, subset=ft=="MZ")
f1.dz=coxph(Surv(entry,exit,cens==0)~asd.exp + cluster(famid),data=recur.x1, subset=ft=="DZ")

f1.adj   =coxph(Surv(entry,exit,cens==0)~asd.exp + bc + sex1 + sex2 + mor.psych + far.psych + cluster(famid),data=recur.x1)
f1.F.adj =coxph(Surv(entry,exit,cens==0)~asd.exp + bc + sex1 + sex2 + mor.psych + far.psych + cluster(famid),data=recur.x1, subset=ft=="F")
f1.MH.adj=coxph(Surv(entry,exit,cens==0)~asd.exp + bc + sex1 + sex2 + mor.psych + far.psych + cluster(famid),data=recur.x1, subset=ft=="MH")
f1.PH.adj=coxph(Surv(entry,exit,cens==0)~asd.exp + bc + sex1 + sex2 + mor.psych + far.psych + cluster(famid),data=recur.x1, subset=ft=="PH")

#f1.F.early    =update(f1.F , subset= bc %in% c("82-86","87-91"))
#f1.F.mid      =update(f1.F , subset= bc %in% c("92-96"))
#f1.F.late     =update(f1.F , subset= bc %in% c("97-01","02-06"))
#f1.F.adj.early=update(f1.F.adj, ~ . - bc , subset= bc %in% c("82-86","87-91"))
#f1.F.adj.late =update(f1.F.adj, ~ . - bc , subset= bc %in% c("97-01","02-06"))


f1.F.bc1=update(f1.F , subset= bc %in% c("82-86"))
f1.F.bc2=update(f1.F , subset= bc %in% c("87-91"))
f1.F.bc3=update(f1.F , subset= bc %in% c("92-96"))
f1.F.bc4=update(f1.F , subset= bc %in% c("97-01"))
f1.F.bc5=update(f1.F , subset= bc %in% c("02-06"))



#- Sex specific full-sibs
f1.F.mm = update(f1.F, ~ . + bc, subset=nt=="F" & sex1=="Male" & sex2=="Male")
f1.F.mf = update(f1.F, ~ . + bc, subset=nt=="F" & sex1=="Male" & sex2=="Female")
f1.F.fm = update(f1.F, ~ . + bc, subset=nt=="F" & sex1=="Female" & sex2=="Male")
f1.F.ff = update(f1.F, ~ . + bc, subset=nt=="F" & sex1=="Female" & sex2=="Female")

#- Sex specific for maternal half-sibs MH
f1.MH.mm = update(f1.MH ~ . + bc, subset=nt=="MH" & sex1=="Male" & sex2=="Male")
f1.MH.mf = update(f1.MH ~ . + bc, subset=nt=="MH" & sex1=="Male" & sex2=="Female")
f1.MH.fm = update(f1.MH ~ . + bc, subset=nt=="MH" & sex1=="Female" & sex2=="Male")
f1.MH.ff = update(f1.MH ~ . + bc, subset=nt=="MH" & sex1=="Female" & sex2=="Female")


#- Sex specific for paternal half-sibs PH
f1.PH.mm = update(f1.PH, subset=nt=="PH" & sex1=="Male" & sex2=="Male")
f1.PH.mf = update(f1.PH, subset=nt=="PH" & sex1=="Male" & sex2=="Female")
f1.PH.fm = update(f1.PH, subset=nt=="PH" & sex1=="Female" & sex2=="Male")
f1.PH.ff = update(f1.PH, subset=nt=="PH" & sex1=="Female" & sex2=="Female")

#-- Check
f1.F$n - (f1.F.mm$n+f1.F.mf$n+f1.F.fm$n+f1.F.ff$n)

ad.list=list(f1, f1.F.adj1, f1.F.adj2, f1.F.adj3, f1.mz, f1.dz, f1.F, f1.MH, f1.PH, f1.MH.adj, f1.PH.adj, f1.F.mm,
             f1.F.mf, f1.F.fm, f1.F.ff, f1.MH.mm, f1.MH.mf, f1.MH.fm, f1.MH.ff, f1.PH.mm,
             f1.PH.mf, f1.PH.fm, f1.PH.ff, f1.F.bc1, f1.F.bc2, f1.F.bc3, f1.F.bc4, f1.F.bc5)


g1=lapply(ad.list, reptab)
g2=t(as.matrix(data.frame(g1)))
rownames(g2)=NULL
colnames(g2)=c("Cases","Var.Ratio","RR (95% CI)")
rownames(g2)=

a=c("Overall * Full and half sib", "Overall * Full-Adj1", "Overall * Full-Adj2", "Overall * Full-Adj3", "Overall * MZ Twins","Overall * DZ Twin",
"Overall * Full sib","Half sibs * MH","Half sibs * PH",
"Half sibs * MH Adj3","Half sibs * PH Adj3", "Full Sib by Sex * Male-Male",
"Full Sib by Sex * Male-Female", "Full Sib by Sex * Female-Male",
"Full Sib by Sex * Female-Female", "MH by Sex * Male-Male", "MH by Sex * Male-Female",
"MH by Sex * Female-Male", "MH by Sex * Female-Female", "PH by Sex * Male-Male",
"PH by Sex * Male-Female", "PH by Sex * Female-Male", "PH by Sex * Female-Female",
"Birth Cohorts * Full Sib 1982-86", "Birth Cohorts * Full Sib 1987-91","Birth Cohorts * Full Sib 1992-96",
"Birth Cohorts * Full Sib 1997-2001", "Birth Cohorts * Full Sib 2002-2006")

cis.ad = data.frame(g2)
save(ad.list, cis.ad, file="psy1203_results_ad.RData", compress=T)


#-----------------------------------------------------------
# Removed code only using sibs exposed by older sibling
# See s_cox5.R for this code
#-----------------------------------------------------------

#-- Cleanup ------------------------------------------------------------------
#rm(ls=c())

#-- End of File --------------------------------------------------------------
