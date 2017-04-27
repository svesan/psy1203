#-----------------------------------------------------------------------------
# Study.......: PSY1203
# Name........: survplot1_jama.R
# Date........: 2013-12-18
# Author......: svesan
# Purpose.....: Create survival curves estimating the autism prevalence up to age 20
# Note........: Had to update for the JAMA submission
#-----------------------------------------------------------------------------
# Data used...: x8.RData
# Data created:
#-----------------------------------------------------------------------------

#-- Libraries ----------------------------------------------------------------
#library()

#-- R functions --------------------------------------------------------------

#-- Calling external programs ------------------------------------------------
#source(file="/home/svesan/ki/AAA/AAA_Research/sasproj/PSY/PSY1203/R-Stata")

#-- Main program -------------------------------------------------------------
setwd("/home/svesan/ki/AAA/AAA_Research/sasproj/PSY/PSY1203/R-Stata")

#-- Read the 
load("psy1203_results_asd_B.RData")

load("psy1203_B.RData")
recur.x0 = subset(psy1203B, subset=outcome=="ASD")

#-- Remove multiple birth among F and half sibs
recur.x1 = subset(recur.x0, subset=(multiple=="Yes" & ft=="F")==F)
recur.x1 = subset(recur.x1, subset=(multiple=="Yes" & ft=="PH")==F)
recur.x1 = subset(recur.x1, subset=(multiple=="Yes" & ft=="MH")==F)

recur.x1 = recur.x1[(names(recur.x1) %in% c("outcome", "multiple", "monozyg1", "monozyg2"))==FALSE]

g=recur.x1

recur.x1=g

f1.F=asd.list[[1]]

data.new=data.frame(asd.exp=factor(c(0,1)))
#fit <- survfit(f1.F, conf.type="none")
#plot(fit$time, fit$surv, xlab="Time to ASD (yrs)", ylab="Survival Probability", type="s", ylim=c(0.75,1))

fit1=survfit(f1.F, newdata=data.new)

fit1.time  = fit1[1]$time
fit1.surv  = 100-fit1[1]$surv*100
fit2.surv  = 100-fit1[2]$surv*100
fit2.lower = 100-fit1[2]$lower*100
fit2.upper = 100-fit1[2]$upper*100

postscript("JAMA_Fig1.eps", width = 4.0, height = 4.0,
           horizontal = FALSE, onefile = FALSE, paper = "special")

  par(mar=c(4.2, 4.4, 1, 1), cex=0.8)
  plot(fit1[1]$time, fit1.surv, xlab="Age", ylab="ASD Probability (%)", type="s", ylim=c(0, 15), xlim=c(0,20), cex.axis=1.25, cex.lab=1.25, lwd=3, col="red")
  points(fit1[2]$time, fit2.surv,   type="s", lty=1, lwd=2, col="black") 
  points(fit1[2]$time, fit2.upper,  type="s", lty=1, lwd=1.5, col="gray35") 
  points(fit1[2]$time, fit2.lower,  type="s", lty=1, lwd=1.5, col="gray35") 

graphics.off()


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
#fit <- survfit(f1.F, conf.type="none")
#plot(fit$time, fit$surv, xlab="Time to ASD (yrs)", ylab="Survival Probability", type="s", ylim=c(0.75,1))

fit1.F=survfit(f1.F, newdata=data.new)

fit1.F.time  = fit1.F[1]$time
fit1.F.surv  = 100-fit1.F[1]$surv*100
fit2.F.surv  = 100-fit1.F[2]$surv*100
fit2.F.lower = 100-fit1.F[2]$lower*100
fit2.F.upper = 100-fit1.F[2]$upper*100

