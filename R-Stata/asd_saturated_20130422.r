################################################################################
###  File name: asd_saturated_20130422.r
###  Study:     Autism: familial recurrence
###  Author:    Ralf Kuja-Halkola
###  Date:      20130419
###  Updated:   20130422
###  Purpose:   Fit models to see whether prevalences may be assumed equal
###             in different groups.
###  Note:      Not effeiciently programmed, will take up a large chunk of 
###             the RAM. Fairly poorly commented. Starting values are important
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

### Some tetrachoric correlations
# All genders
tab <- table(ralf_asd1[, varNames])
polychor( tab , ML=T,std.err=T)
MZtab <- ralf_asd1[ralf_asd1$ft=='MZ', varNames]
table(MZtab)
polychor( table(MZtab) , ML=T,std.err=T)
DZtab <- ralf_asd1[ralf_asd1$ft=='DZ', varNames]
table(DZtab)
polychor( table(DZtab) , ML=T,std.err=T)
Ftab <- ralf_asd1[ralf_asd1$ft=='F', varNames]
table(Ftab)
polychor( table(Ftab) , ML=T,std.err=T)
MHtab <- ralf_asd1[ralf_asd1$ft=='MH', varNames]
table(MHtab)
polychor( table(MHtab) , ML=T,std.err=T)
PHtab <- ralf_asd1[ralf_asd1$ft=='PH', varNames]
table(PHtab)
polychor( table(PHtab) , ML=T,std.err=T)
# Female
tab <- table(ralf_asd1[ralf_asd1$sex1=='Female'&ralf_asd1$sex2=='Female', varNames])
polychor( tab , ML=T,std.err=T)
MZtab <- ralf_asd1[ralf_asd1$ft=='MZ'&ralf_asd1$sex1=='Female'&ralf_asd1$sex2=='Female', varNames]
table(MZtab)
polychor( table(MZtab) , ML=T,std.err=T)
DZtab <- ralf_asd1[ralf_asd1$ft=='DZ'&ralf_asd1$sex1=='Female'&ralf_asd1$sex2=='Female', varNames]
table(DZtab)
polychor( table(DZtab) , ML=T,std.err=T)
Ftab <- ralf_asd1[ralf_asd1$ft=='F'&ralf_asd1$sex1=='Female'&ralf_asd1$sex2=='Female', varNames]
table(Ftab)
polychor( table(Ftab) , ML=T,std.err=T)
MHtab <- ralf_asd1[ralf_asd1$ft=='MH'&ralf_asd1$sex1=='Female'&ralf_asd1$sex2=='Female', varNames]
table(MHtab)
polychor( table(MHtab) , ML=T,std.err=T)
PHtab <- ralf_asd1[ralf_asd1$ft=='PH'&ralf_asd1$sex1=='Female'&ralf_asd1$sex2=='Female', varNames]
table(PHtab)
polychor( table(PHtab) , ML=T,std.err=T)

# Male
tab <- table(ralf_asd1[ralf_asd1$sex1=='Male'&ralf_asd1$sex2=='Male', varNames])
polychor( tab , ML=T,std.err=T)
MZtab <- ralf_asd1[ralf_asd1$ft=='MZ'&ralf_asd1$sex1=='Male'&ralf_asd1$sex2=='Male', varNames]
table(MZtab)
polychor( table(MZtab) , ML=T,std.err=T)
DZtab <- ralf_asd1[ralf_asd1$ft=='DZ'&ralf_asd1$sex1=='Male'&ralf_asd1$sex2=='Male', varNames]
table(DZtab)
polychor( table(DZtab) , ML=T,std.err=T)
Ftab <- ralf_asd1[ralf_asd1$ft=='F'&ralf_asd1$sex1=='Male'&ralf_asd1$sex2=='Male', varNames]
table(Ftab)
polychor( table(Ftab) , ML=T,std.err=T)
MHtab <- ralf_asd1[ralf_asd1$ft=='MH'&ralf_asd1$sex1=='Male'&ralf_asd1$sex2=='Male', varNames]
table(MHtab)
polychor( table(MHtab) , ML=T,std.err=T)
PHtab <- ralf_asd1[ralf_asd1$ft=='PH'&ralf_asd1$sex1=='Male'&ralf_asd1$sex2=='Male', varNames]
table(PHtab)
polychor( table(PHtab) , ML=T,std.err=T)

