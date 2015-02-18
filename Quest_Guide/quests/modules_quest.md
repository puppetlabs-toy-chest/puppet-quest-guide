---
title: Modules
layout: default
---

# Modules

### Prerequisites

- Welcome
- Power of Puppet
- Resources
- Manifests and Classes

## Quest Objectives
 - Understand the purpose of Puppet modules
 - Learn the module directory structure
 - Write and test a simple module
 
## Getting Started

If you want to get things done effeciently in Puppet, the **module** will be
your best friend. You got a little taste of module structure in the Manifests
and Classes quest. In this quest, we'll take you deeper into the details. 

In short, a Puppet module is a self-contained bundle of all the Puppet code and
other data needed to manage some aspect of your configuration. In this quest,
we'll go over the purpose and structure of Puppet modules, before showing you
how to create your own.

When you're ready, type the following command:

    quest --start modules

## Why Meddle with Modules?

> Creation always builds upon something else. There is no art that doesn't
> reuse.

> -Lawrence Lessig


There's no hard-and-fast technical reason why you can't toss all the resource
declarations for a node into one massive class. But this wouldn't be very
Puppetish. Puppet's not just about bringing your nodes in line with a desired
configuration state; it's about doing this in a way that's transparent,
repeatable, and as painless as possible.

Modules allow you to organize your Puppet code into units that are testable,
reusable, and portable, in short, *modular*. This means that instead of writing
Puppet code from scratch for every configuration you need, you can mix and match
solutions from a few well-written modules. And because these modules are
separate and self-contained, they're much easier to test, maintain, and share
than a collection of one-off solutions.

Though there are some technical aspects to how Puppet treats modules, at their
root they're little more than a conventional directory structure and some naming
standards. The module file structure gives Puppet a consistent way to locate
whatever classes, files, templates, plugins, and binaries are required to
fulfill the function of the module.

Modules and the module directory structure also provide an important way to
manage scope within Puppet. Keeping everything nicely tucked away in its own
module means you have to worry much less about name collisions and confusion.

