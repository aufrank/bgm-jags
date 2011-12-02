# clears workspace:  
rm(list=ls(all=TRUE)) 

# sets working directories:
#setwd("C:/Documents and Settings/ewagenmakers/Desktop/temp/BayesBook")
setwd("C:/Documents and Settings/ewagenmakers/My Documents/My Dropbox/EJ/temp/BayesBook/Code/ParameterEstimation_Stat/ExamsQuizzes")
library(R2WinBUGS)
bugsdir = "C:/Program Files/WinBUGS14"

dset=1

if (dset==1)
{
  k = c(1,1,1,1,0,0,1,1,0,1,0,0,1,0,0,1,0,1,0,0,
        0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,1,0,0,0,1,1,0,0,0,0,1,0,0,0,0,0,0,0,
        0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,
        1,0,1,1,0,1,1,1,0,1,0,0,1,0,0,0,0,1,0,0,
        1,1,0,1,0,0,0,1,0,1,0,1,1,0,0,1,0,1,0,0,
        0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,1,1,0,0,0,0,1,0,1,0,0,1,0,0,0,0,1,0,1,
        1,0,0,0,0,0,1,0,0,1,0,0,1,0,0,0,0,0,0,0)
}

if (dset==2)
{
  k = c(1,1,1,1,0,0,1,1,0,1,0,0,NA,0,0,1,0,1,0,0,
        0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,1,0,0,0,1,1,0,0,0,0,1,0,0,0,0,0,0,0,
        0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,
        1,0,1,1,0,1,1,1,0,1,0,0,1,0,0,0,0,1,0,0,
        1,1,0,1,0,0,0,1,0,1,0,1,1,0,0,1,0,1,0,0,
        0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,
        0,0,0,0,NA,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,1,1,0,0,0,0,1,0,1,0,0,1,0,0,0,0,1,0,1,
        1,0,0,0,0,0,1,0,0,1,0,0,1,0,0,0,0,NA,0,0)
}

k = matrix(k, nrow=10, byrow=T)

np = nrow(k)
nq = ncol(k)

data = list("np","nq","k") # to be passed on to WinBUGS
myinits =	list(
  list(q = runif(nq), p = runif(np)))

if (dset==1)
{
# parameters to be monitored:	
  parameters = c("p", "q")

  # The following command calls WinBUGS with specific options.
  # For a detailed description see Sturtz, Ligges, & Gelman (2005).
  samples = bugs(data, inits=myinits, parameters,
    	 			model.file ="ExamsQuizzes_3.txt",
    	 			n.chains=1, n.iter=10000, n.burnin=0, n.thin=1,
    	 			DIC=T, bugs.directory=bugsdir,
    	 			codaPkg=F, debug=T)
  # Now the values for the monitored parameters are in the "samples" object, 
  # ready for inspection.
}

if (dset==2)
{
# parameters to be monitored:	
  parameters = c("p", "q", "NA.array")

  # The following command calls WinBUGS with specific options.
  # For a detailed description see Sturtz, Ligges, & Gelman (2005).
  samples = bugs(data, inits=myinits, parameters,
    	 			model.file ="ExamsQuizzes_3r.txt",
    	 			n.chains=1, n.iter=10000, n.burnin=0, n.thin=1,
    	 			DIC=T, bugs.directory=bugsdir,
    	 			codaPkg=F, debug=T)
  # Now the values for the monitored parameters are in the "samples" object, 
  # ready for inspection.
}

# When you want to sample the missing data, you cannot just return "k" to R,
# as you can with Matlab. 
# Most likely, the reason is that "k" is a matrix, and, say, k[1,13] is a 
# single number.
# WinBUGS will sample k[1,13] when it contains "NA", but R will not accept
# a sequence of samples for the cell k[1,13]. This means the following:
# 1. Using R2WinBUGS, you can tell WinBUGS to monitor and return "k". 
# When you set "debug=T", you can inspect the results, but, when you return
# to R, WinBUGS is unable to pass on its results.
# 2. One clumsy way around this problem is illustrated in the code
# ExamsQuizzes_3r.txt. 