# Female-Male
tab <- table(ralf_asd1[ralf_asd1$sex1=='Female'&ralf_asd1$sex2=='Male', varNames])
polychor( tab , ML=T,std.err=T)
MZtab <- ralf_asd1[ralf_asd1$ft=='MZ'&ralf_asd1$sex1=='Female'&ralf_asd1$sex2=='Male', varNames]
table(MZtab)
polychor( table(MZtab) , ML=T,std.err=T)
DZtab <- ralf_asd1[ralf_asd1$ft=='DZ'&ralf_asd1$sex1=='Female'&ralf_asd1$sex2=='Male', varNames]
table(DZtab)
polychor( table(DZtab) , ML=T,std.err=T)
Ftab <- ralf_asd1[ralf_asd1$ft=='F'&ralf_asd1$sex1=='Female'&ralf_asd1$sex2=='Male', varNames]
table(Ftab)
polychor( table(Ftab) , ML=T,std.err=T)
MHtab <- ralf_asd1[ralf_asd1$ft=='MH'&ralf_asd1$sex1=='Female'&ralf_asd1$sex2=='Male', varNames]
table(MHtab)
polychor( table(MHtab) , ML=T,std.err=T)
PHtab <- ralf_asd1[ralf_asd1$ft=='PH'&ralf_asd1$sex1=='Female'&ralf_asd1$sex2=='Male', varNames]
table(PHtab)
polychor( table(PHtab) , ML=T,std.err=T)

# Male-Female
tab <- table(ralf_asd1[ralf_asd1$sex1=='Male'&ralf_asd1$sex2=='Female', varNames])
polychor( tab , ML=T,std.err=T)
MZtab <- ralf_asd1[ralf_asd1$ft=='MZ'&ralf_asd1$sex1=='Male'&ralf_asd1$sex2=='Female', varNames]
table(MZtab)
polychor( table(MZtab) , ML=T,std.err=T)
DZtab <- ralf_asd1[ralf_asd1$ft=='DZ'&ralf_asd1$sex1=='Male'&ralf_asd1$sex2=='Female', varNames]
table(DZtab)
polychor( table(DZtab) , ML=T,std.err=T)
Ftab <- ralf_asd1[ralf_asd1$ft=='F'&ralf_asd1$sex1=='Male'&ralf_asd1$sex2=='Female', varNames]
table(Ftab)
polychor( table(Ftab) , ML=T,std.err=T)
MHtab <- ralf_asd1[ralf_asd1$ft=='MH'&ralf_asd1$sex1=='Male'&ralf_asd1$sex2=='Female', varNames]
table(MHtab)
polychor( table(MHtab) , ML=T,std.err=T)
PHtab <- ralf_asd1[ralf_asd1$ft=='PH'&ralf_asd1$sex1=='Male'&ralf_asd1$sex2=='Female', varNames]
table(PHtab)
polychor( table(PHtab) , ML=T,std.err=T)


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

