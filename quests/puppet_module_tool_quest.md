
# Puppet Module Tool Quest

Create, install and search for modules on the Puppet Forge. The `puppet module` tool is a command that can do all that and more from the command line. The Puppet Forge is a repository of user-contributed Puppet code and can also generate empty modules and prepare locally developed modules for release on the Forge.

## Actions

- `list` - List installed modules.
- `search` - Search the Puppet Forge for a module.
- `install` - Install a module from the Puppet Forge or a release archive.
- `upgrade` - Upgrade a puppet module.
- `uninstall` - Uninstall a puppet module.
- `build` - Build a module release package.
- `changes` - Show modified files of an installed module.
- `generate` - Generate boilerplate for a new module.

## Tasks

Using the `puppet module` tool

1. Let's see what modules are already installed and where they're located. To do this, we want Puppet to show us in a tree format. Go ahead and type the following command: 

		puppet module list -tree

2. Wow! you have a lot installed. That's great. But it seems like your missing the [module name] module. You should search the Puppet Forge for the module. Type the following command:

		puppet module search [something]

3. There's something on the Forge that exists! Let use it. Let's install module one version earlier than present. Run the following command:

	NOTE: normally I would have you install the latest version, but now I can show you how to update an existing module in the next step

		puppet module install [something] --version

4. Okay, now go ahead and upgrade earlier module version to present version

		puppet module upgrade [something]

5. You don't have to, but if you would like you can uninstall module you just installed by running the below command. If you do choose to uninstall the module, you can always reinstall it later.

		puppet module uninstall [something]