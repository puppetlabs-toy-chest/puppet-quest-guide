{% include '/version.md' %}

# Defined Resource Types

## Quest objectives

- Understand how to manage multiple groups of resources with defined resource
  types.
- Use a defined resource type to easily create home pages for users.

## Getting Started

Classes allow you to group resources together and manage them as a configurable
unit, but a classes in Puppet are **singleton**. This means that a given class
can only be declared once in your node's catalog.

A class is generally intended to manage something like an application or
service that exists only once on your system. In some cases, however, you'll
want to bundle resources together into a group that can be repeated multiple
times within the same node's catalog. It's quite common, for example, to manage
a group of related resources such as SSH keys and configuration files along
with each corresponding user account on a system.

A defined resource type is a block of Puppet code similar in syntax to a class.
It can take parameters and contain a collection of resources along with other
Puppet code such as variables and conditionals to control how those resources
will be defined in a node's catalog. Unlike a class, a defined resource type
is not singleton—it can be declared multiple times on the same node.

In this quest, we'll explore the defined resource type by writing a module to
manage user accounts.

When you're ready to get started, type the following command:

    quest begin defined_resource_types

## Defined resource types

> Repetition - that is the actuality and the earnestness of existence.

> -Søren Kierkegaard

A [defined resource type](https://docs.puppet.com/puppet/latest/lang_defined_types.html)
is a block of Puppet code that can be evaluated multiple times with different
parameters within a single node's catalog. Once it's defined, you can use
a defined resource type in the same way you would any other resource.

The syntax to create a defined resource type is very similar to that you would
use to define a class. Rather than using the `class` keyword, however, you use
`define` to begin the code block.

When creating a defined resource type, keep in mind that resources contained
within it must be differentiated to avoid resource conflicts when the type is
instantiated multiple times. Remember, Puppet uses a resource's **title** to
identify resources internally, and resource's **namevar**, which can be a
different parameter depending on the resource type, to specify a unique aspect
of the system the resource manages. Both the title and namevar must be unique
to avoid resource conflicts. Often, both of these requirements can be addressed
at once by leaving the namevar unset and allowing it to default to the value
of the title.

For example, the following pair of `user` resources leads to an error because
their namevars—in this case, `name`—conflict, though their titles are
different. The second resource's `name` parameter defaults to the value of its
title, `root`, which is the same as the first resource's explicitly set `name`
parameter:

```puppet
user { 'super-user':
  ensure => present,
  name   => 'root',
}

user { 'root':
  ensure => present,
}
```

Similarly, resources with a distinct value for their namevar will still
conflict if the resource title is the same:

```puppet
user { 'admin':
  ensure => present,
  name   => 'wheel',
}

user { 'admin':
  ensure => present,
  name   => 'root',
}
```

These conflicts are easy to spot here, but as you start using variables to set
these values, it can take a little more care to ensure that your resources
remain unique.

To ensure resources contained within your defined resource type are unique, you
can pass the title of defined resource type itself through to be used in the
titles of the resources it contains. This ensures that as long as the you use
when you declare an instance of the defined resource type is unique, all the
resources within it will be unique as well. The defined resource type's title
is automatically available as the `$title` variable within its code block.

Let's get started on our `user_accounts` module to see an example of how this
works.

Begin by creating the directory structure for your module.

    mkdir -p user_accounts/manifests

We'll start with a `user_account.pp` manifest where we'll write our
`ssh_users::user_account` defined resource type.

    vim user_accounts/manifests/ssh_user.pp

We want to manage the user account itself along with the user's public key for
SSH, so we'll expose a few basic parameters for the user resource as well as a
`pub_key` parameter for the user's public key.

```puppet
define user_accounts::ssh_user (
  $key     = undef,
  $group   = undef,
  $shell   = undef,
  $comment = undef,
){
  ...
}
```

Note that we've set the defaults for these parameters to the special value
`undef`. Passing `undef` as the value of a resource parameter is just like
leaving it unset. When we pass these parameters on to the actual `user`
resource within the defined resource type block, it will allow the `user` type
to use its own defaults if the parameters aren't explicitly set.

To handle the `$key` parameter, we'll use a conditional to tell our defined
resource type to skip managing the `ssh_authorized_key` resource for the user's
authorized key if the parameter isn't set. This works because the `undef` value
is evaluated as `false` in a conditional statement.

Now there's just one more tool you need to finish your defined resource type,
one we skimmed over in our earlier discussion of variables. As noted above,
to ensure that all the resources in a defined resource type are unique, you
should incorporate the title of the defined resource type itself into the
titles (and namevars if they're set explicitly) of the resoruces it contains.

Often, however, you'll need to insert this `$title` into a string to create
the full title for a resource. The title for our `ssh_authorized_key` resource, for
example, will look like `"${title}@puppet.vm"`. This is called
[string interpolation](https://docs.puppet.com/puppet/latest/lang_variables.html#interpolation).
Puppet will only interpolate variables inside a double-quoted string (`"..."`).
To avoid ambiguity, the name of a variable (the portion after the `$`) within a
string should be wrapped in curly braces: `${var_name}`.

Now go ahead and finish writing out the rest of your `user_accounts::ssh_user`
defined resource type:

```puppet
define user_accounts::ssh_user (
  $key     = undef,
  $group   = undef,
  $shell   = undef,
  $comment = undef,
){

  if $key {
    ssh_authorized_key { "${title}@puppet.vm"
      ensure => present,
      user   => $title,
      type   => 'ssh-rsa',
      key    => $key,
    }
  }

  user { $title:
    ensure  => present,
    group   => $group,
    shell   => $shell,
    home    => "/home/${title}",
    comment => $comment,
  }

  file { "/home/${title}":
    ensure  => directory,
    owner   => $title,
    group   => $title,
    mode    => '0775',
  }
} 
```

Normally you would ask the users who needed accounts on this system to provide
their own public keys. In this we'll just generate a new key to use as an
example. We'll keep the private half of the key pair in your learning user's
`~/.ssh` directory so you can test these example accounts.

    ssh-keygen -t rsa

Accept the default location and supply the password **puppet**.

With this key set up, we're ready to write the Puppet code to actually declare
which users we want on a system. Rather than put the class that defines these
users into the same `user_accounts` module, we'll follow the same pattern we
used for our database wrapper class and create a `pasture_dev_users` profile
class where we'll actually define the set of users we want to manage on our
systems.

Before creating a `pasture_dev_users.pp` manifest, open the the public key file
you generated and copy it so you'll be able to paste it into your manifest.

    vim ~/.ssh/id_rsa.pub

Copy only the actual key. Don't include the `ssh-rsa` and `learning@puppet.vm`.
Be careful not to include any leading or trailing whitespace.

Now go ahead and open your `pasture_users.pp` manifest.

    vim profile/manifests/pasture_dev_users.pp

Here, we'll create user accounts for Bert and Ernie, the two imaginary friends
who need to access the server:

```puppet
class profile::pasture_dev_users {
  user_accounts::ssh_user { 'bert':
    comment => 'Bert',
    key => '<PASTE KEY HERE>',
  }
  user_accounts::ssh_user { 'ernie':
    comment => 'Ernie',
    key => '<PASTE KEY HERE>',
  }
}
```

Now that this `profile::pasture_dev_users` class is set up, you can easily drop
it into any of your node definitions to add these user accounts and configure
their SSH keys.

Let's add these users to our `pasture-dev.puppet.vm` node.

    vim /etc/puppetlabs/code/environments/production/manifests/site.pp

node 'pasture-dev.puppet.vm' {
  include pasture
  include profile::pasture_dev_users
}

Now use the `pupept job` tool to trigger a Puppet agent run. (If your token
has expired, run the `puppet access login --lifetime 1d` and use the credentials
**learning** and **puppet** to generate a new access token.)

    puppet job run --nodes pasture-dev.puppet.vm

When the Puppet run completes, try connecting to `pasture-dev.puppet.vm` as the
user `bert`.

    ssh bert@pasture-dev.puppet.vm

We're just connecting to check that the SSH key and account works, so go ahead
and disconnect.

    exit

If you've ever managed a site with a large number of user accounts, you might
be wondering how this kind of setup would scale. The example we've given is
enough to demonstrate the use of the defined resource type, but maintaining
different lists of users for each node in your system in this way would quickly
become unwieldy.

## Review

In this quest, we introduced defined resource types, a way to bundle a group of
resource declarations into a repeatable and configurable group.

We covered a few key details you should keep in mind when you're working
on a defined resource type:

  * Defined resource type definitions use similar syntax to class declarations,
    but use the `define` keyword instead of `class`.
  * Use the `$title` variable in constituent resource titles to ensure
    uniqueness.
  * You can use the `undef` value as a default if you want to allow a parameter
    to remain unspecified when the defined type is declared.