################################################################################
### Set up a saturated model to compare stuff with
satMod <- mxModel('SatMod',
  mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=-.3,name='Beta'),
  mxModel('MZ',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thrMZ1','thrMZ2'),name='ThrMZ'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexMZ'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.65,ubound=.9999,name='RhoMZ'),
    mxAlgebra( sexMZ%x%SatMod.Beta , name='MeanMZ'),
    mxAlgebra( rbind(cbind(1,RhoMZ),cbind(RhoMZ,1)) , name='CovMZ'),
    mxData( MZdat , type='raw'),
    mxFIMLObjective(means='MeanMZ',covariance='CovMZ',thresholds='ThrMZ',threshnames=varNames,dimnames=varNames)
  ),
  mxModel('DZ',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thrDZ1','thrDZ2'),name='ThrDZ'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexDZ'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.3,ubound=.9999,name='RhoDZ'),
    mxAlgebra( sexDZ%x%SatMod.Beta , name='MeanDZ'),
    mxAlgebra( rbind(cbind(1,RhoDZ),cbind(RhoDZ,1)) , name='CovDZ'),
    mxData( DZdat , type='raw'),
    mxFIMLObjective(means='MeanDZ',covariance='CovDZ',thresholds='ThrDZ',threshnames=varNames,dimnames=varNames)
  ),
  mxModel('Full',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thrF1','thrF2'),name='ThrF'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexF'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.3,ubound=.9999,name='RhoF'),
    mxAlgebra( sexF%x%SatMod.Beta , name='MeanF'),
    mxAlgebra( rbind(cbind(1,RhoF),cbind(RhoF,1)) , name='CovF'),
    mxData( Fdat , type='raw'),
    mxFIMLObjective(means='MeanF',covariance='CovF',thresholds='ThrF',threshnames=varNames,dimnames=varNames)
  ),
  mxModel('MH',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thrMH1','thrMH2'),name='ThrMH'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexMH'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.12,ubound=.9999,name='RhoMH'),
    mxAlgebra( sexMH%x%SatMod.Beta , name='MeanMH'),
    mxAlgebra( rbind(cbind(1,RhoMH),cbind(RhoMH,1)) , name='CovMH'),
    mxData( MHdat , type='raw'),
    mxFIMLObjective(means='MeanMH',covariance='CovMH',thresholds='ThrMH',threshnames=varNames,dimnames=varNames)
  ),
  mxModel('PH',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thrPH1','thrPH2'),name='ThrPH'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexPH'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.12,ubound=.9999,name='RhoPH'),
    mxAlgebra( sexPH%x%SatMod.Beta , name='MeanPH'),
    mxAlgebra( rbind(cbind(1,RhoPH),cbind(RhoPH,1)) , name='CovPH'),
    mxData( PHdat , type='raw'),
    mxFIMLObjective(means='MeanPH',covariance='CovPH',thresholds='ThrPH',threshnames=varNames,dimnames=varNames)
  ),
  mxAlgebra( MZ.objective+DZ.objective+Full.objective+MH.objective+PH.objective , name='m2ll'),
  mxAlgebraObjective('m2ll')
)

### Run model
satModFit <- mxRun( satMod )

### Look at output
summary(satModFit)


### Gender-effect?
satMod1 <- mxModel( satMod ,
  mxMatrix(type='Full',nrow=1,ncol=1,free=F,values=0,name='Beta'))
satMod1Fit <- mxRun( satMod1 )
### Likelihood ratio
mxCompare(satModFit,satMod1Fit)
# Keep gender effect


