################################################################################
###  File name: asd_ACE_20130419.r
###  Author:    Ralf Kuja-Halkola
###  Date:      20130419
###  Updated:   20130422
###  Purpose:   Fit models to estimate quantitative genetic parameters.
###
###  Note:      
################################################################################

################################################################################
### Information from previous model tests:
### * Different thresholds in 1st- and 2nd- offspring for non-twins
### * Same threshold in twin 1 and twin 2  (both MZ and DZ)
### * Different thresholds across all sibling-types
### (* Full sibs and DZ twins have similar correlation)
### (* MH and PHsibs have similar correlation)
################################################################################

### Needed libraries
library(OpenMx)
library(polycor)

### Read in data
load('C:/Users/ralkuj/Desktop/Work/Project/Autism Sven/Data/ralf_asd1.RData')
str(ralf_asd1)
table(ralf_asd1$ft)

### Variable names
varNames <- c('case1','case2')

### Gender names
sexNames <- c('sex1','sex2')
sum(is.na(ralf_asd1[, sexNames]))

### Fix data in OpenMx format
MZdat <- data.frame(mxFactor(ralf_asd1[ralf_asd1$ft=='MZ', varNames],levels=c(0,1)),1*(ralf_asd1[ralf_asd1$ft=='MZ', sexNames]=='Female'))
table(MZdat[,sexNames]) 
DZdat <- data.frame(mxFactor(ralf_asd1[ralf_asd1$ft=='DZ', varNames],levels=c(0,1)),1*(ralf_asd1[ralf_asd1$ft=='DZ', sexNames]=='Female'))
table(DZdat[,sexNames])
Fdat <- data.frame(mxFactor(ralf_asd1[ralf_asd1$ft=='F', varNames],levels=c(0,1)),1*(ralf_asd1[ralf_asd1$ft=='F', sexNames]=='Female'))
table(Fdat[,sexNames]) 
MHdat <- data.frame(mxFactor(ralf_asd1[ralf_asd1$ft=='MH', varNames],levels=c(0,1)),1*(ralf_asd1[ralf_asd1$ft=='MH', sexNames]=='Female'))
table(MHdat[,sexNames]) 
PHdat <- data.frame(mxFactor(ralf_asd1[ralf_asd1$ft=='PH', varNames],levels=c(0,1)),1*(ralf_asd1[ralf_asd1$ft=='PH', sexNames]=='Female'))
table(PHdat[,sexNames]) 

###################################################
### Set up ACE model /Maybe ADCE model
baseMod <- mxModel('Base',
### Gender fixed effect
  mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=-.3,name='Beta'),
### Quantitative genetic parameters
  mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.1,lbound=0,name='t2'),
  mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.46,lbound=0,name='a2'),
  mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.16,lbound=0,name='d2'),
  mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.1,lbound=0,name='c2'),
  mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.3,lbound=0,name='e2'),
### Constrain to keep variance==1
  mxMatrix(type='Full',nrow=1,ncol=1,free=c(F),values=1,lbound=0,name='One'),
  mxConstraint(t2+a2+d2+c2+e2==One , 'VarEqOne')
)

### Submodels and data input
MZmod <- mxModel('MZ',  
  mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.3,2.3),labels=c('thrMZ','thrMZ'),name='ThrMZ'),
  mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexMZ'),
  mxAlgebra( sexMZ%x%Base.Beta , name='MeanMZ'),
  mxAlgebra( rbind(cbind(Base.t2+Base.a2+Base.d2+Base.c2+Base.e2,Base.t2+Base.a2+Base.d2+Base.c2),
                   cbind(Base.t2+Base.a2+Base.d2+Base.c2        ,Base.t2+Base.a2+Base.d2+Base.c2+Base.e2)) ,name='expCovMZ'),
  mxData( MZdat , type='raw'),
  mxFIMLObjective(means='MeanMZ',covariance='expCovMZ',thresholds='ThrMZ',threshnames=varNames,dimnames=varNames)
)

DZmod <- mxModel('DZ',  
  mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.3,2.3),labels=c('thrDZ','thrDZ'),name='ThrDZ'),
  mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexDZ'),
  mxAlgebra( sexDZ%x%Base.Beta , name='MeanDZ'),
  mxAlgebra( rbind(cbind(Base.t2+Base.a2+Base.d2+Base.c2+Base.e2,Base.t2+.5*Base.a2+.25*Base.d2+Base.c2),
                   cbind(Base.t2+.5*Base.a2+.25*Base.d2+Base.c2     ,Base.t2+Base.a2+Base.d2+Base.c2+Base.e2)) ,name='expCovDZ'),
  mxData( DZdat , type='raw'),
  mxFIMLObjective(means='MeanDZ',covariance='expCovDZ',thresholds='ThrDZ',threshnames=varNames,dimnames=varNames)
)

