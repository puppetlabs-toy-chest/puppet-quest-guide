---
title: Style Reference
layout: default
---

# Style Reference

There are some basic elements of markdown syntax for styling text. When exported to html, this formatting syntax is transformed into tags, which you can then select and style with a .css file.

## Text Styling:

For __strong__ text use double underscores like this:

    __I'm so strong!__
	
For *em*, as in "emphasis," do this:

	*em*

Someone told me that if you want a block quote, 
> you should put a > character at the beginning of your text.

Like this:

	>block quote 

There are lots of reasons why you might want to make a list of things. Here are some examples:

* It's good for the liver.
* Live a little.
* Going shopping.
* etc.

It almost rhymes:

	* To make a list.
	* Use asterisk.

## Images and Links:

![text](../assets/console.png)

It's useful to include diagrams or images to give learners a concrete visualization of a concept. To do this, use the following syntax:
	
	![text](../assets/console.png)
	
You may also want to include a link to another part of the document, or to an external site. Use the following syntax to include a link: 

	[link](http://www.puppetlabs.com/education)

## Custom Elements

In addition to the normal markdown flavors, we've added a few custom tags through the Liquid templating system. Jekyll interprets these and converts them to html tags for us.

For example, we have a style to indicate imperative console commands, as distinct from example code blocks:

<div class="console">
<p>
sudo rm -rf /
</p>
</div>

	Markdown syntax for this feature has yet to be implemented :(

Check out this cool syntax highlighting feature:

{% highlight ruby %}
class { 'puppetlabs':
    ensure => 'present',
    foo    => 'bar',
}
{% endhighlight %}

We also have a special callout element, which can be used to include tips and warnings that will appear alongside the main body of a site.

<div class="callout">
<h3>
Puppet Tip:
</h3>
<p>

	Markdown syntax for this feature has yet to be implemented :(
</p>
</div>

<div class="inline_aside">
<h3>
Inline Aside:
</h3>
<p>
Similarly, we have an inline aside that can be used to include items that are relevant to a topic but tangential to the current quest.
</p>
</div>

	Markdown syntax for this feature has yet to be implemented :(