### Equate threshold for sib 1 and sib 2?
satMod2 <- mxModel('SatMod',
  mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=-.3,name='Beta'),
  mxModel('MZ',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thrMZ','thrMZ'),name='ThrMZ'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexMZ'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.65,ubound=.9999,name='RhoMZ'),
    mxAlgebra( sexMZ%x%SatMod.Beta , name='MeanMZ'),
    mxAlgebra( rbind(cbind(1,RhoMZ),cbind(RhoMZ,1)) , name='CovMZ'),
    mxData( MZdat , type='raw'),
    mxFIMLObjective(means='MeanMZ',covariance='CovMZ',thresholds='ThrMZ',threshnames=varNames,dimnames=varNames)
  ),
  mxModel('DZ',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thrDZ','thrDZ'),name='ThrDZ'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexDZ'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.3,ubound=.9999,name='RhoDZ'),
    mxAlgebra( sexDZ%x%SatMod.Beta , name='MeanDZ'),
    mxAlgebra( rbind(cbind(1,RhoDZ),cbind(RhoDZ,1)) , name='CovDZ'),
    mxData( DZdat , type='raw'),
    mxFIMLObjective(means='MeanDZ',covariance='CovDZ',thresholds='ThrDZ',threshnames=varNames,dimnames=varNames)
  ),
  mxModel('Full',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thrF','thrF'),name='ThrF'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexF'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.3,ubound=.9999,name='RhoF'),
    mxAlgebra( sexF%x%SatMod.Beta , name='MeanF'),
    mxAlgebra( rbind(cbind(1,RhoF),cbind(RhoF,1)) , name='CovF'),
    mxData( Fdat , type='raw'),
    mxFIMLObjective(means='MeanF',covariance='CovF',thresholds='ThrF',threshnames=varNames,dimnames=varNames)
  ),
  mxModel('MH',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thrMH','thrMH'),name='ThrMH'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexMH'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.12,ubound=.9999,name='RhoMH'),
    mxAlgebra( sexMH%x%SatMod.Beta , name='MeanMH'),
    mxAlgebra( rbind(cbind(1,RhoMH),cbind(RhoMH,1)) , name='CovMH'),
    mxData( MHdat , type='raw'),
    mxFIMLObjective(means='MeanMH',covariance='CovMH',thresholds='ThrMH',threshnames=varNames,dimnames=varNames)
  ),
  mxModel('PH',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thrPH','thrPH'),name='ThrPH'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexPH'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.12,ubound=.9999,name='RhoPH'),
    mxAlgebra( sexPH%x%SatMod.Beta , name='MeanPH'),
    mxAlgebra( rbind(cbind(1,RhoPH),cbind(RhoPH,1)) , name='CovPH'),
    mxData( PHdat , type='raw'),
    mxFIMLObjective(means='MeanPH',covariance='CovPH',thresholds='ThrPH',threshnames=varNames,dimnames=varNames)
  ),
  mxAlgebra( MZ.objective+DZ.objective+Full.objective+MH.objective+PH.objective , name='m2ll'),
  mxAlgebraObjective('m2ll')
)

### Run model
satMod2Fit <- mxRun( satMod2 )
summary(satMod2Fit)

### Compare with previous model
mxCompare(satModFit,satMod2Fit)
### Nope, birth-order effects or time-at-risk effects?




### Equate threshold for sib 1 and sib 2 btw sib-types?
satMod3 <- mxModel('SatMod',
  mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=-.3,name='Beta'),
  mxModel('MZ',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thr1','thr2'),name='ThrMZ'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexMZ'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.65,ubound=.9999,name='RhoMZ'),
    mxAlgebra( sexMZ%x%SatMod.Beta , name='MeanMZ'),
    mxAlgebra( rbind(cbind(1,RhoMZ),cbind(RhoMZ,1)) , name='CovMZ'),
    mxData( MZdat , type='raw'),
    mxFIMLObjective(means='MeanMZ',covariance='CovMZ',thresholds='ThrMZ',threshnames=varNames,dimnames=varNames)
  ),
  mxModel('DZ',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thr1','thr2'),name='ThrDZ'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexDZ'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.3,ubound=.9999,name='RhoDZ'),
    mxAlgebra( sexDZ%x%SatMod.Beta , name='MeanDZ'),
    mxAlgebra( rbind(cbind(1,RhoDZ),cbind(RhoDZ,1)) , name='CovDZ'),
    mxData( DZdat , type='raw'),
    mxFIMLObjective(means='MeanDZ',covariance='CovDZ',thresholds='ThrDZ',threshnames=varNames,dimnames=varNames)
  ),
  mxModel('Full',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thr1','thr2'),name='ThrF'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexF'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.3,ubound=.9999,name='RhoF'),
    mxAlgebra( sexF%x%SatMod.Beta , name='MeanF'),
    mxAlgebra( rbind(cbind(1,RhoF),cbind(RhoF,1)) , name='CovF'),
    mxData( Fdat , type='raw'),
    mxFIMLObjective(means='MeanF',covariance='CovF',thresholds='ThrF',threshnames=varNames,dimnames=varNames)
  ),
  mxModel('MH',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thr1','thr2'),name='ThrMH'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexMH'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.12,ubound=.9999,name='RhoMH'),
    mxAlgebra( sexMH%x%SatMod.Beta , name='MeanMH'),
    mxAlgebra( rbind(cbind(1,RhoMH),cbind(RhoMH,1)) , name='CovMH'),
    mxData( MHdat , type='raw'),
    mxFIMLObjective(means='MeanMH',covariance='CovMH',thresholds='ThrMH',threshnames=varNames,dimnames=varNames)
  ),
  mxModel('PH',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thr1','thr2'),name='ThrPH'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexPH'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.12,ubound=.9999,name='RhoPH'),
    mxAlgebra( sexPH%x%SatMod.Beta , name='MeanPH'),
    mxAlgebra( rbind(cbind(1,RhoPH),cbind(RhoPH,1)) , name='CovPH'),
    mxData( PHdat , type='raw'),
    mxFIMLObjective(means='MeanPH',covariance='CovPH',thresholds='ThrPH',threshnames=varNames,dimnames=varNames)
  ),
  mxAlgebra( MZ.objective+DZ.objective+Full.objective+MH.objective+PH.objective , name='m2ll'),
  mxAlgebraObjective('m2ll')
)

