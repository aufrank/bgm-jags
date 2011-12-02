# clears workspace:  
rm(list=ls(all=TRUE)) 

# sets working directories:
#setwd("C:/Documents and Settings/ewagenmakers/Desktop/temp/BayesBook")
setwd("C:/Documents and Settings/ewagenmakers/My Documents/My Dropbox/EJ/temp/BayesBook/Code/ParameterEstimation_Stat/ExamsQuizzes")
library(R2WinBUGS)
bugsdir = "C:/Program Files/WinBUGS14"

dset=3

if (dset==1)
{
k = c(1,0,0,1,1,0,0,1,
      1,0,0,1,1,0,0,1,
      0,1,1,0,0,1,0,0,
      0,1,1,0,0,1,1,0,
      1,0,0,1,1,0,0,1,
      0,0,0,1,1,0,0,1,
      0,1,0,0,0,1,1,0,
      0,1,1,1,0,1,1,0)
k = matrix(k, nrow=8, byrow=T)
}

if (dset==2)
{
k = c(1,0,0,1,1,0,0,1,
      1,0,0,1,1,0,0,1,
      0,1,1,0,0,1,0,0,
      0,1,1,0,0,1,1,0,
      1,0,0,1,1,0,0,1,
      0,0,0,1,1,0,0,1,
      0,1,0,0,0,1,1,0,
      0,1,1,1,0,1,1,0,
      1,0,0,1,NA,NA,NA,NA,
      0,NA,NA,NA,NA,NA,NA,NA,
      NA,NA,NA,NA,NA,NA,NA,NA)
k = matrix(k, nrow=11, byrow=T)
}

if (dset==3)
{
k = c(1,0,0,1,1,0,0,1,
      1,0,0,1,1,0,0,1,
      1,0,0,1,1,0,0,1,
      1,0,0,1,1,0,0,1,
      1,0,0,1,1,0,0,1,
      1,0,0,1,1,0,0,1,
      1,0,0,1,1,0,0,1,
      1,0,0,1,1,0,0,1,
      1,0,0,1,1,0,0,1,
      1,0,0,1,1,0,0,1,
      1,0,0,1,1,0,0,1,
      1,0,0,1,1,0,0,1,
      0,1,1,0,0,1,0,0,
      0,1,1,0,0,1,1,0,
      1,0,0,1,1,0,0,1,
      0,0,0,1,1,0,0,1,
      0,1,0,0,0,1,1,0,
      0,1,1,1,0,1,1,0,
      1,0,0,1,NA,NA,NA,NA,
      0,NA,NA,NA,NA,NA,NA,NA,
      NA,NA,NA,NA,NA,NA,NA,NA)
k = matrix(k, nrow=21, byrow=T)
}

np = nrow(k)
nq = ncol(k)

data = list("np","nq","k") # to be passed on to WinBUGS
inits =	list(
  list(qz = round(runif(nq)), pz = round(runif(np)), alpha=0.5, beta=0.5))

if (dset==1)
{
# parameters to be monitored:	
  parameters = c("qz", "pz", "alpha", "beta")

  # The following command calls WinBUGS with specific options.
  # For a detailed description see Sturtz, Ligges, & Gelman (2005).
  samples = bugs(data, inits, parameters,
    	 			model.file ="ExamsQuizzes_4.txt",
    	 			n.chains=1, n.iter=2000, n.burnin=1000, n.thin=1,
    	 			DIC=T, bugs.directory=bugsdir,
    	 			codaPkg=F, debug=T)
  # Now the values for the monitored parameters are in the "samples" object, 
  # ready for inspection.
}

if (dset==2)
{
# parameters to be monitored:	
  parameters = c("qz", "pz", "alpha", "beta", "NA.LP1", "NA.LP2", "NA.LP3")

  # The following command calls WinBUGS with specific options.
  # For a detailed description see Sturtz, Ligges, & Gelman (2005).
  samples = bugs(data, inits, parameters,
    	 			model.file ="ExamsQuizzes_4r.txt",
    	 			n.chains=1, n.iter=2000, n.burnin=1000, n.thin=1,
    	 			DIC=T, bugs.directory=bugsdir,
    	 			codaPkg=F, debug=T)
  # Now the values for the monitored parameters are in the "samples" object, 
  # ready for inspection.
}

if (dset==3)
{
# parameters to be monitored:	
  parameters = c("qz", "pz", "alpha", "beta", "NA.LP1", "NA.LP2", "NA.LP3")

  # The following command calls WinBUGS with specific options.
  # For a detailed description see Sturtz, Ligges, & Gelman (2005).
  samples = bugs(data, inits, parameters,
    	 			model.file ="ExamsQuizzes_4rr.txt",
    	 			n.chains=1, n.iter=2000, n.burnin=1000, n.thin=1,
    	 			DIC=T, bugs.directory=bugsdir,
    	 			codaPkg=F, debug=T)
  # Now the values for the monitored parameters are in the "samples" object, 
  # ready for inspection.
}
 
