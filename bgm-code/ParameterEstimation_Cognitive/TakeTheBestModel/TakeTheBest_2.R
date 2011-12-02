# Take the Best with unknown search order
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

  pop = scan("citworld_pop.txt") 
  lab = scan("citworld_labs.txt", what="character")
  c   = matrix(scan("citworld_cues.txt"), nrow = length(pop), ncol=9, byrow=T) #cues
}

if (dataset == 2) #prfworld
{
# Professors and their salaries (51 objects and 5 cues)

  pop = scan("prfworld_pop.txt")
  lab = scan("prfworld_labs.txt", what="character")
  c   = matrix(scan("prfworld_cues.txt"), nrow = length(pop), ncol=5, byrow=T) #cues
}

# Number of Cities and Cues
n  = length(pop)
nc = ncol(c)

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

# Setup Base
M    = nc^2
base = matrix(rep(0,nc*M), nrow=nc, ncol=M)

for (i in 1:nc)
{
	base[i,seq(from=i, by=nc, to=M)] = 1/nc
}

data  = list("c", "p", "k", "nc", "nq", "M", "base") # to be passed on to WinBUGS
myinits =	list(
  list(gamma = 0.5, cv = c(1:nc)))  

# parameters to be monitored:	
parameters = c("gamma", "cvo", "sc")

# NB with 2000 iterations, this takes a long time to run:
# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits=myinits, parameters,
	 			model.file ="TakeTheBest_2.txt",
	 			n.chains=1, n.iter=1000, n.burnin=100, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir,
	 			codaPkg=F, debug=T)
# Now the values for the monitored parameters are in the "samples" object, 
# ready for inspection.

samples$summary

# Beginning analysis of the search order posterior
t  = samples$sims.list$cvo
sc = samples$sims.list$sc

# What search orders are there in the posterior?
ut  = unique(t, margin=2)
nut = nrow(ut)


# What's the estimated mass of each, and how accurate is it?
pc = array()
matches = array()
nt = nrow(t)
for (i in 1:nut) {
    counter=0 
    rows = numeric()
    #loop through rows of t
    for (j in 1:nt)
	if (identical(ut[i,],t[j,])) {	
	  counter=counter+1 			
	  rows = c(rows,j)
	}
    matches[i]=counter				
    pc[i]    = sc[rows[1]]
}

# Sort in decreasing order
newmatches = sort(matches, T, index.return=T)
matches = newmatches$x
ind = newmatches$ix
ut=ut[ind,]
pc=pc[ind]

# Display results
cat(paste("There are", nut, "search orders sampled in the posterior.\n"))
for (i in 1:nut) {
   cat(paste("Order=(", paste(ut[i,],collapse=" "), "), Estimated Mass=", round(matches[i]/sum(matches),4), ", Accuracy=", pc[i], sep="","\n"))
}







