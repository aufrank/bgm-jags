# clears workspace:  
rm(list=ls(all=TRUE)) 

# sets working directories:
#setwd("C:/Documents and Settings/ewagenmakers/Desktop/temp/BayesBook")
setwd("C:/Documents and Settings/ewagenmakers/My Documents/My Dropbox/EJ/temp/BayesBook/Code/ParameterEstimation_Stat/ExamplesGaussian")

library(R2WinBUGS)
bugsdir = "C:/Program Files/WinBUGS14"

x    = c(1.1, 1.9, 2.3, 1.8)
n    = length(x)

data  = list("x", "n") # to be passed on to WinBUGS
myinits =	list(
  list(mu = 0, sigma = 1))

# parameters to be monitored:	
parameters = c("mu", "sigma")

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits=myinits, parameters,
	 			model.file ="Gaussian_1.txt",
	 			n.chains=1, n.iter=1000, n.burnin=0, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir,
	 			codaPkg=F, debug=T)
# Now the values for the monitored parameters are in the "samples" object, 
# ready for inspection.

mu    = samples$sims.list$mu
sigma = samples$sims.list$sigma 

