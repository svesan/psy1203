load("psy1203_results_nocousins_asd_C.RData")

f1.F       = asd.list[[1]]
f1.F.adj4  = asd.list[[9]]
f1.MH.adj4 = asd.list[[13]]
f1.PH.adj4 = asd.list[[17]]
f1.mz.adj4 = asd.list[[20]]
f1.dz.adj4 = asd.list[[21]]

z.F       = cox.zph(f)
z.F.adj3  = cox.zph(asd.list[[8]])
z.F.adj4  = cox.zph(f1.F.adj4)
z.MH.adj4 = cox.zph(f1.MH.adj4)
z.PH.adj4 = cox.zph(f1.PH.adj4)
z.mz.adj4 = cox.zph(f1.mz.adj4)
z.dz.adj4 = cox.zph(f1.dz.adj4)

print(z.F.adj4)



par(mfrow=c(1,2))
plot(z.F[1], ylim=c(1, 3), resid=F, cex.lab=1.5)
abline(h=log(10.3))
title(c("Full Sib Crude. log(RR) vs age","Ref. line for the estimated log(RR)"))

png(filename="PH-1.png") ; #, units="cm", width=16, height=8, res=300)

plot(z.F.adj4[1], ylim=c(1, 3), resid=F, cex.lab=1.5)
abline(h=log(10.3))
title(c("Full Sib Adj. log(RR) vs age","Ref. line for the estimated log(RR)"))

dev.off()


png(filename="PH-2.png", units="cm", width=14, height=14, res=300)

par(mfrow=c(2,2))
plot(z.MH.adj4[1], ylim=c(0, 3), resid=F, cex.lab=1.15)
abline(h=log(3.3))
title(c("Mat Half-Sib Adj. log(RR) vs age","Ref. line for the estimated log(RR)"))

plot(z.PH.adj4[1], ylim=c(0, 3), resid=F, cex.lab=1.15)
abline(h=log(2.9))
title(c("Pat Half-Sib Adj. log(RR) vs age","Ref. line for the estimated log(RR)"))

plot(z.mz.adj4[1], ylim=c(0, 13), resid=F, cex.lab=1.15)
abline(h=log(152.9))
title(c("MZ twins Adj. log(RR) vs age","Ref. line for the estimated log(RR)"))

plot(z.dz.adj4[1], ylim=c(0, 13), resid=F, cex.lab=1.15)
abline(h=log(8.2))
title(c("DZ twins Adj. log(RR) vs age","Ref. line for the estimated log(RR)"))

dev.off()

$mai
[1] 1.02 0.82 0.82 0.42

$mar
[1] 5.1 4.1 4.1 2.1

png(filename="PH-1.png", units="cm", width=12, height=12, res=175)
par(mar=c(4, 2, 2, 1))

plot(z.F.adj4[1], ylim=c(1, 3), resid=F)
abline(h=log(10.3))
title(c("Full Sib Adj"))

dev.off()


png(filename="PH-2.png", units="cm", width=14, height=14, res=275)

par(mfrow=c(2,2), mar=c(4, 2, 2, 1))
plot(z.MH.adj4[1], ylim=c(0, 3), resid=F, cex.lab=1)
abline(h=log(3.3))
title(c("Mat Half-Sib Adj"))

plot(z.PH.adj4[1], ylim=c(0, 3), resid=F, cex.lab=1)
abline(h=log(2.9))
title(c("Pat Half-Sib Adj"))

plot(z.mz.adj4[1], ylim=c(0, 13), resid=F, cex.lab=1)
abline(h=log(152.9))
title(c("MZ twins Adj"))

plot(z.dz.adj4[1], ylim=c(0, 13), resid=F, cex.lab=1)
abline(h=log(8.2))
title(c("DZ twins Adj"))

dev.off()




