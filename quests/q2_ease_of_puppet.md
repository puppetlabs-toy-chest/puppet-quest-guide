# Quest #2: The Ease of Puppet

Puppet is truly  wonderful tool for managing small or huge sums of nodes in a simple and effective way. In this quest we are going to see the true value of using Puppet and Puppet tools such as the Puppet Forge and Puppet Enterprise Console.

## Welcome aboard Swabbie!
Type the following command:

<!--task 1-->

	quest two story

<!--Okay Swabbie, ready to see the power and ease of using Puppet. We're not going to give you access just yet to Polly. We want to show you some things first on how Puppet simplifies our tasks and makes life a whole lot easier on the open seas. You see, Puppet isn't just a tool, it's an infrastructure that adpats to an ever changing environment...like the ocean ay. Just to get your feet wet a little, before I send you to mop the decks, we're going to have you install a fully functioning wordpress blog using puppet. This should only take you a few minutes Swabbie but is an excellent example on the ease and power of using Puppet. So let's get started!-->

To accomplish this feet we need to install certain modules to get everything up and running. Type each of these commands individually into the terminal:

<!--task 2-->
<!--task 3-->
<!--task 4-->

	puppet module install puppetlabs/mysql
	puppet module install puppetlabs/apache
	puppet module install hunner/wordpress

Ay, wonderful. You see, you just downloaded three Puppet Forge modules from your own terminal, just by typing the <code>puppet module install</code> command. I'm sure we'll make a stop or two at the Forge during our journey, but this was just a simple introduction to it.

Listen here Swabbie, we now need your IP address. I'm going to introduce you to another Puppet tool called Facter. Facter essentailly is a tool that allows you to pull certain facts, such as in this case, your IP address. Type the following command:

<!--task 5-->

	facter ipaddress

I don't have such a good memory after all these years so I would need to write this down. Depending on your memory this your choice but you will need this. 


### Navigating the Puppet Enterprise Console
<strong>STEP #1:</strong> Okay, open up your browser window and type the following into the URL: https://[your ip address]

<strong>STEP #2:</strong> Next you'll need a username and password. Don't worry, I've already set this up for you.
<!--task 6-->
<strong>Username: puppet@example.com</strong><br>
<strong>Password: learningpuppet</strong>

Say hello to the Puppet Enterprise Console. This is an amazing tool that helps us manage everything in a simple dashboard. We have already taken the liberty to set up a class for you called "wpblog" which you will have to associate with this (what is the correct terminology).

<strong>STEP #3:</strong> Can you find the 'Classes' window along the left side of the screen? Your going to want to click the "Add Class"" button <!--task 7-->

<strong>STEP #4:</strong> Next, in the 'Class Name' area, type "wpblog". This is adding the class to the Puppet Enterprise Console so you can associate it with the modules you first installed. Don't worry about typing anything into the description field.Click the "Create" button. <!--task 8-->

<strong>STEP #5:</strong> Next, in the upper left corner of the screen, click the "Nodes" button in the main menu bar. Then go ahead and click on 'learn.localdomain' near the center of the screen. Click the "Edit" button in the upper right corner of the screen. <!--task 9-->

<strong>STEP #6:</strong> In the classes section start typing 'wpblog'. Ahh, you see how it came up on its own. That's because we added the class earlier to the Console. Go ahead and finish spelling it out or hit 'Enter' on your keyboard. Click the 'Update' button. <!--task 10-->

### Back to the terminal

You know what Swabbie, your not half bad at using the Puppet Enterprise Console for your first time. You're now going to want to head back to your terminal.

In your terminal run the following command to test for the Puppet Agent. This is key because this is what is what talks with the Puppet Enterprise Console.

<!--task 11-->

	puppet agent -t

You should see a bunch of green text. That's a good sign everything worked out correctly for you. Now, run the following command to now apply everything you've just done to your local machine.

<!--task 12-->

	puppet apply wpblog/tests/init.pp


So lets check out your Wordpress blog. Go to this [URL]


## That's awesome, but how does it all work?

<!--I need to relate the above example to the material below. You should have enough info to start building the quest-->

Before we dig any deeper into this thought, you need to gain a high leveling of understanding how systems are configured with Puppet. Each of the concepts described below are explained in greater detail in future quests, but we would like to introduce you to these concepts now. 

Let us now examine the structure of the above quest your just completed. This is just an example but the same logic applies everywhere within Puppet.

Puppet sees systems as collections of __Resources__. _A resource is a unit of configuration, whose state can be managed by Puppet_. Resource types include _file_, _package_, _service_, _user_, _group_ etc.

Your goal with managing systems with Puppet, is using Puppet's DSL to describe all the resources you want to manage. This may seem like a daunting task, considering all the different types of resources, but in reality, we use the principle of modularity to describe larger and larger building blocks.

Grouping a set of resources together gives you a __class__. _A class is a collection of related resources, which, once defined, can be declared as a single unit_. For example, a class could contain all of the elements (files, settings, modules, scripts, etc) needed to configure a specific technology on a host - such as an Apache webserver, or a Postfix mailserver, or a certain application.

Essentially, when you think of managing systems with Puppet, you are looking to create classes that configure certain technologies for you, and then assigning the right combination of classes to each system to configure the system appropriately. You need only define each class once, and you re-use the definitions repeatedly, as needed, to configure all of the systems you manage.

The machines do not all have to be configured exactly the same way. Puppet's DSL provides for describing conditional logic, and this, in combination with a list of __facts__ that are available for each of the systems, provides you with the means to customize configurations for individual machines.

In subsequent sections, we will learn about each of the concepts and terms presented above in greater detail.


### Ready to start [Quest #3](docs.puppetlabs.com/learning) 