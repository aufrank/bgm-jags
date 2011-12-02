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
Q   = apply(q>0,1,sum) #number of questions for each child
S   = 82         # number of subjects
Z   = 6  # number of latent classes
N   = 15 # maximum number of toys

data  = list("g", "q", "S", "Q", "Z", "N") # to be passed on to WinBUGS
myinits =	list(
  list(v = 10, z = floor(runif(S)*Z)+1, pitmp=rep(1/N, N)))  

# parameters to be monitored:	
parameters = c("pp","ppz","ppb","v","z")

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits=myinits, parameters,
	 			model.file ="NumberConcept_1.txt",
	 			n.chains=1, n.iter=2000, n.burnin=1000, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir,
	 			codaPkg=F, debug=T)
# Now the values for the monitored parameters are in the "samples" object, 
# ready for inspection.

samples$summary

###Figure 12.2

PPB=samples$sims.array[,,"ppb"]

hist(PPB,breaks=seq(0.5,15.5,1),freq=F,xlab="Number",ylab="Probability", main="",axes=F,ylim=c(0,0.20),xlim=c(0.5,N),cex.lab=1.2)
axis(1,at=seq(1,N,1),label=c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15"))
axis(2, at=c(0,0.05,0.1,0.15,0.20))


###Figure 12.3
ld = length(samples$summary[,1])
m=as.vector(samples$summary[c((ld-S):(ld-1)),1])
m_in=sort.int(m,index.return=T)


layout(matrix(c(
			84,1:14,
			84,15:28,
			84,29:42,
			84,43:56,
			84,57:70,
			84,71:82,0,0,
			84,rep(83,14)),7,15,byrow=T))

for (i in 1:S) {
	subj=m_in$ix[i];
	par(mar=c(.2,.2,1.2,.2))
	hist(samples$sims.array[,,paste("z[",subj,"]",sep="")],freq=F,breaks=seq(0.5,6.5,1),right=F,main=subj,axes=F,xlab="",ylab="",col="black",xlim=c(0,7),ylim=c(0,1))
	axis(1, at=c(1,2,3,4,5,6),label=c("","","","","",""),tck = 0.1)
      axis(3, at=c(1,2,3,4,5,6),label=c("","","","","",""),tck = 0.1)

	box("plot")
}
plot.new()
text(.5,.9,"Knower Level",cex=2.5)
plot.new()
text(.5,.6,"Posterior Mass",cex=2.5,srt=90)


###Figure 12.4

subjlist = c(79,77,73,70,72,69)
mains = c("0","1","2","3","4","HN")
sc=2.2
sc2=0.1
eps=.000

layout(matrix(1:6,2,byrow=T))
par(mar=c(6,4,2,.5))
for (z in subjlist) {
	plot(-1,100,xlim=c(0,15),ylim=c(0,15), main=paste("Subject ", z," (", mains[which(subjlist==z)]," Knower)",sep=""),xlab="Question", ylab="Answer",cex.lab=1.8,axes=F,cex.main=1.4)
	axis(1, at=c(1:15), label=c("1","","3","","5","","7","","9","","11","","13","","15"))
	axis(2, at=c(1:15), label=c("1","","3","","5","","7","","9","","11","","13","","15"),las=1)
	for (i in 1:N) {
		count=hist(samples$sims.array[,,paste("pp[",z,",",i,"]",sep="")],plot=F,breaks=seq(0.5,15.5,1))
		count=count$counts
		mc=max(count)
		count=count/mc
	
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

###Figure 12.5

modalvalue <- function(x, na.rm=FALSE)
{
    x = unlist(x);
    if(na.rm) x = x[!is.na(x)]
    u = unique(x);
    n = length(u);
    frequencies = rep(0, n);
    for(i in 1:n)
    {
        if(is.na(u[i]))
        {
            frequencies[i] = sum(is.na(x))
        } else
        {
            frequencies[i] = sum(x==u[i], na.rm=TRUE)
        }
    }
    u[which.max(frequencies)]
}

mv=rep(0,S);
for (i in 1:S) {
    mv[i]=modalvalue(samples$sims.array[,,paste("z[",i,"]",sep="")])
}

sc=2.2
sc2=0.1
eps=.000
mains = c("0","1","2","3","4","HN")

layout(matrix(1:6,2,byrow=T))
par(mar=c(6,4,2,.5))
for (z in 1:Z) {
	plot(-1,100,xlim=c(0,15),ylim=c(0,15), main=(paste(mains[z],"Knower")),xlab=("Question"), ylab=("Answer"),cex.lab=1.8,axes=F,cex.main=1.4)
	axis(1, at=c(1:15), label=c("1","","3","","5","","7","","9","","11","","13","","15"))
	axis(2, at=c(1:15), label=c("1","","3","","5","","7","","9","","11","","13","","15"),las=1)
	for (i in 1:N) {
		count=hist(samples$sims.array[,,paste("ppz[",z,",",i,"]",sep="")],plot=F,breaks=seq(0.5,15.5,1))
		count=count$counts
		mc=max(count)
		count=count/mc
	
		for (j in 1:N) {
			if (count[j]>eps) {
				points(i,j,pch=22, col="black",cex=sc*sqrt(count[j]))
			}
		}
	}
	match=which(mv==z)

	for (i in match) {
		points(q[i,1:Q[i]]+rnorm(Q[i],1)*sc2,
			 g[i,1:Q[i]]+rnorm(Q[i],1)*sc2,
			pch="x",col="black",cex=2.5)
	}
	box("plot")
}
