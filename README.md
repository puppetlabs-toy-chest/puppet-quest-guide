# Courseware Learning VM

## Synopsis

The Learning VM (Virtual Machine) is a self contained environment with everything a new user needs to get started learning Puppet. The courses are in an extensible quest-based format to allow users to explore and build on concepts at their own pace. The self-paced learning format lets users at any level, not just command-line ninjas, get started with Puppet quickly and painlessly.

Because the VM and Quest Guide are self contained, the user can learn Puppet anywhere; after the initial download, no internet connection is required.

## Markdown Content

Each Quest for the Quest Guide content is created and stored as a markdown (.md) file. Markdown is a lightweight format and allows for good separation between content, on the one hand, and on the other, parsing, formatting, and rendering implementations.

### YAML Header

Each quest markdown file must begin with a yaml header. This allows Jekyll to identify the file and provides variables to be used in processing. Currently, this header will consist of two lines, marked off from the rest of the file by `---` lines.

The first defines the title, and should be set to the title of the Quest. The second tells Jekyll what layout template to use in generating html from the markdown. This should always be set to `default`.

	---
	title: Resource Ordering
	layout: default
	---

### Title and Headers

Each quest should start with the title of that quest as an h1. In markdown, h1 is designated with a single `#` at the beginning of the lines, e.g.:

	# Resource Ordering

Following the title is a list of course prerequisites under an h3. Prerequisites are entered here as a list of quest titles:

	### Prerequisites
	- Resources
	- Manifests
	
Next is a Quest Objectives section under an h2 with that name:

	## Quest Objectives
	
In this section, include a brief one paragraph summary of the quest objectives. At the end of this section, include the sentence "If you're ready to get started, type the following command:", followed by the start quest command, indented to display as a code block, and with the appropriate quest argument. (This will depend on the VM quest implementation, to be covered below.)

    quest --start ordering
    
After this begin the main content of the quest, using h2 and h3 level headers as appropriate.

### Liquid Templates

We use the Liquid templating system in order to extend the syntax available in markdown and allow us to include asides and custom-formatted task notation.

Errors in template syntax will prevent Jekyll from running properly. Before making a pull request with content changes, make sure that Jekyll will run. If there are Liquid syntax errors, Jekyll will throw a Liquid Exception and point you to the offending file.

#### Code Highlighting

Blocks of code must be wrapped in `{% highlight <language> %} {% endhighlight %}` tags, like so:

	{% highlight puppet %}
	user { 'root':
  		ensure           => 'present',
  	{% endhighlight %}

#### Asides

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

There is also an inline-aside style. This is displayed in the main body of the text, but is set off from the flow of the document. Unlike the asides above, this can include a title, which can include spaces. (Some special characters work here, but this hasn't been tested, so be sure to double check that your content renders properly before making a PR.)

```
{% aside Title of aside %}
Content of the aside.
{% endaside %}
```
#### Images

To inclue images, use the following figure template:

```
{% figure 'assets/filename.png' %}
```

Using this template instead of standard markdown image syntax ensures that the image will be wrapped in the appropriate tags necessary for rendering and also gives it an automatically generated figure label. Note that all images should be stored in the `assets` folder in order to be accessible to both pdf and html rendering methods. Also note that you must wrap the image filepath in single quotation marks.

#### Tasks

Finally, there is a template to be used in Task numbering. Place this before each task. Because task numbering is associated directly with the VM task tracking function, you must enter each task number manually.

```
{% task 1 %}
```

## Jekyll Site

The Quest Guide is a static website generated from source markdown and served by Jekyll.  To view the site, first install the ruby gem Jekyll by typing the following in your console:
	
	sudo gem install jekyll
	
When Jekyll is successfully installed, you can serve the website navigating to the top directory:

	cd /path/to/courseware-lvm/Quest_Guide
	
and entering the command:

	jekyll serve --watch
	
Now open your web browser and point it to:
	
	localhost:4000

## PDF Generation

The pdf_make.py script will automatically generate the PDF files that are bundled with the Learning VM download.

Though the PDF is a separate end-point from the Jekyll static html version of the Quest Guide, it relies on Jekyll to parse markdown and liquid templates to html.

The script uses PrinceXML to generate PDFs, so you must have Prince installed (http://www.princexml.com/download/) for it to function. Note that you must register your copy of Prince in order to generate PDFs without a watermark.

The script also has three library dependencies outside of the Python standard libraries:

* html5lib
* BeautifulSoup4
* Markdown

These can be installed using either pip or easy_install, e.g.

	easy_install BeautifulSoup4

Once the dependencies are installed, navigate to the top directory of the repository, and use the arguments `--setup` or `-s` and/or `--quest` or `-q` to specify which PDFs you would like to generate, e.g.:
	
	python pdf_maker.py -s -q
	
Note that though this script automatically runs a `jekyll build` command, there is currently an issue with the timing of the subprocess that means the changes aren't always made before pdf generation begins. Pending a fix, you may have to run this script twice for changes to register, or manually build the jekyll site prior to running the script.
	 
## Quest Ordering

Quest_Guide/_data/quest_order.yml contains a list of quests with url and title. The order of quests in this file determines the order that they will be listed in the website nav and the PDF version of the Quest Guide.

In the future, this file will also include data about quest dependencies to allow for non-linear quest progress.

Whenever possible, this file should be the single source of information for any process that requires data about quests.