Fullmod <- mxModel('Full',  
  mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.3,2.3),labels=c('thrF1','thrF2'),name='ThrF'),
  mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexF'),
  mxAlgebra( sexF%x%Base.Beta , name='MeanF'),
  mxAlgebra( rbind(cbind(Base.t2+Base.a2+Base.d2+Base.c2+Base.e2,.5*Base.a2+.25*Base.d2+Base.c2),
                   cbind(.5*Base.a2+.25*Base.d2+Base.c2     ,Base.t2+Base.a2+Base.d2+Base.c2+Base.e2)) ,name='expCovF'),
  mxData( Fdat , type='raw'),
  mxFIMLObjective(means='MeanF',covariance='expCovF',thresholds='ThrF',threshnames=varNames,dimnames=varNames)
)

MHmod <- mxModel('MH',  
  mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.3,2.3),labels=c('thrMH1','thrMH2'),name='ThrMH'),
  mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexMH'),
  mxAlgebra( sexMH%x%Base.Beta , name='MeanMH'),
  mxAlgebra( rbind(cbind(Base.t2+Base.a2+Base.d2+Base.c2+Base.e2,.25*Base.a2+Base.c2),
                   cbind(.25*Base.a2+Base.c2    ,Base.t2+Base.a2+Base.d2+Base.c2+Base.e2)) ,name='expCovMH'),
  mxData( MHdat , type='raw'),
  mxFIMLObjective(means='MeanMH',covariance='expCovMH',thresholds='ThrMH',threshnames=varNames,dimnames=varNames)
)

PHmod <- mxModel('PH',  
  mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.3,2.3),labels=c('thrPH1','thrPH2'),name='ThrPH'),
  mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexPH'),
  mxAlgebra( sexPH%x%Base.Beta , name='MeanPH'),
  mxAlgebra( rbind(cbind(Base.t2+Base.a2+Base.d2+Base.c2+Base.e2,.25*Base.a2),
                   cbind(.25*Base.a2            ,Base.t2+Base.a2+Base.d2+Base.c2+Base.e2)) ,name='expCovPH'),
  mxData( PHdat , type='raw'),
  mxFIMLObjective(means='MeanPH',covariance='expCovPH',thresholds='ThrPH',threshnames=varNames,dimnames=varNames)
)

### Gather submodels
TADCEmod <- mxModel( 'TADCE' , baseMod , MZmod , DZmod , Fullmod , MHmod , PHmod ,
  mxAlgebra( MZ.objective+DZ.objective+Full.objective+MH.objective+PH.objective , name='m2ll'),
  mxAlgebraObjective('m2ll')
)
### Run model
TADCEmodFit <- mxRun( TADCEmod )

### Look at output
summary(TADCEmodFit)
0.461412943 + 0.154816380

##############################
### ADCE model:
ADCEmod <- mxModel( 'ADCE' , baseMod , MZmod , DZmod , Fullmod , MHmod , PHmod ,
  mxAlgebra( MZ.objective+DZ.objective+Full.objective+MH.objective+PH.objective , name='m2ll'),
  mxAlgebraObjective('m2ll')
)                                                           
### Fix t2-parameter at 0
ADCEmod@submodels$Base@matrices$t2@values <- matrix(0,1,1)
ADCEmod@submodels$Base@matrices$t2@free <- matrix(F,1,1)
### Run model
ADCEmodFit <- mxRun( ADCEmod )

### Look at output
summary(ADCEmodFit)
0.458199104 +  0.16169641

### Likelihood ratio test             
#mxCompare(satModFit,TADCEmodFit)
mxCompare(TADCEmodFit,ADCEmodFit)

#############################
### ACE model: 
ACEmod <- mxModel( 'ACE' , baseMod , MZmod , DZmod , Fullmod , MHmod , PHmod ,
  mxAlgebra( MZ.objective+DZ.objective+Full.objective+MH.objective+PH.objective , name='m2ll'),
  mxAlgebraObjective('m2ll'),
### Confidence bounds
  mxCI(c('Base.a2','Base.c2','Base.e2'))
)
### Fix t2-parameter at 0
ACEmod@submodels$Base@matrices$t2@values <- matrix(0,1,1)
ACEmod@submodels$Base@matrices$t2@free <- matrix(F,1,1)
### Fix d2-parameter at 0
ACEmod@submodels$Base@matrices$d2@values <- matrix(0,1,1)
ACEmod@submodels$Base@matrices$d2@free <- matrix(F,1,1)

