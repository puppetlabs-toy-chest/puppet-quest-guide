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

## PDF Generation

The pdf_make.py script will automatically generate the PDF files that are bundled with the Learning VM download.

The script uses PrinceXML to generate PDFs, so you must have Prince installed (http://www.princexml.com/download/) for it to function. Note that you must register your copy of Prince in order to generate PDFs without a watermark.

The script also has three library dependencies outside of the Python standard libraries:

* html5lib
* BeautifulSoup
* Markdown

These can be installed using either pip or easy_install, e.g.

	easy_install BeautifulSoup

Once the dependencies are installed, navigate to the top directory of the repository, and use the arguments `--setup` or `-s` and/or `--quest` or `-q` to specify which PDFs you would like to generate, e.g.:
	
	python pdf_maker.py -s -q
	 