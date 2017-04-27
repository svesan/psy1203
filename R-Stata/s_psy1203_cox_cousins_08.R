#-----------------------------------------------------------------------------
# Study.......: PSY1203
# Name........: s_psy1203_cox_cousins_08.R
# Date........: 2013-05-23
# Author......: svesan
# Purpose.....: Read the data from SAS and run the Cox regressions
# Note........: The results should be adjusted for robust standard errors
# Note........: 130610 changed psy1203A to psy1203B and inserted _B to make this clear
# Note........: 140203 updated for review by JAMA. Added older sibling analysis
# ............: and create fresh output since could not find earlier. Added adj4.
# Note........: 140204 compared with s_..._07 I removed several model due to time limit
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
  #b=round(summary(f1.C.adj)$conf.int[1,], 3)
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

load("psy1203_cousin_B.RData")


#-----------------------------------------------------------
# ASD cousins
#-----------------------------------------------------------
recur.x0 = subset(psy1203cousinB, subset=outcome=="ASD")

#-- Remove multiple birth among F and half sibs
recur.x1 = subset(recur.x0, subset=(multiple=="Yes")==F)

recur.x1 = recur.x1[(names(recur.x1) %in% c("outcome", "multiple", "monozyg1", "monozyg2"))==FALSE]


rm(psy1203cousinB,recur.x0)

table(recur.x1$cens)

write("Average age at diagnosis")
hepp=subset(recur.x1,recur.x1$cens<1)
summary(hepp$exit)

write("Number of ASD")
hepp=subset(recur.x1,recur.x1$cens<1)
table(hepp$cens)


f1.C =coxph(Surv(entry,exit,cens==0)~asd.exp + cluster(famid),data=recur.x1)

#f1.C.adj1 =update(f1.C, ~ . + bc) removed this since take so long time
f1.C.adj2 =update(f1.C, ~ . + bc + sex1 + sex2)
f1.C.adj3 =update(f1.C.adj2, ~ .  + mor.psych + far.psych)
f1.C.adj4 =update(f1.C.adj3, ~ .  + oldma +oldpa)

#- Sex specific full-sibs
#f1.C.mm = update(f1.C, ~ . + bc, subset=sex1=="Male" & sex2=="Male"    )
#f1.C.mf = update(f1.C, ~ . + bc, subset=sex1=="Male" & sex2=="Female"  )
#f1.C.fm = update(f1.C, ~ . + bc, subset=sex1=="Female" & sex2=="Male"  )
#f1.C.ff = update(f1.C, ~ . + bc, subset=sex1=="Female" & sex2=="Female")

#f1.C.mm.adj = update(f1.C.mm, ~ . + mor.psych + far.psych)
#f1.C.mf.adj = update(f1.C.mf, ~ . + mor.psych + far.psych)
#f1.C.fm.adj = update(f1.C.fm, ~ . + mor.psych + far.psych)
#f1.C.ff.adj = update(f1.C.ff, ~ . + mor.psych + far.psych)

f1.C.mm.adj4 = update(f1.C, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=sex1=="Male" & sex2=="Male"    )
f1.C.mf.adj4 = update(f1.C, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=sex1=="Male" & sex2=="Female"  )
f1.C.fm.adj4 = update(f1.C, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=sex1=="Female" & sex2=="Male"  )
f1.C.ff.adj4 = update(f1.C, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=sex1=="Female" & sex2=="Female")


#-- Check
f1.C$n - (f1.C.mm.adj4$n+f1.C.mf.adj4$n+f1.C.fm.adj4$n+f1.C.ff.adj4$n)

asd.list=list(f1.C, f1.C.adj2, f1.C.adj3, f1.C.adj4, f1.C.mm.adj4, f1.C.mf.adj4, f1.C.fm.adj4, f1.C.ff.adj4)

summary(f1.C)
summary(f1.C.adj2)
summary(f1.C.adj3)
summary(f1.C.adj4)
summary(f1.C.mm.adj4)
summary(f1.C.mf.adj4)
summary(f1.C.fm.adj4)
summary(f1.C.ff.adj4)


cis.cousin.asd = data.frame(g2)
save(asd.list, cis.cousin.asd, file="s_psy1203_cox_cousins_08_ASD-01.RData", compress=T)

