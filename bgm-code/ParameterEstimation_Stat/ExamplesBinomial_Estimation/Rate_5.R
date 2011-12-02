# clears workspace:  
rm(list=ls(all=TRUE)) 

# sets working directories:
#setwd("F:/Codes/ExamplesBinomial_Estimation")
setwd("C:/Documents and Settings/ewagenmakers/My Documents/My Dropbox/EJ/temp/BayesBook/Code/ParameterEstimation_Stat/ExamplesBinomial_Estimation")

library(R2WinBUGS)
bugsdir = "C:/Program Files/WinBUGS14"

k = 1
n = 2

data  = list("k", "n") # to be passed on to WinBUGS
myinits =	list(
  list(theta = 0.5, thetaprior = 0.5))
  
# parameters to be monitored:	
parameters = c("theta", "thetaprior")

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits=myinits, parameters,
	 			model.file ="Rate_5.txt",
	 			n.chains=1, n.iter=10000, n.burnin=0, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir,
	 			codaPkg=F, debug=T)
# Now the values for the monitored parameters are in the "samples" object, 
# ready for inspection.

######################Plots########################################################################
theta      = samples$sims.list$theta
thetaprior = samples$sims.list$thetaprior 

#Prior and posterior of theta
hist(theta, 100, freq=F, axes=F, main="", xlab="", ylab="", xlim=c(0,1), ylim=c(0,50))
axis(1, at=c(0,0.2,0.4,0.6,0.8,1), lab=c("0","0.2","0.4","0.6","0.8","1"),cex.axis=0.8)
mtext("Rate", side=1, line=2.25, cex=1.2)
axis(2, cex.axis=0.8)
mtext("Posterior Density", side=2, line=2.25, cex=1.2)

par(new=T)

hist(thetaprior, 100, freq=F, axes=F, main="", xlab="", ylab="", xlim=c(0,1), ylim=c(0,50), lty=3, col="gray")
axis(1, at=c(0,0.2,0.4,0.6,0.8,1), lab=c("0","0.2","0.4","0.6","0.8","1"),cex.axis=0.8)
axis(2, cex.axis=0.8)

legend(0.4,45, c("Prior", "Posterior"), lty=c(3,1), col=c ("grey", "black"))
