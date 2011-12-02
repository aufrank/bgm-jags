#### R2Winbugs Code for a Bayesian hierarchical test of the Geurts data.
#### Do children with ADHD perform worse on the Wisconsin Card Sorting Task
#### than children who develop typically (i.e., normal controls)?
   
rm(list=ls(all=TRUE)) # clears workspace

# sets working directories:
setwd("C:\\EJ\\UvApost\\uvapapers\\2008\\Himanshu\\SDtex\\Code\\Geurts")
library(R2WinBUGS)
bugsdir = "C:\\Program Files\\WinBUGS14"

### Geurts data:
# Normal Controls:         
num.errors = c(15,10, 61,11, 60, 44, 63, 70, 57,11, 67, 21, 89,12, 63, 11, 96,10, 37,19, 44,18, 78, 27, 60,14)
N.NC       = c(89,74,128,87,128,121,128,128,128,78,128,106,128,83,128,100,128,73,128,86,128,86,128,100,128,79)
K.NC       = N.NC - num.errors
# ADHD:
num.errors = c( 88, 50, 58,17, 40, 18,21, 50, 21, 69,19, 29,11, 76, 46, 36, 37, 72,27, 92,13, 39, 53, 31, 49, 
                57,17,10,12,21, 39, 43, 49,17, 39,13, 68, 24, 21,27, 48, 54, 41, 75, 38, 76,21, 41, 61,24, 28,21)
N.AD       = c(128,128,128,86,128,117,89,128,110,128,93,107,87,128,128,113,128,128,98,128,93,116,128,116,128,
               128,93,86,86,96,128,128,128,86,128,78,128,111,100,95,128,128,128,128,128,128,98,127,128,93,110,96)
K.AD       = N.AD - num.errors
           
# two-sided p-value = .72
t.test(K.NC/N.NC, K.AD/N.AD, alternative = c("two.sided"), paired=F)

data  = list("K.NC","N.NC","K.AD","N.AD") # to be passed on to WinBUGS

inits=function()
  {
    list(phi.NC = rnorm(26,mean=0,sd=1), phi.AD = rnorm(52,mean=0,sd=1), 
         mu = rnorm(1,mean=0,sd=1), sigma = runif(1,0,5), delta = rnorm(1,mean=0,sd=1))
  }

parameters = c("delta")

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits, parameters,
	 			model.file ="GeurtsModel.txt",
	 			n.chains=3, n.iter=100000, n.burnin=1000, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir, #DIC=T or else error message
	 			codaPkg=F, debug=T)
# Now the values for delta are in the "samples" object, ready for inspection.

# The commands below are useful for a quick overview:
print(samples) # note that Rhat should be close to 1 to indicate convergence of the chains
plot(samples)  # a visual representation
names(samples) # summarizes the variables
chain = 1
samples$sims.array[1:15,chain,] # gives an overview of variables

# plot different chains to show mixing for posterior:
par(cex.main = 1.5, mar = c(5, 6, 4, 5) + 0.1, mgp = c(3.5, 1, 0), cex.lab = 1.5,
    font.lab = 2, cex.axis = 1.3, bty = "n", las=1)
chain = 1
N     = length(samples$sims.array[,1,"delta"])
plot(samples$sims.array[1:N,chain,"delta"], type="l", ylim=c(-1,1), xlim=c(1,N), lwd=2, lty=1, ylab=" ", xlab="MCMC Iteration", axes=F)
axis(1)
axis(2) 
mtext(expression(delta), side=2, line = 4, cex=2)
chain = 2
lines(samples$sims.array[1:N,chain,"delta"], lwd=2, lty=2)
chain = 3
lines(samples$sims.array[1:N,chain,"delta"], lwd=2, lty=3)

# Collect posterior samples across all chains:
delta.posterior  = samples$sims.list$delta      

#============ Unrestricted analysis      ===========================
#============ BFs based on logspline fit ===========================
library(polspline) # this package can be installed from within R
fit.posterior = logspline(delta.posterior)

# 95% confidence interval:
x0=qlogspline(0.025,fit.posterior)
x1=qlogspline(0.975,fit.posterior)

posterior     = dlogspline(0, fit.posterior) # this gives the pdf at point delta = 0
prior         = dnorm(0)                     # height of order--restricted prior at delta = 0
BF01          = posterior/prior
# BF01 = 3.96, BF10 = 0.25