### Run model
satMod3Fit <- mxRun( satMod3 )
summary(satMod3Fit)

### Likelhood ratio test
mxCompare(satModFit,satMod3Fit)
### Nope!


### Equate threshold for sib 1 and sib 2 within twins?

satMod4 <- mxModel('SatMod',
  mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=-.3,name='Beta'),
  mxModel('MZ',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thrMZ','thrMZ'),name='ThrMZ'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexMZ'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.65,ubound=.9999,name='RhoMZ'),
    mxAlgebra( sexMZ%x%SatMod.Beta , name='MeanMZ'),
    mxAlgebra( rbind(cbind(1,RhoMZ),cbind(RhoMZ,1)) , name='CovMZ'),
    mxData( MZdat , type='raw'),
    mxFIMLObjective(means='MeanMZ',covariance='CovMZ',thresholds='ThrMZ',threshnames=varNames,dimnames=varNames)
  ),
  mxModel('DZ',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thrDZ','thrDZ'),name='ThrDZ'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexDZ'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.3,ubound=.9999,name='RhoDZ'),
    mxAlgebra( sexDZ%x%SatMod.Beta , name='MeanDZ'),
    mxAlgebra( rbind(cbind(1,RhoDZ),cbind(RhoDZ,1)) , name='CovDZ'),
    mxData( DZdat , type='raw'),
    mxFIMLObjective(means='MeanDZ',covariance='CovDZ',thresholds='ThrDZ',threshnames=varNames,dimnames=varNames)
  ),
  mxModel('Full',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thrF1','thrF2'),name='ThrF'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexF'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.3,ubound=.9999,name='RhoF'),
    mxAlgebra( sexF%x%SatMod.Beta , name='MeanF'),
    mxAlgebra( rbind(cbind(1,RhoF),cbind(RhoF,1)) , name='CovF'),
    mxData( Fdat , type='raw'),
    mxFIMLObjective(means='MeanF',covariance='CovF',thresholds='ThrF',threshnames=varNames,dimnames=varNames)
  ),
  mxModel('MH',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thrMH1','thrMH2'),name='ThrMH'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexMH'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.12,ubound=.9999,name='RhoMH'),
    mxAlgebra( sexMH%x%SatMod.Beta , name='MeanMH'),
    mxAlgebra( rbind(cbind(1,RhoMH),cbind(RhoMH,1)) , name='CovMH'),
    mxData( MHdat , type='raw'),
    mxFIMLObjective(means='MeanMH',covariance='CovMH',thresholds='ThrMH',threshnames=varNames,dimnames=varNames)
  ),
  mxModel('PH',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thrPH1','thrPH2'),name='ThrPH'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexPH'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.12,ubound=.9999,name='RhoPH'),
    mxAlgebra( sexPH%x%SatMod.Beta , name='MeanPH'),
    mxAlgebra( rbind(cbind(1,RhoPH),cbind(RhoPH,1)) , name='CovPH'),
    mxData( PHdat , type='raw'),
    mxFIMLObjective(means='MeanPH',covariance='CovPH',thresholds='ThrPH',threshnames=varNames,dimnames=varNames)
  ),
  mxAlgebra( MZ.objective+DZ.objective+Full.objective+MH.objective+PH.objective , name='m2ll'),
  mxAlgebraObjective('m2ll')
)

