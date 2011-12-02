# clears workspace:  
rm(list=ls(all=TRUE)) 

# sets working directories:
#setwd("C:/Documents and Settings/ewagenmakers/Desktop/temp/BayesBook")
setwd("C:/Documents and Settings/ewagenmakers/My Documents/My Dropbox/EJ/temp/BayesBook/Code/ParameterEstimation_Stat/ExamplesGaussian")
library(R2WinBUGS)
bugsdir = "C:/Program Files/WinBUGS14"

x = matrix(c(90,95,100,105,110,115,150,155,160),nrow=3,ncol=3,byrow=T) 
x

n = nrow(x) # number of people
m = ncol(x) # number of repeated measurements

data  = list("x", "n", "m") # to be passed on to WinBUGS
myinits =	list(
  list(mu = rep(100,n), sigma = 1))

# parameters to be monitored:	
parameters = c("mu", "sigma")

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits=myinits, parameters,
	 			model.file ="Gaussian_3.txt",
	 			n.chains=1, n.iter=1000, n.burnin=0, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir,
	 			codaPkg=F, debug=T)
# Now the values for the monitored parameters are in the "samples" object, 
# ready for inspection.


