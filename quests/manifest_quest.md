---
title: Manifests
layout: default
---

# Manifest Quest

In this quest you will gain a better understanding of resource declarations, the resource abstraction layer and using puppet apply for applying manifests.

## What you should already know

- Puppet Resource Quest

## Resource Delarations

To us, **resource declarations** are the purpose describing what we do here on Elvium. They give us a purpose in this systemic life of processes and functions. Everything in Elvium, to their core, is comprised of a **manifest**. These manfiests contain our personalized puppet code for completing tasks and making sure our world continues to run as an efficient machine. Manifests are files containing code written in Puppet's DSL, with the filename extension ".pp". These describe how you want various resources to be configured for a system.

## Abstracting away complexity

As you trek around Elvium you will notice that _attributes_ for the resources will change, along with their values, depending on the [operating system region of Elvium] you are in. It is important for you to focus on the _type_ of resource you encounter.

Remember, at the core of everything in [name of fantast world] is a puppet manifest. Puppet code abstracts away the complexity of managing resources of various types by leveraging different __providers__ to realize the resource on the various operating systems. The implementation of how resources are realized on various operating systems might differ, the tools that provide these implementations on various operating systems are the __providers__ for the resource type.

Puppet has a __Resource Abstraction Layer__ (RAL) that consists of resource types and providers, and Puppet automatically translates your description of how you want the various resources you manage to be configured to the appropriate platform-specific commands required to realize your description.

### Tasks

1. Remember, you can use `puppet describe user` and `puppet resource user` for help using and understanding the user resource.
2. To establish the manifest you're going to want to place it in your earth version's home directory (`/root`)

		cd /root

3. So now we're ready to start writing are first manifest to manage the Earth verison of yourself on Elvium. First we are going to create you in the system. Enter the following command 

		nano user.pp

4. Type the follow task into the manifest:

		user { 'earthname':
		  ensure => 'present',
		}

5. Save the file as `user.pp`

## Puppet Parser

`puppet parser` is like Puppet's version of spellcheck. This action validates Puppet's DSL syntax without compiling a catalog or syncing any resources. If no manifest files are provided, Puppet will validate the default site manifest. If there are no syntax errors, Puppet will return nothing, otherwise Puppet will display the first syntax error encountered. 

### Tasks

1. Enter the following command in the command line:

		puppet parser validate user.pp

## Puppet Apply

This is a very handy tool for learning to write code in Puppet's DSL and is a standalone puppet execution tool. However, in reality, you'll probably use this tool to describe the configurations of an entire system in a single file. This description will be constructed as a list of all resources you want to manage on your system, but as you can imagine, that might end up being a _really_ long file! You will see how this can be a more manageable process when you come across **Classes** during your journey.

### Tasks

1. Try the following command to learn more about the `puppet apply`

		puppet help apply

2. Simulate the change in the system without actually enforcing the `user.pp` manifest

		puppet apply --noop user.pp

3. Using `puppet apply` apply the simulate manifest `user.pp`

		puppet apply user.pp

4. See if your earth version exists

		puppet resource user earthname

You will see that puppet does, indeed create a user called `earthname`!

## Supplemental Information 

### Definitions

* **Resource declaration** - A fragment of Puppet code that details the desired state of a resource and instructs Puppet to manage it. This term helps to differentiate between the literal resource on disk and the specification for how to manage that resource. However, most often, these are just referred to as “resources.”
* **Manifest** - A file containing code written in the Puppet language, and named with the `.pp` file extension. Most manifests are contained in modules. Every manifest in a module should define a single class or defined type. The Puppet code in a manifest can be any of the following:
	*  Declare resources and classes
	*  Set variables
	*  Evaluate functions
	*  Define classes, defined types, and nodes
* **Providers** - platform-specific implementations for the different types
* **Attributes** - Attributes are used to specify the state desired for a given configuration resource. Each resource type has a slightly different set of possible attributes, and each attribute has its own set of possible values. For example, a package resource would have an `ensure` attribute, whose value could be `present`, `latest`, `absent`, or a version number.
* **Resource type** -   High-level models of differnt kinds of resources

### Puppet Apply Usage

- `-d` or `--debug`: Enable full debugging.
- `--detailed-exitcodes`: Provide transaction information via exit codes.
- `-h` or `--help`: Print this help message
- `--loadclasses`: Load any stored classes.
- `-l` or `--logdest`: Where to send messages.
- `--noop`: Viewing changes before executing them.
- `-e` or `--execute`: Execute a specific piece of Puppet code
- `-v` or `--verbose`: Print extra information.
- `--catalog`: Apply a JSON catalog.
- `--write-catalog-summary`: After compiling the catalog saves the resource list and classes list to the node in the state directory named classes.txt and resources.txt

### Cheat Sheet

Not all resource types are equally common or useful, so weʼve made a printable cheat sheet that explains the eight most useful types. [Download the core types cheat sheet here](http://docs.puppetlabs.com/puppet_core_types_cheatsheet.pdf)

The [type reference page ](http://docs.puppetlabs.com/references/latest/type.html)lists all of Puppetʼs built-in resource types, 	in 	extreme detail. It can be a bit overwhelming for a new user, but 	it 	has most of the info youʼll need in a normal day of writing Puppet code.
