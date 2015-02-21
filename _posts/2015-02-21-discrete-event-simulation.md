---
title: "Discrete Event Simulation"
author: "Nicholas Head"
date: "February 18, 2015"
layout: default
---





###M/M/1 Queue

A single-server queue with a simple birth-death process:

$$\begin{array}{l l}
    \text{transition} & \quad \text{rate} \\
    i \rightarrow i + 1 & \quad \lambda & \quad  (i \geq 0) \\
    i \rightarrow i - 1 & \quad \mu     & \quad  (i \geq 1) \\
  \end{array} $$

The simulation loop:

{% highlight r %}
RunSim.MM1 <- function (lambda, mu, simDuration) {
  simTime <- 0    # sim time
  timeForNextBirth <- 0         # time for next arrival
  timeForNextDeath <- simDuration     # time for next departure
  lastEventTime <- simTime   # tmp var for last event time
  lastBusyTimeStart <- 0         # tmp var for last busy-time start
  numberInSystem <- 0          # number in system
  totalBusyTime <- 0          # total busy time
  totalCompletions <- 0          # total completions
  
  set.seed(1)
  
  while (simTime < simDuration) {
      if (timeForNextBirth < timeForNextDeath) {      # birth
          simTime <- timeForNextBirth
          
          ret = IncrementPopulation(numberInSystem, simTime, lastEventTime) # instrumentation
          numberInSystem = ret[1]
          lastEventTime = ret[2]
          
          timeForNextBirth <- simTime + rexp(1, lambda)
          
          if(numberInSystem == 1) { 
              lastBusyTimeStart <- simTime
              timeForNextDeath <- simTime + rexp(1, mu)  # exponential  interarrival period
          }
      } else {            # death
          simTime <- timeForNextDeath
          
          ret = IncrementPopulation(numberInSystem, simTime, lastEventTime, -1) # instrumentation
          numberInSystem = ret[1]
          lastEventTime = ret[2]
          totalCompletions <- totalCompletions + 1
          
          if (numberInSystem > 0) { 
              timeForNextDeath <- simTime + rexp(1, mu)  # exponential  service period
          }
          else { 
              timeForNextDeath <- simDuration
              totalBusyTime <- totalBusyTime + simTime - lastBusyTimeStart
          }
      }   
  }
  return (c(simTime, totalBusyTime, totalCompletions))
}
{% endhighlight %}
Kick off the simulation with appropriate parameters:


{% highlight r %}
lambda <- 0.7500188    # birth rate
mu <- 1.0000    # death rate
simDuration   <- 10^5 # duration of sim

ret = RunSim.MM1(lambda, mu, simDuration)
simTime = ret[1]
totalBusyTime = ret[2]
totalCompletions = ret[3]
{% endhighlight %}

Average busy period: $\frac{1}{\mu - \lambda}$

{% highlight r %}
1/(mu - lambda)
{% endhighlight %}



{% highlight text %}
## [1] 4.000301
{% endhighlight %}

Average waiting time: $\frac{1}{\mu - \lambda} - \frac{1}{\mu} = \frac{\rho}{\mu - \lambda}$

{% highlight r %}
1/(mu - lambda) - 1/mu
{% endhighlight %}



{% highlight text %}
## [1] 3.000301
{% endhighlight %}



| utilization B/T| mean queue length| mean throughput C/T| mean residence time| estimated queue length |
|---------------:|-----------------:|-------------------:|-------------------:|-----------------------:|
|       0.7477478|          3.021881|             0.74954|            4.031648|                2.952506|

![center]({{ site.url }}/images/discrete-event-simulation-unnamed-chunk-7-1.png) 

We can double check our theoretical results using the 'queueing' package:

{% highlight r %}
library(queueing)

## create input parameters
i_mm1 <- NewInput.MM1(lambda=lambda, mu=mu, n=3)
## Build the model
summary(QueueingModel(i_mm1))
{% endhighlight %}



{% highlight text %}
## The inputs of the M/M/1 model are:
## lambda: 0.7500188, mu: 1, n: 3
## 
## The outputs of the M/M/1 model are:
## 
## The probability (p0, p1, ..., pn) of the n = 3 clients in the system are:
## 0.2499812 0.1874906 0.1406215 0.1054687
## The traffic intensity is: 0.7500188
## The server use is: 0.7500188
## The mean number of clients in the system is: 3.00030082262186
## The mean number of clients in the queue is: 2.25028202262186
## The mean number of clients in the server is: 0.7500188
## The mean time spend in the system is: 4.00030082262186
## The mean time spend in the queue is: 3.00030082262186
## The mean time spend in the server is: 1
## The mean time spend in the queue when there is queue is: 4.00030082262186
## The throughput is: 0.7500188
{% endhighlight %}



{% highlight text %}
## Loading required package: methods
{% endhighlight %}


###M/M/C Queue

Now we examine a queueing model with support for $c$ servers:

$$\begin{array}{l l}
    \text{transition} & \quad \text{rate} \\
    i \rightarrow i + 1 & \quad \lambda & \quad  (i \geq 0) \\
    i \rightarrow i - 1 & \quad \mu \text{ min} (i, c)     & \quad  (i \geq 1) \\
  \end{array} $$

The simulation loop is identical to the version for the M/M/1 queue apart from the modification to the timeToNextDeath reflecting the new transition logic:


{% highlight r %}
timeForNextDeath <- simTime + rexp(1, min(numberInSystem, c) / mu)
{% endhighlight %}


Kick off the simulation with appropriate parameters:


{% highlight r %}
c = 1 # number of servers
lambda <- 0.7500188    # birth rate
mu <- 1.0000    # death rate
simDuration   <- 10^5 # duration of sim

ret = RunSim.MMC(lambda, mu, c, simDuration)
simTime = ret[1]
totalBusyTime = ret[2]
totalCompletions = ret[3]
{% endhighlight %}



| utilization B/T| mean queue length| mean throughput C/T| mean residence time| estimated queue length |
|---------------:|-----------------:|-------------------:|-------------------:|-----------------------:|
|       0.7477478|          6.043762|             0.74954|            8.063295|                5.905011|

![center]({{ site.url }}/images/discrete-event-simulation-unnamed-chunk-13-1.png) 

We can double check our theoretical results using the 'queueing' package:

{% highlight r %}
library(queueing)

## create input parameters
i_mmc <- NewInput.MMC(lambda=lambda, mu=mu, n=3, c = c)
## Build the model
summary(QueueingModel(i_mmc))
{% endhighlight %}



{% highlight text %}
## The inputs of the model M/M/c are:
## lambda: 0.7500188, mu: 1, c: 1, n: 3, method: Exact
## 
## The outputs of the model M/M/c are:
## 
## The probability (p0, p1, ..., pn) of the n = 3 clients in the system are:
## 0.2499812 0.1874906 0.1406215 0.1054687
## The traffic intensity is: 0.7500188
## The server use is: 0.7500188
## The mean number of clients in the system is: 3.00030082262186
## The mean number of clients in the queue is: 2.25028202262186
## The mean number of clients in the server is: 0.7500188
## The mean time spend in the system is: 4.00030082262186
## The mean time spend in the queue is: 3.00030082262186
## The mean time spend in the server is: 1
## The mean time spend in the queue when there is queue is: 4.00030082262186
## The throughput is: 0.7500188
{% endhighlight %}



