# clears workspace:  
rm(list=ls(all=TRUE)) 

# sets working directories:
#setwd("C:/Documents and Settings/ewagenmakers/Desktop/temp/BayesBook")
setwd("C:/Documents and Settings/ewagenmakers/My Documents/My Dropbox/EJ/temp/BayesBook/Code/ParameterEstimation_Stat/BasicDataAnalysis")
library(R2WinBUGS)
bugsdir = "C:/Program Files/WinBUGS14"

# Choose a dataset:
dset=5

# The datasets:
if (dset == 1)
{
  x = matrix(c(10,8.04, 8,6.95, 13,7.58, 9,8.81, 11,8.33, 
               14,9.96, 6,7.24, 4,4.26, 12,10.84, 7,4.82, 5,5.68),nrow=11,ncol=2,byrow=T) 
}

if (dset == 2)
{
  x = matrix(c(10,8.04, 8,6.95, 13,7.58, 9,8.81, 11,8.33, 
               14,9.96, 6,7.24, 4,4.26, 12,10.84, 7,4.82, 5,5.68,
               10,8.04, 8,6.95, 13,7.58, 9,8.81, 11,8.33, 
               14,9.96, 6,7.24, 4,4.26, 12,10.84, 7,4.82, 5,5.68),nrow=22,ncol=2,byrow=T) 
}

if (dset == 3)
{
  x = matrix(c(10,9.14, 8,8.14, 13,8.74, 9,8.77, 11,9.26, 
               14,8.1, 6,6.13, 4,3.10, 12,9.13, 7,7.26, 5,4.74),nrow=11,ncol=2,byrow=T) 
}

if (dset == 4)
{
  x = matrix(c(10,7.46, 8,6.77, 13,12.74, 9,7.11, 11,7.81, 
               14,8.84, 6,6.08, 4,5.39, 12,8.15, 7,6.42, 5,5.73),nrow=11,ncol=2,byrow=T) 
}

if (dset == 5)
{
  x = matrix(c(8,6.58, 8,5.76, 8,7.71, 8,8.84, 8,8.47, 
               8,7.04, 8,5.25, 19,12.5, 8,5.56, 8,7.91, 8,6.89),nrow=11,ncol=2,byrow=T) 
}

n = nrow(x) # number of people/units measured

data  = list("x", "n") # to be passed on to WinBUGS
myinits =	list(
  list(r = 0, mu = c(0,0), lambda = c(1,1)))
# parameters to be monitored:	
parameters = c("r", "mu", "sigma")

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits=myinits, parameters,
	 			model.file ="Correlation_1.txt",
	 			n.chains=1, n.iter=5000, n.burnin=0, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir,
	 			codaPkg=F, debug=F)
# Now the values for the monitored parameters are in the "samples" object, 
# ready for inspection.

r = samples$sims.list$r

#Frequentist point-estimate of r:
freq.r = cor(x[,1],x[,2])

#make the two panel plot:
layout(matrix(c(1,2),1,2))
layout.show(2)
#some plotting options to make things look better:
par(cex.main = 1.5, mar = c(5, 6, 4, 5) + 0.1, mgp = c(3.5, 1, 0), cex.lab = 1.5,
    font.lab = 2, cex.axis = 1.3, bty = "n", las=1)
# data panel:    
plot(x[,1],x[,2], type="p", pch=19, cex=1.5)
# correlation panel:
plot(density(r, from=-1,to=1), main="", ylab="Posterior Density", xlab="Correlation", lwd=2)
lines(c(freq.r, freq.r), c(0,100), lwd=2, lty=2)

