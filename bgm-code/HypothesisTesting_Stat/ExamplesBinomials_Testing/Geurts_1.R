# clears workspace:  
rm(list=ls(all=TRUE)) 

# sets working directories:
setwd("C:/Documents and Settings/ewagenmakers/Desktop/temp/BayesBook")
library(R2WinBUGS)
bugsdir = "C:/Program Files/WinBUGS14"

### Geurts data:
# Normal Controls:         
num_errors = c(15,10, 61,11, 60, 44, 63, 70, 57,11, 67, 21, 89,12, 63, 11, 96,10, 37,19, 44,18, 78, 27, 60,14)
N_NC       = c(89,74,128,87,128,121,128,128,128,78,128,106,128,83,128,100,128,73,128,86,128,86,128,100,128,79)
K_NC       = N_NC - num_errors
# ADHD:
num_errors = c( 88, 50, 58,17, 40, 18,21, 50, 21, 69,19, 29,11, 76, 46, 36, 37, 72,27, 92,13, 39, 53, 31, 49, 
                57,17,10,12,21, 39, 43, 49,17, 39,13, 68, 24, 21,27, 48, 54, 41, 75, 38, 76,21, 41, 61,24, 28,21)
N_AD       = c(128,128,128,86,128,117,89,128,110,128,93,107,87,128,128,113,128,128,98,128,93,116,128,116,128,
               128,93,86,86,96,128,128,128,86,128,78,128,111,100,95,128,128,128,128,128,128,98,127,128,93,110,96)
K_AD       = N_AD - num_errors
           
# two-sided p-value = .72
t.test(K_NC/N_NC, K_AD/N_AD, alternative = c("two.sided"), paired=F)

data  = list("K_NC","N_NC","K_AD","N_AD") # to be passed on to WinBUGS

inits=function()
  {
    list(phi_NC = rnorm(26,mean=0,sd=1), phi_AD = rnorm(52,mean=0,sd=1), 
         mu = rnorm(1,mean=0,sd=1), sigma = runif(1,0,5), delta = rnorm(1,mean=0,sd=1))
  }

parameters = c("delta")

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits, parameters,
	 			model.file ="GeurtsModel.txt",
	 			n.chains=3, n.iter=10000, n.burnin=1000, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir, #DIC=T or else error message
	 			codaPkg=F, debug=T)
# Now the values for delta are in the "samples" object, ready for inspection.


######################################################
# H1: delta is unrestricted
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
prior         = dnorm(0)                     # height of order--restricted prior at delta = 0
BF01          = posterior/prior
# BF01 = 3.96, BF10 = 0.25

#============ Plot Prior and Posterior ================================

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
