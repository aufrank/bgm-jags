# clears workspace:  
rm(list=ls(all=TRUE)) 

# sets working directories:
setwd("D:/BugsBoek/NEW.BugsBook/Content/Advanced_Topics/WBDev/Codes")
library(R2WinBUGS)
bugsdir = "C:/Program Files/BlackBox Component Builder 1.5"

nburnin = 1000 
niter = 10000 
nchains = 3

load("rtdata.Rdata")

rt=rtdata
ns=length(nrt)

data = list("rt", "nrt", "ns")

inits =function()
{
list(vg=runif(1,3,6),ag=runif(1,3,6),Terg=runif(1,0.3,0.6))
}


#parameters to be monitored
parameters = c("vg", "ag", "Terg","vi","ai","Teri")



# The following command calls WinBUGS with specific options.
# For a detailed description see Sturtz, Ligges, & Gelman (2005).
swald.hier = bugs(data, inits, parameters, 
				model.file="ShiftedWald_2.txt",
				n.chains=nchains, n.iter=niter,
				n.burnin=nburnin, n.thin=1,
				DIC=T, bugs.directory=bugsdir,
				codaPkg=F, debug=T, clearWD=T)

# Now the values for the monitored parameters are in the "swald.hier" object, 
# ready for inspection.

###Figure 17.8

library(logspline)

mod=function(data) #function to compute mode
{
	d=density(data)
	i=which.max(d$y)
	m=d$x[i]
return(m)
}


v=swald.hier$sims.list$vg
a=swald.hier$sims.list$ag
t=swald.hier$sims.list$Terg

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
	xlim=c(3,9),ylim=c(0,2.5),
	lwd=2,
	xlab='vg',main='')
axis(1,at=c(3,6,9))
axis(2,tcl=0,labels=F)
lines(c(mv,mv),c(0,fv(mv)),col='gray',lty=2,lwd=2)

pv=logspline(v)
x0=qlogspline(0.025,pv)
x1=qlogspline(0.975,pv)
arrows(x0,max(dv$y)*1.1,x1,max(dv$y)*1.1,length=0.1,angle=90,code=3,lwd=2)
text(x1+0.6,max(dv$y)*1.1,labels='95%',cex=1.5)
x0
x1

plot(da,axes=F,
	xlim=c(0,4),ylim=c(0,8),
	lwd=2,
	xlab='ag',ylab='',main='')
axis(1,at=c(0,2,4))
axis(2,tcl=0,labels=F)
lines(c(ma,ma),c(0,fa(ma)),col='gray',lty=2,lwd=2)

pa=logspline(a)
x0=qlogspline(0.025,pa)
x1=qlogspline(0.975,pa)
arrows(x0,max(da$y)*1.1,x1,max(da$y)*1.1,length=0.1,angle=90,code=3,lwd=2)
text(x1+0.4,max(da$y)*1.1,labels='95%',cex=1.5)
x0
x1
plot(dt,axes=F,
	xlim=c(0,0.5),ylim=c(0,50),

	lwd=2,
	xlab='Terg',ylab='',main='')
axis(1,at=c(0,0.25,0.5))
axis(2,tcl=0,labels=F)
lines(c(mt,mt),c(0,ft(mt)),col='gray',lty=2,lwd=2)

pt=logspline(t)
x0=qlogspline(0.025,pt)
x1=qlogspline(0.975,pt)
arrows(x0,max(dt$y)*1.1,x1,max(dt$y)*1.1,length=0.1,angle=90,code=3,lwd=2)
text(x1+0.05,max(dt$y)*1.1,labels='95%',cex=1.5)
x0
x1


###Figure17.10

vg=swald.hier$sims.list$vi[,1]
ag=swald.hier$sims.list$ai[,1]
tg=swald.hier$sims.list$Teri[,1]

load("C:/Documents and Settings/Dora.REKENBEEST/Desktop/WinBUGS/Book/WBDev/swald.ind.RData")

vi=swald.ind$sims.matrix[,1]
ai=swald.ind$sims.matrix[,2]
ti=swald.ind$sims.matrix[,3]

mvg=mod(vg)
dvg=density(vg)
fvg=splinefun(dvg)

mvi=mod(vi)
dvi=density(vi)
fvi=splinefun(dvi)

