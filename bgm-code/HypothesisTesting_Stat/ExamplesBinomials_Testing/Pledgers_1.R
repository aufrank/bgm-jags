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
# H1: delta is unrestricted
######################################################

# Collect posterior samples across all chains:
delta.posterior  = samples$sims.list$delta      
delta.prior      = samples$sims.list$deltaprior

#============ BFs based on logspline fit ===========================
library(polspline) # this package can be installed from within R
fit.prior     = logspline(delta.prior, lbound=-1, ubound=1) # note the bounds.
fit.posterior = logspline(delta.posterior, lbound=-1, ubound=1)

# 95% confidence interval:
x0=qlogspline(0.025,fit.posterior)
x1=qlogspline(0.975,fit.posterior)

posterior     = dlogspline(0, fit.posterior) # this gives the pdf at point delta = 0
prior         = dlogspline(0, fit.prior)     # based on the logspline fit
BF01          = posterior/prior
# 1/BF01 gives 2.14 -- Exact solution: 2.223484
BF01          = posterior # because we know the height of the prior equals 1 at delta = 0 
# 1/BF01 gives 2.17

#============ Plot Prior and Posterior ================================
# Two plots, once globally and once zoomed-in

par(cex.main = 1.5, mar = c(5, 6, 4, 5) + 0.1, mgp = c(3.5, 1, 0), cex.lab = 1.5,
    font.lab = 2, cex.axis = 1.3, bty = "n", las=1)
#======= Plot Prior and Posterior ======================
Nbreaks = 20
y = hist(delta.prior, Nbreaks, prob=T, border="white", ylim=c(0,25), xlim=c(-1,1), lwd=2, lty=3, ylab="Density", xlab=" ", main=" ", axes=F) 
#white makes the original histogram -- with unwanted vertical lines -- invisible
lines(c(y$breaks, max(y$breaks)), c(0,y$intensities,0), type="S", lwd=2, lty=3) 
axis(1, at = c(-1, -0.5, 0, 0.50, 1), lab=c("-1", "-0.5", "0", "0.5", "1"))
axis(2)
mtext(expression(delta), side=1, line = 2.8, cex=2)
par(new=T)
x = hist(delta.posterior, Nbreaks, prob=T, border="white", ylim=c(0,25), xlim=c(-1,1), lwd=2, lty=1, ylab="Density", xlab=" ", main ="Full Scale", axes=F) 
#white makes the original histogram -- with unwanted vertical lines -- invisible
lines(c(x$breaks, max(x$breaks)), c(0,x$intensities,0), type="S", lwd=2) 
axis(1, at = c(-1, -0.5, 0, 0.50, 1), lab=c("-1", "-0.5", "0", "0.5", "1"))
axis(2)
#now bring in log spline density estimation:
par(new=T)
# plot the triangular prior:
lines(c(-1,0),c(0,1), lty=1, lwd=1)
lines(c(0,1),c(1,0), lty=1, lwd=1)
par(new=T)
plot(fit.posterior, ylim=c(0,25), xlim=c(-1,1), lty=1, lwd=1, axes=F)

text(-1, 20, labels = "Posterior", cex = 1.5, pos=4)
text(-1, 2, labels = "Prior", cex=1.5, pos=4)

######## Second plot, zoom in:
par(cex.main = 1.5, mar = c(5, 6, 4, 5) + 0.1, mgp = c(3.5, 1, 0), cex.lab = 1.5,
    font.lab = 2, cex.axis = 1.3, bty = "n", las=1)
xmin = -0.05
xmax = 0.05
ymax = 5
plot(0,0, ylim=c(0,ymax), xlim=c(xmin,xmax), lwd=2, lty=3, ylab="Density", xlab=" ", main="Zoomed in", axes=F, col="white") 
#white makes this invisible
axis(1, at = c(xmin, 0, xmax), lab=c(paste(xmin), "0", paste(xmax)))
axis(2)
mtext(expression(delta), side=1, line = 2.8, cex=2)
par(new=T)
plot(fit.posterior, ylim=c(0,ymax), xlim=c(xmin,xmax), lty=1, lwd=2, axes=F)
lines(c(-1,0),c(0,1), lty=1, lwd=2)
lines(c(0,1),c(1,0), lty=1, lwd=2)
points(0, 1, pch=19, cex=2)
points(0, dlogspline(0, fit.posterior),pch=19, cex=2)

text(-0.015, 4, labels = "Posterior", cex = 1.5, pos=4)
text(0.01, 1.3, labels = "Prior", cex=1.5, pos=4)

