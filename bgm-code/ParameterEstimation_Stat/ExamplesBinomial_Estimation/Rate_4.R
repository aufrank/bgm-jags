# clears workspace:  
rm(list=ls(all=TRUE)) 

# sets working directories:
#setwd("F:/Codes/ExamplesBinomial_Estimation")
setwd("C:/Documents and Settings/ewagenmakers/My Documents/My Dropbox/EJ/temp/BayesBook/Code/ParameterEstimation_Stat/ExamplesBinomial_Estimation")

library(R2WinBUGS)
bugsdir = "C:/Program Files/WinBUGS14"

k = c(3, 1, 4, 5)
n = 10
m = length(k)

data  = list("k", "n", "m") # to be passed on to WinBUGS
myinits =	list(
  list(theta = 0.5, thetaprior = 0.5))

# parameters to be monitored:	
parameters = c("theta", "thetaprior", "postpredk", "priorpredk")

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits=myinits, parameters,
	 			model.file ="Rate_4.txt",
	 			n.chains=1, n.iter=5000, n.burnin=0, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir,
	 			codaPkg=F, debug=T)
# Now the values for the monitored parameters are in the "samples" object, 
# ready for inspection.

######################Plots########################################################################
theta      = samples$sims.list$theta
thetaprior = samples$sims.list$thetaprior 
postpredk  = samples$sims.list$postpredk 
priorpredk = samples$sims.list$priorpredk

layout(matrix(c(1,2),2,1))
layout.show(2)
#Prior and posterior of theta
plot(density(theta), zero.line=F, axes=F, main="", xlab="", ylab="", xlim=c(0,1), ylim=c(0,6))
axis(1, at=c(0,0.2,0.4,0.6,0.8,1), lab=c("0","0.2","0.4","0.6","0.8","1"),cex.axis=0.8)
mtext("Rate", side=1, line=2.25, cex=1.2)
axis(2, at=c(0,2,4,6),cex.axis=0.8)
mtext("Posterior Density", side=2, line=2.25, cex=1.2)
lines(density(thetaprior, from=0, to=1), lty=3, col="gray")
legend(0.775,5.75, c("Prior", "Posterior"), lty=c(3,1), col=c ("grey", "black"))

#Prior and posterior predictive
hist(postpredk,breaks=c(-0.5,0.5,1.5,2.5,3.5,4.5,5.5,6.5,7.5,8.5,9.5,10.5),freq=F, right=F, ylab="", xlab="", ylim=c(0,0.3),main="", axes=F )
axis(1, at=c(0,2,4,6,8,10),lab=c(0,2,4,6,8,10),cex.axis=0.8)
mtext("Success Count", side=1, line=2.25, cex=1.2)
axis(2,at=c(0,0.1,0.2,0.3),lab=c("0","0.1","0.2","0.3"),cex.axis=0.8)
mtext("Posterior Mass", side=2, line=2.25, cex=1.2)
hist(priorpredk, breaks=c(-0.5,0.5,1.5,2.5,3.5,4.5,5.5,6.5,7.5,8.5,9.5,10.5),freq=F,right=F,add=T, lty=3,border="grey")
legend(8,0.3, c("Prior", "Posterior"), lty=c(3,1),col=c("grey", "black"))
