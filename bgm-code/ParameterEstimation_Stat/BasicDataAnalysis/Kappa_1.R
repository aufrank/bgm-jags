# clears workspace:  
rm(list=ls(all=TRUE)) 

# sets working directories:
#setwd("C:/Documents and Settings/ewagenmakers/Desktop/temp/BayesBook")
setwd("C:/Documents and Settings/ewagenmakers/My Documents/My Dropbox/EJ/temp/BayesBook/Code/ParameterEstimation_Stat/BasicDataAnalysis")
library(R2WinBUGS)
bugsdir = "C:/Program Files/WinBUGS14"

# choose a data set:
# Influenza Clinical Trial
d= c(14, 4, 5, 210)
#Hearing Loss Assessment Trial
#d= c(20, 7, 103, 417)
# Salem Witch Trial Data
#d= c(157, 0, 13, 0)

n = sum(d) # number of people/units measured

data  = list("d", "n") # to be passed on to WinBUGS
myinits =	list(
  list(alpha = 0.5, beta = 0.5, gamma = 0.5))

# parameters to be monitored:	
parameters = c("kappa","xi","psi","alpha","beta","gamma","pi")

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits=myinits, parameters,
	 			model.file ="Kappa_1.txt",
	 			n.chains=1, n.iter=2000, n.burnin=0, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir,
	 			codaPkg=F, debug=T)
# Now the values for the monitored parameters are in the "samples" object, 
# ready for inspection.

plot(samples)

samples$mean$kappa

# Compare to Cohen's point estimate
p0 = (d[1]+d[4])/n
pe = (((d[1]+d[2]) * (d[1]+d[3])) + ((d[2]+d[4]) * (d[3]+d[4]))) / n^2
kappa.Cohen = (p0-pe) / (1-pe) 
kappa.Cohen