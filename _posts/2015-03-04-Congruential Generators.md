---
title: "Congruential Generators"
author: "Nick Head"
date: "3 March 2015"
output: html_document
layout: default
---

#Generation of Uniform Random Variables



Congruential (multiplicative) generators are written in the form:

$$X_n = a X_{n-1} \text{ mod } M$$

With $X_0$ being the seed. 

A mixed congruential (linear) generator is in the form:

$$X_n = a X_{n-1} + b \text{ mod } M$$



{% highlight r %}
GenerateRandomUniforms <- function (a, b, M, seed, n) {
  rnumbers = numeric(n)
  for(j in 1:n){
    seed = (a*seed + b)%%M
    rnumbers[j] = seed/M
  }
  return(rnumbers)
}
{% endhighlight %}

Firstly an acceptable generator (although showing some periodicity: 

{% highlight r %}
u = GenerateRandomUniforms(a = 77, b = 0, M = 2049, seed = 999, n=1000)
par(mfcol = c(1,2))
hist(u)
acf(u)
{% endhighlight %}

![center]({{ site.url }}/images/congruential-generators-unnamed-chunk-3-1.png) 

Now one with a notably low period (showing high ACF at lag 23): 

{% highlight r %}
u = GenerateRandomUniforms(a = 5, b = 20, M = 23, seed = 11, n=1000)
par(mfcol = c(1,2))
hist(u)
acf(u)
{% endhighlight %}

![center]({{ site.url }}/images/congruential-generators-unnamed-chunk-4-1.png) 

Contrast with `runif()`:


{% highlight r %}
u = runif(n = 1000)
par(mfcol = c(1,2))
hist(u)
acf(u)
{% endhighlight %}

![center]({{ site.url }}/images/congruential-generators-unnamed-chunk-5-1.png) 


