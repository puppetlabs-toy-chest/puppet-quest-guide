{% include '/version.md' %}

# Defined resource types

## Quest objectives

- Manage a group of resources with a *defined resource type*.
- Understand the difference between a defined resource type and class.
- Learn how to handle the uniqueness constraints of resources contained within
  a defined resource type.
- Use a defined resource type to manage user accounts and ssh keys.

## Getting started

In this quest, you'll create a module to help manage user accounts and their
SSH keys. For each user, you'll manage the user account itself, the
user's ssh key, and the user's home directory. If you only wanted to manage
this set of resources for a single user, you could create a class. However,
you're more likely to manage multiple resources for multiple users who
need access to a system. In this case, a class will not be sufficient. Classes
in Puppet are *singleton*, which means they can only be declared once within
a node's catalog.

Instead, you will use a *defined resource type*. A defined resource type is a
block of Puppet code similar in syntax to a class. It can take parameters and
contain a collection of resources along with other Puppet code such as
variables and conditionals to control how those resources will be defined in a
node's catalog. Unlike a class, a defined resource type is not singleton—it can
be declared multiple times on the same node.

When you're ready to get started, type the following command:

    quest begin defined_resource_types

## Defined resource types

> Repetition - that is the actuality and the earnestness of existence.

> -Søren Kierkegaard

A [defined resource
type](https://docs.puppet.com/puppet/latest/lang_defined_types.html) is a block
of Puppet code that can be evaluated multiple times within a single node's
catalog.

The syntax to create a defined resource type is very similar to the syntax you
would use to define a class. Rather than using the `class` keyword, however,
you use `define` to begin the code block.

```puppet
define defined_type_name (
  parameter_one = default_value,
  parameter_two = default_value,
){
  ...
}
```

Once it's defined, you can use a defined resource type in the same way you
would any other resource.

```puppet
defined_type_name { 'title':
  parameter_one => 'foo',
  parameter_two => 'bar',
}
```

Because a defined resource type is not singleton, it's up to you to ensure that
none of the resources it contains violate resource uniqueness constraints when
the defined resource type is declared multiple times.

Each resource must have a unique *title* and *namevar*. Recall that a
resource's title is a unique identifier for that resource within Puppet, while
the namevar specifies a unique aspect of the system that the resource will
manage. 

So how do you guarantee that these resources are unique? Within the block
of code that defines your defined resource, you get a "free" `$title`. This
`$title` variable is set to the title of your defined resource instance when
you declare it. By incorporating this `$title` variable into the titles of each
resource included in the defined resource type, you can ensure that as long as
the defined resource type itself has a unique title, the resources it includes
will be unique as well.

Let's get started on our `user_accounts` module to see an example of how this
works. Like a class, a defined resource type should be defined within a module.
In many cases, a defined resource type can be included in a module to support
the functionality provided by that module's class or classes. For example, the
`postgresql` module you used in the previous quest provides defined resource
types to help manage things like databases, users, and grants. In this case,
however, we'll create a standalone module for our defined resource type.

<div class = "lvm-task-number"><p>Task 1:</p></div>

Begin by creating the module's directory structure.

    mkdir -p user_accounts/manifests

<div class = "lvm-task-number"><p>Task 2:</p></div>

We'll start with a `ssh_user.pp` manifest where we'll write an
`user_accounts::ssh_user` defined resource type.

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
to use its own defaults.

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

Add `ssh_authorized_key`, `user`, and `file` resources to the body of the
defined type.

```puppet
define user_accounts::ssh_user (
  $key     = undef,
  $group   = undef,
  $shell   = undef,
  $comment = undef,
){

  if $key {
    ssh_authorized_key { "${title}@puppet.vm":
      ensure => present,
      user   => $title,
      type   => 'ssh-rsa',
      key    => $key,
    }
  }

  user { $title:
    ensure  => present,
    groups  => $group,
    shell   => $shell,
    home    => "/home/${title}",
    comment => $comment,
  }

  file { "/home/${title}":
    ensure => directory,
    owner  => $title,
    group  => $title,
    mode   => '0755',
  }

  file { "/home/${title}/.ssh":
    ensure => directory,
    owner  => $title,
    group  => $title,
    mode   => '0700',
    before => Ssh_authorized_key["${title}@puppet.vm"],
  }
}
```

<div class = "lvm-task-number"><p>Task 3:</p></div>

Normally you would ask the users who needed accounts on this system to provide
their own public keys. For the sake of demonstration we'll generate our own
key. The private half of the key pair will stay in your learning user's
`~/.ssh` directory so you can test these example accounts.

    ssh-keygen -t rsa

Accept the default location and supply the password *puppet*.

With this key set up, you're ready to write the Puppet code to actually declare
which users we want on a system. Rather than place this directly in your
`site.pp` manifest, you'll create a `pasture_dev_users` profile class where you
will use your defined resource type to specify the set of users you want to
manage on a system. 

Before creating the manifest where you will define this class, open the
public key file you generated and copy the contents so you'll be able to paste
it into your manifest.

    vim ~/.ssh/id_rsa.pub

Copy only the actual key. Don't include the `ssh-rsa` and `root@learning.puppet.vm`.
Be careful not to include any leading or trailing whitespace. Depending on how
line-breaks appear in your console, you may have to manually delete newline
characters or whitespace after you paste in this key.

<div class = "lvm-task-number"><p>Task 4:</p></div>

Now create a `dev_users.pp` profile manifest.

    vim profile/manifests/pasture/dev_users.pp

Here, we'll create user accounts for Bert and Ernie, the two imaginary
colleagues who need to access the server.

```puppet
class profile::pasture::dev_users {
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

<div class = "lvm-task-number"><p>Task 5:</p></div>

Now that this `profile::pasture::dev_users` class is set up, you can easily
drop it into the `role::pasture_app` class to add these user accounts and
configure their SSH keys.

    vim /etc/puppetlabs/code/environments/production/modules/role/manifests/pasture_app.pp

```puppet
class role::pasture_app {
  include profile::pasture::app
  include profile::pasture::dev_users
  include profile::base::motd
}
```

<div class = "lvm-task-number"><p>Task 6:</p></div>

Use the `puppet job` tool to trigger a Puppet agent run. (If your token has
expired, run the `puppet access login --lifetime 1d` and use the credentials
**learning** and **puppet** to generate a new access token.)

    puppet job run --nodes pasture-app-small.puppet.vm

When the Puppet run completes, connect to `pasture-app-small.puppet.vm` as the
user `bert`.

    ssh bert@pasture-app-small.puppet.vm

Once you've verified that the you can connect as this user, go ahead and
disconnect.

    exit

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

## Additional Resources

* Read more about defined resource types at our [docs page](https://docs.puppet.com/puppet/latest/lang_defined_types.html).
* Defined resource types are covered in our Puppet Fundamentals, Puppet Practitioner, and Puppetizing Infrastructure courses. Explore our [in-person](https://learn.puppet.com/category/instructor-led-training) and [online](https://learn.puppet.com/category/online-instructor-led-training) training options for more information.
