# clears workspace:  
rm(list=ls(all=TRUE)) 

# sets working directories:
#setwd("C:/Documents and Settings/ewagenmakers/Desktop/temp/BayesBook")
setwd("C:/Documents and Settings/ewagenmakers/My Documents/My Dropbox/EJ/temp/BayesBook/Code/ParameterEstimation_Stat/ExamsQuizzes")
library(R2WinBUGS)
bugsdir = "C:/Program Files/WinBUGS14"

k = c(21,17,21,18,22,31,31,34,34,35,35,36,39,36,35)
p = length(k) #number of people
n = 40 # number of questions


data  = list("p", "k", "n") # to be passed on to WinBUGS
myinits =	list(
  list(phi = c(NA,0.5), z = round(runif(p)))) # Initial group assignment

# parameters to be monitored:	
parameters = c("phi","z")

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits=myinits, parameters,
	 			model.file ="ExamsQuizzes_1.txt",
	 			n.chains=1, n.iter=1000, n.burnin=0, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir,
	 			codaPkg=F, debug=T)
# Now the values for the monitored parameters are in the "samples" object, 
# ready for inspection.

