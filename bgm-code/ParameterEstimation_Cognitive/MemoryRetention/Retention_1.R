# clears workspace:  
rm(list=ls(all=TRUE)) 

# sets working directories:
setwd("C:/Documents and Settings/ewagenmakers/My Documents/My Dropbox/EJ/temp/BayesBook/Code/ParameterEstimation_Cognitive/MemoryRetention")
library(R2WinBUGS)
bugsdir = "C:/Program Files/WinBUGS14"

t     = c(1, 2, 4, 7, 12, 21, 35, 59, 99, 200)
nt    = length(t)
slist = 1:4
ns    = length(slist)

k = matrix(c(18, 18, 16, 13, 9, 6, 4, 4, 4, NA,
             17, 13,  9,  6, 4, 4, 4, 4, 4, NA,
             14, 10,  6,  4, 4, 4, 4, 4, 4, NA,
             NA, NA, NA, NA,NA,NA,NA,NA,NA, NA), nrow=ns, ncol=nt, byrow=T)
k

n = matrix(18,rep(ns*nt), nrow=ns, ncol=nt)

data  = list("k", "n", "t", "ns", "nt") # to be passed on to WinBUGS

myinits =	list(
  list(alpha = 0.5, beta = 0.5))

# parameters to be monitored:	
parameters = c("alpha", "beta", "predk")

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits=myinits, parameters,
	 			model.file ="Retention_1.txt",
	 			n.chains=1, n.iter=10000, n.burnin=0, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir,
	 			codaPkg=F, debug=T)
# Now the values for the monitored parameters are in the "samples" object, 
# ready for inspection.



##############Fancy plots################################################
##Figure 8.2

alpha=samples$sims.array[,,1]
beta=samples$sims.array[,,2]
d.beta=density(beta)

layout(matrix(c(1,2,3,0),2,2,byrow=T), width=c(2/3, 1/3), heights=c(2/3,1/3))
#layout.show()

par(mar=c(2,2,1,0))
plot(alpha,beta, xlab="", ylab="", xlim=c(0,1),ylim=c(0,1),axes=F)
box(lty=1)

par(mar=c(2,2,1,4))
plot(d.beta$y, d.beta$x, ylim=range(c(0,1)), xlim=rev(range(d.beta$y)), type='l', axes=F, xlab="", ylab="")
axis(4, at=c(0,1))
mtext(expression(beta), side=4,line=1, cex=1.3)
box(lty=1)

par(mar=c(6,2,0,0))
plot(density(alpha),zero.line=F, main="", ylab="", xlab="", cex.lab=1.3,xlim=c(0,1), axes=F)
axis(1,at=c(0,1))
mtext(expression(alpha), side=1.2,line=1, cex=1.3)
box(lty=1)

##Figure 8.3

layout(matrix(c(1:4),2,2,byrow=T))
#layout.show()
sc=3.5
jj = numeric()
xx = numeric()

for (i in 1:ns) {
	plot(-1,100,xlim=c(0,10),ylim=c(0,18), main=(paste("Subject", i)),xlab=("Time Lags"), ylab=("Retention Count"),cex.lab=1.3, axes=F)
	axis(1, at=c(1,2,3,4,5,6,7,8,9,10), lab=c("1","2","3","7","12","21","35","59","99","200"),cex.axis=0.7)
	axis(2, at=c(0,18),lab=c("0","18"),cex.axis=0.7)
	box(lty=1)
	for (j in 1:nt) {
		j1 = i*10-10+j+2
		count=hist(samples$sims.array[,,j1],c(0:n[i,j]),plot=F)
		count=count$counts
		count=count/sum(count)
		for (x in 1:n[i,j]){
			if (count[x]>0){
				points(j,x,pch=22, col="black",cex=sc*sqrt(count[x]))
				if (!is.na(k[i,j]) && k[i,j]==x){
					points(j,x,pch=22,bg="black",cex=sc*sqrt(count[x]))
					jj = c(jj,j)
					xx = c(xx,x)
				}
			}
		}
	}
	coords = list(x=jj, y=xx)
	lines(coords,lwd=2)
	jj = numeric()
	xx = numeric()
}
