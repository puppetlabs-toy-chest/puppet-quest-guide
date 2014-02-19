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