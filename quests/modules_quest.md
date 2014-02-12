
# Modules Quest

A Puppet **module** is a collection of resources, definitions, files, templates, etc, organized around a particular purpose. In order to enable Puppet to find these class definitions, manifests allow one to test the class defintions that it may need to configure a machine for a particular purpose. We adhere to a consistent directory structure in which we place class definitions and any other files that are needed etc.

## Module Path

All the modules are placed in a special directory specified by the **modulepath**. The modulepath is setting that can be defined in Puppet configuration file. Puppet's configuration file exists in the directory `/etc/puppetlabs/puppet/puppet.conf` in Elvium.
You can also find the modulepath with the following command:
    puppet agent --configprint modulepath
What the returned value tells us is that Puppet will look in the directories `/etc/puppetlabs/puppet/modules` and then in `/opt/puppet/share/puppet/modules` to find the modules in use on the system.

## Module Structure

<!-- In the future there can be a more advanced quest with understanding module structure -->

A module is a directory with a pre-defined structure, with class definitions, files etc in specific sub-directories. The module’s name must be the same name of the directory. Inside a module there must be a manifests directory, which can contain any number of `.pp` files but must contain the `init.pp` file. The `init.pp` file must contain a single class definition and must be the same as the module’s name.

## Declaring Classes from Modules

Once a class is stored in a module, there are actually several ways to declare it. You've already seen this, but you can declare classes by putting `include [resource]` in your main manifest.

The `include` function declares a class, if it hasn’t already been declared somewhere else. If a class _**has**_ already been declared, `include` will notice that and do nothing.

This lets you safely declare a class in several places. If some class depends on something in another class, it can declare that class without worrying whether it’s also being declared in `site.pp`.

## Tasks

1. Find your `modulepath` and then ensure your are working in that directory.

2. Create your manifests directory by typing the following command:

		mkdir -p users/manifests

3. 




## Supplemental Information

### Definitions

* **Module** - 
* **Module Path** - 
* 