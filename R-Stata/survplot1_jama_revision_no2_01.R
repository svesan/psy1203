#-----------------------------------------------------------------------------
# Study.......: PSY1203
# Name........: survplot1_jama_revision_no2_01.R
# Date........: 2014-03-28
# Author......: svesan
# Purpose.....: Answer last (?) questions from JAMA following their acceptance
# ............: of the manuscript.
# Note........: They wanted exact prevalence figures corresponding to figure 1
# ............: for the all the family relations
#-----------------------------------------------------------------------------
# Data used...: x8.RData
# Data created:
#-----------------------------------------------------------------------------

#-- Libraries ----------------------------------------------------------------
library(survival)

#-- R functions --------------------------------------------------------------

#-- Calling external programs ------------------------------------------------
#source(file="/home/svesan/ki/AAA/AAA_Research/sasproj/PSY/PSY1203/R-Stata")

#-- Main program -------------------------------------------------------------
#setwd("/home/svesan/ki/AAA/AAA_Research/sasproj/PSY/PSY1203/R-Stata")
setwd("/home/svesan/ki/ABS/mep/sasproj/PSY/PSY1203/R-Stata")

#-- Read the 
#load("psy1203_results_asd_B.RData")
load("psy1203_results_nocousins_asd_C.RData")

load("psy1203_B.RData")

recur.x0 = subset(psy1203B, subset=outcome=="ASD")

#-- Remove multiple birth among F and half sibs
recur.x1 = subset(recur.x0, subset=(multiple=="Yes" & ft=="F")==F)
recur.x1 = subset(recur.x1, subset=(multiple=="Yes" & ft=="PH")==F)
recur.x1 = subset(recur.x1, subset=(multiple=="Yes" & ft=="MH")==F)

recur.x1 = recur.x1[(names(recur.x1) %in% c("outcome", "multiple", "monozyg1", "monozyg2"))==FALSE]

g=recur.x1



#-----------------------------------
# Full sibs
#-----------------------------------
recur.x1=subset(g, ft=="F")

#-- Cases and person year for the two curves in the figure
a=recur.x1[names(recur.x1) %in% c("exit", "entry", "asd.exp", "cens")==TRUE]; a$pyear=a$exit-a$entry
c(sum(1-a$cens[a$asd.exp==1]),sum(a$pyear[a$asd.exp==1]))
c(sum(1-a$cens[a$asd.exp==0]),sum(a$pyear[a$asd.exp==0]))


f1.F=asd.list[[1]]

data.new=data.frame(asd.exp=factor(c(0,1)))

fit1.F=survfit(f1.F, newdata=data.new)

fit1.F.time  = fit1.F[1]$time
fit1.F.surv  = 100-fit1.F[1]$surv*100
fit2.F.surv  = 100-fit1.F[2]$surv*100
fit2.F.lower = 100-fit1.F[2]$lower*100
fit2.F.upper = 100-fit1.F[2]$upper*100

postscript("JAMA_Figure1_F.eps", width = 4.0, height = 4.0,
           horizontal = FALSE, onefile = FALSE, paper = "special")

  par(mar=c(4.2, 4.4, 1, 1), cex=0.8)
  plot(fit1.F[1]$time, fit1.F.surv, xlab="Age", ylab="ASD Probability (%)", type="s", ylim=c(0, 15), xlim=c(0,20), cex.axis=1.25, cex.lab=1.25, lwd=3, col="red")
  points(fit1.F[2]$time, fit2.F.surv,   type="s", lty=1, lwd=2, col="black") 
  points(fit1.F[2]$time, fit2.F.upper,  type="s", lty=1, lwd=1.5, col="gray35") 
  points(fit1.F[2]$time, fit2.F.lower,  type="s", lty=1, lwd=1.5, col="gray35") 
  #abline(v=20, h=c(1,1.1,1.2))

graphics.off()