mag=mod(ag)
dag=density(ag)
fag=splinefun(dag)

mai=mod(ai)
dai=density(ai)
fai=splinefun(dai)

mtg=mod(tg)
dtg=density(tg)
ftg=splinefun(dtg)

mti=mod(ti)
dti=density(ti)
fti=splinefun(dti)

dev.new(height=3,width=10)


par(cex.main = 1.5, mar = c(5, 4, 3, 2) + 0.1, mgp = c(2.5, 1, 0),
cex.lab = 2, font.lab = 2, cex.axis = 1.3, bty = "n", las=1)
layout(matrix(1:3,1,3))

plot(dvg,axes=F,
	xlim=c(3,9),ylim=c(0,1.5),
	lwd=2,
	xlab='vi[1]',main='')
axis(1,at=c(3,6,9))
axis(2,tcl=0,labels=F)
lines(c(mvg,mvg),c(0,fvg(mvg)),col='gray',lty=2,lwd=2)

lines(dvi,
	xlim=c(3,9),ylim=c(0,1.5),
	lwd=1.5,lty=3,
	xlab='v',main='')

pvg=logspline(vg)
x0=qlogspline(0.025,pvg)
x1=qlogspline(0.975,pvg)
arrows(x0,max(dvg$y)*1.1,x1,max(dvg$y)*1.1,length=0.1,angle=90,code=3,lwd=2)
text(x1+0.6,max(dvg$y)*1.1,labels='95%',cex=1.5)

pvi=logspline(vi)
x0=qlogspline(0.025,pvi)
x1=qlogspline(0.975,pvi)
arrows(x0,max(dvg$y)*1.3,x1,max(dvg$y)*1.3,length=0.1,angle=90,code=3,lwd=1.5,lty=3)
text(x1+0.6,max(dvg$y)*1.3,labels='95%',cex=1.5)

plot(dag,axes=F,
	xlim=c(0,4.2),ylim=c(0,5),
	lwd=2,
	xlab='ai[1]',ylab='',main='')
axis(1,at=c(0,2,4))
axis(2,tcl=0,labels=F)
lines(c(mag,mag),c(0,fag(mag)),col='gray',lty=2,lwd=2)

lines(dai,
	xlim=c(0,4),ylim=c(0,4),
	lwd=1.5,lty=3,
	xlab='a',ylab='',main='')

pag=logspline(ag)
x0=qlogspline(0.025,pag)
x1=qlogspline(0.975,pag)
arrows(x0,max(dag$y)*1.1,x1,max(dag$y)*1.1,length=0.1,angle=90,code=3,lwd=2)
text(x1+0.4,max(dag$y)*1.1,labels='95%',cex=1.5)

pai=logspline(ai)
x0=qlogspline(0.025,pai)
x1=qlogspline(0.975,pai)
arrows(x0,max(dag$y)*1.3,x1,max(dag$y)*1.3,length=0.1,angle=90,code=3,lwd=1.5,lty=3)
text(x1+0.4,max(dag$y)*1.3,labels='95%',cex=1.5)

plot(dtg,axes=F,
	xlim=c(0,0.5),ylim=c(0,40),
	lwd=2,
	xlab='Teri[1]',ylab='',main='')
axis(1,at=c(0,0.25,0.5))
axis(2,tcl=0,labels=F)
lines(c(mtg,mtg),c(0,ftg(mtg)),col='gray',lty=2,lwd=2)

lines(dti,
	xlim=c(0,0.5),ylim=c(0,40),
	lwd=1.5,lty=3,
	xlab='Ter',ylab='',main='')

ptg=logspline(tg)
x0=qlogspline(0.025,ptg)
x1=qlogspline(0.975,ptg)
arrows(x0,max(dtg$y)*1.1,x1,max(dtg$y)*1.1,length=0.1,angle=90,code=3,lwd=2)
text(x1+0.05,max(dtg$y)*1.1,labels='95%',cex=1.5)

pti=logspline(ti)
x0=qlogspline(0.025,pti)
x1=qlogspline(0.975,pti)
arrows(x0,max(dtg$y)*1.3,x1,max(dtg$y)*1.3,length=0.1,angle=90,code=3,lwd=1.5,lty=3)
text(x1+0.05,max(dtg$y)*1.3,labels='95%',cex=1.5)

