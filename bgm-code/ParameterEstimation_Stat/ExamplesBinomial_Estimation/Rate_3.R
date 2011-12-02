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
  list(theta = 0.5))

# parameters to be monitored:	
parameters = c("theta")

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits=myinits, parameters,
	 			model.file ="Rate_3.txt",
	 			n.chains=1, n.iter=1000, n.burnin=0, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir,
	 			codaPkg=F, debug=T)
# Now the values for the monitored parameters are in the "samples" object, 
# ready for inspection.


