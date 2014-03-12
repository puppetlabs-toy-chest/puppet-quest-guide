# Courseware Learning VM

## Synopsis

The Learning VM (Virtual Machine) is a self contained environment with everything a new user needs to get started learning Puppet. The courses are in an extensible quest-based format to allow users to explore and build on concepts at their own pace. The self-paced learning format lets users at any level, not just command-line ninjas, get started with Puppet quickly and painlessly.

Because the VM and Quest Guide are self contained, the user can learn Puppet anywhere; after the initial download, no internet connection is required.

## Jekyll Site

The Quest Guide is a static website generated from source markdown and served by Jekyll.  To view the site, first install the ruby gem Jekyll by typing the following in your console:
	
	sudo gem install jekyll
	
When Jekyll is successfully installed, you can serve the website navigating to the top directory:

	cd /path/to/courseware-lvm/Quest_Guide
	
and entering the command:

	jekyll serve --watch
	
Now open your web browser and point it to:
	
	localhost:4000
	
## Liquid Templates

We use the Liquid templating system in order to extend the syntax available in markdown and allow us to include asides and custom-formatted task notation.

Errors in template syntax will prevent Jekyll from running properly. Before making a pull request with content changes, make sure that Jekyll will run. If there are Liquid syntax errors, Jekyll will throw a Liquid Exception and point you to the offending file.

There are three types of aside that will be displayed floating to the right of the text. Each has an icon according to its type and will include the content between the template tags. This content should be kept brief, and you should avoid using too many of these in close succession to avoid clutter.

```
{% tip %}
Here's a tip!
{% endtip %}

{% warning %}
Here's a warning!
{% endwarning %}

{% fact %}
Here's a fact!
{% endfact %}
```

There is also an inline-aside style. This is displayed in the main body of the text, but is set off from the flow of the document. Unlike the asides above, this can include a title, which can include spaces. Some special characters work here, but this hasn't been tested, so be sure to double chekc that you don't break things.

```
{% aside Title of aside %}
Content of the aside.
{% endaside %}

```

Finally, there is a template to be used in Task numbering. Place this before each task and increment the numbering as needed.

```
{% task 1 %}
```

## PDF Generation

The pdf_make.py script will automatically generate the PDF files that are bundled with the Learning VM download.

The script uses PrinceXML to generate PDFs, so you must have Prince installed (http://www.princexml.com/download/) for it to function. Note that you must register your copy of Prince in order to generate PDFs without a watermark.

The script also has three library dependencies outside of the Python standard libraries:

* html5lib
* BeautifulSoup4
* Markdown

These can be installed using either pip or easy_install, e.g.

	easy_install BeautifulSoup

Once the dependencies are installed, navigate to the top directory of the repository, and use the arguments `--setup` or `-s` and/or `--quest` or `-q` to specify which PDFs you would like to generate, e.g.:
	
	python pdf_maker.py -s -q
	 
