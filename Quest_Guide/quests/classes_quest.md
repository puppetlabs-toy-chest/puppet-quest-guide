---
title: Classes
layout: default
---

# Classes

### Prerequisites

- Welcome Quest
- Power of Puppet Quest
- Resources Quest
- Mainfest Quest

## Quest Objectives

So we've mentioned the term classes in previous quests. Remember that little blurb regarding enforcing a collection of resource declarations across an entire system with a single file? That collection of resources is called a **class**. In this quest we cover the use of classes within a Puppet manifest to group resource declarations into reusable blocks of Puppet code. When you're ready to get started, type the following command:

    quest --start classes

{% aside This is just an example %}
We've written this quest to help you learn the functionality and purpose of classes. To keep things simple, we will write code to both define classes and include them within a single manifest. Keep in mind, however, that in practice you will always define your classes in a separate manifest. In the Modules Quest we will show you the proper way define classes and declare classes separately.
{% endaside %}

## Defining Classes

In the Power of Puppet Quest, we used a class called `lvmguide` to help us set up the website version of this Quest Guide. This class gives us a nice illustration of the structure of a class definition. We won't be creating or editing a manifest just yet, but we've included the code from the `lvmguide` class declaration below below for easy reference as we talk about defining classes. 

There are a few more advanced concepts at work in this example, so don't worry if a few things remain unclear at this point. For now, we're going to focus primarily on how class definitions work and we will circle back to some of the other topics in later quests.

{% highlight puppet %}
class lvmguide (  $document_root = '/var/www/html/lvmguide',  $port = '80',){  class { 'apache':    default_vhost => false,  }  apache::vhost { 'learning.puppetlabs.vm':    port    => $port,    docroot => $document_root,  }
  file { '/var/www/html/lvmguide':    ensure  => directory,    owner   => $::apache::params::user,    group   => $::apache::params::group,    source  => 'puppet:///modules/lvmguide/html', recurse => true,    require => Class['apache'],  }
}{% endhighlight %}

In this example we've **defined** a class called `lvmguide`. The first line of the class definition begins with the word class, followed by the name of the class we're defining: in this case, `lvmguide`.

{% highlight puppet %}
class lvmguide (
{% endhighlight %}

Notice that instead of the usual curly bracket, there is an open parenthesis at the end of this first line, and it isn't until after the closing paranthesis that we see the opening curly bracket.

{% highlight puppet %}
class lvmguide (  $document_root = '/var/www/html/lvmguide',  $port = '80',){
{% endhighlight %}

The variable declarations contained in these parentheses are called class **parameters**.

Class parameters allow you to pass a set of variables to a class. In this case, we are setting `$document_root` and `$port` parameters. The values assigned to these parameters in the class definition are the **default values**, which will be used whenever the parameters are not explicitly set.

We will address parameterized classes further in a later quest, so don't be alarmed if the concept is still a touch unclear at this point.

The first item you see inside the curly braces is... another class! One of the advantages of keeping your classes modular is that you can easily pull together all the classes you need to achieve a particular purpose.

{% highlight puppet %}
  class { 'apache':    default_vhost => false,  }{% endhighlight %}
In this case, we wanted to set up an apache server to host our Quest Guide content as a website. Instead of trying to reinvent the wheel, as it were, we are able to pull in the existing `apache` class from the `apache` module we downloaded from the Puppet Forge.If we had wanted to include the `apache` class with its default parameter settings, we could have used the `include apache` syntax. Because we wanted to set the `default_vhost` parameter, however, we used the resource-like class declaration syntax. This allows us to set class parameters: in this case, `default_vhost`.

Our final two code blocks in the class definition are resource declarations:

{% highlight puppet %}
  apache::vhost { 'learning.puppetlabs.vm':    port    => $port,    docroot => $document_root,  }
  file { '/var/www/html/lvmguide':    ensure  => directory,    owner   => $::apache::params::user,    group   => $::apache::params::group,    source  => 'puppet:///modules/lvmguide/html',    recurse => true,    require => Class['apache'],  }{% endhighlight %}

First, we declare a `vhost` resource type, and pass along values from our class parameters to its `port` and `docroot` attributes.

As in the above example, class definitions give you a consice way to group other classes and resource declarations into re-usable chunks according to a function that those elements will help us achieve. You can then selectively assign these classes to different machines across your Puppetized network in order to easily configure those machines to fulfill the defined function. Now that the `lvmguide` class is defined, enabling the Quest Guide website on other machines would be as easy as assigning that class in the PE Console.

{% task 1 %}
Now that we've seen an example, let's dive in. First, just as we enforced manifests in the Manifest Quest, let's see what happens when we enforce a manifest in the `ntp` module.

	puppet apply /root/examples/modules1-ntp1.pp

That's funny. Nothing happened. This is because the class in the `modules1-ntp1.pp` manifest is only being defined and not declared. Declared? What's that? We will discuss that in the section below.

{% task 2 %}
We are going to have to modify the `modules1-ntp1.pp` manifest a little to make sure Puppet applies the defined resources. Type the following command to edit the ntp manifest:

	nano /root/examples/modules1-ntp1.pp

{% aside Text Editors %}
Remember, for the sake of simplicity and consistency, we use the text editor nano in our instructions, but feel free to use vim or another text editor of your choice.
{% endaside %}

## Declaring Classes

In the previous section, we saw an example of a class definition and learned that a class is a collection of resources. The question that still needs answering is, how can we use the class definition? How can we tell Puppet to use the definition as part of configuring a system?

You can direct Puppet to apply a class definition on a system by using the `include` directive. We already know that Puppet manifests are files with the extension `.pp` and contain code in Puppet's DSL. In addition to Puppet's DSL, the `include` directive is already built into the Puppet infrastructure so you can use class(es) in any manifest.

But when you say `include lvmguide`, how does Puppet know where to find the class definition? When you start working with Modules in the Modules Quest, you will see that Puppet Manifests can be placed in a directory structure that allows Puppet organize your classes in a systematic way.

Again, a more real life use case would applying the ntp module across your system.

{% task 3 %}
In the `modules1-ntp1.pp` manifest go ahead and add the `include ntp` directive at the very end. Make sure it is outside of the curly braces. This will tell Puppet to apply the defined `ntp` resource.

{% task 4 %}
Go ahead and now enforce the manifest `/root/examples/modules1-ntp1.pp`.

	HINT: Use the puppet apply tool. Refer to the Manifests Quest.

Great! This time Puppet actually applied our defined ntp resource. Always remember to define first, then declare.

Again, please do not ever do this above example in real life, since you may want to include classes across multiple nodes. This is just an example to show you the functionality and benefit of classes. In the Modules Quest we will show you the proper way define classes and declare classes separately.

