# Quest #2: The Ease of Puppet

Puppet is truly  wonderful tool for managing small or huge sums of nodes in a simple and effective way. In this quest we are going to see the true value of using Puppet and Puppet tools such as the Puppet Forge and Puppet Enterprise Console.


## Managing Systems with Puppet

Before we dig any deeper into this quest, you need to gain a high leveling of understanding how systems are configured with Puppet. Each of the concepts described below are explained in greater detail in future quests, but would like to introduce you to these concepts now. 

Puppet sees systems as collections of __Resources__. _A resource is a unit of configuration, whose state can be managed by Puppet_. Resource types include _file_, _package_, _service_, _user_, _group_ etc.

Your goal with managing systems with Puppet, is using Puppet's DSL to describe all the resources you want to manage. This may seem like a daunting task, considering all the different types of resources, but in reality, we use the principle of modularity to describe larger and larger building blocks.

Grouping a set of resources together gives you a __class__. _A class is a collection of related resources, which, once defined, can be declared as a single unit_. For example, a class could contain all of the elements (files, settings, modules, scripts, etc) needed to configure a specific technology on a host - such as an Apache webserver, or a Postfix mailserver, or a certain application.

Essentially, when you think of managing systems with Puppet, you are looking to create classes that configure certain technologies for you, and then assigning the right combination of classes to each system to configure the system appropriately. You need only define each class once, and you re-use the definitions repeatedly, as needed, to configure all of the systems you manage.

The machines do not all have to be configured exactly the same way. Puppet's DSL provides for describing conditional logic, and this, in combination with a list of __facts__ that are available for each of the systems, provides you with the means to customize configurations for individual machines.

In subsequent sections, we will learn about each of the concepts and terms presented above in greater detail.

## Welcome Aboard Swabbie!
Type the following command:


	quest two story