#-- Write the predicted prevalence at ages 18 to 22
cbind(fit2.F.surv, 1:2700)[fit1.F.time %in% c(18,19,20,21,22)]
#result: 11.05208   12.08140   12.89868   13.69201   14.48202 

fit1.F.surv[fit1.F.time %in% c(18,19,20,21,22)]
#result: 0.8129593 0.8933921 0.9578812 1.0210219 1.0844369

#-----------------------------------
# Maternal half sibs
#-----------------------------------

recur.x1=subset(g, ft=="MH")

f2.MH=asd.list[[2]]

data.new=data.frame(asd.exp=factor(c(0,1)))
#fit <- survfit(f1.F, conf.type="none")
#plot(fit$time, fit$surv, xlab="Time to ASD (yrs)", ylab="Survival Probability", type="s", ylim=c(0.75,1))

fit1.mh=survfit(f2.MH, newdata=data.new)

fit1.mh.time  = fit1.mh[1]$time
fit1.mh.surv  = 100-fit1.mh[1]$surv*100
fit2.mh.surv  = 100-fit1.mh[2]$surv*100
fit2.mh.lower = 100-fit1.mh[2]$lower*100
fit2.mh.upper = 100-fit1.mh[2]$upper*100

postscript("JAMA_Figure1_MH.eps", width = 4.0, height = 4.0,
           horizontal = FALSE, onefile = FALSE, paper = "special")

  par(mar=c(4.2, 4.4, 1, 1), cex=0.8)
  plot(fit1.mh[1]$time, fit1.mh.surv, xlab="Age", ylab="ASD Probability (%)", type="s", ylim=c(0, 15), xlim=c(0,20), cex.axis=1.25, cex.lab=1.25, lwd=3, col="red")
  points(fit1.mh[2]$time, fit2.mh.surv,   type="s", lty=1, lwd=2, col="black") 
  points(fit1.mh[2]$time, fit2.mh.upper,  type="s", lty=1, lwd=1.5, col="gray35") 
  points(fit1.mh[2]$time, fit2.mh.lower,  type="s", lty=1, lwd=1.5, col="gray35") 
  abline(v=20, h=c(1, 1.2, 2))

graphics.off()

#-- Write the predicted prevalence at ages 18 to 22
fit2.mh.surv[fit1.mh.time %in% c(18,19,20,21,22)]
#result: 7.437904 8.044643 8.555414 9.023299 9.423913  and 1.539425 1.669313 1.779188 1.880270 1.967149

fit1.mh.surv[fit1.mh.time %in% c(18,19,20,21,22)]
#result: 1.539425 1.669313 1.779188 1.880270 1.967149


#-----------------------------------
# Paternal half sibs
#-----------------------------------
recur.x1=subset(g, ft=="PH")

f3.PH=asd.list[[3]]

data.new=data.frame(asd.exp=factor(c(0,1)))

fit1.ph=survfit(f3.PH, newdata=data.new)

fit1.ph.time  = fit1.ph[1]$time
fit1.ph.surv  = 100-fit1.ph[1]$surv*100
fit2.ph.surv  = 100-fit1.ph[2]$surv*100
fit2.ph.lower = 100-fit1.ph[2]$lower*100
fit2.ph.upper = 100-fit1.ph[2]$upper*100

postscript("JAMA_Figure1_PH.eps", width = 4.0, height = 4.0,
           horizontal = FALSE, onefile = FALSE, paper = "special")

  par(mar=c(4.2, 4.4, 1, 1), cex=0.8)
  plot(fit1.ph[1]$time, fit1.ph.surv, xlab="Age", ylab="ASD Probability (%)", type="s", ylim=c(0, 15), xlim=c(0,20), cex.axis=1.25, cex.lab=1.25, lwd=3, col="red")
  points(fit1.ph[2]$time, fit2.ph.surv,   type="s", lty=1, lwd=2, col="black") 
  points(fit1.ph[2]$time, fit2.ph.upper,  type="s", lty=1, lwd=1.5, col="gray35") 
  points(fit1.ph[2]$time, fit2.ph.lower,  type="s", lty=1, lwd=1.5, col="gray35") 
  abline(v=20, h=c(1, 1.2, 2))

