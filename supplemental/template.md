# PDF Style Reference

## Markdown Syntax

There are some basic elements of markdown syntax for styling text. When exported to html, this formatting syntax is transformed into tags, which you can then select and style with a .css file.

### Normal paragraph:

This is normal paragraph text.

	nothin' special

### Strong:

For __strong__ text use double underscores like this:

	__strong__
	
It shows up in the html file wrapped in a `<strong>` tag, like so:
	
	<strong>Powerful Message</strong>

### Emphasis:

For *em*, as in "emphasis," do this:

	*em*

### Block Quote:

Someone told me that if you want a block quote, 
> you should put a > character at the beginning of your text.

Like this:

	>block quote 

### Lists:

There are lots of reasons why you might want to make a list of things. Here are some examples:

* It's good for the liver.
* Live a little.
* Going shopping.
* etc.

It almost rhymes:

	* To make a list.
	* Use asterisk.
	
### Inline image:

![text](./assets/console.png)
	
	![text](./assets/console.png)
	
### Links: 

How about a [link](http://www.puppetlabs.com/education)? You do that like this:

	[link](http://www.puppetlabs.com/education)
	
# Custom Elements

### Console Command:

Let's not actually type this, though.

<div class="console">
<p>
sudo rm -rf /
</p>
</div>

	<div class="console">
	<p>
	sudo rm -rf /
	</p>
	</div>

```
class { 'puppetlabs':
	ensure => 'present',
	foo    => 'bar',
}
```

<div class="callout">
<h3>
Puppet Tip:
</h3>
<p>
You can create a nifty callout by wrapping your text in &ltdiv class="callout"&gt&lt/div&gt tags! Note that markdown syntax doesn't work in this context--you'll have to treat everything you put here like normal html. Be sure to include an h3 and put your text in p tags.
</p>
</div>

### Page Breaks:

This page isn't quite long enough to have a page break automatically, but I'm getting impatient. Let's end it, like so:

	<div class="page-break"></div>

<div class="page-break"></div>

<div class="aside">
<h3>
Inline Aside:
</h3>
<p>
If you want to talk about something that's slightly tangential, you can wrap it in a div tag with the "aside" class. Remember, markdown syntax doesn't apply, so you'll have to put your text in a p tag and include an h3 as the title.
</p>
</div>

	<div class="aside">
	<h3>
	Inline Aside:
	</h3>
	<p>
	If you want to talk about something that's slightly tangential, you can wrap it in a div tag with the "aside" class. Remember, markdown syntax doesn't apply, so you'll have to put your text in a p tag and include an h3 as the title.
	</p>
	</div>






