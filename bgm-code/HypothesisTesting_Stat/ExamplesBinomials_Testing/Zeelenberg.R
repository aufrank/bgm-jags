# clears workspace:  
rm(list=ls(all=TRUE)) 

# sets working directories:
setwd("C:/Documents and Settings/ewagenmakers/Desktop/temp/BayesBook")
library(R2WinBUGS)
bugsdir = "C:/Program Files/WinBUGS14"

### Zeelenberg data:
# Study Both:         
K_SB = c(15,11,15,14,15,18,16,16,18,16,15,13,18,12,11,13,17,18,16,11,17,18,12,18,18,14,21,18,17,10,
         11,12,16,18,17,15,19,12,21,15,16,20,15,19,16,16,14,18,16,19,17,11,19,18,16,16,11,19,18,12,
         15,18,20, 8,12,19,16,16,16,12,18,17,11,20)
N_SB = rep(21,74)

# Study Neither: 
K_SN = c(15,12,14,15,13,14,10,17,13,16,16,10,15,15,10,14,17,18,19,12,19,18,10,18,16,13,15,20,13,15,
	       13,14,19,19,19,18,13,12,19,16,14,17,15,16,15,16,13,15,14,19,12,11,17,13,18,13,13,19,18,13,
         13,16,18,14,14,17,12,12,16,14,16,18,13,13)
N_SN = rep(21,74)

         
# two-sided p-value = .03
t.test(K_SN, K_SB, alternative = c("two.sided"), paired=T)

data  = list("K_SN","K_SB","N_SN","N_SB") # to be passed on to WinBUGS

inits=function()
  {
    list(phi_SN = rnorm(74,mean=0,sd=1), alpha=rnorm(74,mean=0,sd=1),
         mu_phi = abs(rnorm(1,mean=0,sd=1)), sigma_phi = runif(1,0,5),
         sigma_alpha = runif(1,0,5), delta = abs(rnorm(1,mean=0,sd=1)))
  }
parameters = c("delta")

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits, parameters,
	 			model.file ="ZeelenbergModel.txt",
	 			n.chains=3, n.iter=10000, n.burnin=1000, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir, #DIC=T or else error message
	 			codaPkg=F, debug=F)
# Now the values for delta are in the "samples" object, ready for inspection.

# Collect posterior samples across all chains:
delta.posterior  = samples$sims.list$delta      

#============ BFs based on logspline fit ===========================
library(polspline) # this package can be installed from within R
fit.posterior = logspline(delta.posterior, lbound=0)

# 95% confidence interval:
x0=qlogspline(0.025,fit.posterior)
x1=qlogspline(0.975,fit.posterior)

posterior     = dlogspline(0, fit.posterior) # this gives the pdf at point delta = 0
prior         = 2*dnorm(0)                   # height of order--restricted prior at delta = 0
BF01          = posterior/prior
# BF01 = 0.22, BF10 = 4.49

#####################################################################
### Plot Prior and Posterior under order-restriction that delta > 0 
#####################################################################

par(cex.main = 1.5, mar = c(5, 6, 4, 5) + 0.1, mgp = c(3.5, 1, 0), cex.lab = 1.5,
    font.lab = 2, cex.axis = 1.3, bty = "n", las=1)

Nbreaks = 80
y = hist(delta.posterior, Nbreaks, prob=T, border="white", ylim=c(0,1.5), xlim=c(0,4), lwd=2, lty=1, ylab="Density", xlab=" ", main=" ", axes=F) 
#white makes the original histogram -- with unwanted vertical lines -- invisible
lines(c(y$breaks, max(y$breaks)), c(0,y$intensities,0), type="S", lwd=2, lty=1) 
lines(c(0,0), c(0,3), col="white", lwd=4)
axis(1, at = c(0,1,2,3,4), lab=c("0", "1", "2", "3", "4"))
axis(2)
mtext(expression(delta), side=1, line = 2.8, cex=2)
#now bring in log spline density estimation:
par(new=T)
plot(fit.posterior, ylim=c(0,1.5), xlim=c(0,4), lty=1, lwd=1, axes=F)
points(0, dlogspline(0, fit.posterior),pch=19, cex=2)
# plot the prior:
par(new=T)
plot ( function( x ) 2*dnorm( x, 0, 1 ), ylim=c(0,1.5), xlim=c(0,4), lwd=1, lty=1, ylab=" ", xlab = " ") 
points(0, 2*dnorm(0), pch=19, cex=2)

text(0.8, 1, labels = "Posterior", cex = 1.5, pos=4)
text(1.7, 0.25, labels = "Prior", cex=1.5, pos=4)

