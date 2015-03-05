---
title: "Non-Uniform Random Variables"
author: "Nick Head"
date: "3 March 2015"
layout: default
---

#Generation of Non-Uniform Random Variables



##Inversion Method

For an RV $X$ with a pdf $f$ and cdf $F$ where:

$$F(x) = \int_{-\infty}^x f(t) dt$$

Assuming $F$ has an inverse, we can simulate $X$ by setting $U = F(X)$ via:

$$P(U \leq u) = P[F(X) \leq F(x)] = P[F^{-1}(F(X) \leq F^{-1}(F(x))] = P(X = x)$$

### Exponential Distribution

$$X \sim Exp(\lambda)$$

$$f(x) = \lambda e^{-\lambda x} \quad (x \geq 0)$$

$$F(x) = 1 - e^{-\lambda x} \quad (x \geq 0)$$

$$F^{-1}(u) = - \frac{log(1-u)}{\lambda} = - \frac{log(u)}{\lambda} = x$$


{% highlight r %}
n = 1000
lambda = 2
u = runif(n)
xInv = -log(u)/lambda
{% endhighlight %}
Compare with `rexp`:

{% highlight r %}
xExp = rexp(n, lambda)

par(mfcol = c(1,2))
hist(xInv)
hist(xExp)
{% endhighlight %}

![center]({{ site.url }}/images/non-uniform-rvs-unnamed-chunk-3-1.png) 

### Logistic Distribution

$$X \sim \text{ Logistic}()$$

$$f(x) = \frac{e^{-x}}{(1 + e^{-x})^2}$$

$$F(x) = \frac{1}{(1 + e^{-x})}$$

$$F^{-1}(u) = - log(\frac{1}{u} - 1) = x$$


{% highlight r %}
n = 10000
u = runif(n)
xInv = -log(1/u - 1)
{% endhighlight %}
Compare with `rlogis`:

{% highlight r %}
xLogis = rlogis(n, 0, 1)

par(mfcol = c(1,2))
hist(xInv)
hist(xLogis)
{% endhighlight %}

![center]({{ site.url }}/images/non-uniform-rvs-unnamed-chunk-5-1.png) 

##Table Lookup Method

###Binomial Distribution

$$X \sim Bin(10,0.3)$$


{% highlight r %}
n <- 10
p <- .3
t <- seq(0,n-1)
prob = pbinom(t,n,p)
{% endhighlight %}

With a CDF:

|      0|      1|      2|      3|      4|      5|      6|      7|      8|  9|
|------:|------:|------:|------:|------:|------:|------:|------:|------:|--:|
| 0.0282| 0.1493| 0.3828| 0.6496| 0.8497| 0.9527| 0.9894| 0.9984| 0.9999|  1|


{% highlight r %}
Nsim=10^4; 
xTable=numeric(Nsim)
uvec = runif(Nsim)
xTable = as.numeric(lapply(uvec, function(u){ sum(prob<u)}))
{% endhighlight %}
Compare with `rbinom`:

{% highlight r %}
xBinom = rbinom(Nsim, n, p)
par(mfcol = c(1,2))
hist(xTable)
hist(xBinom)
{% endhighlight %}

![center]({{ site.url }}/images/non-uniform-rvs-unnamed-chunk-9-1.png) 

###Poisson Distribution

$$X \sim Poisson(2)$$


{% highlight r %}
lambda=2
t=seq(0,9)
prob=ppois(t, lambda)
{% endhighlight %}

With a CDF:

|      0|     1|      2|      3|      4|      5|      6|      7|      8|  9|
|------:|-----:|------:|------:|------:|------:|------:|------:|------:|--:|
| 0.1353| 0.406| 0.6767| 0.8571| 0.9473| 0.9834| 0.9955| 0.9989| 0.9998|  1|


{% highlight r %}
Nsim=10^4; 
xTable=numeric(Nsim)
uvec = runif(Nsim)
xTable = as.numeric(lapply(uvec, function(u){ sum(prob<u)}))
{% endhighlight %}
Compare with `rpois`:

{% highlight r %}
xPois = rpois(Nsim, lambda)
par(mfcol = c(1,2))
hist(xTable)
hist(xPois)
{% endhighlight %}

![center]({{ site.url }}/images/non-uniform-rvs-unnamed-chunk-13-1.png) 


##Acceptance-Rejection Method

Simplified Algorithm:

1. Generate $Y \sim g$, $U \sim \mathcal{U}_{[0,1]}$

2. Accept $X = Y$ if $U \leq f(Y)/Mg(y)$

3. Return to 1 otherwise.

In pseudocode this is found by:


{% highlight r %}
> u=runif(1)*M
> y=randg(1)
> while (u>f(y)/g(y)){
+   u=runif(1)*M
+   y=randg(1)
+ }
{% endhighlight %}

In 'production' code this is implemented as follows:

{% highlight r %}
Simulate <- function(Nsim, f_fn, g_fn, randg_fn) {
  #M is found by finding the maximum of f(x)/g(x) over [0,1]
  M = optimize(f=function(x){f_fn(x)/g_fn(x)},interval=c(0,1),maximum=TRUE)$objective
  
  #graphing logic
  ylim <- c(0, 5)
  xlim <- c(0, 1)
  curve(f_fn(x),from = 0,to = 1, xlim = xlim, ylim = ylim)
  par(new=T)
  
  x_star = randg_fn(Nsim)
  y_star = runif(Nsim, max = M * g_fn(x_star)) # y* drawn from proposal function g
  x = NULL
  successCount = 0
  for(i in 1:Nsim){
    #accept x* if y* <= f(x*)
    if(y_star[i] <= f_fn(x_star[i])){ 
      successCount = successCount + 1
      x[successCount] = x_star[i]
      
      #plot the accepted points
      points(x_star[i], y_star[i], xlab = NA, ylab = NA, xaxt='n', yaxt='n', xlim = xlim, ylim = ylim, col="blue")
    }
    else{
      #plot the rejected points
      points(x_star[i], y_star[i], xlab = NA, ylab = NA, xaxt='n', yaxt='n', xlim = xlim, ylim = ylim, col="red")
    }
  }
  return(successCount)
}
{% endhighlight %}

As an example, $X \sim \mathcal{Be}(2.7, 6.3)$ with a rectangular $Y \sim \mathcal{U}(0,1)$ envelope:


{% highlight r %}
alpha <- 2.7
beta <- 6.3
Nsim = 1000
successCount = Simulate(Nsim, 
                        f_fn = function (x) {dbeta(x,alpha,beta)},
                        g_fn = function (y) {dunif(y)},
                        randg_fn = function (Nsim) {runif(Nsim)})
{% endhighlight %}

![center]({{ site.url }}/images/non-uniform-rvs-unnamed-chunk-16-1.png) 

Total acceptance rate: 37.6%

To increase the efficiency of the simulation we can increase the acceptance rate by introducing a tighter proposal density (the envelope). For instance try $Y \sim \mathcal{Be}(2,6)$


{% highlight r %}
successCount = Simulate(Nsim, 
                        f_fn = function (x) {dbeta(x,alpha,beta)},
                        g_fn = function (y) {dbeta(y,2,6)},
                        randg_fn = function (Nsim) {rbeta(Nsim, 2, 6)}
                        )
{% endhighlight %}

![center]({{ site.url }}/images/non-uniform-rvs-unnamed-chunk-17-1.png) 

Total acceptance rate: 59.2%
