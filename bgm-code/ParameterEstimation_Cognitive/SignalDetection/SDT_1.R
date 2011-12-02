# clears workspace:  
rm(list=ls(all=TRUE)) 

# sets working directories:
setwd("C:/Documents and Settings/ewagenmakers/My Documents/My Dropbox/EJ/temp/BayesBook/Code/ParameterEstimation_Cognitive/SignalDetection")
library(R2WinBUGS)
bugsdir = "C:/Program Files/WinBUGS14"

dataset = 1

if (dataset == 1) #Demo
{
  n = 3 #number of cases
  data = matrix(c(70, 50, 30, 50, 7, 5, 3, 5, 10, 0, 0, 10), nrow=n, ncol=4, byrow=T)
}

if (dataset == 2) #Lehrner et al. (1995) data 
{
  n = 3 #number of cases
  data = matrix(c(148, 29, 32, 151, 150, 40, 30, 140, 150, 51, 40, 139), nrow=n, ncol=4, byrow=T)
}

HR = data[,1]
FA = data[,2]
MI = data[,3]
CR = data[,4]

data  = list("HR", "FA", "MI", "CR", "n") # to be passed on to WinBUGS
myinits =	list(
  list(d = rep(0,n), c = rep(0,n)))  

# parameters to be monitored:	
parameters = c("d", "c", "h", "f")

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits=myinits, parameters,
	 			model.file ="SDT_1.txt",
	 			n.chains=1, n.iter=10000, n.burnin=0, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir,
	 			codaPkg=F, debug=T)
# Now the values for the monitored parameters are in the "samples" object, 
# ready for inspection.

d1 = samples$sims.list$d[,1]
d2 = samples$sims.list$d[,2]
d3 = samples$sims.list$d[,3]

c1 = samples$sims.list$c[,1]
c2 = samples$sims.list$c[,2]
c3 = samples$sims.list$c[,3]

h1 = samples$sims.list$h[,1]
h2 = samples$sims.list$h[,2]
h3 = samples$sims.list$h[,3]

f1 = samples$sims.list$f[,1]
f2 = samples$sims.list$f[,2]
f3 = samples$sims.list$f[,3]

#make the four panel plot:
layout(matrix(c(1,2,3,4), 2, 2, byrow = TRUE))
#layout.show(4)
#some plotting options to make things look better:
par(cex.main = 1.5, mar = c(5, 6, 4, 5) + 0.1, mgp = c(3.5, 1, 0), cex.lab = 1.5,
    font.lab = 2, cex.axis = 1.3, bty = "n", las=1)
# Discriminability panel:    
plot(density(d1), lwd=2, col="red", main="", ylab="", xlab="", 
     xlim=c(-2,6), axes=F)
axis(1)
axis(2, labels=F, at=c(0,24))

lines(density(d2), lwd=2, col="green", lty=2)
lines(density(d3), lwd=2, col="blue", lty=2)

mtext("Probability Density", side=2, line = 2, cex=1.5, las=0)
mtext("Discriminability", side=1, line = 2.5, cex=1.5)

# Bias panel:    
plot(density(c1), lwd=2, col="red", main="", ylab="", xlab="", 
     xlim=c(-2,2), axes=F)
axis(1)
axis(2, labels=F, at=c(0,24))

lines(density(c2), lwd=2, col="green", lty=2)
lines(density(c3), lwd=2, col="blue", lty=2)

mtext("Probability Density", side=2, line = 2, cex=1.5, las=0)
mtext("Bias", side=1, line = 2.5, cex=1.5)

# Hit Rate panel:    
plot(density(h1), lwd=2, col="red", main="", ylab="", xlab="", 
     xlim=c(0,1), axes=F)
axis(1)
axis(2, labels=F, at=c(0,24))

lines(density(h2), lwd=2, col="green", lty=2)
lines(density(h3), lwd=2, col="blue", lty=2)

if (dataset == 1)
{
  lines(c(0, 0.1),c(7,7), lwd=2, lty=1, col="red")
  lines(c(0, 0.1),c(6,6), lwd=2, lty=2, col="green")
  lines(c(0, 0.1),c(5,5), lwd=2, lty=3, col="blue")
  
  text(0.15, 7, labels="first", offset=0, cex = 1.3, pos=4)
  text(0.15, 6, labels="second", offset=0, cex = 1.3, pos=4)
  text(0.15, 5, labels="third", offset=0, cex = 1.3,pos=4)
}

if (dataset == 2)
{
  lines(c(0, 0.1),c(7,7), lwd=2, lty=1, col="red")
  lines(c(0, 0.1),c(6,6), lwd=2, lty=2, col="green")
  lines(c(0, 0.1),c(5,5), lwd=2, lty=3, col="blue")
  
  text(0.15, 7, labels="Control", offset=0, cex = 1.3, pos=4)
  text(0.15, 6, labels="Group I", offset=0, cex = 1.3, pos=4)
  text(0.15, 5, labels="Group II", offset=0, cex = 1.3,pos=4)
}

mtext("Probability Density", side=2, line = 2, cex=1.5, las=0)
mtext("Hit Rate", side=1, line = 2.5, cex=1.5)

# False-Alarm Rate panel:    
plot(density(f1), lwd=2, col="red", main="", ylab="", xlab="", 
     xlim=c(0,1), axes=F)
axis(1)
axis(2, labels=F, at=c(0,24))

lines(density(f2), lwd=2, col="green", lty=2)
lines(density(f3), lwd=2, col="blue", lty=2)

mtext("Probability Density", side=2, line = 2, cex=1.5, las=0)
mtext("False-Alarm Rate", side=1, line = 2.5, cex=1.5)



