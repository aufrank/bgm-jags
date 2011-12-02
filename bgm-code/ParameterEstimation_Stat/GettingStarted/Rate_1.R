# R2WinBUGS Example;
# When you work through the code for the first time, 
# execute each command one at a time to better understand
# what it does.

# clears workspace:  
rm(list=ls(all=TRUE)) 

# sets working directories:
#setwd("D:/BugsBoek/NEW.BugsBook/Content/ParameterEstimation_Stat/GettingStarted/Codes")
#setwd("C:/EJ/UvApost/uvapapers/papers 2009/NEW.BugsBook/Content/ParameterEstimation_Stat/GettingStarted/Codes")
#setwd("D:/BugsBoek/NEW.BugsBook/Content/ParameterEstimation_Stat/GettingStarted/Codes")
setwd("C:/Documents and Settings/ewagenmakers/My Documents/My Dropbox/EJ/temp/BayesBook/Code/ParameterEstimation_Stat/GettingStarted")

library(R2WinBUGS)
bugsdir = "C:/Program Files/WinBUGS14"

k = 5
n = 10

data  = list("k", "n") # to be passed on to WinBUGS

myinits =	list(
  list(theta = 0.1),
  list(theta = 0.9))

# parameters to be monitored:	
parameters = c("theta")

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits=myinits, parameters,
	 			model.file ="Rate_1.txt",
	 			n.chains=2, n.iter=20000, n.burnin=0, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir,
	 			codaPkg=F, debug=F)
# Now the values for the monitored parameters are in the "samples" object, 
# ready for inspection.

# The commands below are useful for a quick overview:
print(samples)  # a rough summary
plot(samples)   # a visual representation
names(samples)  # summarizes the variables
samples$summary # more detailed summary
chain = 1
samples$sims.array[1:15,chain,]# array: element, chain, column (theta/deviance)

# Collect posterior and prior samples across all chains:
theta = samples$sims.list$theta 

# Plot a density estimate for theta: 
plot(density(theta))
