# clears workspace:  
rm(list=ls(all=TRUE)) 

# sets working directories:
setwd("C:/Documents and Settings/ewagenmakers/My Documents/My Dropbox/EJ/temp/BayesBook/Code/ParameterEstimation_Cognitive/NumberConcepts")
library(R2WinBUGS)
bugsdir = "C:/Program Files/WinBUGS14"

# read the data

g   = matrix(scan("g.txt", sep=","), ncol=38, nrow=82, byrow=T)
g   = g[,-c(22:38)]
q   = matrix(scan("q.txt", sep=","), ncol=21, nrow=82, byrow=T)
age = scan("age.txt")
S   = 82         # number of subjects
Q   = apply(q>0,1,sum) # number of questions for each child
N   = 15 # maximum number of toys

data  = list("g", "q", "S", "Q", "N") # to be passed on to WinBUGS
myinits =	list(
  list(sigma = rep(1,S), pitmp=rep(1/N, N)))  

# parameters to be monitored:	
parameters = c("pp","ppb","sigma")

# NB. even with only 1000 iterations, the sampling can take a long time! 
# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits=myinits, parameters,
	 			model.file ="NumberConcept_2.txt",
	 			n.chains=1, n.iter=1000, n.burnin=100, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir,
	 			codaPkg=F, debug=T)
# Now the values for the monitored parameters are in the "samples" object, 
# ready for inspection.

samples$summary


###Figure 12.7

PPB=samples$sims.array[,,"ppb"]

hist(PPB,breaks=seq(0.5,15.5,1),freq=F,xlab="Number",ylab="Probability", main="",axes=F,ylim=c(0,0.10),xlim=c(0.5,N),cex.lab=1.2)
axis(1,at=seq(1,N,1),label=c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15"))
axis(2, at=c(0,0.025,0.05,0.075,0.10))

###Figure 12.8

subjlist = c(79,77,73,70,72,69)
sc=2.2
sc2=0.1
eps=.000

mc=rep(0,S);
for (i in 1:S) {
    mc[i]=mean(samples$sims.array[,,paste("sigma[",i,"]",sep="")])
}
mc=round(mc, 2)

layout(matrix(1:6,2,byrow=T))
par(mar=c(6,4,2,.5))
for (z in subjlist) {
	plot(-1,100,xlim=c(0,15),ylim=c(0,15), main=substitute(paste("Subject ", z, " (", sigma, "=", mymc, ")", sep=" "),list(z = z, mymc = mc[z])),xlab="Question", ylab="Answer",cex.lab=1.8,axes=F,cex.main=1.8)
	axis(1, at=c(1:15), label=c("1","","3","","5","","7","","9","","11","","13","","15"))
	axis(2, at=c(1:15), label=c("1","","3","","5","","7","","9","","11","","13","","15"),las=1)
	for (i in 1:N) {
		count=hist(samples$sims.array[,,paste("pp[",z,",",i,"]",sep="")],plot=F,breaks=seq(0.5,15.5,1))
		count=count$counts
		maxc=max(count)
		count=count/maxc
	
		for (j in 1:N) {
			if (count[j]>eps) {
				points(i,j,pch=22, col="black",cex=sc*sqrt(count[j]))
			}
		}
	}
	points(q[z,1:Q[z]]+rnorm(Q[z],1)*sc2,
		 g[z,1:Q[z]]+rnorm(Q[z],1)*sc2,
		pch="x",col="black",cex=2.5)
	box("plot")
}




