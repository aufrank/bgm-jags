# clears workspace:  
rm(list=ls(all=TRUE)) 

# sets working directories:
setwd("C:/Documents and Settings/ewagenmakers/My Documents/My Dropbox/EJ/temp/BayesBook/Code/ParameterEstimation_Cognitive/MultidimensionalScaling")
library(R2WinBUGS)
bugsdir = "C:/Program Files/WinBUGS14"

# Set Metric:
r=1

NSUBJ = 12
NSTIM = 9
s = array(scan("sind.txt"), dim = c(NSTIM,NSTIM,NSUBJ)) 
NSUBJ = 9

data  = list("s", "NSUBJ", "NSTIM", "r") # to be passed on to WinBUGS
myinits =	list(
  list(pt = array(rep(0,NSTIM*2),dim=c(NSTIM,2)), sigma = 0.001))  

# parameters to be monitored:	
parameters = c("p", "sigma")

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits=myinits, parameters,
	 			model.file ="MultidimensionalScaling_1.txt",
	 			n.chains=1, n.iter=1000, n.burnin=100, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir,
	 			codaPkg=F, debug=T)
# Now the values for the monitored parameters are in the "samples" object, 
# ready for inspection.

dim1 = paste("p[",1:9,",1]",sep = "")
dim2 = paste("p[",1:9,",2]",sep = "")

# Plot Posterior Distribution of Points
max1 = max(samples$sims.list$p[,,1])
min1 = min(samples$sims.list$p[,,1])
max2 = max(samples$sims.list$p[,,2])
min2 = min(samples$sims.list$p[,,2])

#some plotting options to make things look better:
par(cex.main = 1.5, mar = c(5, 6, 4, 5) + 0.1, mgp = c(3.5, 1, 0), cex.lab = 1.5,
    font.lab = 2, cex.axis = 1.3, bty = "o", las=1)
  
for (i in 1:NSTIM)
{
  if (i==1)
  {
      plot(samples$sims.array[,,dim1[i]], samples$sims.array[,,dim2[i]], type="p", xlim=c(min1,max1), ylim=c(min2,max2),
           xlab="Dimension 1", ylab="Dimension 2")
      text(mean(samples$sims.array[,,dim1[i]]), mean(samples$sims.array[,,dim2[i]]), paste(i,sep=""), cex=1.5, col="white")
  }
  if (i>1)
  {
    points(samples$sims.array[,,dim1[i]], samples$sims.array[,,dim2[i]])
    text(mean(samples$sims.array[,,dim1[i]]), mean(samples$sims.array[,,dim2[i]]), paste(i,sep=""), cex=1.5, col="white")    
  }
}


