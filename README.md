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

