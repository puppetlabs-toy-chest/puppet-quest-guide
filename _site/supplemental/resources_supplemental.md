## Supplemental Information 

* **Resource** - A unit of configuration, whose state can be managed by Puppet. Every resource has a type (such as file, service, or user), a title, and one or more attributes with specified values (for example, an ensure attribute with a value of present). Resources can be large or small, simple or complex, and they do not always directly map to simple details on the client – they might sometimes involve spreading information across multiple files, or even involve modifying devices. For example, a service resource only models a single service, but may involve executing an init script, running an external command to check its status, and modifying the system’s run level configuration.
* **Resource Type** - 
* **Resource Declaration** - A fragment of Puppet code that details the desired state of a resource and instructs Puppet to manage it. This term helps to differentiate between the literal resource on disk and the specification for how to manage that resource. However, most often, these are just referred to as “resources.”
* **Title** - The unique identifier of a resource or class. In a resource declaration, the title is the part after the first curly brace and before the colon. a resource’s title need not map to any actual attribute of the target system; it is only a referent. This means you can give a resource a single title even if its name has to vary across different kinds of system, like a configuration file whose location differs on Solaris.
* **Attribute** - Attributes are used to specify the state desired for a given configuration resource. Each resource type has a slightly different set of possible attributes, and each attribute has its own set of possible values. For example, a package resource would have an `ensure` attribute, whose value could be `present`, `latest`, `absent`, or a version number.
* **Value** - The value of an attribute is specified with the `=>` operator; attribute/value pairs are separated by commas.


Not all resource types are equally common or useful, so weʼve made a printable cheat sheet that explains the eight most useful types. [Download the core types cheat sheet here](http://docs.puppetlabs.com/puppet_core_types_cheatsheet.pdf)

The [type reference page ](http://docs.puppetlabs.com/references/latest/type.html)lists all of Puppetʼs built-in resource types, 	in 	extreme detail. It can be a bit overwhelming for a new user, but 	it 	has most of the info youʼll need in a normal day of writing Puppet code. 
