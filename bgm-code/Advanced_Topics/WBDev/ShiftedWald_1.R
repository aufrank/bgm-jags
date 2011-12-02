# clears workspace:  
rm(list=ls(all=TRUE)) 

# sets working directories:
setwd("D:/BugsBoek/NEW.BugsBook/Content/Advanced_Topics/WBDev/Codes")
library(R2WinBUGS)
bugsdir = "C:/Program Files/BlackBox Component Builder 1.5"

#load data
load("rtdata.Rdata")

#the data from the first participant (rt)
rt=rtdata[1,]
nrt=nrt[1]

niter = 10000 
nburnin = 1000
nchains = 3 

data = list("rt", "nrt")

inits =function()
{
list(v=runif(1,3,6),a=runif(1,3,6),Ter=runif(1,0.3,0.6))
}

#parameters to be monitored
parameters = c("v", "a", "Ter")

# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
swald.ind = bugs(data, inits, parameters,
				model.file="ShiftedWald_1.txt",
				n.chains=nchains,n.iter=niter,n.burnin=nburnin,
                                n.thin=1,DIC=T,bugs.directory=bugsdir,codaPkg=F,
				debug=T,clearWD=T)


# Now the values for the monitored parameters are in the "swald.ind" object, 
#ready for inspection.


#############Figures
##Fugure 17.5

library(logspline)
mod=function(data)  #function to compute the mode
{
	d=density(data)
	i=which.max(d$y)
	m=d$x[i]
return(m)
}

v=swald.ind$sims.matrix[,1]
a=swald.ind$sims.matrix[,2]
t=swald.ind$sims.matrix[,3]

mv=mod(v)
dv=density(v)
fv=splinefun(dv)

ma=mod(a)
da=density(a)
fa=splinefun(da)

mt=mod(t)
dt=density(t)
ft=splinefun(dt)

dev.new(height=3,width=10)


par(cex.main = 1.5, mar = c(5, 4, 3, 2) + 0.1, mgp = c(2.5, 1, 0),
cex.lab = 2, font.lab = 2, cex.axis = 1.3, bty = "n", las=1)
layout(matrix(1:3,1,3))

plot(dv,axes=F,
	xlim=c(3,9),ylim=c(0,0.6),
	lwd=2,
	xlab='v',main='')
axis(1,at=c(3,6,9))
axis(2,tcl=0,labels=F)
lines(c(mv,mv),c(0,fv(mv)),col='gray',lty=2,lwd=2)

pv=logspline(v)
x0=qlogspline(0.025,pv)
x1=qlogspline(0.975,pv)
arrows(x0,max(dv$y)*1.1,x1,max(dv$y)*1.1,length=0.1,angle=90,code=3,lwd=2)
text((x0+x1)/2,max(dv$y)*1.2,labels='95%',cex=1.5)

x0
x1

plot(da,axes=F,
	xlim=c(0,4),ylim=c(0,1.2),
	lwd=2,
	xlab='a',ylab='',main='')
axis(1,at=c(0,2,4))
axis(2,tcl=0,labels=F)
lines(c(ma,ma),c(0,fa(ma)),col='gray',lty=2,lwd=2)

pa=logspline(a)
x0=qlogspline(0.025,pa)
x1=qlogspline(0.975,pa)
arrows(x0,max(da$y)*1.1,x1,max(da$y)*1.1,length=0.1,angle=90,code=3,lwd=2)
text((x0+x1)/2,max(da$y)*1.2,labels='95%',cex=1.5)

x0
x1

plot(dt,axes=F,
	xlim=c(0,0.5),ylim=c(0,11),
	lwd=2,
	xlab='Ter',ylab='',main='')
axis(1,at=c(0,0.25,0.5))
axis(2,tcl=0,labels=F)
lines(c(mt,mt),c(0,ft(mt)),col='gray',lty=2,lwd=2)

pt=logspline(t)
x0=qlogspline(0.025,pt)
x1=qlogspline(0.975,pt)
arrows(x0,max(dt$y)*1.1,x1,max(dt$y)*1.1,length=0.1,angle=90,code=3,lwd=2)
text((x0+x1)/2,max(dt$y)*1.2,labels='95%',cex=1.5)

x0
x1






