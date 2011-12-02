# clears workspace:  
rm(list=ls(all=TRUE)) 

# sets working directories:
#setwd("C:/Documents and Settings/ewagenmakers/Desktop/temp/BayesBook")
setwd("C:/Documents and Settings/ewagenmakers/My Documents/My Dropbox/EJ/temp/BayesBook/Code/ParameterEstimation_Stat/BasicDataAnalysis")
library(R2WinBUGS)
bugsdir = "C:/Program Files/WinBUGS14"

c    = scan("changepointdata.txt")
n    = length(c)
t    = 1:n
tmax = max(t)

data  = list("c", "n", "t", "tmax") # to be passed on to WinBUGS
myinits =	list(
  list(mu = c(1,1), lambda = 1, tau = tmax/2))

# parameters to be monitored:	
parameters = c("mu","sigma","tau")

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits=myinits, parameters,
	 			model.file ="ChangeDetection_1.txt",
	 			n.chains=1, n.iter=1000, n.burnin=0, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir,
	 			codaPkg=F, debug=T)
# Now the values for the monitored parameters are in the "samples" object, 
# ready for inspection.

plot(samples)
mean.tau = samples$mean$tau
mean.mu1 = samples$mean$mu[1]
mean.mu2 = samples$mean$mu[2]

#some plotting options to make things look better:
par(cex.main = 1.5, mar = c(5, 6, 4, 5) + 0.1, mgp = c(3.5, 1, 0), cex.lab = 1.5,
    font.lab = 2, cex.axis = 1.3, bty = "n", las=1)
# the plotting: 
plot(c, type="l", main="", ylab="Values", xlab="Samples")
lines(c(1, mean.tau), c(mean.mu1,mean.mu1), lwd=2, col="red")
lines(c(mean.tau+1,length(c)), c(mean.mu2,mean.mu2), lwd=2, col="red")