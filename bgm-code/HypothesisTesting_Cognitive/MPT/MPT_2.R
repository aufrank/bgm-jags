# MPT model, between-subject test
# clears workspace:  
rm(list=ls(all=TRUE)) 

# sets working directories:
setwd("C:/Documents and Settings/ewagenmakers/Desktop/temp/BayesBook")
bugsdir = "C:/Program Files/WinBUGS14"
# Rekenbeest:
# setwd("D:\\Users\\ewagenmakers\\BayesMPT")
# bugsdir = "D:\\programs\\WinBUGS14"

library(R2WinBUGS)

#### data:
n.subjects.1 = 21
n.subjects.2 = 21 # set to 19 when outliers are removed
n.items      = 20

# MPT data, brain damage group
trial1.b = list( subjs = 21, items=20, response = structure(.Data = c(0,0,3,17,0,0,4,16,0,1,3,16,0,0,5,15,0,0,2,18,1,1,7,11,0,2,11,7,0,0,6,14,2,0,7,11,2,1,3,14,1,0,1,18,3,0,7,10,2,0,3,15,2,1,2,15,1,1,8,10,5,1,5,9,0,0,4,16,1,0,1,18,0,0,2,18,0,0,4,16,0,1,3,16),.Dim = c(4, 21)))
trial6.b = list( subjs = 21, items=20, response = structure(.Data = c(0,0,11,9,2,1,5,12,3,0,1,16,4,0,4,12,0,0,0,20,2,3,12,3,3,0,4,13,0,2,6,12,1,3,10,6,2,4,3,11,2,0,3,15,7,7,3,3,2,1,6,11,14,2,2,2,1,2,11,6,13,3,2,2,0,0,0,20,0,0,4,16,0,0,6,14,5,0,6,9,4,1,1,14),.Dim = c(4, 21)))
# MPT data, control group
trial1.c = list( subjs = 21, items=20, response = structure(.Data = c(2,4,4,10,2,1,3,14,2,2,5,11,6,0,4,10,1,0,4,15,1,0,2,17,1,2,4,13,4,1,6,9,5,1,4,10,1,0,9,10,5,0,3,12,0,1,6,13,1,5,7,7,1,1,4,14,2,2,3,13,2,1,5,12,2,0,6,12,1,0,5,14,2,1,8,9,3,0,2,15,1,2,3,14),.Dim = c(4, 21)))
trial6.c = list( subjs = 21, items=20, response = structure(.Data = c(14,3,1,2,12,3,1,4,18,0,1,1,15,3,0,2,7,1,10,2,3,6,11,0,8,4,3,5,17,1,1,1,13,4,3,0,11,6,1,2,16,1,2,1,10,1,3,6,7,13,0,0,8,4,3,5,16,1,1,2,5,4,7,4,15,0,5,0,6,3,6,5,17,2,0,1,17,1,0,2,8,3,6,3),.Dim = c(4, 21)))

response.1 = t(trial6.c$response)
response.2 = t(trial6.b$response)

## remove outliers?
#n.subjects.2 = 19 # set to 19 when outliers are removed
#response.2   = response.2[-c(14,16),]

data  = list("response.1","response.2","n.subjects.1","n.subjects.2","n.items") # to be passed on to WinBUGS                      
####

#### WinBUGS stuff:
inits=function()
  {
    list(c.mu=rnorm(1,mean=0,sd=1), r.mu=rnorm(1,mean=0,sd=1), u.mu=rnorm(1,mean=0,sd=1),
         c.2.sigma = runif(1,0,2), r.2.sigma = runif(1,0,2), u.2.sigma = runif(1,0,2),
         c.1.sigma = runif(1,0,2), r.1.sigma = runif(1,0,2), u.1.sigma = runif(1,0,2),
         c.delta=rnorm(1,mean=0,sd=1), r.delta=rnorm(1,mean=0,sd=1), u.delta=rnorm(1,mean=0,sd=1),             
         c.2.probit = rnorm(n.subjects.2,mean=0,sd=1),c.1.probit = rnorm(n.subjects.1,mean=0,sd=1),
         r.2.probit = rnorm(n.subjects.2,mean=0,sd=1),r.1.probit = rnorm(n.subjects.1,mean=0,sd=1),
         u.2.probit = rnorm(n.subjects.2,mean=0,sd=1),u.1.probit = rnorm(n.subjects.1,mean=0,sd=1))                   
  }
  
parameters = c("c.delta", "r.delta", "u.delta", "r.mu", "r.2.sigma", "r.1.sigma") 

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits, parameters,
	 			model.file ="MPT_2.txt",
	 			n.chains=3, n.iter=5000, n.burnin=1500, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir, #DIC=T or else error message
	 			codaPkg=F, debug=T)
# Now the values for delta are in the "samples" object, ready for inspection.

# Hi Dora, je ziet dat er ook hier problemen zijn met het zwalken van de sigma's. Maar nu
# is het ook duidelijk dat de sigma's soms blijven hangen rond de nul.
# Dit vraagt natuurlijk weer om een parameter recovery study (lukt het 
# ueberhaupt wel, zelfs als het data-genererende proces juist is). Zie andere R file.