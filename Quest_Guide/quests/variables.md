---
title: Variables
layout: default
---

# Variables and Variability

>The green reed which bends in the wind is stronger than the mighty oak which breaks in a storm.

> --Confuscius

To start this quest enter the following command:

		quest --start variables

## Variables

What you have learned so far about manifests gives you the means to achieve a great deal. However, you need not travel far down your destined path of Puppet mastery before manifests like the ones you have written thus far will seem stiff and brittle; you will need something more supple, able to shift to meet changing conditions as you travel the roads of Elvium and beyond.

You’ve almost definitely used variables before in some other programming or scripting language, but `$variables` always start with a dollar sign and you assign them with the `=` operator. You can use variables as the value for any resource attribute, or as the title of a resource.

	$longthing = "Really long SSH key"

    file {'authorized_keys':
      path    => '/root/.ssh/authorized_keys',
      content => $longthing,
    }

{% aside What about the `$::variable` %}
People who write manifests to share with the public often adopt the habit of always using the $::variable notation when referring to facts. The double-colon prefix specifies that a given variable should be found at top scope. This isn’t actually necessary, since variable lookup will always reach top scope anyway.
{% endaside %}

Lets make our manifests more adaptable by using variables.

### Tasks

1. To see an example of a variable doing its duty, first navigate to your workshop directory and create a new manifest called `fickle.pp`
	
2.	Enter the following to name and assign a variable:
{% highlight ruby %}
$variable_name = "variable value!\n"
{% endhighlight %}
	Note the `$` symbol at the beginning of the var

## Facts

>Get your facts first, then distort them as you please.

> --Mark Twain

Puppet has a bunch of built-in, pre-assigned variables that you can use. Remember the Puppet tool `facter` when you first started? Just a quick refresher, `facter` discovers system information, normalizes it into a set of variables, and then passes them off to Puppet. Puppet’s compiler accesses those facts when it’s reading a manifest.

Remember running `facter ipaddress`? Puppet told you your IP address without you having to do anything. What if I wanted to turn `facter ipaddress` into a variable? You guessed it. It would look like this `${ipaddress}`

How does this make our manifests more flexible? If I entered the following variables in a manifest:

		file {'motd':
		  ensure  => file,
		  path    => '/etc/motd',
		  mode    => 0644,
		  content => "This Learning Puppet VM's IP address is ${ipaddress}. It is running ${operatingsystem} ${operatingsystemrelease} and Puppet ${puppetversion}.

		Web console login:
		  URL: https://${ipaddress_eth0}
		  User: puppet@example.com
		  Password: learningpuppet
		",
		}

and then applied the manifest, this is what would be returned: 

		file {'motd':
		  ensure  => file,
		  path    => '/etc/motd',
		  mode    => 0644,
		  content => This Learning Puppet VM's IP address is 172.16.52.135. It is running CentOS 5.7 and Puppet 3.0.1.

		Web console login:
		  URL: https://172.16.52.135
		  User: puppet@example.com
		  Password: learningpuppet
		}

It's as simple as that without hardly doing anything on your end. Feeling confident? Lets combine our knowledge of variables and facts in our manifest

### Tasks

1. 

Our manifests are becoming more flexible, with pretty much no real work on our part.