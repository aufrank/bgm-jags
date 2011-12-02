# Produces:
# (1) figure showing MCMC iterations for binomial example 
# (2) figure showing MCMC-based prior and posterior distributions
rm(list=ls(all=TRUE))
setwd("C:\\EJ\\UvApost\\uvapapers\2008\\BUGSBook\\EJStuff\\TheoryEstimation\\Code")
library(R2WinBUGS)
bugsdir = "C:\\Program Files\\WinBUGS14"

k = 9; n = 10; 

data  = list("k","n")

inits1 = list(theta = .1, thetaprior = 0.5)
inits2 = list(theta = .5, thetaprior = 0.5)
inits3 = list(theta = .9, thetaprior = 0.5)
inits = list(inits1,inits2,inits3)

parameters = c("theta", "thetaprior")

samples = bugs(	data, inits, parameters,
	 			model.file ="Rate.txt",
	 			n.chains=3, n.iter=3000, n.burnin=0, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir, #DIC=T or else error message
	 			codaPkg=F, debug=T)

# plot of three chains, for first 300 trials
par(cex.main = 1.5, mar = c(5, 6, 4, 5) + 0.1, mgp = c(3.5, 1, 0), cex.lab = 1.5,
    font.lab = 2, cex.axis = 1.3, bty = "n", las=1)
chain=1
N = 100
plot(samples$sims.array[1:N,chain,1], type="l", ylim=c(0,1), xlim=c(1,N), lwd=2, lty=1, ylab=" ", xlab="MCMC Iteration", axes=F)
axis(1)
axis(2) 
mtext(expression(theta), side=2, line = 2.8, cex=2)

chain=2
lines(samples$sims.array[1:N,chain,1], lwd=2, lty=2)

chain=3
lines(samples$sims.array[1:N,chain,1], lwd=2, lty=3)

lines(c(10, 20), c(0.4, 0.4), lwd=2, lty=1)
text(35, 0.4, "Chain 1", cex=1.5)

lines(c(10, 20), c(0.3, 0.3), lwd=2, lty=2) 
text(35, 0.3, "Chain 2", cex=1.5)           

lines(c(10, 20), c(0.2, 0.2), lwd=2, lty=3) 
text(35, 0.2, "Chain 3", cex=1.5)   
        
#################################
# plot posterior and prior (9000 samples in each):
# First, collect samples across chains:
post  = samples$sims.list$theta      
prior = samples$sims.list$thetaprior

library(polspline) #this package can be installed from within R
fit.prior = logspline(prior[1:9000], lbound=0, ubound=1)
fit.post  = logspline(post[1:9000], lbound=0, ubound=1)

par(cex.main = 1.5, mar = c(5, 6, 4, 5) + 0.1, mgp = c(3.5, 1, 0), cex.lab = 1.5,
    font.lab = 2, cex.axis = 1.3, bty = "n", las=1)

Nbreaks = 20
y = hist(prior, Nbreaks, prob=T, border="white", ylim=c(0,5), xlim=c(0,1), lwd=2, lty=3, ylab="Density", xlab=" ", main=" ", axes=F) 
#white makes the original histogram -- with unwanted vertical lines -- invisible
lines(c(y$breaks, max(y$breaks)), c(0,y$intensities,0), type="S", lwd=2, lty=3) 
axis(1, at = c(0, 0.25, 0.50, 0.75, 1), lab=c("0", "0.25", "0.5", "0.75", "1"))
axis(2)
lines(c(0,0),c(0,1), col="white", lwd=2)

par(new=T)

x = hist(post, Nbreaks, prob=T, border="white", ylim=c(0,5), xlim=c(0,1), lwd=2, lty=1, ylab="Density", xlab=" ", main =" ", axes=F) 
#white makes the original histogram -- with unwanted vertical lines -- invisible
lines(c(x$breaks, max(x$breaks)), c(0,x$intensities,0), type="S", lwd=2) 
axis(1, at = c(0, 0.25, 0.50, 0.75, 1), lab=c("0", "0.25", "0.5", "0.75", "1"))
axis(2)

mtext(expression(theta), side=1, line = 2.8, cex=2)

#now bring in log spline density estimation:

par(new=T)
plot(fit.prior, ylim=c(0,5), xlim=c(0,1), lty=1, lwd=1, axes=F)
par(new=T)
plot(fit.post, ylim=c(0,5), xlim=c(0,1), lty=1, lwd=1, axes=F)

# find mode
x = dlogspline(seq(from=.85,to=.95,by=.001), fit.post)
#which(x==max(x)) #gives 42, so mode = .85 + .001*42 = .892
 
#text with prior and posterior
text(0.1, 1.25, labels="Prior", cex = 1.5) 
text(0.65, 3, labels="Posterior", cex = 1.5) 

#95% confidence interval

x0=qlogspline(0.025,fit.post)
x1=qlogspline(0.975,fit.post)
arrows(x0, 4.6, x1, 4.6, length = 0.25, angle = 90, code = 3, lwd=2)
text((x0+x1)/2, 4.6+0.25, labels="95%", cex = 1.5) 









