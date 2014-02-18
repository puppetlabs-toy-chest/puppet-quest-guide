
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

Once a class is stored in a module, there are actually several ways to declare it. You've already seen this, but you can declare classes by putting `include [class name]` in your main manifest.

The `include` function declares a class, if it hasn’t already been declared somewhere else. If a class _**has**_ already been declared, `include` will notice that and do nothing.

This lets you safely declare a class in several places. If some class depends on something in another class, it can declare that class without worrying whether it’s also being declared in `site.pp`.

## Tasks

1. Find your `modulepath` and then ensure your are working in that directory.

2. Create your manifests directory by typing the following command:

		mkdir -p users/manifests

3. Now, we're going to want to edit the manifest. Type the following command:

		nano users/manifest/init.pp

4. Do you remember the `user` resource and the anatomy of how a resource is constructed? Using that knowledge can you make sure that user como is present in the user class.

5. Next, check to make sure the syntax you entered is correct using `puppet parser`.

6. Lets now make a test directory in the same modulepath. Type the following command:

		mkdir users/tests

7. Like we did before, we are going to want to edit the manifest in the test directory: Type the following command:

		nano users/tests/init.pp

8. We are going to take advantage of the `include` function now. Type the following information into the manifest:

		include users

9. Next, check to make sure the syntax you entered is correct using `puppet parser`.

10. Oh shoot! We forgot to add the staff `group` to user como. Can you quickly run back into the manifest and make sure the staff `group` is present. Don't forgot to add `/bin/bash` as the shell and `gid => 'staff',` for user como as well.

11. Sorry about that, check again to make sure the syntax you entered is correct using `puppet parser`.

12. We're not ready to execute this manifest just yet. We want to test run it first. Do you remember in the Manifests Quests when we discussed how to do that? Go ahead and apply the manifest in the test directory in `--noop` mode.

13. Great! Everything is running how it should be. Now finish this off by enforcing your class on the local system.

You just created your first puppet module!! The two important things to note here are:
1.  Puppet's DSL, by virtue of its __declarative__ nature, makes it possible for us to define the attributes of the resouces, without the need to concern ourselves with _how_ the definition is enforced. Puppet uses the Resource Abstraction Layer to abstract away the complexity surrounding the specific commands to be executed, and the operating system-specific tools used to realize our definition! You did not need to know or specify the command to create a new unix user group to create the group `staff`, for example.
2. By creating a class called users, it is now possible for us to automate the process of creating the users we need on any system with Puppet installed on it, by simply including that class on that system. Class definitions are reusable!
