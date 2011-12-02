# clears workspace:  
rm(list=ls(all=TRUE)) 

# sets working directories:
setwd("F:/Codes/tTest")
library(R2WinBUGS)
bugsdir = "C:/Program Files/WinBUGS14"

# Read data Dr. Smith
Winter = c(-0.05,0.41,0.17,-0.13,0.00,-0.05,0.00,0.17,0.29,0.04,0.21,0.08,0.37,0.17,0.08,-0.04,-0.04,0.04,-0.13,-0.12,0.04,0.21,0.17,
       0.17,0.17,0.33,0.04,0.04,0.04,0.00,0.21,0.13,0.25,-0.05,0.29,0.42,-0.05,0.12,0.04,0.25,0.12)
 
Summer = c(0.00,0.38,-0.12,0.12,0.25,0.12,0.13,0.37,0.00,0.50,0.00,0.00,-0.13,-0.37,-0.25,-0.12,0.50,0.25,0.13,0.25,0.25,0.38,0.25,0.12,
      0.00,0.00,0.00,0.00,0.25,0.13,-0.25,-0.38,-0.13,-0.25,0.00,0.00,-0.12,0.25,0.00,0.50,0.00)

X = Winter-Summer # allowed because it is a within-subjects design
X = X/sd(X)       # standardize

nsubj = length(Winter) # number of subjects

data  = list("X", "nsubj") # to be passed on to WinBUGS

inits=function()
{
	list(delta=rnorm(1,0,3), sigma=runif(1,0,5))
}

# Parameters to be monitored
parameters=c("delta")

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits, parameters,
	 			model.file ="Ttest_1.txt",
	 			n.chains=3, n.iter=10000, n.burnin=1000, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir,
	 			codaPkg=F, debug=T)
# Now the values for the monitored parameters are in the "samples" object, 
# ready for inspection.

samples$summary # overview

# Please work through the analyses below one at a time
######################################################
# Analysis 1. H1: delta ~ Cauchy (unrestricted case)
######################################################

# Collect posterior samples across all chains:
delta.posterior  = samples$sims.list$delta  

#============ BFs based on logspline fit ===========================
library(polspline) # this package can be installed from within R
fit.posterior = logspline(delta.posterior)

# 95% confidence interval:
x0=qlogspline(0.025,fit.posterior)
x1=qlogspline(0.975,fit.posterior)

posterior     = dlogspline(0, fit.posterior) # this gives the pdf at point delta = 0
prior         = dcauchy(0)                   # height of order--restricted prior at delta = 0
BF01          = posterior/prior
BF01

#============ Plot Prior and Posterior  ===========================
par(cex.main = 1.5, mar = c(5, 6, 4, 5) + 0.1, mgp = c(3.5, 1, 0), cex.lab = 1.5,
    font.lab = 2, cex.axis = 1.3, bty = "n", las=1)
xlow  = -3
xhigh = 3
yhigh = 4
Nbreaks = 80
y = hist(delta.posterior, Nbreaks, prob=T, border="white", ylim=c(0,yhigh), xlim=c(xlow,xhigh), lwd=2, lty=1, ylab="Density", xlab=" ", main=" ", axes=F) 
#white makes the original histogram -- with unwanted vertical lines -- invisible
lines(c(y$breaks, max(y$breaks)), c(0,y$intensities,0), type="S", lwd=2, lty=1) 
axis(1, at = c(-4,-3,-2,-1,0,1,2,3,4), lab=c("-4","-3","-2","-1","0", "1", "2", "3", "4"))
axis(2)
mtext(expression(delta), side=1, line = 2.8, cex=2)
#now bring in log spline density estimation:
par(new=T)
plot(fit.posterior, ylim=c(0,yhigh), xlim=c(xlow,xhigh), lty=1, lwd=1, axes=F)
points(0, dlogspline(0, fit.posterior),pch=19, cex=2)
# plot the prior:
par(new=T)
plot ( function( x ) dcauchy( x, 0, 1 ), xlow, xhigh, ylim=c(0,yhigh), xlim=c(xlow,xhigh), lwd=1, lty=1, ylab=" ", xlab = " ", axes=F) 
axis(1, at = c(-4,-3,-2,-1,0,1,2,3,4), lab=c("-4","-3","-2","-1","0", "1", "2", "3", "4"))
axis(2)
points(0, dcauchy(0), pch=19, cex=2)

###########################################################################
# Analysis 2. H1: delta ~ Cauchy^- (restricted case, negative values only)
###########################################################################

# Collect posterior samples across all chains:
delta.posterior  = samples$sims.list$delta
# selects only negative delta's:
delta.posterior  = delta.posterior[which(delta.posterior<0)]