### Run model
satMod4Fit <- mxRun( satMod4 )
summary(satMod4Fit)

### Likelhood ratio test
mxCompare(satModFit,satMod4Fit)
# OK to equate across twin1 and twin 2


### Equal thresholds, different means btw sib types (reference=Full sibs)

satMod5 <- mxModel('SatMod',
  mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=-.3,name='Beta'),
  mxModel('MZ',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thr1','thr1'),name='ThrMZ'),
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(0),labels=c('meanMZ','meanMZ'),name='MeanMZ'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexMZ'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.65,ubound=.9999,name='RhoMZ'),
    mxAlgebra( sexMZ%x%SatMod.Beta+MeanMZ  , name='expMeanMZ'),
    mxAlgebra( rbind(cbind(1,RhoMZ),cbind(RhoMZ,1)) , name='CovMZ'),
    mxData( MZdat , type='raw'),
    mxFIMLObjective(means='expMeanMZ',covariance='CovMZ',thresholds='ThrMZ',threshnames=varNames,dimnames=varNames)
  ),
  mxModel('DZ',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thr1','thr1'),name='ThrDZ'),
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(0),labels=c('meanDZ','meanDZ'),name='MeanDZ'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexDZ'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.3,ubound=.9999,name='RhoDZ'),
    mxAlgebra( sexDZ%x%SatMod.Beta+MeanDZ , name='expMeanDZ'),
    mxAlgebra( rbind(cbind(1,RhoDZ),cbind(RhoDZ,1)) , name='CovDZ'),
    mxData( DZdat , type='raw'),
    mxFIMLObjective(means='expMeanDZ',covariance='CovDZ',thresholds='ThrDZ',threshnames=varNames,dimnames=varNames)
  ),
  mxModel('Full',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thr1','thr2'),name='ThrF'),     
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexF'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.3,ubound=.9999,name='RhoF'),
    mxAlgebra( sexF%x%SatMod.Beta , name='expMeanF'),
    mxAlgebra( rbind(cbind(1,RhoF),cbind(RhoF,1)) , name='CovF'),
    mxData( Fdat , type='raw'),
    mxFIMLObjective(means='expMeanF',covariance='CovF',thresholds='ThrF',threshnames=varNames,dimnames=varNames)
  ),
  mxModel('MH',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thr1','thr2'),name='ThrMH'),    
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(0),labels=c('meanMH','meanMH'),name='MeanMH'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexMH'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.12,ubound=.9999,name='RhoMH'),
    mxAlgebra( sexMH%x%SatMod.Beta + MeanMH , name='expMeanMH'),
    mxAlgebra( rbind(cbind(1,RhoMH),cbind(RhoMH,1)) , name='CovMH'),
    mxData( MHdat , type='raw'),
    mxFIMLObjective(means='expMeanMH',covariance='CovMH',thresholds='ThrMH',threshnames=varNames,dimnames=varNames)
  ),
  mxModel('PH',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thr1','thr2'),name='ThrPH'),    
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(0),labels=c('meanPH','meanPH'),name='MeanPH'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexPH'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.12,ubound=.9999,name='RhoPH'),
    mxAlgebra( sexPH%x%SatMod.Beta + MeanPH , name='expMeanPH'),
    mxAlgebra( rbind(cbind(1,RhoPH),cbind(RhoPH,1)) , name='CovPH'),
    mxData( PHdat , type='raw'),
    mxFIMLObjective(means='expMeanPH',covariance='CovPH',thresholds='ThrPH',threshnames=varNames,dimnames=varNames)
  ),
  mxAlgebra( MZ.objective+DZ.objective+Full.objective+MH.objective+PH.objective , name='m2ll'),
  mxAlgebraObjective('m2ll')
)
### Run model
satMod5Fit <- mxRun( satMod5 )
summary(satMod5Fit)

