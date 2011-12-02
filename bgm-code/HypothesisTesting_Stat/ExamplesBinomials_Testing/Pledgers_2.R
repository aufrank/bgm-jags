# clears workspace:  
rm(list=ls(all=TRUE)) 

# sets working directories:
setwd("C:/Documents and Settings/ewagenmakers/Desktop/temp/BayesBook")
library(R2WinBUGS)
bugsdir = "C:/Program Files/WinBUGS14"

# pledger data:
s1 = 424
s2 = 5416
n1 = 777
n2 = 9072

# two-sided p-value = 0.005848:
prop.test(c(s1,s2), c(n1,n2), alternative = c("two.sided")) #approximate

# Analytical Bayes factor:
log.BF01 = lchoose(n1,s1) + lchoose(n2,s2) + log(n1+1) + log(n2+1) - lchoose((n1+n2),(s1+s2)) - log(n1+n2+1)
BF01 = exp(log.BF01)

data  = list("s1","s2","n1","n2") # to be passed on to WinBUGS
inits =	function()
{			
  list(theta1 = runif(1), theta2 = runif(1), theta1prior = runif(1), theta2prior = runif(1))
}
parameters = c("theta1", "theta2", "delta", "deltaprior")

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(	data, inits, parameters,
	 			model.file ="PledgersModel.txt",
	 			n.chains=3, n.iter=10000, n.burnin=1000, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir, #DIC=T or else error message
	 			codaPkg=F, debug=T)
# Now the values for delta and deltaprior are in the "samples" object, ready for inspection.

######################################################
# Order-restriction. H1: delta < 0
######################################################
# Collect posterior samples across all chains:
delta.posterior  = samples$sims.list$delta      
delta.prior      = samples$sims.list$deltaprior

#============ BFs based on logspline fit ===========================
library(polspline) # this package can be installed from within R
# height of the unrestricted posterior at delta=0:
# Method 1, renormalization
fit.posterior = logspline(delta.posterior, lbound=-1, ubound=1)
posterior     = dlogspline(0, fit.posterior) # this gives the pdf at point delta = 0
# renormalize:
area            = sum(delta.posterior < 0)/length(delta.posterior)
posterior.OR.M1 = posterior/area
prior.OR        = 2 # we know this exactly
BF02            = posterior.OR.M1/prior.OR # 0.23, BF20 = 4.34

# Method 2, estimate truncated posterior
delta.posterior.OR  = delta.posterior[which(delta.posterior<0)]
delta.prior.OR      = delta.prior[which(delta.prior<0)]
fit.posterior.OR    = logspline(delta.posterior.OR, lbound=-1, ubound=0)
posterior.OR.M2     = dlogspline(0, fit.posterior.OR) # this gives the pdf at point delta = 0
BF02                = posterior.OR.M2/2 # 0.26, BF20 = 3.78

#======= Plot Order-Restricted Prior and Posterior ======================
par(cex.main = 1.5, mar = c(5, 6, 4, 5) + 0.1, mgp = c(3.5, 1, 0), cex.lab = 1.5,
    font.lab = 2, cex.axis = 1.3, bty = "n", las=1)

Nbreaks = 20
y = hist(delta.prior.OR, Nbreaks, prob=T, border="white", ylim=c(0,25), xlim=c(-1,0), lwd=2, lty=3, ylab="Density", xlab=" ", main=" ", axes=F) 
#white makes the original histogram -- with unwanted vertical lines -- invisible
lines(c(y$breaks, max(y$breaks)), c(0,y$intensities,0), type="S", lwd=2, lty=3) 
lines(c(0,0), c(0,2), col="white", lwd=2)
axis(1, at = c(-1, -0.5, 0), lab=c("-1", "-0.5", "0"))
axis(2)
mtext(expression(delta), side=1, line = 2.8, cex=2)
par(new=T)
x = hist(delta.posterior.OR, Nbreaks, prob=T, border="white", ylim=c(0,25), xlim=c(-1,0), lwd=2, lty=1, ylab="Density", xlab=" ", main ="Full Scale", axes=F) 
#white makes the original histogram -- with unwanted vertical lines -- invisible
lines(c(x$breaks, max(x$breaks)), c(0,x$intensities,0), type="S", lwd=2) 
axis(1, at = c(-1, -0.5, 0), lab=c("-1", "-0.5", "0"))
axis(2)
#now bring in log spline density estimation:
par(new=T)
# plot(fit.prior, ylim=c(0,25), xlim=c(-1,1), lty=1, lwd=1, axes=F)
# plot the prior:
lines(c(-1,0),c(0,2), lty=1, lwd=1)
par(new=T)
plot(fit.posterior.OR, ylim=c(0,25), xlim=c(-1,0), lty=1, lwd=1, axes=F)

text(-0.375, 20, labels = "Posterior", cex = 1.5, pos=4)
text(-0.5, 2.5, labels = "Prior", cex=1.5, pos=4)

######## Second plot, zoom in:
par(cex.main = 1.5, mar = c(5, 6, 4, 5) + 0.1, mgp = c(3.5, 1, 0), cex.lab = 1.5,
    font.lab = 2, cex.axis = 1.3, bty = "n", las=1)
xmin = -0.05
xmax = 0
ymax = 5
plot(0,0, ylim=c(0,ymax), xlim=c(xmin,xmax), lwd=2, lty=3, ylab="Density", xlab=" ", main="Zoomed in", axes=F, col="white") 
#white makes this invisible
axis(1, at = c(xmin, -0.025, xmax), lab=c(paste(xmin), -0.025, paste(xmax)))
axis(2)
mtext(expression(delta), side=1, line = 2.8, cex=2)
par(new=T)
plot(fit.posterior.OR, ylim=c(0,ymax), xlim=c(xmin,xmax), lty=1, lwd=2, axes=F)
lines(c(-1,0),c(0,2), lty=1, lwd=2)
points(0, 2, pch=19, cex=2)
points(0, dlogspline(0, fit.posterior.OR),pch=19, cex=2)

points(0, posterior.OR.M1, pch=21, cex=2, lwd=2)

text(-0.04, 1.7, labels = "Prior", cex=1.5, pos=4)
text(-0.032, 4, labels = "Posterior", cex = 1.5, pos=4)

