setwd("C:\\Documents and Settings\\Dora.REKENBEEST\\Desktop\\WinBUGS\\Book")
library(R2WinBUGS)
bugsdir = "C:\\Program Files\\WinBUGS14"

k = 5
n = 10

data  = list("k", "n")
inits =	function()
		{
			list(theta = 0.5)
		}
parameters = c("theta")

ex1.sim = bugs(data, inits, parameters,
	 			model.file ="example1_rateproblem.txt",
	 			n.chains=1, n.iter=2000, n.burnin=0, n.thin=1,
	 			DIC=T, bugs.directory=bugsdir, #DIC=T or else error message
	 			codaPkg=F, debug=F)


samples=ex1.sim$sims.array[,,1]


#plots posterior density

postscript("DensityChain1.eps", width=6, height=6, horizontal = FALSE, onefile = FALSE, paper = "special",
          encoding = "TeXtext.enc")

#par(mar=c(3,4,0,2))
plot(density(samples), zero.line=F, xlab="", ylab="", main="", ylim= c(0.1,4),xlim=c(0,1), axes=F) #zero.line removes the gray line above x axis
axis(1, at = c(0, 0.2, 0.4, 0.6, 0.8, 1), lab=c("0.0", "0.2", "0.4", "0.6", "0.8", "1.0"))
axis(2,las=2, at = c(0, 1, 2, 3, 4), lab=c("0", "1", "2", "3", "4"))
mtext(expression(theta), side=1, line = 3.75, cex=1.6) #line gives text padding
mtext("Posterior Density", side=2, line = 3.1, cex=1.4)

dev.off()


postscript("DensityChain2.eps", width=6, height=6.75, horizontal = FALSE, onefile = FALSE, paper = "special",
          encoding = "TeXtext.enc")


#to plot chain
par(mar=c(6,2,4,2))
plot(ex1.sim$sims.array[,,1], type="l", ylim=c(0,1), xlim=c(0,2000), lwd=1, lty=1, ylab="", xlab="", axes=F)
axis(1, las=3)	#las rotates axis numbers
axis(2) 
text(1350, -0.215, srt=180, adj = 0, labels = "MCMC Iteration", xpd = TRUE, cex=1.4) #use text if you wan to rotate the label using srt
#mtext(expression(theta), side=2, line = 2.8, cex=1.6)

dev.off()