### Likelihood ratio test
mxCompare(satModFit,satMod5Fit)
mxCompare(satMod4Fit,satMod5Fit)
# Borderline significant

######################################
### Check if correlations differs btw sib types

### Equal correlation in DZ and full sibs?
satMod6 <- mxModel('SatMod',
  mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=-.3,name='Beta'),
  mxModel('MZ',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thrMZ','thrMZ'),name='ThrMZ'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexMZ'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.65,ubound=.9999,name='RhoMZ'),
    mxAlgebra( sexMZ%x%SatMod.Beta , name='MeanMZ'),
    mxAlgebra( rbind(cbind(1,RhoMZ),cbind(RhoMZ,1)) , name='CovMZ'),
    mxData( MZdat , type='raw'),
    mxFIMLObjective(means='MeanMZ',covariance='CovMZ',thresholds='ThrMZ',threshnames=varNames,dimnames=varNames)
  ),
  mxModel('DZ',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thrDZ','thrDZ'),name='ThrDZ'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexDZ'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.3,ubound=.9999,label='rhoF',name='RhoDZ'),
    mxAlgebra( sexDZ%x%SatMod.Beta , name='MeanDZ'),
    mxAlgebra( rbind(cbind(1,RhoDZ),cbind(RhoDZ,1)) , name='CovDZ'),
    mxData( DZdat , type='raw'),
    mxFIMLObjective(means='MeanDZ',covariance='CovDZ',thresholds='ThrDZ',threshnames=varNames,dimnames=varNames)
  ),
  mxModel('Full',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thrF1','thrF2'),name='ThrF'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexF'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.3,ubound=.9999,label='rhoF',name='RhoF'),
    mxAlgebra( sexF%x%SatMod.Beta , name='MeanF'),
    mxAlgebra( rbind(cbind(1,RhoF),cbind(RhoF,1)) , name='CovF'),
    mxData( Fdat , type='raw'),
    mxFIMLObjective(means='MeanF',covariance='CovF',thresholds='ThrF',threshnames=varNames,dimnames=varNames)
  ),
  mxModel('MH',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thrMH1','thrMH2'),name='ThrMH'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexMH'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.12,ubound=.9999,name='RhoMH'),
    mxAlgebra( sexMH%x%SatMod.Beta , name='MeanMH'),
    mxAlgebra( rbind(cbind(1,RhoMH),cbind(RhoMH,1)) , name='CovMH'),
    mxData( MHdat , type='raw'),
    mxFIMLObjective(means='MeanMH',covariance='CovMH',thresholds='ThrMH',threshnames=varNames,dimnames=varNames)
  ),
  mxModel('PH',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thrPH1','thrPH2'),name='ThrPH'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexPH'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.12,ubound=.9999,name='RhoPH'),
    mxAlgebra( sexPH%x%SatMod.Beta , name='MeanPH'),
    mxAlgebra( rbind(cbind(1,RhoPH),cbind(RhoPH,1)) , name='CovPH'),
    mxData( PHdat , type='raw'),
    mxFIMLObjective(means='MeanPH',covariance='CovPH',thresholds='ThrPH',threshnames=varNames,dimnames=varNames)
  ),
  mxAlgebra( MZ.objective+DZ.objective+Full.objective+MH.objective+PH.objective , name='m2ll'),
  mxAlgebraObjective('m2ll')
)

### Run model
satMod6Fit <- mxRun( satMod6 )
summary(satMod6Fit)

### Likelhood ratio test
mxCompare(satMod4Fit,satMod6Fit)
# OK