graphics.off()

#-- Write the predicted prevalence at ages 18 to 22
fit2.ph.surv[fit1.ph.time %in% c(18,19,20,21,22)]
#result: 5.821902 6.309147 6.699141 6.965098 7.319690

fit1.ph.surv[fit1.ph.time %in% c(18,19,20,21,22)]
#result: 1.406517 1.527215 1.624168 1.690463 1.779077


#-- Thus, at age 20 for full siblings there was 13% vs 1%, for maternal half sibs there was 9% vs 2% and paternal half sibs 7% vs 2%

#-- or with more decimals; for full sibs 12.9% vs 1%, for maternal half sibs there was 8.6% vs 1.8% and paternal half sibs 6.77% vs 1.6%


#-----------------------------------
# DZ twins
#-----------------------------------
rm(recur.x1)
recur.x1 = subset(g, subset=(ft=="DZ")==T)
table(recur.x1$monozyg1, recur.x1$monozyg2)

f5.DZ=asd.list[[5]]

data.new=data.frame(asd.exp=factor(c(0,1)))

fit1.dz=survfit(f5.DZ, newdata=data.new)

fit1.dz.time  = fit1.dz[1]$time
fit1.dz.surv  = 100-fit1.dz[1]$surv*100
fit2.dz.surv  = 100-fit1.dz[2]$surv*100
fit2.dz.lower = 100-fit1.dz[2]$lower*100
fit2.dz.upper = 100-fit1.dz[2]$upper*100

postscript("JAMA_Figure1_DZ.eps", width = 4.0, height = 4.0,
           horizontal = FALSE, onefile = FALSE, paper = "special")

  par(mar=c(4.2, 4.4, 1, 1), cex=0.8)
  plot(fit1.dz[1]$time, fit1.dz.surv, xlab="Age", ylab="ASD Probability (%)", type="s", ylim=c(0, 25), xlim=c(0,20), cex.axis=1.25, cex.lab=1.25, lwd=3, col="red")
  points(fit1.dz[2]$time, fit2.dz.surv,   type="s", lty=1, lwd=2, col="black") 
  points(fit1.dz[2]$time, fit2.dz.upper,  type="s", lty=1, lwd=1.5, col="gray35") 
  points(fit1.dz[2]$time, fit2.dz.lower,  type="s", lty=1, lwd=1.5, col="gray35") 
  abline(v=20, h=c(1, 1.2, 2))

graphics.off()

#-- Write the predicted prevalence at ages 18 to 22
fit2.dz.surv[fit1.dz.time %in% c(18,19,20,21,22)]
#result: 11.77523 12.47898 12.94841 13.85589 14.46040

fit1.dz.surv[fit1.dz.time %in% c(18,19,20,21,22)]
#result: 1.006522 1.070519 1.113471 1.197111 1.253278



#-----------------------------------
# MZ twins
#-----------------------------------
rm(recur.x1)
recur.x1 = subset(g, subset=(ft=="MZ")==T)
table(recur.x1$monozyg1, recur.x1$monozyg2)

f4.MZ=asd.list[[4]]

data.new=data.frame(asd.exp=factor(c(0,1)))

fit1.mz=survfit(f4.MZ, newdata=data.new)

fit1.mz.time  = fit1.mz[1]$time
fit1.mz.surv  = 100-fit1.mz[1]$surv*100
fit2.mz.surv  = 100-fit1.mz[2]$surv*100
fit2.mz.lower = 100-fit1.mz[2]$lower*100
fit2.mz.upper = 100-fit1.mz[2]$upper*100

