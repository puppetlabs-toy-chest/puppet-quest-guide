
# Modules Quest
A Puppet __*module*__ is a collection of class definitions, file, template etc, organized around a particular purpose. In order to enable Puppet to find the class definitions, manifests that allow one to test the class defintions, files that may be required, etc that it may need to configure a machine for a particular purpose, we adhere to a consistent directory structure in which we place class definitions, any files that are needed etc.

## Module Path

All the modules are placed in a special directory specified by the __*modulepath*__.
The modulepath is setting that can be defined in Puppet configuration file. Puppet's configuration file exists in the directory `/etc/puppetlabs/puppet/puppet.conf` on the Learning VM.
You can also find the modulepath by means of the following command:
    puppet agent --configprint modulepath
Try running that command on the Learning Puppet VM now, and confirm that it returns the following value:
`/etc/puppetlabs/puppet/modules:/opt/puppet/share/puppet/modules`
What the above tells us is that Puppet will look in the directories `/etc/puppetlabs/puppet/modules` and then in `/opt/puppet/share/puppet/modules` to find the modules in use on the system.


## Module Structure

<!-- In the future there can be a more advanced quest with understanding module structure -->

A module is a directory.
The module’s name must be the name of the directory.
It contains a manifests directory, which can contain any number of .pp files.
The manifests directory should always contain an init.pp file.
This file must contain a single class definition. The class’s name must be the same as the module’s name.





Modules are directories with a pre-defined structure, with class definitions, files etc in specific sub-directories. 
Inside a module, manifests with class definitions are always placed in a directory called __*manifests*__. A class with the same name as the module is defined in a file called __*init.pp*__.


## Declaring Classes from Modules
Once a class is stored in a module, there are actually several ways to declare or assign it. You should try each of these right now by manually turning off the ntpd service, declaring or assigning the class, and doing a Puppet run in the foreground.

We already saw this: you can declare classes by putting include ntp in your main manifest.

The include function declares a class, if it hasn’t already been declared somewhere else. If a class HAS already been declared, include will notice that and do nothing.

This lets you safely declare a class in several places. If some class depends on something in another class, it can declare that class without worrying whether it’s also being declared in site.pp.

## Tasks

- discuss modulepath
- module structure
- declaring classes from modules `include [resource]`


## Supplemental Information

### Definitions
