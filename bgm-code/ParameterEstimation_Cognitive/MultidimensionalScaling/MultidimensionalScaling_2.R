# clears workspace:  
rm(list=ls(all=TRUE)) 

# sets working directories:
setwd("C:/Documents and Settings/ewagenmakers/My Documents/My Dropbox/EJ/temp/BayesBook/Code/ParameterEstimation_Cognitive/MultidimensionalScaling")
library(R2WinBUGS)
bugsdir = "C:/Program Files/WinBUGS14"

# Set Metric:
r=1.8

NSUBJ = 16
NSTIM = 10
s = array(scan("helm_ind.txt"), dim = c(NSTIM,NSTIM,NSUBJ)) 
s = s/max(s)
s = 1-s

s=s[,,c(7:10,15:16,1:6,11:14)]

data  = list("s", "NSUBJ", "NSTIM", "r") # to be passed on to WinBUGS
myinits =	list(
  list(pt = array(rep(0,NSTIM*2*2),dim=c(NSTIM,2,2)), z01 = round(runif(NSUBJ-10,0,1)), sigma = 0.001))  

# parameters to be monitored:	
parameters = c("p", "z", "sigma")

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
samples = bugs(data, inits=myinits, parameters,
	 			model.file ="MultidimensionalScaling_2.txt",
	 			n.chains=1, n.iter=1000, n.burnin=100, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir,
	 			codaPkg=F, debug=T)
# Now the values for the monitored parameters are in the "samples" object, 
# ready for inspection.

# observe latent assigments:
samples$summary

# Plot Posterior Distribution of Points,
# one panel per group

layout(matrix(c(1,2),1,2))
layout.show(2)
#maximize this window before plotting

shortlabs = c("rp","ro","y","gy1","gy2","g","b","pb","p2","p1")

for (g in 1:2)
{

  max1 = max(samples$sims.list$p[,,1,g])
  min1 = min(samples$sims.list$p[,,1,g])
  max2 = max(samples$sims.list$p[,,2,g])
  min2 = min(samples$sims.list$p[,,2,g])
  
  #some plotting options to make things look better:
  par(cex.main = 1.5, mar = c(5, 6, 4, 5) + 0.1, mgp = c(3.5, 1, 0), cex.lab = 1.5,
      font.lab = 2, cex.axis = 1.3, bty = "o", las=1)  

  for (i in 1:NSTIM)
  {
    if (i==1)
    {
        plot(samples$sims.list$p[,i,2,g],samples$sims.list$p[,i,1,g], type="p", xlim=c(min2,max2), ylim=c(min1,max1),
             xlab="Dimension 1", ylab="Dimension 2")
        text(mean(samples$sims.list$p[,i,2,g]),mean(samples$sims.list$p[,i,1,g]), paste(shortlabs[i],sep=""), cex=1.5, col="red")
    }
    if (i>1)
    {
      points(samples$sims.list$p[,i,2,g],samples$sims.list$p[,i,1,g])
      text(mean(samples$sims.list$p[,i,2,g]),mean(samples$sims.list$p[,i,1,g]), paste(shortlabs[i],sep=""), cex=1.5, col="red")    
    }
  }    
}