#####################################################################
### Plot Prior and Posterior
#####################################################################

par(cex.main = 1.5, mar = c(5, 6, 4, 5) + 0.1, mgp = c(3.5, 1, 0), cex.lab = 1.5,
    font.lab = 2, cex.axis = 1.3, bty = "n", las=1)

Nbreaks = 80
y = hist(delta.posterior, Nbreaks, prob=T, border="white", ylim=c(0,2), xlim=c(-3,3), lwd=2, lty=1, ylab="Density", xlab=" ", main="Unrestricted Analysis", axes=F) 
#white makes the original histogram -- with unwanted vertical lines -- invisible
lines(c(y$breaks, max(y$breaks)), c(0,y$intensities,0), type="S", lwd=2, lty=1) 
axis(1, at = c(-3,-2,-1,0,1,2,3), lab=c("-3","-2", "-1", "0", "1", "2", "3"))
axis(2)
mtext(expression(delta), side=1, line = 2.8, cex=2)
#now bring in log spline density estimation:
par(new=T)
plot(fit.posterior, ylim=c(0,2), xlim=c(-3,3), lty=1, lwd=1, axes=F)
points(0, dlogspline(0, fit.posterior),pch=19, cex=2)
# plot the prior:
par(new=T)
plot ( function( x ) dnorm( x, 0, 1 ), -3, 3, xlim=c(-3,3), ylim=c(0,2), lwd=1, lty=1, ylab=" ", xlab = " ") 
points(0, dnorm(0), pch=19, cex=2)

text(0.3, 1.5, labels = "Posterior", cex = 1.5, pos=4)
text(1, 0.3, labels = "Prior", cex=1.5, pos=4)

#============ Order-restricted analysis, delta > 0  ================

# height of the unrestricted posterior at delta=0:
# Method 1, renormalization
posterior     = dlogspline(0, fit.posterior) # this gives the pdf at point delta = 0
# renormalize:
area            = sum(delta.posterior > 0)/length(delta.posterior)
posterior.OR.M1 = posterior/area
prior.OR        = 2*dnorm(0) # we know this exactly
BF02            = posterior.OR.M1/prior.OR # 4.94

# Method 2, estimate truncated posterior
delta.posterior.OR  = delta.posterior[which(delta.posterior>0)]
fit.posterior.OR    = logspline(delta.posterior.OR, lbound=0)
posterior.OR.M2     = dlogspline(0, fit.posterior.OR) # this gives the pdf at point delta = 0
BF02                = posterior.OR.M2/prior.OR # 4.95


#####################################################################
### Plot Prior and Posterior under order-restriction that delta > 0 
#####################################################################

par(cex.main = 1.5, mar = c(5, 6, 4, 5) + 0.1, mgp = c(3.5, 1, 0), cex.lab = 1.5,
    font.lab = 2, cex.axis = 1.3, bty = "n", las=1)

Nbreaks = 80
y = hist(delta.posterior.OR, Nbreaks, prob=T, border="white", ylim=c(0,6), xlim=c(0,3), lwd=2, lty=1, ylab="Density", xlab=" ", main="Order-Restricted Analysis", axes=F) 
#white makes the original histogram -- with unwanted vertical lines -- invisible
lines(c(y$breaks, max(y$breaks)), c(0,y$intensities,0), type="S", lwd=2, lty=1) 
lines(c(0,0), c(0,6), col="white", lwd=4)
axis(1, at = c(0,1,2,3), lab=c("0", "1", "2", "3"))
axis(2)
mtext(expression(delta), side=1, line = 2.8, cex=2)
#now bring in log spline density estimation:
par(new=T)
plot(fit.posterior.OR, ylim=c(0,6), xlim=c(0,3), lty=1, lwd=1, axes=F)
points(0, dlogspline(0, fit.posterior.OR),pch=19, cex=2)
# plot the prior:
par(new=T)
plot ( function( x ) 2*dnorm( x, 0, 1 ), 0, 3, ylim=c(0,6), xlim=c(0,3), lwd=1, lty=1, ylab=" ", xlab = " ", axes=F) 
points(0, 2*dnorm(0), pch=19, cex=2)

text(0.2, 3, labels = "Posterior", cex = 1.5, pos=4)
text(1, 0.8, labels = "Prior", cex=1.5, pos=4)

