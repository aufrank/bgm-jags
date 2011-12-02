#### R2Winbugs Code for a Bayesian hierarchical test for the MPT model.
# This code tests parameter recovery

rm(list=ls(all=TRUE)) # clears workspace

# sets working directories:
setwd("C:/Documents and Settings/ewagenmakers/Desktop/temp/BayesBook")
bugsdir = "C:/Program Files/WinBUGS14"
# Rekenbeest:
# setwd("D:\\Users\\ewagenmakers\\BayesMPT")
# bugsdir = "D:\\programs\\WinBUGS14"

library(R2WinBUGS)

Generate.MPT.within = function(n.subjects=21,n.items=20,c.mu,r.mu,u.mu,c.mu.diff,r.mu.diff,u.mu.diff,
                               c.sigma,r.sigma,u.sigma,c.sigma.diff,r.sigma.diff,u.sigma.diff)
{
      
  c = array()
  r = array()
  u = array()
  C = matrix(nrow=n.subjects, ncol=4) # model probabilities
  R = matrix(nrow=n.subjects, ncol=4) # produced responses
  diff.c = array()
  diff.r = array()
  diff.u = array()
  c2 = array()
  r2 = array()
  u2 = array()
  C2 = matrix(nrow=n.subjects, ncol=4) # model probabilities
  R2 = matrix(nrow=n.subjects, ncol=4) # produced responses
  
  for (i in 1:n.subjects)
  {
    #still on the probit-scale:
    c[i] = rnorm(1, mean=c.mu, sd=c.sigma)
    r[i] = rnorm(1, mean=r.mu, sd=r.sigma)
    u[i] = rnorm(1, mean=u.mu, sd=u.sigma)    

    diff.c[i] = rnorm(1, mean=c.mu.diff, sd=c.sigma.diff)
    diff.r[i] = rnorm(1, mean=r.mu.diff, sd=r.sigma.diff)
    diff.u[i] = rnorm(1, mean=u.mu.diff, sd=u.sigma.diff)
    
    #now to probability scale
    c[i]  = pnorm(c[i])
    r[i]  = pnorm(r[i])
    u[i]  = pnorm(u[i])
    c2[i] = pnorm(c[i]+diff.c[i])
    r2[i] = pnorm(r[i]+diff.r[i])
    u2[i] = pnorm(u[i]+diff.u[i])

    #model predictions:
    C[i,1] = c[i] * r[i]
    C[i,2] = (1-c[i]) * u[i]^2
    C[i,3] = (1-c[i]) * 2 * u[i] * (1-u[i])
    C[i,4] = c[i] * (1-r[i]) + (1-c[i]) * (1-u[i])^2
    R[i,]  = rmultinom(1, n.items, C[i,])
    
    C2[i,1] = c2[i] * r2[i]
    C2[i,2] = (1-c2[i]) * u2[i]^2
    C2[i,3] = (1-c2[i]) * 2 * u2[i] * (1-u2[i])
    C2[i,4] = c2[i] * (1-r2[i]) + (1-c2[i]) * (1-u2[i])^2
    R2[i,]  = rmultinom(1, n.items, C2[i,])
  }
  return(list(R,R2,C,C2))
}

# some typical parameters settings:
n.subjects   = 210 # if you want this to run faster just decrease the number of 
                   # subjects, items, and iterations. 
n.items      = 400
c.mu         = qnorm(0.48)
r.mu         = qnorm(0.22)
u.mu         = qnorm(0.33)
c.mu.diff    = 0.4
r.mu.diff    = 0.3
u.mu.diff    = 0.2
c.sigma      = 0.2
r.sigma      = 0.2
u.sigma      = 0.2
c.sigma.diff = 0.2
r.sigma.diff = 0.2
u.sigma.diff = 0.2

response = Generate.MPT.within(n.subjects, n.items, c.mu,r.mu,u.mu,c.mu.diff,r.mu.diff,u.mu.diff,
                               c.sigma,r.sigma,u.sigma,c.sigma.diff,r.sigma.diff,u.sigma.diff)

response.1 = response[[1]]
response.2 = response[[2]]

apply(response.1,2,mean)
apply(response.2,2,mean)

data  = list("response.1","response.2","n.subjects","n.items") # to be passed on to WinBUGS                      

#### WinBUGS stuff:
inits=function()
  {
    list(c.1.mu=rnorm(1,mean=0,sd=1), r.1.mu=rnorm(1,mean=0,sd=1), u.1.mu=rnorm(1,mean=0,sd=1),
         c.1.sigma = runif(1,0,5), r.1.sigma = runif(1,0,5), u.1.sigma = runif(1,0,5),
         c.delta=rnorm(1,mean=0,sd=1), r.delta=rnorm(1,mean=0,sd=1), u.delta=rnorm(1,mean=0,sd=1),             
         c.diff.sigma = runif(1,0,5), r.diff.sigma = runif(1,0,5), u.diff.sigma = runif(1,0,5),
         c.1.probit = rnorm(n.subjects,mean=0,sd=1),r.1.probit = rnorm(n.subjects,mean=0,sd=1),u.1.probit = rnorm(n.subjects,mean=0,sd=1))                   
  }
  
parameters = c("r.diff.mu", "r.delta", "r.diff.sigma")
#parameters = c("c.delta", "r.delta", "u.delta", "c.diff.sigma", "r.diff.sigma", "u.diff.sigma", "c.1.mu", "r.1.mu", "u.1.mu")
#parameters = c("c.delta", "r.delta", "u.delta")

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits, parameters,
	 			model.file ="MPT_1.txt",
	 			n.chains=3, n.iter=5000, n.burnin=1500, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir, #DIC=T or else error message
	 			codaPkg=F, debug=T)
# Now the values for delta are in the "samples" object, ready for inspection.

# Dora, ik genereer dus data volgens het model, en kijk dan of ik het goed terug kan schatten. Dat gaat
# goed voor alle parameters, maar niet voor c.mu.diff, r.mu.diff en u.mu.diff. 
# Ik doe vast iets verkeerd, maar ik zie het niet. Helemaal fout kan het ook weer niet zijn, omdat de andere
# parameters dus wel goed teruggeschat worden. Misschien zie jij waar het niet goed gaat.