g1=lapply(asd.list, reptab)
g2=t(as.matrix(data.frame(g1)))
rownames(g2)=NULL
colnames(g2)=c("Cases","Var.Ratio","RR (95% CI)")

rownames(g2)=c("Cousins - Crude", "Cousins - Adj2", "Cousins - Adj3", "Cousins - Adj4", "Cousins * Male-Male Adj4", "Cousins * Male-Female Adj4", "Cousins * Female-Male Adj4", "Cousins * Female-Female Adj4")

cis.cousin.asd = data.frame(g2)

cis.cousin.asd

save(asd.list, cis.cousin.asd, file="s_psy1203_cox_cousins_08_ASD.RData", compress=T)


#-- Output the results
sink("s_psy1203_cox_cousins_08_ASD.txt", split=T, append=FALSE)

options(width=160)

table(recur.x1$cens)

write("Average age at diagnosis for the cousins")
hepp=subset(recur.x1,recur.x1$cens<1)
summary(hepp$exit)

write("Number of ASD for cousins")
hepp=subset(recur.x1,recur.x1$cens<1)
table(hepp$cens)

lapply(ad.list, summary)

sink()


#-----------------------------------------------------------
# AD cousins
# Repeat code above
#-----------------------------------------------------------
rm(list=ls());gc(TRUE)

#-- reptab function extract CIs from the coxph objects
reptab = function (model) {
  #-- 3: dataset, 4: subset
  b=round(summary(model)$conf.int[1,], 3)
  #b=round(summary(f1.C.adj)$conf.int[1,], 3)
  varratio = round(model$var[1,1] / model$naive.var[1,1], 3)
  ci = paste(b[1],' (',b[3], '-', b[4], ')')
  #as.character(model$call[[3]]),

  c(as.character(model$nevent), as.character(varratio), ci)
}

load("psy1203_cousin_B.RData")


recur.x0 = subset(psy1203cousinB, subset=outcome=="AD")

#-- Remove multiple birth among F and half sibs
recur.x1 = subset(recur.x0, subset=(multiple=="Yes")==F)

recur.x1 = recur.x1[(names(recur.x1) %in% c("outcome", "multiple", "monozyg1", "monozyg2"))==FALSE]


rm(psy1203cousinB,recur.x0)

table(recur.x1$cens)

write("Average age at diagnosis")
hepp=subset(recur.x1,recur.x1$cens<1)
summary(hepp$exit)

write("Number of AD")
hepp=subset(recur.x1,recur.x1$cens<1)
table(hepp$cens)


f1.C =coxph(Surv(entry,exit,cens==0)~asd.exp + cluster(famid),data=recur.x1)

#f1.C.adj1 =update(f1.C, ~ . + bc) removed this since take so long time
f1.C.adj2 =update(f1.C, ~ . + bc + sex1 + sex2)
f1.C.adj3 =update(f1.C.adj2, ~ .  + mor.psych + far.psych)
f1.C.adj4 =update(f1.C.adj3, ~ .  + oldma +oldpa)

#- Sex specific full-sibs
#f1.C.mm = update(f1.C, ~ . + bc, subset=sex1=="Male" & sex2=="Male")
#f1.C.mf = update(f1.C, ~ . + bc, subset=sex1=="Male" & sex2=="Female")
#f1.C.fm = update(f1.C, ~ . + bc, subset=sex1=="Female" & sex2=="Male")
#f1.C.ff = update(f1.C, ~ . + bc, subset=sex1=="Female" & sex2=="Female")

#f1.C.mm.adj = update(f1.C.mm, ~ . + mor.psych + far.psych)
#f1.C.mf.adj = update(f1.C.mf, ~ . + mor.psych + far.psych)
#f1.C.fm.adj = update(f1.C.fm, ~ . + mor.psych + far.psych)
#f1.C.ff.adj = update(f1.C.ff, ~ . + mor.psych + far.psych)

f1.C.mm.adj4 = update(f1.C, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=sex1=="Male" & sex2=="Male"    )
f1.C.mf.adj4 = update(f1.C, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=sex1=="Male" & sex2=="Female"  )
f1.C.fm.adj4 = update(f1.C, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=sex1=="Female" & sex2=="Male"  )
f1.C.ff.adj4 = update(f1.C, ~ . + bc + mor.psych + far.psych + oldma +oldpa, subset=sex1=="Female" & sex2=="Female")


