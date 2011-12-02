# clears workspace:  
rm(list=ls(all=TRUE)) 

# sets working directories:
#setwd("F:/Codes/ExamplesBinomial_Estimation")
setwd("C:/Documents and Settings/ewagenmakers/My Documents/My Dropbox/EJ/temp/BayesBook/Code/ParameterEstimation_Stat/ExamplesBinomial_Estimation")

library(R2WinBUGS)
bugsdir = "C:/Program Files/WinBUGS14"

k1 = 5
k2 = 7
n1 = 10
n2 = 10

data  = list("k1", "k2", "n1", "n2") # to be passed on to WinBUGS
myinits =	list(
  list(theta1 = 0.1, theta2 = 0.9))

# parameters to be monitored:	
parameters = c("delta", "theta1", "theta2")

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits=myinits, parameters,
	 			model.file ="Rate_2.txt",
	 			n.chains=1, n.iter=10000, n.burnin=0, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir,
	 			codaPkg=F, debug=F)
# Now the values for the monitored parameters are in the "samples" object, 
# ready for inspection.

# Collect posterior samples:
delta = samples$sims.list$delta 

# Plot a density estimate for delta: 
plot(density(delta), xlab="Difference in Rates", ylab="Posterior Density", main =" ", xlim=c(-1,1))

# Add some plotting options to make things look better:
par(cex.main = 1.5, mar = c(5, 6, 4, 5) + 0.1, mgp = c(3.5, 1, 0), cex.lab = 1.5,
    font.lab = 2, cex.axis = 1.3, bty = "n", las=1)
plot(density(delta), xlab="Difference in Rates", ylab="Posterior Density", main =" ", lwd=2, xlim=c(-1,1))
 
# mean of delta:
mean(delta)
# median of delta:
median(delta)
# mode of delta, estimated from the "density" smoother:
density(delta)$x[which(density(delta)$y==max(density(delta)$y))]
# 95% confidence interval for delta:
low  = round(.025*length(delta))
high = round(.975*length(delta))
sort(delta)[low]
sort(delta)[high]