postscript("JAMA_Figure1_MZ.eps", width = 4.0, height = 4.0,
           horizontal = FALSE, onefile = FALSE, paper = "special")

  par(mar=c(4.2, 4.4, 1, 1), cex=0.8)
  plot(fit1.mz[1]$time, fit1.mz.surv, xlab="Age", ylab="ASD Probability (%)", type="s", ylim=c(0, 85), xlim=c(0,20), cex.axis=1.25, cex.lab=1.25, lwd=3, col="red")
  points(fit1.mz[2]$time, fit2.mz.surv,   type="s", lty=1, lwd=2, col="black") 
  points(fit1.mz[2]$time, fit2.mz.upper,  type="s", lty=1, lwd=1.5, col="gray35") 
  points(fit1.mz[2]$time, fit2.mz.lower,  type="s", lty=1, lwd=1.5, col="gray35") 
#  abline(v=20, h=c(1, 1.2, 2))

graphics.off()

#-- Write the predicted prevalence at ages 18 to 22
fit2.mz.surv[fit1.mz.time <20.25 & fit1.mz.time > 19.75]
#result: 59.17532 59.17532

fit1.mz.surv[fit1.mz.time <20.25 & fit1.mz.time > 19.75]
#result: 0.4118948 0.4118948


#==============================================
# NOW DO THE COUSINS
#==============================================
load("s_psy1203_cox_cousins_08_ASD.RData")
load("psy1203_cousin_B.RData")

#-----------------------------------------------------------
# ASD cousins
#-----------------------------------------------------------
recur.x0 = subset(psy1203cousinB, subset=outcome=="ASD")

#-- Remove multiple birth among F and half sibs
recur.x1 = subset(recur.x0, subset=(multiple=="Yes")==F)

recur.x1 = recur.x1[(names(recur.x1) %in% c("outcome", "multiple", "monozyg1", "monozyg2"))==FALSE]


f1.C=asd.list[[1]]

data.new=data.frame(asd.exp=factor(c(0,1)))

fit1.C=survfit(f1.C, newdata=data.new)

fit1.C.time  = fit1.C[1]$time
fit1.C.surv  = 100-fit1.C[1]$surv*100
fit2.C.surv  = 100-fit1.C[2]$surv*100
fit2.C.lower = 100-fit1.C[2]$lower*100
fit2.C.upper = 100-fit1.C[2]$upper*100

postscript("JAMA_Figure1_cousins.eps", width = 4.0, height = 4.0,
           horizontal = FALSE, onefile = FALSE, paper = "special")

  par(mar=c(4.2, 4.4, 1, 1), cex=0.8)
  plot(fit1.C[1]$time, fit1.C.surv, xlab="Age", ylab="ASD Probability (%)", type="s", ylim=c(0, 15), xlim=c(0,20), cex.axis=1.25, cex.lab=1.25, lwd=3, col="red")
  points(fit1.C[2]$time, fit2.C.surv,   type="s", lty=1, lwd=2, col="black") 
  points(fit1.C[2]$time, fit2.C.upper,  type="s", lty=1, lwd=1.5, col="gray35") 
  points(fit1.C[2]$time, fit2.C.lower,  type="s", lty=1, lwd=1.5, col="gray35") 
#  abline(v=20, h=c(1, 1.2, 2))

graphics.off()

#-- Write the predicted prevalence at ages 18 to 22
fit2.C.surv[fit1.C.time %in% c(18,19,20,21,22)]
#result: 2.171233 2.388852 2.563104 2.736799 2.895254

fit1.C.surv[fit1.C.time %in% c(18,19,20,21,22)]
#result: 0.8030468 0.8841543 0.9491810 1.0140735 1.0733362


#Text for the manuscript:

#For participants with a full sibling with ASD the cumulative probability of and ASD diagnosis at age 20 #was estimated at 12.9% for full siblings, 8.6% for maternal half siblings, 6.8% for paternal half siblings #and for cousins 2.6%, 12.9% for DZ twins and 59.2% for MZ twins.


#-- Cleanup ------------------------------------------------------------------
#rm(ls=c())

#-- End of File --------------------------------------------------------------