#============ BFs based on logspline fit ===========================
fit.posterior = logspline(delta.posterior,ubound=0) # NB. note the bound

# 95% confidence interval:
x0=qlogspline(0.025,fit.posterior)
x1=qlogspline(0.975,fit.posterior)

posterior     = dlogspline(0, fit.posterior) # this gives the pdf at point delta = 0
prior         = 2*dcauchy(0)                 # height of order--restricted prior at delta = 0
BF01          = posterior/prior
BF01

#============ Plot Prior and Posterior  ===========================
par(cex.main = 1.5, mar = c(5, 6, 4, 5) + 0.1, mgp = c(3.5, 1, 0), cex.lab = 1.5,
    font.lab = 2, cex.axis = 1.3, bty = "n", las=1)
xlow  = -3
xhigh = 0
yhigh = 12
Nbreaks = 80
y = hist(delta.posterior, Nbreaks, prob=T, border="white", ylim=c(0,yhigh), xlim=c(xlow,xhigh), lwd=2, lty=1, ylab="Density", xlab=" ", main=" ", axes=F) 
#white makes the original histogram -- with unwanted vertical lines -- invisible
lines(c(y$breaks, max(y$breaks)), c(0,y$intensities,0), type="S", lwd=2, lty=1) 
axis(1, at = c(-3,-2,-1,0), lab=c("-3","-2","-1","0"))
axis(2)
mtext(expression(delta), side=1, line = 2.8, cex=2)
#now bring in log spline density estimation:
par(new=T)
plot(fit.posterior, ylim=c(0,yhigh), xlim=c(xlow,xhigh), lty=1, lwd=1, axes=F)
points(0, dlogspline(0, fit.posterior),pch=19, cex=2)
# plot the prior:
par(new=T)
plot ( function( x ) 2*dcauchy( x, 0, 1 ), xlow, xhigh, ylim=c(0,yhigh), xlim=c(xlow,xhigh), lwd=1, lty=1, ylab=" ", xlab = " ", axes=F) 
axis(1, at = c(-3,-2,-1,0), lab=c("-3","-2","-1","0"))
axis(2)
points(0, 2*dcauchy(0), pch=19, cex=2)

###########################################################################
# Analysis 3. H1: delta ~ Cauchy^+ (restricted case, positive values only)
###########################################################################

# Collect posterior samples across all chains:
delta.posterior  = samples$sims.list$delta  
# selects only positive delta's:
delta.posterior  = delta.posterior[which(delta.posterior>0)]

#============ BFs based on logspline fit ===========================
fit.posterior = logspline(delta.posterior,lbound=0) # NB. note the bound

# 95% confidence interval:
x0=qlogspline(0.025,fit.posterior)
x1=qlogspline(0.975,fit.posterior)

posterior     = dlogspline(0, fit.posterior) # this gives the pdf at point delta = 0
prior         = 2*dcauchy(0)                   # height of order--restricted prior at delta = 0
BF01          = posterior/prior
BF01

#============ Plot Prior and Posterior  ===========================
par(cex.main = 1.5, mar = c(5, 6, 4, 5) + 0.1, mgp = c(3.5, 1, 0), cex.lab = 1.5,
    font.lab = 2, cex.axis = 1.3, bty = "n", las=1)
xlow  = 0
xhigh = 3
yhigh = 12
Nbreaks = 80
y = hist(delta.posterior, Nbreaks, prob=T, border="white", ylim=c(0,yhigh), xlim=c(xlow,xhigh), lwd=2, lty=1, ylab="Density", xlab=" ", main=" ", axes=F) 
#white makes the original histogram -- with unwanted vertical lines -- invisible
lines(c(y$breaks, max(y$breaks)), c(0,y$intensities,0), type="S", lwd=2, lty=1) 
axis(1, at = c(0,1,2,3,4), lab=c("0", "1", "2", "3", "4"))
axis(2)
mtext(expression(delta), side=1, line = 2.8, cex=2)
#now bring in log spline density estimation:
par(new=T)
plot(fit.posterior, ylim=c(0,yhigh), xlim=c(xlow,xhigh), lty=1, lwd=1, axes=F)
points(0, dlogspline(0, fit.posterior),pch=19, cex=2)
# plot the prior:
par(new=T)
plot ( function( x ) 2*dcauchy( x, 0, 1 ), xlow, xhigh, ylim=c(0,yhigh), xlim=c(xlow,xhigh), lwd=1, lty=1, ylab=" ", xlab = " ", axes=F) 
axis(1, at = c(0,1,2,3,4), lab=c("0", "1", "2", "3", "4"))
axis(2)
points(0, 2*dcauchy(0), pch=19, cex=2)
