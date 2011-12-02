# clears workspace:
rm(list=ls(all=TRUE))

# sets working directories:
#setwd("F:/Codes/Convergence")
setwd("C:/Documents and Settings/ewagenmakers/My Documents/My Dropbox/EJ/temp/BayesBook/Code/ParameterEstimation_Stat/Convergence")
library(R2WinBUGS)
bugsdir = "C:/Program Files/WinBUGS14"

# Read data, a sequence of 33 participants * 90 problems 
# [3 probability estimates per problem] 
x = read.table("ConjunctionData.txt")

# Create three matrices: each row is a participant, each column is an item 
# Note that the [-30,] removes the data from participant 30: 
PA  = t(matrix(x[,1], nrow=90, ncol=33))[-30,]
PB  = t(matrix(x[,2], nrow=90, ncol=33))[-30,]
PAB = t(matrix(x[,3], nrow=90, ncol=33))[-30,]

# defines the number of items and number of participants
nsubj = length(PA[,1])
nitem = length(PA[1,])

data  = list("PA", "PB", "PAB", "nsubj", "nitem") # to be passed on to WinBUGS
myinits = list(
   list(betaphi = rnorm(nsubj,mean=0,sd=1), muphi = -0.6, sigmaphi = 0.2),
   list(betaphi = rnorm(nsubj,mean=0,sd=1), muphi = 0,   sigmaphi = 0.2),
   list(betaphi = rnorm(nsubj,mean=0,sd=1), muphi = 0.6,  sigmaphi = 0.2))

# parameters to be monitored:
parameters = c("beta", "muphi", "mu", "sigmaphi")

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits=myinits, parameters,
	 			model.file ="ConjunctionModel.txt",
	 			n.chains=3, n.iter=4000, n.burnin=1000, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir,
	 			codaPkg=F, debug=T)
# Now the values for the monitored parameters are in the "samples" object, 
# ready for inspection.

# Assess Convergence with Coda package
library(coda)

coda.c1 = as.mcmc(samples$sims.array[,1,"mu"])
coda.c2 = as.mcmc(samples$sims.array[,2,"mu"])
coda.c3 = as.mcmc(samples$sims.array[,3,"mu"])

# Now put different chains in a single coda object
coda.c  = mcmc.list(coda.c1,coda.c2,coda.c3)

gelman.diag(coda.c)
# for more information, type "?gelman.diag" at the R prompt
# the help function also links to other stuff that coda can do
# Note that as a rule of thumb, Rhat must be < 1.1. The closer
# to 1.0 the better!
gelman.plot(coda.c)

# inspect the chains' autocorrelation (the lower the better):
autocorr(coda.c)

# the following allows you to easily "thin" the chain, leaving in
# only every thin'th value. This is not needed here, as the 
# autocorrelations are already very low. 
coda.c.thin = window(coda.c, thin=10)
autocorr(coda.c.thin)

# Visually check for fat hairy caterpillars and indistinguishability of the chains:
traceplot(coda.c)