### Equal correlation in MH & PH as well??
satMod7 <- mxModel('SatMod',
  mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=-.3,name='Beta'),
  mxModel('MZ',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thrMZ','thrMZ'),name='ThrMZ'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexMZ'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.65,ubound=.9999,name='RhoMZ'),
    mxAlgebra( sexMZ%x%SatMod.Beta , name='MeanMZ'),
    mxAlgebra( rbind(cbind(1,RhoMZ),cbind(RhoMZ,1)) , name='CovMZ'),
    mxData( MZdat , type='raw'),
    mxFIMLObjective(means='MeanMZ',covariance='CovMZ',thresholds='ThrMZ',threshnames=varNames,dimnames=varNames)
  ),
  mxModel('DZ',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thrDZ','thrDZ'),name='ThrDZ'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexDZ'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.3,ubound=.9999,label='rhoF',name='RhoDZ'),
    mxAlgebra( sexDZ%x%SatMod.Beta , name='MeanDZ'),
    mxAlgebra( rbind(cbind(1,RhoDZ),cbind(RhoDZ,1)) , name='CovDZ'),
    mxData( DZdat , type='raw'),
    mxFIMLObjective(means='MeanDZ',covariance='CovDZ',thresholds='ThrDZ',threshnames=varNames,dimnames=varNames)
  ),
  mxModel('Full',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thrF1','thrF2'),name='ThrF'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexF'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.3,ubound=.9999,label='rhoF',name='RhoF'),
    mxAlgebra( sexF%x%SatMod.Beta , name='MeanF'),
    mxAlgebra( rbind(cbind(1,RhoF),cbind(RhoF,1)) , name='CovF'),
    mxData( Fdat , type='raw'),
    mxFIMLObjective(means='MeanF',covariance='CovF',thresholds='ThrF',threshnames=varNames,dimnames=varNames)
  ),
  mxModel('MH',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thrMH1','thrMH2'),name='ThrMH'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexMH'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.12,ubound=.9999,label='rhoH',name='RhoMH'),
    mxAlgebra( sexMH%x%SatMod.Beta , name='MeanMH'),
    mxAlgebra( rbind(cbind(1,RhoMH),cbind(RhoMH,1)) , name='CovMH'),
    mxData( MHdat , type='raw'),
    mxFIMLObjective(means='MeanMH',covariance='CovMH',thresholds='ThrMH',threshnames=varNames,dimnames=varNames)
  ),
  mxModel('PH',  
    mxMatrix(type='Full',nrow=1,ncol=2,free=c(T,T),values=c(2.4,2.4),labels=c('thrPH1','thrPH2'),name='ThrPH'),
    mxMatrix(type='Full',nrow=1,ncol=2,labels=c('data.sex1','data.sex2'),name='sexPH'),
    mxMatrix(type='Full',nrow=1,ncol=1,free=c(T),values=.12,ubound=.9999,label='rhoH',name='RhoPH'),
    mxAlgebra( sexPH%x%SatMod.Beta , name='MeanPH'),
    mxAlgebra( rbind(cbind(1,RhoPH),cbind(RhoPH,1)) , name='CovPH'),
    mxData( PHdat , type='raw'),
    mxFIMLObjective(means='MeanPH',covariance='CovPH',thresholds='ThrPH',threshnames=varNames,dimnames=varNames)
  ),
  mxAlgebra( MZ.objective+DZ.objective+Full.objective+MH.objective+PH.objective , name='m2ll'),
  mxAlgebraObjective('m2ll')
)

### Run model
satMod7Fit <- mxRun( satMod7 )
summary(satMod7Fit)

### Likelhood ratio test
mxCompare(satModFit,satMod7Fit)
mxCompare(satMod6Fit,satMod7Fit)
# OK!
rm(list=c('satMod','satMod1','satMod2','satMod3','satMod4','satMod5','satMod6','satMod7','satMod1Fit','satMod2Fit','satMod3Fit','satMod4Fit','satMod5Fit','satMod6Fit'))
ls()


################################################################################
### Final model information:
### * Different thresholds in 1st- and 2nd- offspring for non-twins
### * Same threshold in twin 1 and twin 2
### * Different thresholds across all sibling-types
### * Full sibs and DZ twins have similar correlation
### * MH and PHsibs have similar correlation
################################################################################
