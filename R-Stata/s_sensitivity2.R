#-----------------------------------------------------------------------------
# Study.......: PSY1203
# Name........: s_sensitivity2.R
# Date........: 2014-03-03
# Author......: svesan
# Purpose.....: Sensitivity analyses following the jama revison
# Note........: Check adjustment by yearly birth year and stratify by family 
# ............: size                              
#-----------------------------------------------------------------------------
# Data used...:
# Data created:
#-----------------------------------------------------------------------------

#-- Libraries ----------------------------------------------------------------
rm(list=ls());gc(TRUE)
library(survival)

#-- R functions --------------------------------------------------------------


#-- Calling external programs ------------------------------------------------
#source(file="/home/workspace/projects/AAA/AAA_Research/sasproj/PSY/PSY1203/R-

#-- Main program -------------------------------------------------------------
sink("s_psy1203_sensitivity2.txt", split=T, append=FALSE)
options(width=100)

#setwd("/home/svesan/ki/AAA/AAA_Research/sasproj/PSY/PSY1203/R-Stata/")
setwd("/home/svesan/ki/ABS/mep/sasproj/PSY/PSY1203/R-Stata/")

#source("jama1.R")
#save("jama1", file="jama1.R", compress=T)

#-- Note, This dataset should be the same as psy1203B but only ASD and only ft=F
load("jama1.RData")

jama1$outcome="ASD"
jama1$ft="F"

#-----------------------------------------------------------
# ASD singletons
#-----------------------------------------------------------
recur.x0 = subset(jama1, subset=outcome=="ASD")

#-- Remove multiple birth among F and half sibs
recur.x1 = subset(recur.x0, subset=(multiple=="Yes" & ft=="F")==F)

recur.x1 = recur.x1[(names(recur.x1) %in% c("outcome", "multiple", "monozyg1", "monozyg2"))==FALSE]

summary(recur.x1)

rm(recur.x0, jama1);gc()

#-----------------------------------------------------------
# First check that the results are the same as for psy1203B
#-----------------------------------------------------------
load("/home/svesan/ki/ABS/mep/sasproj/PSY/PSY1203/R-Stata/psy1203_B.RData")
recur.z0 = subset(psy1203B, subset=outcome=="ASD" & ft=="F")

#-- Remove multiple birth among F and half sibs
recur.z1 = subset(recur.z0, subset=(multiple=="Yes" & ft=="F")==F)
recur.z1 = subset(recur.z1, subset=(multiple=="Yes" & ft=="PH")==F)
recur.z1 = subset(recur.z1, subset=(multiple=="Yes" & ft=="MH")==F)

recur.z1 = recur.z1[(names(recur.x1) %in% c("outcome", "multiple", "monozyg1", "monozyg2"))==FALSE]

summary(recur.z1)

rm(psy1203B,jama1,recur.x0);gc()


table(recur.x1$cens)

write("Average age at diagnosis. Dataset psy1203B (for check purposes)")
hepp=subset(recur.z1,recur.x1$cens<1)
by(hepp$exit, hepp$ft, mean)

write("Number of ASD. Dataset psy1203B (for check purposes)")
by(hepp$cens, hepp$ft, table)

write("Cox fully adjusted, full sib, ASD. Dataset psy1203B (for check purposes)")
coxph(Surv(entry,exit,cens==0)~asd.exp + bc  + sex1 + sex2 + mor.psych + far.psych + oldma +oldpa + cluster(famid),data=recur.z1)



#=========================================================================
# First compare adjustment using 5-year intervals with one-year-intervals
#=========================================================================
f1.F = coxph(Surv(entry,exit,cens==0) ~ asd.exp + cluster(famid), data=recur.x1)

f1.F.adj1 =update(f1.F, ~ . + bc)
f1.F.adj2 =update(f1.F, ~ . + ns(byr,df=3))

f1.F.adj3 =update(f1.F.adj1, ~ . + sex1 + sex2 + mor.psych + far.psych + oldma +oldpa)
f1.F.adj4 =update(f1.F.adj2, ~ . + sex1 + sex2 + mor.psych + far.psych + oldma +oldpa)

write("Adjusting for birth cohorts in 5-year categories")
summary(f1.F.adj1)
summary(f1.F.adj2)

summary(f1.F.adj3)
summary(f1.F.adj4)

#=========================================================================
# Then, stratify by familsize
#=========================================================================
fs2 = update(f1.F.adj3, subset=famsize==2)
fs3 = update(f1.F.adj3, subset=famsize==3)
fs4 = update(f1.F.adj3, subset=famsize==4)
fs5 = update(f1.F.adj3, subset=famsize==5)
fs6 = update(f1.F.adj3, subset=famsize==6)
fs6b= update(f1.F.adj3, subset=famsize>5)


summary(fs2)
summary(fs3)
summary(fs4)
summary(fs5)
summary(fs6)
summary(fs6b)

#-- Calculated cumulateiv family size and ASD cases
a=table(recur.x1$famsize, (1-recur.x1$cens))
b=matrix(a,ncol=2)
c=b
c[,1]=round(100*c[,1]/sum(c[,1]),digit=2)
c[,2]=round(100*c[,2]/sum(c[,2]),digit=2)
cbind(b,c)

#-- cumulative for >5
d=b
d[7,] = c(sum(d[6:13,1]), sum(d[6:13,2]))
d = d[1:7,]
e = d
d[,1]=round(100*d[,1]/sum(d[,1]),digit=2)
d[,2]=round(100*d[,2]/sum(d[,2]),digit=2)
cbind(d, e)


sink()


#-- Cleanup ------------------------------------------------------------------
#rm(ls=c())

#-- End of File --------------------------------------------------------------
