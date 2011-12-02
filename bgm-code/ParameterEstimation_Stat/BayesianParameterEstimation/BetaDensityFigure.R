rm(list=ls(all=TRUE))
setwd("C:\\EJ\\UvApost\\uvapapers\\2008\\Himanshu\\SDtex\\Figures")

# prior:
a = 1
b = 1
# data:
s = 9
f = 1

# plot posterior and prior:
par(cex.main = 1.5, mar = c(5, 6, 4, 5) + 0.1, mgp = c(3.5, 1, 0), cex.lab = 1.5,
    font.lab = 2, cex.axis = 1.3, bty = "n", las=1)

plot ( function( x ) dbeta( x, a+s, b+f ), 0, 1, ylim=c(0,5), xlim=c(0,1), lwd=2, lty=1, ylab="Density", xlab=" ", axes=F) 
axis(1, at = c(0, 0.25, 0.50, 0.75, 1), lab=c("0", "0.25", "0.5", "0.75", "1"))
axis(2)

par(new=T)
plot ( function( x ) dbeta( x, a, b ), 0, 1, ylim=c(0,5), xlim=c(0,1), lwd=2, lty=3, ylab="Density", xlab=" ", axes=F) 
axis(1, at = c(0, 0.25, 0.50, 0.75, 1), lab=c("0", "0.25", "0.5", "0.75", "1"))
axis(2)

mtext(expression(theta), side=1, line = 2.8, cex=2)

#MLE
arrows(.9, dbeta(.9,a+s,b+f), .9, 0.5, lwd=2)
text(.9, .25, labels="MLE", cex = 1.5) 

#text with prior and posterior
text(0.1, 1.25, labels="Prior", cex = 1.5) 
text(0.65, 3, labels="Posterior", cex = 1.5) 

#95% confidence interval
x0=qbeta(0.025,a+s,b+f)
x1=qbeta(0.975,a+s,b+f)
arrows(x0, 4.6, x1, 4.6, length = 0.25, angle = 90, code = 3, lwd=2)
text((x0+x1)/2, 4.6+0.25, labels="95%", cex = 1.5) 

#mass below .5:
pbeta(.5, a+s, b+f) #.006
