#### R2Winbugs Code for a Bayesian hierarchical test for the MPT model.
# This code tests parameter recovery

rm(list=ls(all=TRUE)) # clears workspace
# sets working directories:
setwd("C:/Documents and Settings/ewagenmakers/Desktop/temp/BayesBook")
bugsdir = "C:/Program Files/WinBUGS14"
# Rekenbeest:
# setwd("D:/Users/ewagenmakers/BayesMPT")
# bugsdir = "D:/programs/WinBUGS14"

library(R2WinBUGS)

Generate.MPT.between = function(n.subjects=21,n.items=20,
                                c.mu,r.mu,u.mu,
                                c.alpha,r.alpha,u.alpha,
                               c1.sigma,r1.sigma,u1.sigma,
                               c2.sigma,r2.sigma,u2.sigma)
# code assumes n.subjects.1 = n.subjects.2                               
{
  c1 = array()
  r1 = array()
  u1 = array()
  C1 = matrix(nrow=n.subjects, ncol=4) # model probabilities
  R1 = matrix(nrow=n.subjects, ncol=4) # produced responses

  c2 = array()
  r2 = array()
  u2 = array()
  C2 = matrix(nrow=n.subjects, ncol=4) # model probabilities
  R2 = matrix(nrow=n.subjects, ncol=4) # produced responses

  for (i in 1:n.subjects)
  {
    c1[i] = pnorm(rnorm(1, mean=c.mu-(c.alpha/2), sd=c1.sigma))
    r1[i] = pnorm(rnorm(1, mean=r.mu-(r.alpha/2), sd=r1.sigma))
    u1[i] = pnorm(rnorm(1, mean=u.mu-(u.alpha/2), sd=u1.sigma))    

    c2[i] = pnorm(rnorm(1, mean=c.mu+(c.alpha/2), sd=c2.sigma))
    r2[i] = pnorm(rnorm(1, mean=r.mu+(r.alpha/2), sd=r2.sigma))
    u2[i] = pnorm(rnorm(1, mean=u.mu+(u.alpha/2), sd=u2.sigma))    

    C1[i,1] = c1[i] * r1[i]
    C1[i,2] = (1-c1[i]) * u1[i]^2
    C1[i,3] = (1-c1[i]) * 2 * u1[i] * (1-u1[i])
    C1[i,4] = c1[i] * (1-r1[i]) + (1-c1[i]) * (1-u1[i])^2

    C2[i,1] = c2[i] * r2[i]
    C2[i,2] = (1-c2[i]) * u2[i]^2
    C2[i,3] = (1-c2[i]) * 2 * u2[i] * (1-u2[i])
    C2[i,4] = c2[i] * (1-r2[i]) + (1-c2[i]) * (1-u2[i])^2
    
    R1[i,] = rmultinom(1, n.items, C1[i,])
    R2[i,] = rmultinom(1, n.items, C2[i,])

  }
  return(list(R1,R2,C1,C2))
}

# some typical parameters settings:
n.subjects = 210
n.items    = 200
c.mu       = qnorm(0.48)
r.mu       = qnorm(0.22)
u.mu       = qnorm(0.33)
c.alpha    = 0.3
r.alpha    = 0.3
u.alpha    = 0.3
c1.sigma   = 0.2
r1.sigma   = 0.2
u1.sigma   = 0.2
c2.sigma   = 0.2
r2.sigma   = 0.2
u2.sigma   = 0.2

response = Generate.MPT.between(n.subjects, n.items, c.mu,r.mu,u.mu,
                                c.alpha,r.alpha,u.alpha,
                               c1.sigma,r1.sigma,u1.sigma,
                               c2.sigma,r2.sigma,u2.sigma)

response.1 = response[[1]]
response.2 = response[[2]]

apply(response.1,2,mean)
apply(response.2,2,mean)

n.subjects.1 = n.subjects
n.subjects.2 = n.subjects

data  = list("response.1","response.2","n.subjects.1","n.subjects.2","n.items") # to be passed on to WinBUGS                      

inits=function()
{
    list(c.mu=rnorm(1,mean=0,sd=1), r.mu=rnorm(1,mean=0,sd=1), u.mu=rnorm(1,mean=0,sd=1),
         c.1.sigma = runif(1,0,2), r.1.sigma = runif(1,0,2), u.1.sigma = runif(1,0,2),
         c.2.sigma = runif(1,0,2), r.2.sigma = runif(1,0,2), u.2.sigma = runif(1,0,2),
         c.delta=rnorm(1,mean=0,sd=1), r.delta=rnorm(1,mean=0,sd=1), u.delta=rnorm(1,mean=0,sd=1))
}
    
parameters = c("c.delta", "r.delta", "u.delta", "r.1.sigma", "c.1.sigma", "u.1.sigma", "r.mu")

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits, parameters,
	 			model.file ="MPT_2.txt",
	 			n.chains=3, n.iter=5000, n.burnin=1500, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir, #DIC=T or else error message
	 			codaPkg=F, debug=T)
# Now the values for delta are in the "samples" object, ready for inspection.