Finally, because modules are standardized and self-contained, they're easy to
share. Puppet Labs hosts a free service called the
[Forge](https://forge.puppetlabs.com) where you can find a wide array of modules
developed and maintained by others.

## The modulepath
All modules accessible by your Puppet Master are located in the directories
specified by the *modulepath* variable in Puppet's configuration file. On the
Learning VM, this configuration file is `/etc/puppetlabs/puppet/puppet.conf`.

{% task 1 %}
---
- execute: puppet agent --configprint modulepath
{% endtask %}

You can find the modulepath on any system with Puppet installed by running the
`puppet agent` command with the `--configprint` flag and the `modulepath`
argument:

    puppet agent --configprint modulepath

This will tell you that Puppet looks in the directories
`/etc/puppetlabs/puppet/environments/production/modules`,
`/etc/puppetlabs/puppet/modules`, and then in
`/opt/puppet/share/puppet/modules` to find available modules.

Throughout the quests in the Learning VM, you will work in the
`/etc/puppetlabs/puppet/environments/production/modules` directory. This
is where you keep modules for your production environment. (Site specific
modules you need to be available for all environments are kept in
`/etc/puppetlabs/puppet/modules`, and modules required by Puppet Enterprise
itself are kept in the `/opt/puppet/share/puppet/modules` directory.)

## Module Structure
Now that you have an idea of why modules are useful and where they're kept, it's
time to delve a little deeper into the anatomy of a module. 

A module consists of a pre-defined structure of directories that help Puppet
reliably locate the module's contents.

Use the the `puppet module list` command to see what modules are already 
installed. You'll probably recognize some familiar names from previous quests.

To get clear picture of the directory structure of the modules here, you can use
a couple flags with the `tree` command to limit the output to directories, and
limit the depth to two directories.

    tree -L 2 -d /etc/puppetlabs/puppet/environments/production/modules/
	
You'll see a list of directories, like so:

    /etc/puppetlabs/puppet/environments/production/modules/
    └── apache
        ├── files
        ├── lib
        ├── manifests
        ├── spec
        ├── templates
        └── tests
        ...
    	
Each of the standardized subdirectory names you see tells Puppet users and
Puppet itself where to find each of the various components that come together to
make a complete module.

Now that you have an idea of what a module is and what it looks like, you're
ready to make your own. 

You've already had a chance to play with the *user* and *package* resources in
previous quests, so this time we'll focus on the *file* resource type. The
*file* resource type is also a nice example for this quest because Puppet uses
some URI abstraction based on the module structure to locate the sources for
files. 

The module you'll make in this quest will manage some settings for Vim, the text
editor you've been using to write your Puppet code. Because the settings for
services and applications are often set in a configuration file, the *file*
resource type can be very handy for managing these settings.

Change your working directory to the modulepath if you're not already there.

    cd /etc/puppetlabs/puppet/environments/production/modules

{% task 2 %}
---
- execute: mkdir /etc/puppetlabs/puppet/environments/production/modules/vimrc
{% endtask %}

The top directory will be the name you want for the module. In this case, let's
call it "vimrc." Use the `mkdir` command to create your module directory:

    mkdir vimrc

{% task 3 %}
---
- execute: mkdir /etc/puppetlabs/puppet/environments/production/modules/vimrc/{manifests,tests,files}
{% endtask %}

Now you need three more directories, one for manifests, one for tests, and one
for files.

    mkdir vimrc/{manifests,tests,files}

If you use the `tree vimrc` command to take a look at your new module, you
should now see a structure like this:

    vimrc
    ├── files
    ├── manifests
    └── tests
  
    3 directories, 0 files

{% task 4 %}
---
- execute: cp /root/.vimrc /etc/puppetlabs/puppet/environments/production/modules/vimrc/files/vimrc
{% endtask %}

We've already set up the Learning VM with some custom settings for Vim. Instead
of starting from scratch, copy the existing `.vimrc` file into the `files`
directory of your new module. Any file in the `files` directory of a module in
the Puppet master's modulepath will be available to client nodes through
Puppet's built-in fileserver.

    cp ~/.vimrc vimrc/files/vimrc
	
{% task 5 %}
- execute: vim /etc/puppetlabs/puppet/environments/production/modules/vimrc/files/vimrc
  input:
    - G
    - O
    - set number
    - "\e"
    - ":"
    - "wq\r"
{% endtask %}
	
Once you've copied the file, open so you can make an addition.

    vim vimrc/files/vimrc

We'll keep things simple. By default, line numbering is disabled. Add the
following line to the end of the file to tell Vim to turn on line numbering.

    set number
	
Save and exit.

{% task 6 %}
- file: /etc/puppetlabs/puppet/environments/production/modules/vimrc/manifests/init.pp
  content: |
    class vimrc {
      file { '/root/.vimrc':
        ensure => 'present',
        source => 'puppet:///modules/vimrc/vimrc',
      }
    } 
{% endtask %}

Now that your source file is ready, you need to write a manifest to tell puppet
what to do with it.

Remember, the manifest that includes the main class for a module is always
called `init.pp`. Create the `init.pp` manifest in your module's manifests
directory.

    vim vimrc/manifests/init.pp

The Puppet code you put in here will be pretty simple. You need to define a
class `vimrc`, and within it, make a *file* resource declaration to tell Puppet
to take the `vimrc/files/vimrc` file from your module and use Puppet's file
server to push it out to the specified location.

In this case, the `.vimrc` file that defines your Vim settings lives in the
`/root` directory. This is the file you want Puppet to manage, so its full path
(i.e. `/root/.vimrc`) will be the *title* of the file resource you're declaring.

This resource declaration will then need two attribute value pairs. 

First, as with the other resource types you've encountered, `ensure =>
'present',` tells Puppet to ensure that the entity described by the resource
exists on the system. 

Second, the `source` attribute tells Puppet what the managed file should
actually contain. The value for the source attribute should be the URI of the
source file.

All Puppet file server URIs are structured as follows:

    puppet://{server hostname (optional)}/{mount point}/{remainder of path}
	
However, there's some URI abstraction magic built in to Puppet that makes these
URIs more concise.

First, the optional server hostname is nearly always omitted, as it defaults to
the hostname of the Puppet master. Unless you need to specify a file server
other than the Puppet master, your file URIs should begin with a triple forward
slash, like so: `puppet:///`.

Second, nearly all file serving in Puppet is done through modules. Puppet
provides a couple of shortcuts to make accessing files in modules simpler.
First, Puppet treats `modules` as a special mount point that will point to the
Puppet master's modulepath. So the first part of the URI will generally look
like `puppet:///modules/`

Finally, because all files to be served from a module must be kept in the
module's `files` directory, this directory is implicit and is left out of the
URI.

So while the full path to the vimrc source file is
`/etc/puppetlabs/puppet/environments/production/modules/vimrc/files/vimrc`,
Puppet's URI abstraction shortens it to `/modules/vimrc/vimrc`. Combined with
the implicit hostname, then, the attribute value pair for the source URI is:

    source => 'puppet:///modules/vimrc/vimrc',

Putting this all together, your init.pp manifest should contain the following:

{% highlight puppet %}
class vimrc {
  file { '/root/.vimrc':
    ensure => 'present',
    source => 'puppet:///modules/vimrc/vimrc',
  }
}
{% endhighlight %}

Save the manifest, and use the `puppet parser` tool to validate your syntax:

    puppet parser validate vimrc/manifests/init.pp

Remember, this manifest *defines* the `vimrc` class, but you'll need to
*declare* it for it to have an effect. That is, we've described what the `vimrc`
class is, but you haven't told Puppet to actually do anything with it.

{% task 7 %}
- file: /etc/puppetlabs/puppet/environments/production/modules/vimrc/tests/init.pp
  content: include vimrc
{% endtask %}

To test the `vimrc` class, create a manifest called `init.pp`  in the
`vimrc/tests` directory.

    vim vimrc/tests/init.pp

All you'll do here is *declare* the `vimrc` class with the `include` directive.

{% highlight puppet %}
include vimrc
{% endhighlight %}

{% task 8 %}
- execute: puppet apply /etc/puppetlabs/puppet/environments/production/modules/vimrc/tests/init.pp
{% endtask %}

Apply the new manifest with the `--noop` flag. If everything looks good, drop
the `--noop` and apply it for real.

You'll see something like the following:

    Notice: /Stage[main]/Vimrc/File[/root/.vimrc]/content: content changed
    '{md5}99430edcb284f9e83f4de1faa7ab85c8' to
    '{md5}f685bf9bc0c197f148f06704373dfbe5'
	
When you tell Puppet to manage a file, it compares the md5 hash of the target
file against that of the specified source file to check if any changes need to
be made. Because the hashes did not match, Puppet knew that the target file did
not match the desired state, and changed it to match the source file you had
specified.

To see that your line numbering settings have been applied, open a file with
Vim. You should see the number of each line listed to the left.

## Review

In this quest, you learned about the structure and purpose of Puppet modules.
You created a module directory structure, and wrote the class you need to manage
a configuration file for Vim. You also saw how Puppet uses md5 hashes to
determine whether a target file matches the specified source file. 

In the quests that follow, you'll learn more about installing and deploying
pre-made modules from the Puppet Forge.
