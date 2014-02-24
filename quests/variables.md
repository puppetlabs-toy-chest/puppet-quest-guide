---
title: Variables
layout: default
---

# Variables and Variability

>The green reed which bends in the wind is stronger than the mighty oak which breaks in a storm.

> --Confuscius

What you have learned so far about manifests gives you the means to achieve a great deal. However, you need not travel far down your destined path of Puppet mastery before manifests like the ones you have written thus far will seem stiff and brittle; you will need something more supple, able to shift to meet changing conditions as you travel the roads of Elvium and beyond.

One way to make your manifests more adaptable is by using variables.

## Tasks

1. To see an example of a variable doing its duty, first navigate to your workshop directory and create a new manifest called `fickle.pp`
	
2.	Enter the following to name and assign a variable:
{% highlight ruby %}
$variable_name = "variable value!\n"
{% endhighlight %}
	Note the `$` symbol at the beginning of the var

## Facts

>Get your facts first, then distort them as you please.

> --Mark Twain
