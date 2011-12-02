# clears workspace:  
rm(list=ls(all=TRUE)) 

# sets working directories:
setwd("C:/Documents and Settings/ewagenmakers/My Documents/My Dropbox/EJ/temp/BayesBook/Code/ParameterEstimation_Cognitive/TakeTheBestModel")
library(R2WinBUGS)
bugsdir = "C:/Program Files/WinBUGS14"

# read the data

dataset = 1 # 1 = citworld, 2 = prfworld

if (dataset == 1) #citworld
{
# German cities and their populations (83 objects and 9 cues)
# In order, the cues correspond to:
# soccer team
# state capital
# former east germany
# industrial belt
# licence plate
# intercity trainline
# exposition site
# national capital
# university 

#cue validities:
  v = c(0.8700,0.7700,0.5100,0.5600,0.7500,0.7800,0.9100,1.0000,0.7100)

  pop = scan("citworld_pop.txt") 
  lab = scan("citworld_labs.txt", what="character")
  c   = matrix(scan("citworld_cues.txt"), nrow = length(pop), ncol=length(v), byrow=T) #cues
}

if (dataset == 2) #prfworld
{
# Professors and their salaries (51 objects and 5 cues)

#cue validities:
  v = c(0.9798,0.8765,0.8773,0.3224,0.4512)

  pop = scan("prfworld_pop.txt")
  lab = scan("prfworld_labs.txt", what="character")
  c   = matrix(scan("prfworld_cues.txt"), nrow = length(pop), ncol=length(v), byrow=T) #cues
}

# Number of Cities and Cues
n  = length(pop)
nc = length(v)

# Order cue validities (worst to best)
vo = rank(v) #worst unit has value 1

# Correct decisions for all possible questions
p  = data.frame()
k  = array()
cc = 1
for (i in 1:(n-1))
{
  for (j in (i+1):n)
  {
  # Record two object in cc-th question
    p[cc,1] = i
    p[cc,2] = j
  # Record correct answer (1=first object; 0=second)
    k[cc] = 1*(pop[i] > pop[j])
    cc = cc+1
  }
}
p = as.matrix(p)
# Total number of questions
nq = cc-1

data  = list("c", "p", "k", "nc", "vo", "nq") # to be passed on to WinBUGS
myinits =	list(
  list(gamma = 0.5))  

# parameters to be monitored:	
parameters = c("gamma", "sc")

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits=myinits, parameters,
	 			model.file ="TakeTheBest_1.txt",
	 			n.chains=1, n.iter=1000, n.burnin=0, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir,
	 			codaPkg=F, debug=T)
# Now the values for the monitored parameters are in the "samples" object, 
# ready for inspection.

samples$summary