### Fit model , running intervals makes takes much longer
ACEmodFit <- mxRun( ACEmod , intervals=FALSE )
summary(ACEmodFit)
0.5443067

### Likelihood ratio test          
#mxCompare(satModFit,ACEmodFit)
mxCompare(TADCEmodFit,ACEmodFit)
mxCompare(ADCEmodFit,ACEmodFit)

summary(ACEmodFit)$Minus2LogLikelihood

### Profile likelihood confidence intervals
round(summary(ACEmodFit)$CI,6)
##########################


#############################
### ADE model: 
ADEmod <- mxModel( 'ADE' , baseMod , MZmod , DZmod , Fullmod , MHmod , PHmod ,
  mxAlgebra( MZ.objective+DZ.objective+Full.objective+MH.objective+PH.objective , name='m2ll'),
  mxAlgebraObjective('m2ll'),
### Confidence bounds
  mxCI(c('Base.a2','Base.d2','Base.e2'))
)
### Fix t2-parameter at 0
ADEmod@submodels$Base@matrices$t2@values <- matrix(0,1,1)
ADEmod@submodels$Base@matrices$t2@free <- matrix(F,1,1)
### Fix c2-parameter at 0
ADEmod@submodels$Base@matrices$c2@values <- matrix(0,1,1)
ADEmod@submodels$Base@matrices$c2@free <- matrix(F,1,1)

### Fit model , running intervals makes takes much longer
ADEmodFit <- mxRun( ADEmod , intervals=FALSE )
summary(ADEmodFit)
0.4665714+0.1606355

### Likelihood ratio test
#mxCompare(satModFit,ADEmodFit)
mxCompare(TADCEmodFit,ADEmodFit)
mxCompare(ADCEmodFit,ADEmodFit)

summary(ADEmodFit)$Minus2LogLikelihood

### Profile likelihood confidence intervals
round(summary(ADEmodFit)$CI,6)
##########################


#############################
### AE model: 
AEmod <- mxModel( 'AE' , baseMod , MZmod , DZmod , Fullmod , MHmod , PHmod ,
  mxAlgebra( MZ.objective+DZ.objective+Full.objective+MH.objective+PH.objective , name='m2ll'),
  mxAlgebraObjective('m2ll'),
### Confidence bounds
  mxCI(c('Base.a2','Base.e2'))
)
### Fix t2-parameter at 0
AEmod@submodels$Base@matrices$t2@values <- matrix(0,1,1)
AEmod@submodels$Base@matrices$t2@free <- matrix(F,1,1)
### Fix d2-parameter at 0
AEmod@submodels$Base@matrices$c2@values <- matrix(0,1,1)
AEmod@submodels$Base@matrices$c2@free <- matrix(F,1,1)
### Fix d2-parameter at 0
AEmod@submodels$Base@matrices$d2@values <- matrix(0,1,1)
AEmod@submodels$Base@matrices$d2@free <- matrix(F,1,1)

### Fit model , running intervals makes takes much longer
AEmodFit <- mxRun( AEmod , intervals=TRUE )
summary(AEmodFit)

### Likelihood ratio test
#mxCompare(satModFit,AEmodFit)
mxCompare(TADCEmodFit,AEmodFit)
mxCompare(ADCEmodFit,AEmodFit)
mxCompare(ADEmodFit,AEmodFit)

### Profile likelihood confidence intervals
round(summary(AEmodFit)$CI,4)
##########################


################################################################################
### Likelihood ratio tests for all models
#mxCompare(satMod7Fit,list(TADCEmodFit,ADCEmodFit,ACEmodFit,ADEmodFit,AEmodFit))
#mxCompare(satModFit,list(TADCEmodFit,ADCEmodFit,ACEmodFit,ADEmodFit,AEmodFit))
mxCompare(TADCEmodFit,list(ADCEmodFit,ACEmodFit,ADEmodFit,AEmodFit))
mxCompare(ADCEmodFit,list(ACEmodFit,ADEmodFit,AEmodFit))
mxCompare(ADEmodFit,list(ACEmodFit,AEmodFit)) 
mxCompare(ACEmodFit,list(ADEmodFit,AEmodFit))
################################################################################




################################################################################
################################ END OF FILE ################################### 
################################################################################