#-- Check
f1.C$n - (f1.C.mm.adj4$n+f1.C.mf.adj4$n+f1.C.fm.adj4$n+f1.C.ff.adj4$n)

ad.list=list(f1.C, f1.C.adj2, f1.C.adj3, f1.C.adj4, f1.C.mm.adj4, f1.C.mf.adj4, f1.C.fm.adj4, f1.C.ff.adj4)

summary(f1.C)
summary(f1.C.adj2)
summary(f1.C.adj3)
summary(f1.C.adj4)
summary(f1.C.mm.adj4)
summary(f1.C.mf.adj4)
summary(f1.C.fm.adj4)
summary(f1.C.ff.adj4)


print(ad.list)

save(ad.list, file="s_psy1203_cox_cousins_08_AD-01.RData", compress=T)


g1=lapply(ad.list, reptab)
g2=t(as.matrix(data.frame(g1)))
rownames(g2)=NULL
colnames(g2)=c("Cases","Var.Ratio","RR (95% CI)")
rownames(g2)=c("Cousins - Crude", "Cousins - Adj2", "Cousins - Adj3", "Cousins - Adj4", "Cousins * Male-Male Adj4", "Cousins * Male-Female Adj4", "Cousins * Female-Male Adj4", "Cousins * Female-Female Adj4")

cis.cousin.ad = data.frame(g2)

cis.cousin.ad

save(ad.list, cis.cousin.ad, file="s_psy1203_cox_cousins_08_AD.RData", compress=T)


#-- Output the results
sink("s_psy1203_cox_cousins_08_AD.txt", split=T, append=FALSE)

options(width=160)

table(recur.x1$cens)

write("Average age at diagnosis for the cousins")
hepp=subset(recur.x1,recur.x1$cens<1)
summary(hepp$exit)

write("Number of AD for cousins")
hepp=subset(recur.x1,recur.x1$cens<1)
table(hepp$cens)

lapply(ad.list, summary)

sink()


#-----------------------------------------------------------
# Using sibs exposed by older sibling
#-----------------------------------------------------------
rm(list=ls());gc(TRUE)

#-- reptab function extract CIs from the coxph objects
reptab = function (model) {
  #-- 3: dataset, 4: subset
  b=round(summary(model)$conf.int[1,], 3)
  #b=round(summary(f1.C.adj)$conf.int[1,], 3)
  varratio = round(model$var[1,1] / model$naive.var[1,1], 3)
  ci = paste(b[1],' (',b[3], '-', b[4], ')')
  #as.character(model$call[[3]]),

  c(as.character(model$nevent), as.character(varratio), ci)
}

load("psy1203_cousin_B.RData")


recur.x0 = subset(psy1203cousinB, subset=outcome=="ASD" and oldsib=="Yes")


#-- Remove multiple birth among F and half sibs
recur.x1 = subset(recur.x0, subset=(multiple=="Yes")==F)

recur.x1 = recur.x1[(names(recur.x1) %in% c("outcome", "multiple", "monozyg1", "monozyg2"))==FALSE]


rm(psy1203cousinB, recur.x0);gc()

table(recur.x1$cens)

write("Average age at diagnosis using only older sib for exposure")
hepp=subset(recur.x1,recur.x1$cens<1)
summary(hepp$exit)

write("Number of ASD using only older sib for exposure")
hepp=subset(recur.x1,recur.x1$cens<1)
table(hepp$cens)


f1.C.oldsib =coxph(Surv(entry,exit,cens==0)~asd.exp + cluster(famid),data=recur.x1)

#f1.C.adj1 =update(f1.C, ~ . + bc) removed this since take so long time
f1.C.oldsib.adj3 =update(f1.C, ~ . + bc + sex1 + sex2 + mor.psych + far.psych)
f1.C.oldsib.adj4 =update(f1.C.adj3, ~ .  + oldma +oldpa)


sink("s_psy1203_cox_cousins_08_OLDSIB.txt", split=T, append=FALSE)

summary(f1.C.oldsib)
summary(f1.C.oldsib.adj3)
summary(f1.C.oldsib.adj4)

sink()

#-- Cleanup ------------------------------------------------------------------
#rm(ls=c())

#-- End of File --------------------------------------------------------------


