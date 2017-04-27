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


#-- Cleanup ------------------------------------------------------------------
#rm(ls=c())

#-- End of File --------------------------------------------------------------
