# clears workspace:  
rm(list=ls(all=TRUE)) 

# sets working directories:
setwd("C:/Documents and Settings/ewagenmakers/My Documents/My Dropbox/EJ/temp/BayesBook/Code/ParameterEstimation_Cognitive/SignalDetection")
library(R2WinBUGS)
bugsdir = "C:/Program Files/WinBUGS14"

source("heit_rotello.RData") #loads the data

niter   = 10000
nburnin = 1000

for (dataset in 1:2) #analyse both conditions
{
	if (dataset == 1)
		data = std_i # the induction data
	if (dataset == 2)
		data = std_d # the deduction data
		
  HR = data[,1]
  FA = data[,2]
  MI = data[,3]
  CR = data[,4]		
	n  = nrow(data)	

  data  = list("HR", "FA", "MI", "CR", "n") # to be passed on to WinBUGS
  myinits =	list(
    list(d = rep(0, n), c = rep(0, n), mud = 0, muc = 0, lambdad = 1, lambdac = 1))  

  # parameters to be monitored:	
  parameters = c("mud", "muc", "sigmad", "sigmac")
	
  if (dataset == 1) # induction
	{
    # The following command calls WinBUGS with specific options.
    # For a detailed description see Sturtz, Ligges, & Gelman (2005).
    isamples = bugs(data, inits=myinits, parameters,
    	 			model.file ="SDT_2.txt",
    	 			n.chains=1, n.iter=niter, n.burnin=nburnin, n.thin=1,
    	 			DIC=T, bugs.directory=bugsdir,
    	 			codaPkg=F, debug=T)				
  }

  if (dataset == 2) # deduction
	{
    # The following command calls WinBUGS with specific options.
    # For a detailed description see Sturtz, Ligges, & Gelman (2005).
    dsamples = bugs(data, inits=myinits, parameters,
    	 			model.file ="SDT_2.txt",
    	 			n.chains=1, n.iter=niter, n.burnin=nburnin, n.thin=1,
    	 			DIC=T, bugs.directory=bugsdir,
    	 			codaPkg=F, debug=T)				
  }

}		
		
# Now the values for the monitored parameters are in the "isamples" and 
# "dsamples "objects, ready for inspection.



#####Figure 9.5 & 9.6

keepi=1000
keep=sample(niter, keepi)

imud=isamples$sims.array[,,"mud"]
imuc=isamples$sims.array[,,"muc"]
d.imuc=density(imuc)


dmud=dsamples$sims.array[,,"mud"]
dmuc=dsamples$sims.array[,,"muc"]
d.dmuc=density(dmuc)


layout(matrix(c(1,2,3,0),2,2,byrow=T), width=c(2/3, 1/3), heights=c(2/3,1/3))
#layout.show()

par(mar=c(2,2,1,0))
plot(imud[keep],imuc[keep], xlab="", ylab="", axes=F,xlim=c(-1,6), ylim=c(-3,3))
points(dmud[keep],dmuc[keep], col="grey")
box(lty=1)

par(mar=c(2,1,1,4))
plot(d.imuc$y, d.imuc$x, xlim=rev(c(0,2.5)),type='l', axes=F, xlab="", ylab="",ylim=c(-3,3))
lines(d.dmuc$y, d.dmuc$x, col="grey")
axis(4)
mtext(expression(paste(mu, "c")), side=4,line=2.3, cex=1.3)
box(lty=1)

par(mar=c(6,2,0,0))
plot(density(imud),zero.line=F ,main="", ylab="", xlab="", cex.lab=1.3, axes=F, xlim=c(-1,6),ylim=c(0,1))
lines(density(dmud), col="grey")
axis(1, at=c(-1, 0, 1, 2, 3, 4, 5, 6))
mtext(expression(paste(mu, "d")), side=1.2,line=2, cex=1.3)
box(lty=1)

