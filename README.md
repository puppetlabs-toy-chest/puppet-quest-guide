# Courseware Learning VM

## Synopsis

The Learning VM (Virtual Machine) is a self contained learning environment.
It includes with everything a new user needs to get started learning Puppet.
The courses are in an extensible quest-based format to allow users to
explore and build on concepts at their own pace. 

The Learning VM is written with Puppet Enterprise (PE) in mind, and some of
the content is PE-specific. That being said, however, a user interested
in Puppet Open Source will likely find the content helpful as well.

Because the VM and Quest Guide are self contained, a user can learn
Puppet anywhere; after the initial download, no internet connection is
required.

## Quest content

Content for the Quest Guide is created in a Markdown (.md) format. We're
currently using the (Jekyll)[http://jekyllrb.com/] static site generator
to build the Quest Guide from raw Markdown source. While the bulk of
content follows standard (Markdown)[http://daringfireball.net/projects/markdown/]
syntax, the content includes a few other elements. We'll go over
some conventions and extensions below. 

### YAML Header

Each quest Markdown file must begin with a yaml header. This allows
Jekyll to identify the file and provides variables to be used in
processing. Currently, this header will consist of two lines, marked
off from the rest of the file by `---` lines.

The first defines the title, and should be set to the title of the quest.
The second tells Jekyll what layout template to use in generating html from
the Markdown. This should always be set to `default`.

	---
	title: Resource Ordering
	layout: default
	---

### Title and Headers

Each quest should start with the title of that quest as an h1. In Markdown,
h1 is designated with a single `#` at the beginning of the lines, e.g.:

	# Resource Ordering
	
Next is a Quest Objectives section under an h2 with that name:

	## Quest Objectives
	
In this section, include a brief one paragraph summary of the quest
objectives. At the end of this section, include the a sentence like
"If you're ready to get started, type the following command:",
followed by the start quest command, indented to display as a code
block, and with the quest name as its argument. This argument
refers to the spec file for that quest, so replace any spaces
with underscores to match the spec filename.

    quest --start resource_ordering
    
After this, begin the main content of the quest, using h2 and h3
level headers as appropriate.

### Liquid templates

We use the Liquid templating system to extend the syntax available
in Markdown and allow us to include asides and custom-formatted
task notation.

These custom templates are defined by Ruby files in the
`Quest_Guide/_plugins` directory.

Errors in template syntax will prevent Jekyll from running properly.
Before making a pull request with content changes, make sure that
Jekyll will run. If there are Liquid syntax errors, Jekyll will throw
a Liquid Exception and point you to the offending file.

#### Code Highlighting

Blocks of code must be wrapped in `{% highlight <language> %} {% endhighlight %}`
tags, like so:

	{% highlight puppet %}
	user { 'root':
  		ensure           => 'present',
  	{% endhighlight %}

#### Asides

(NOTE: We're considering deprecating the tip, warning, and fact
aside styles or replacing them with to simplify our styles and
formatting)

There are three types of aside that will be displayed floating
to the right of the text. Each has an icon according to its
type and will include the content between the template tags.
This content should be kept brief, and you should avoid using
too many of these in close succession to avoid clutter.

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

There is also an inline-aside style. This is displayed in the
main body of the text, but is set off from the flow of the document.
Unlike the asides above, this can include a title, which can include
spaces. (Some special characters work here, but this hasn't been
tested, so be sure to double check that your content renders properly
before making a PR.)

```
{% aside Title of aside %}
Content of the aside.
{% endaside %}
```

#### Tasks

Finally, there is a template to be used in numbering tasks and specifying
completion steps for the automated testing system. Place this before
each task. Because task numbering is associated directly with the VM
task tracking function, you must enter each task number manually.

The content of the task template is a block of YAML that scripts
the steps required to complete a task. See the Rakefile for the
code that implements this content.

The YAML content is parsed into a list of steps. A step can either
specify a command to execute and an optional list of inputs to supply
if that command opens a subprocess, or give a filename and the content
for that file.

An excute command will look something like this:

```
{% task 2 %}
---
- execute: "puppet describe user | less"
  input:
    - 'q'
{% endtask %}
```

Note that if you open a subprocess, you must also include an
input that will exit that process. In the example above,
we send the `q` command to exit `less`.

A File command will look like this:

```
{% task 6 %}
---
- file: /etc/puppetlabs/puppet/environments/production/modules/vimrc/manifests/init.pp
  content: |
    class vimrc {
      file { '/root/.vimrc':
        ensure => 'present',
        source => 'puppet:///modules/vimrc/vimrc',
      }
    }
{% endtask %}
```

(NOTE: Though these completion steps are currently included in the corresponding
quest Markdown files, they will likely be split out into separate files in
the future.)

## Jekyll

The Quest Guide is a static website generated from source Markdown and served
by Jekyll.  To view the site, first install the ruby gem Jekyll:
	
	gem install jekyll
	
When Jekyll is successfully installed, you can serve the
website by navigating to the top directory:

	cd /path/to/courseware-lvm/Quest_Guide
	
and entering the command:

	jekyll serve --watch
	
Now open your web browser and point it to:
	
	localhost:4000
	
To build the HTML without launching the development server, use the command:

	jekyll build
	 
## Quest ordering

Quest_Guide/_data/quest_order.yml contains a list of quests with url and
title. The order of quests in this file determines the order that they
will be listed in the website navbar.

Whenever possible, this file should be the single source of quest meta-data.
