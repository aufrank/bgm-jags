# MPT model, within-subject test
# clears workspace:  
rm(list=ls(all=TRUE)) 

# sets working directories:
setwd("C:/Documents and Settings/ewagenmakers/Desktop/temp/BayesBook")
bugsdir = "C:/Program Files/WinBUGS14"
# Rekenbeest:
# setwd("D:\\Users\\ewagenmakers\\BayesMPT")
# bugsdir = "D:\\programs\\WinBUGS14"

library(R2WinBUGS)

### MPT data, brain damage group
trial1.b = list( subjs = 21, items=20, response = structure(.Data = c(0,0,3,17,0,0,4,16,0,1,3,16,0,0,5,15,0,0,2,18,1,1,7,11,0,2,11,7,0,0,6,14,2,0,7,11,2,1,3,14,1,0,1,18,3,0,7,10,2,0,3,15,2,1,2,15,1,1,8,10,5,1,5,9,0,0,4,16,1,0,1,18,0,0,2,18,0,0,4,16,0,1,3,16),.Dim = c(4, 21)))
trial2.b = list( subjs = 21, items=20, response = structure(.Data = c(0,1,5,14,1,0,4,15,1,0,1,18,1,0,5,14,0,0,2,18,4,2,10,4,1,0,8,11,0,2,6,12,2,4,4,10,1,2,5,12,1,0,5,14,4,2,7,7,1,0,7,12,4,1,5,10,2,1,10,7,9,1,4,6,0,0,3,17,1,0,0,19,0,1,3,16,1,0,6,13,0,1,2,17),.Dim = c(4, 21)))
trial6.b = list( subjs = 21, items=20, response = structure(.Data = c(0,0,11,9,2,1,5,12,3,0,1,16,4,0,4,12,0,0,0,20,2,3,12,3,3,0,4,13,0,2,6,12,1,3,10,6,2,4,3,11,2,0,3,15,7,7,3,3,2,1,6,11,14,2,2,2,1,2,11,6,13,3,2,2,0,0,0,20,0,0,4,16,0,0,6,14,5,0,6,9,4,1,1,14),.Dim = c(4, 21)))

# MPT data, control group
trial1.c = list( subjs = 21, items=20, response = structure(.Data = c(2,4,4,10,2,1,3,14,2,2,5,11,6,0,4,10,1,0,4,15,1,0,2,17,1,2,4,13,4,1,6,9,5,1,4,10,1,0,9,10,5,0,3,12,0,1,6,13,1,5,7,7,1,1,4,14,2,2,3,13,2,1,5,12,2,0,6,12,1,0,5,14,2,1,8,9,3,0,2,15,1,2,3,14),.Dim = c(4, 21)))
trial6.c = list( subjs = 21, items=20, response = structure(.Data = c(14,3,1,2,12,3,1,4,18,0,1,1,15,3,0,2,7,1,10,2,3,6,11,0,8,4,3,5,17,1,1,1,13,4,3,0,11,6,1,2,16,1,2,1,10,1,3,6,7,13,0,0,8,4,3,5,16,1,1,2,5,4,7,4,15,0,5,0,6,3,6,5,17,2,0,1,17,1,0,2,8,3,6,3),.Dim = c(4, 21)))

response.1 = t(trial1.c$response)
response.2 = t(trial6.c$response)

#response.1 = response.1[-c(14,16),] #remove two outliers in the brain damage group, 
#response.2 = response.2[-c(14,16),] #this does not help much (of course you need to adjust n.subjects when you do this)

n.subjects = 21
n.items    = 20

data  = list("response.1","response.2","n.subjects","n.items") # to be passed on to WinBUGS                      

inits=function()
{
    list(c.1.mu=rnorm(1,mean=0,sd=1), r.1.mu=rnorm(1,mean=0,sd=1), u.1.mu=rnorm(1,mean=0,sd=1),
         c.1.sigma = runif(1,0,5), r.1.sigma = runif(1,0,5), u.1.sigma = runif(1,0,5),
         c.delta=rnorm(1,mean=0,sd=1), r.delta=rnorm(1,mean=0,sd=1), u.delta=rnorm(1,mean=0,sd=1),             
         c.diff.sigma = runif(1,0,5), r.diff.sigma = runif(1,0,5), u.diff.sigma = runif(1,0,5),
         c.1.probit = rnorm(n.subjects,mean=0,sd=1),r.1.probit = rnorm(n.subjects,mean=0,sd=1),
         u.1.probit = rnorm(n.subjects,mean=0,sd=1))                   
}
  
parameters = c("r.diff.mu", "r.delta", "r.diff.sigma", "u.delta", "u.diff.sigma", "c.delta", "c.diff.sigma")
#parameters = c("c.delta", "r.delta", "u.delta", "c.diff.sigma", "r.diff.sigma", "u.diff.sigma")
#parameters = c("c.delta", "r.delta", "u.delta")


# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits, parameters,
	 			model.file ="MPT_1.txt",
	 			n.chains=3, n.iter=5000, n.burnin=1500, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir, #DIC=T or else error message
	 			codaPkg=F, debug=T)
# Now the values for delta are in the "samples" object, ready for inspection.

# Dora: je ziet de problemen; 
# 1. Voor de control group (test list 1 versus 6): Voor de delta voor de r parameter lijkt netjes, 
# maar de mean en sd fluctueren zo wild, en correleren zo hoog, dat ze niet geindentificeerd lijken. Raar he? 
# Als je data simuleert komt dit niet voor. Misschien ligt het aan outliers oid.
# 2. Voor de brain damage group (test list 1 versus 6): Niet alleen vertoont de r parameter dezelfde kuren,
# maar de c parameter ziet er ook niet goed uit -- de c.diff.sigma lijkt af en toe vast te plakken rond de nul.
# Misschien dat parameter expansion hier ook helpt?   

# We kunnen die prior op de standaard deviatie natuurlijk een stuk strakker zetten, of moeten we 
# naar een prior toe met meer massa voor kleine standaard deviaties, zoals gamma op de precisie.
# Het is natuurlijk wel zaak om dit rare gedrag te vergelijken met wat je krijgt als je data simuleert.
# Zie hiervoor de andere R file (want daar zijn ook problemen mee :-))









