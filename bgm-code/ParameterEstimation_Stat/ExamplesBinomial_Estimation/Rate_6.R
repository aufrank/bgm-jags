# clears workspace:  
rm(list=ls(all=TRUE)) 

# sets working directories:
#setwd("F:/Codes/ExamplesBinomial_Estimation")
setwd("C:/Documents and Settings/ewagenmakers/My Documents/My Dropbox/EJ/temp/BayesBook/Code/ParameterEstimation_Stat/ExamplesBinomial_Estimation")
library(R2WinBUGS)
bugsdir = "C:/Program Files/WinBUGS14"

Nmax = 500
k    = c(16,18,22,25,27)
m    = length(k)

data  = list("Nmax", "k", "m") # to be passed on to WinBUGS
myinits =	list(
  list(theta = 0.5, n = Nmax/2))

# parameters to be monitored:	
parameters = c("theta", "n")

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits=myinits, parameters,
	 			model.file ="Rate_6.txt",
	 			n.chains=1, n.iter=5000, n.burnin=0, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir,
	 			codaPkg=F, debug=T)
# Now the values for the monitored parameters are in the "samples" object, 
# ready for inspection.

theta      = samples$sims.list$theta
n          = samples$sims.list$n 

## First calculate MLE:
cc=-Inf
ind=0

for (i in 1:length(n)){

	logL=0
	for(j in 1:m){
			
		logL=logL+lgamma(n[i]+1)-lgamma(k[j]+1)-lgamma(n[i]-k[j]+1)
		logL=logL+k[j]*log(theta[i])+(n[i]-k[j])*log(1-theta[i])
		}
		if (logL>cc) {
			ind=i
			cc=logL
		}
}
# end MLE

######################Plots########################################################################
layout(matrix(c(2,0,1,3),2,2,byrow=T), width=c(2/3, 1/3), heights=c(1/3,2/3))
xhist=hist(n,plot=F)
yhist=hist(theta,plot=F)
top= max(c(xhist$counts, yhist$counts))
xrange <- c(0,Nmax)
yrange <- c(0,1)

par(mar=c(5,5,1,1))
plot(n,theta,xlim=xrange, ylim=yrange,ylab="", xlab="")
axis(1)
mtext("Number of Surveys", side=1,line=2.25, cex=1.2)
axis(2, cex=1.2)
mtext("Rate of Return", side=2 ,line=2.25, cex=1.2)
points(mean(n),mean(theta), col="red", lwd=3, pch=4) #expectation
points(n[ind],theta[ind], col="green", lwd=3, pch=10) #Maximum Likelihood

par(mar=c(0,4,1,1))
barplot(xhist$counts, axes=FALSE, ylim=c(0, top), space=0,col="lightblue")

par(mar=c(4,0,1,3))
barplot(yhist$counts, axes=FALSE, xlim=c(0, top), space=0, horiz=TRUE,col="lightblue")