postscript("JAMA_Fig1_MH.eps", width = 4.0, height = 4.0,
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

postscript("JAMA_Fig1_MH.eps", width = 4.0, height = 4.0,
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

postscript("JAMA_Fig1_MH.eps", width = 4.0, height = 4.0,
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
#result: 1.380777 1.512686 1.611018 1.684511 1.763782


#-- Thus, at age 20 for full siblings there was 13% vs 1%, for maternal half sibs there was 9% vs 2% and paternal half sibs 7% vs 2%

#-- or with more decimals; for full sibs 12.9% vs 1%, for maternal half sibs there was 8.6% vs 1.8% and paternal half sibs 6.77% vs 1.6%


#-----------------------------------
# DZ twins
#-----------------------------------
#recur.x1 = subset(recur.x0, subset=(multiple=="Yes" & ft=="DZ")==T)
recur.x1 = subset(recur.x0, subset=(ft=="DZ")==T)
table(recur.x1$monozyg1, recur.x1$monozyg2)

f5.DZ=asd.list[[5]]

data.new=data.frame(asd.exp=factor(c(0,1)))

fit1.dz=survfit(f5.DZ, newdata=data.new)

fit1.dz.time  = fit1.dz[1]$time
fit1.dz.surv  = 100-fit1.dz[1]$surv*100
fit2.dz.surv  = 100-fit1.dz[2]$surv*100
fit2.dz.lower = 100-fit1.dz[2]$lower*100
fit2.dz.upper = 100-fit1.dz[2]$upper*100

postscript("JAMA_Fig1_MH.eps", width = 4.0, height = 4.0,
           horizontal = FALSE, onefile = FALSE, paper = "special")

  par(mar=c(4.2, 4.4, 1, 1), cex=0.8)
  plot(fit1.dz[1]$time, fit1.dz.surv, xlab="Age", ylab="ASD Probability (%)", type="s", ylim=c(0, 15), xlim=c(0,20), cex.axis=1.25, cex.lab=1.25, lwd=3, col="red")
  points(fit1.dz[2]$time, fit2.dz.surv,   type="s", lty=1, lwd=2, col="black") 
  points(fit1.dz[2]$time, fit2.dz.upper,  type="s", lty=1, lwd=1.5, col="gray35") 
  points(fit1.dz[2]$time, fit2.dz.lower,  type="s", lty=1, lwd=1.5, col="gray35") 
  abline(v=20, h=c(1, 1.2, 2))

gradzics.off()

#-- Write the predicted prevalence at ages 18 to 22
fit2.dz.surv[fit1.dz.time %in% c(18,19,20,21,22)]
#result: 11.77523 12.47898 12.94841 13.85589 14.46040

fit1.dz.surv[fit1.dz.time %in% c(18,19,20,21,22)]
#result: 1.098638 1.163264 1.233869 1.273663 1.324077


#-----------------------------------
# MZ twins
#-----------------------------------
#recur.x1 = subset(recur.x0, subset=(multiple=="Yes" & ft=="MZ")==T)
recur.x1 = subset(recur.x0, subset=(ft=="MZ")==T)
table(recur.x1$monozyg1, recur.x1$monozyg2)

f5.MZ=asd.list[[4]]

data.new=data.frame(asd.exp=factor(c(0,1)))

fit1.mz=survfit(f5.MZ, newdata=data.new)

fit1.mz.time  = fit1.mz[1]$time
fit1.mz.surv  = 100-fit1.mz[1]$surv*100
fit2.mz.surv  = 100-fit1.mz[2]$surv*100
fit2.mz.lower = 100-fit1.mz[2]$lower*100
fit2.mz.upper = 100-fit1.mz[2]$upper*100

postscript("JAMA_Fig1_MH.eps", width = 4.0, height = 4.0,
           horizontal = FALSE, onefile = FALSE, paper = "special")

  par(mar=c(4.2, 4.4, 1, 1), cex=0.8)
  plot(fit1.mz[1]$time, fit1.mz.surv, xlab="Age", ylab="ASD Probability (%)", type="s", ylim=c(0, 15), xlim=c(0,20), cex.axis=1.25, cex.lab=1.25, lwd=3, col="red")
  points(fit1.mz[2]$time, fit2.mz.surv,   type="s", lty=1, lwd=2, col="black") 
  points(fit1.mz[2]$time, fit2.mz.upper,  type="s", lty=1, lwd=1.5, col="gray35") 
  points(fit1.mz[2]$time, fit2.mz.lower,  type="s", lty=1, lwd=1.5, col="gray35") 
  abline(v=20, h=c(1, 1.2, 2))

gramzics.off()

#-- Write the predicted prevalence at ages 18 to 22
fit2.mz.surv[fit1.mz.time <20.25 & fit1.mz.time > 19.75]
#result: 59.17532 59.17532

fit1.mz.surv[fit1.mz.time <20.25 & fit1.mz.time > 19.75]
#result: 0.4118948 0.4118948



#-- Cleanup ------------------------------------------------------------------
#rm(ls=c())

#-- End of File --------------------------------------------------------------



f1.all =coxph(Surv(entry,exit,cens==0)~asd.exp + cluster(famid),data=recur.x1)


data.new=data.frame(asd.exp=factor(c(0,1)))

fit1.all=survfit(f1.all, newdata=data.new)

fit1.all.time  = fit1.all[1]$time
fit1.all.surv  = 100-fit1.all[1]$surv*100
fit2.all.surv  = 100-fit1.all[2]$surv*100
fit2.all.lower = 100-fit1.all[2]$lower*100
fit2.all.upper = 100-fit1.all[2]$upper*100

postscript("JAMA_Fig1_MH.eps", width = 4.0, height = 4.0,
           horizontal = FALSE, onefile = FALSE, paper = "special")

  par(mar=c(4.2, 4.4, 1, 1), cex=0.8)
  plot(fit1.all[1]$time, fit1.all.surv, xlab="Age", ylab="ASD Probability (%)", type="s", ylim=c(0, 15), xlim=c(0,20), cex.axis=1.25, cex.lab=1.25, lwd=3, col="red")
  points(fit1.all[2]$time, fit2.all.surv,   type="s", lty=1, lwd=2, col="black") 
  points(fit1.all[2]$time, fit2.all.upper,  type="s", lty=1, lwd=1.5, col="gray35") 
  points(fit1.all[2]$time, fit2.all.lower,  type="s", lty=1, lwd=1.5, col="gray35") 

graphics.off()



