# SIMPLE model
# clears workspace:  
rm(list=ls(all=TRUE)) 

# sets working directories:
setwd("C:/Documents and Settings/ewagenmakers/My Documents/My Dropbox/EJ/temp/BayesBook/Code/ParameterEstimation_Cognitive/SIMPLE")

library(R2WinBUGS)
bugsdir = "C:/Program Files/WinBUGS14"

# read the data

k          = matrix(scan("k_M.txt", sep=","), ncol=40, nrow=6, byrow=T) 
tr         = c(1440,1280,1520,1520,1200,1280)
listlength = c(10,15,20,20,30,40)
pc         = matrix(scan("pc_M.txt", sep=","), ncol=40, nrow=6, byrow=T) 
#nsubj = c(18,16,19,19,15,16)
#labs  =
#pi    = c(2,2,2,1,1,1)
dsets = 6 

# Set Dataset to Use
T =  k*0
for (dset in 1:dsets)
{
  if (dset==1)
  {
    nwords = 10
    lag    = 2
    offset = 15
  } 
  if (dset==2)
  {
    nwords = 15
    lag    = 2
    offset = 20
  } 
  if (dset==3)
  {
    nwords = 20
    lag    = 2
    offset = 25
  } 
  if (dset==4)
  {
    nwords = 20
    lag    = 1
    offset = 10
  } 
  if (dset==5)
  {
    nwords = 30
    lag    = 1
    offset = 15
  } 
  if (dset==6)
  {
    nwords = 40
    lag    = 1
    offset = 20
  } 
 # Temporal Offset For Free Recall
    T[dset,1:nwords]=offset+seq(from=(nwords-1)*lag, by=-lag, to=0)
}

k = t(k)
T = t(T)
data  = list("k", "tr", "listlength", "T", "dsets") # to be passed on to WinBUGS

myinits =	list(
  list(c = rep(1,dsets), t = rep(0.5,dsets), s = rep(1,dsets)))  
 
## A first try, without the pcpred parameter: 
## parameters to be monitored:	
#parameters = c("c","s","t") 

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
#samples = bugs(data, inits=myinits, parameters,
#	 			model.file ="SIMPLE_1.txt",
#	 			n.chains=1, n.iter=20, n.burnin=10, n.thin=1,
#	 			DIC=TRUE, bugs.directory=bugsdir,
#	 			codaPkg=F, debug=TRUE)
## Now the values for the monitored parameters are in the "samples" object, 
## ready for inspection.
## NB. Note that DIC/debug=TRUE (in full), as "T" is already used in the code.

# Monitoring parameter "pcpred" gives an error upon return to R. 
# The following code fixes this:

# parameters to be monitored:	
parameters = c("c","s","t","pcpred")

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits=myinits, parameters,
	 			model.file ="SIMPLE_1R.txt",
	 			n.chains=1, n.iter=2000, n.burnin=1000, n.thin=1,
	 			DIC=TRUE, bugs.directory=bugsdir,
	 			codaPkg=F, debug=TRUE)
# NB. The pcpred values of -999 are obviously dummy values;
# they should not appear in any of the plots.

samples$summary

#Figure 13.2

layout(matrix(c(
	7,1,2,3,
	7,4,5,6,
	8,8,8,8
	),3,4,byrow=T), c(1,2,2,2), c(2,2,.5))
layout.show(8)
hm=20
ll=listlength

for (dset in 1:dsets) {
	plot(-1,-1,xlim=c(0,40),ylim=c(0,1),xlab="",ylab="",las=1)
	for (i in 1:ll[dset]) { 
		data = samples$sims.array[,,paste("pcpred[",i,",",dset,"]",sep="")]
		points(i+runif(hm,0,1)*.1,data[ceiling(runif(hm,0,1)*samples$n.iter)],col="grey")
	}
	points(1:ll[dset],pc[dset,1:ll[dset]],xlim=c(0,40),ylim=c(0,1))
	lines(1:ll[dset],pc[dset,1:ll[dset]])

	box("plot")
}
par(mar=c(rep(0,4)))
plot.new()
text(.45,.5,"Probability Correct",cex=2.5,srt=90)
plot.new()
text(.5,.5,"Serial Position",cex=2.5,mar=c(rep(0,4)))



