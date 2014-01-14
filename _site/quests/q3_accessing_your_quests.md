# Quest #3: Accessing your quests

So Quest #3 is a short one, but very important. You're going to set up a site on your local machine that will access a directory of quests. From here on out, there will be no more PDF documents and you'll access all quests from this local site. We'll walk you through some steps to help you out

## Set the sails!

Type the following command:

	quest three story

<!--You did well Swabbie on your previous quest. You're a quick learner ay. I think you'll be a fine addition to the crew. The Captain sure knows how to pick'em ay. We're about to set the sails and head out to sea. Any final questions before be raise the anchor? Ay, I didn't think so. I hope your ready for some adventure!-->

Type the following command:

	puppet module install puppetlabs/apache

<!--We may need to change the port of the apache config file to access the 'site' on their local 
machine that will house all the quests-->
<!--what about caching this module-->

<!--Once this is installed and running we need to point the VM IP address to the browser-->

Type the following command:

	puppet apply -e bootstrap

<!--installs site on the local machine-->
<!--have .pp constructed and cached-->

Type the following command:

	facter ipaddress
	
Type the IP address into your browser.

<!--We need a plan for updating quests-->
<!--would a package installer be an option?-->
<!--how would we notify the user that there is a new package to be installed?-->