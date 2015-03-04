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

##Rejection Method
