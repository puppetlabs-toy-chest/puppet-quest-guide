{% include '/version.md' %}

# Defined resource types

## Quest objectives

- Manage a group of resources with a *defined resource type*.
- Understand the difference between a defined resource type and class.
- Learn how to handle the uniqueness constraints of resources contained within
  a defined resource type.
- Use a defined resource type to manage user accounts and ssh keys.

## Getting started

As we noted in discussions of classes earlier in this guide, Puppet's classes
are *singleton*. In other words, classes in the Puppet language can only exist
once within a given catalog, and writing Puppet code that declares a class
twice will result in a compilation error. For many system components, there is
a natural fit between this idea of a singleton class and a single instance or
installation of the class's managed component on the node. For example, an
Apache server will generally run only a single instance of an `httpd` service
and have one set of configuration files. In this case, Puppet's singleton
classes ensure that you don't have multiple conflicting specifications for how
a corresponding component should be configured.

In some cases, however, this one-to-one correspondence doesn't hold. A single
Apache `httpd` process may serve multiple virtual hosts, for example. In this
quest, we'll focus on a simple example: user accounts. While Puppet has a
built-in `user` resource type, a system administrator will often need to manage
a whole range of other resources on a per-user basis. For this quest, we'll go
through the exercise of setting up SSH keys for each user account, but the same
principle can easily be extended to cover a range of other user-related
resources.

To address this need, of repeatable groups of resources, the Puppet language
uses *defined resource types*. A defined resource type is a block of Puppet
code similar in syntax to a class. Like a class, a defined resource type can
take parameters and use these parameters to configure a related group of
resources. Unlike a class, however, a defined resource type, is not singleton.
This means that the defined resource type may be declared multiple times on the
same node.

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

Once it's defined, you can use a defined resource type by declaring it like
you would any other resource type.

```puppet
defined_type_name { 'title':
  parameter_one => 'foo',
  parameter_two => 'bar',
}
```

Because a defined resource type is not singleton, it's up to you as a module
developer to ensure that none of the resources it contains violate resource
uniqueness constraints when the defined resource type is declared multiple
times.

Before continuing, let's take a moment to review those constraints. To avoid
duplicate resource errors during compilation, all resource must have a *title*
and *namevar* parameter that are unique with respect to resources of the same
type.

## Resource uniqueness constraints

A resource's *title* is the unique identifier Puppet user internally to keep
track of that resource. Resource relationships, for example, rely on resource
titles to specify dependency relationships between resources. Resource titles
are also used to log and report on resource state changes across Puppet runs.

A resource's *namevar* is the parameter that specifies the unique aspect on the
target system that the resource manages. A resource doesn't actually have a
parameter called *namevar*—rather the term namevar refers to the parameter that
plays this role. For example, the namevar of a `file` resource is its `path`
parameter. By requiring that a resource has a unique namevar, the Puppet parser
avoids creating conflicting definitions for the state of a single aspect of the
target system. If Puppet allowed two `file` resource declarations with the same
`path` parameter, for example, it would not be clear which of the two resource
declarations should be enforced for the file at that path.

Though a resource's title and namevar are distinct, the value you would assign
to a resource's namevar is generally an excellent cadidate for an expressive
and unique title. For example, if the `path` of a file resource is
`/etc/hosts`, using that path as the resource title makes it immediately clear
what the the resource is managing. The common convention, then, is to use the
value of a resource's namevar as its title. To support this convention, a
resource's namevar default to the value of its title unless it is explicitly
set to a different value. This is why, for instance, you generally see the
filepath or package name used the title of `file` and `package` resources, and
the `path` or `name` parameter left unset.

## Maintaining uniqueness in defined resource types

Now that you understand resource uniqueness constraints, how do you guarantee
that the resources included in a defined resource type are unique?

Just as you would give include a title in the declaration of any of Puppet's
built-in resource types, you include a title when declaring a defined resource
type. The title given to a defined resource type when it is declared is
available within the defined resource type's code block as the `$title`
variable. By incorporating this `$title` variable into the titles of each
resource included in the defined resource type, you can ensure that as long as
the defined resource type itself is declared with a unique title, the resources
it includes are also unique.

## Managing user accounts

To see how this all fits together, let's get started on a `ssh_user` defined
resource type.

Like a class, a defined resource type should be defined within a module. In
many cases, a defined resource type is be included in a module to support the
functionality provided by that module's class or classes. For example, the
`postgresql` module you used in the previous quest provides defined resource
types to help manage the groups of related resources that come together to
manage aspects of your database configuration such as databases, users, and
grants. In this case, however, we want to keep things simple, so we'll create a
standalone module to contain our defined resource type.

<div class = "lvm-task-number"><p>Task 1:</p></div>

Before you begin, make sure you're working in your module directory.

    cd /etc/puppetlabs/code/environments/production/modules

Create the `user_accounts` module's directory structure.

    mkdir -p user_accounts/manifests

<div class = "lvm-task-number"><p>Task 2:</p></div>

Next, create a `ssh_user.pp` manifest to contain the `user_accounts::ssh_user`
defined resource type.

    vim user_accounts/manifests/ssh_user.pp

We want to manage the user account itself along with the user's public key for
SSH, so we'll expose a few basic parameters for the user resource as well as a
`pub_key` parameter for the user's public key.

The parameter list for your defined type should look like this:

```puppet
define user_accounts::ssh_user (
  $key,
  $group   = undef,
  $shell   = undef,
  $comment = undef,
){
  ...
}
```

Note that the `$pub_key` parameter has no default value, while the default
values for the other parameters are set to 'undef'. There is an important
difference here.

A parameter with no supplied default value is required. Leaving out a default
value for the `$pub_key` parameter means that declaring an instance of this
`ssh_user` defined resource type without supplying a value for the `$pub_key`
parameter will result in a compilation error. Because this resource requires
a user's public key in order to correctly provide SSH access with public key
authentication, this is the desired behavior.

```puppet
  ssh_authorized_key { "${title}@puppet.vm":
    ensure => present,
    user   => $title,
    type   => 'ssh-rsa',
    key    => $key,
  }
```

The `group`, `shell`, and `comment` parameters, on the other hand, are not
required. The `ssh_user` defined resource type, includes an ordinary `user`
resource to actual user account on the system.

```puppet
  user { $title:
    ensure  => present,
    groups  => $group,
    shell   => $shell,
    home    => "/home/${title}",
    comment => $comment,
  }
```

This `user` resource already has its own defaults for handling `group`,
`shell`, and `comment`. The desired behavior, then, is to use the values passed
in by parameter when they're provided, but revert to the `user` type's own
defaults for any of these parameters that isn't supplied when the defined
resource type is declared.

The special `undef` value lets you achieve both of these things. Under the hood
`undef` is exactly what Puppet sees when it tries to evaluate a variable or
parameter that has not been set. By setting it as the default for your optional
parameters, you can literally pass the "undefined" state of a parameter through
to the underlying `user` resource, which will then fall back to its default
behavior for that parameter.

Putting these `user` and `ssh_authorized_key` resources together with `file`
resources to manage the user's home directory and `.ssh` directory, your
`user_accounts::ssh_user` defined resource type will look like this:

```puppet
define user_accounts::ssh_user (
  $key,
  $group   = undef,
  $shell   = undef,
  $comment = undef,
){
  ssh_authorized_key { "${title}@puppet.vm":
    ensure => present,
    user   => $title,
    type   => 'ssh-rsa',
    key    => $pub,
  }
  file { "/home/${title}/.ssh":
    ensure => directory,
    owner  => $title,
    group  => $title,
    mode   => '0700',
    before => Ssh_authorized_key["${title}@puppet.vm"],
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
}
```

## String interpolation

You may have noticed another new element of syntax into this code. Some of the
double-quoted strings (`"..."`) in this manifest include variables in the
`${var_name}` format. This is Puppet's [string
interpolation](https://docs.puppet.com/puppet/latest/lang_variables.html#interpolation)
syntax. String interpolation allows you to insert a variable into any
double-quoted string.

String interpolation is useful throughout Puppet, but it is particularly
salient in the context of defined resource types because it allows you to
incorporate the `$title` variable of the defined resource type itself into the
titles of its constituent resources.  The title of the `ssh_authorized_key`
resource, for example, looks like `"${title}@puppet.vm"`.

Why is this so important? Remember, all resources included in the body of a
defined resource type must still meet the same uniqueness constraints of any
other Puppet resource. By passing the unique given to the defined resource type
itself through to each constituent resource, whether directly, as in the case
of the `user` resource, or indirectly through string interpolation, you can
guarantee the uniqueness of all the resources included within the defined
resource type.

<div class = "lvm-task-number"><p>Task 3:</p></div>

Normally you would ask the users who needed accounts on this system to provide
their own public keys. For the sake of demonstration, however, you'll generate
one key pair to use with all the users you're going to manage. This will allow
you to log in as those users and validate that the defined resource type has
worked as expected.

Use the `ssh-keygen` command to create a new keypair:

    ssh-keygen -t rsa

Accept the default location and supply the password *puppet*.

With this key created, you're ready to write the Puppet code to actually
declare which users we want on a system.

<div class = "lvm-task-number"><p>Task 4:</p></div>

Rather than place this directly in your `site.pp` manifest, as you might have
before we introduced the roles and profiles pattern, we'll create a
`pasture_dev_users` profile class, and use a Hiera lookup to programatically
create users as needed on each system in your infrastructure.

In this case, we'll include our user accounts on all nodes in the `beauvine.vm`
domain, so we'll be editing the `domain/beauvine.vm.yaml` Hiera data source at
`/etc/puppetlabs/code/environments/production/data/domain/beauvine.vm.yaml`.

Assuming you're still working in your modules directory, go up one level to
`/etc/puppetlabs/code/environments/production/` to make it easier to access
this `data` directory.

    cd ..

Before you open the data file to edit, save some effort by using the bash `>>`
append operator to append it to your `id_rsa.pub` public key to the end of the
data file.

    cat ~/.ssh/id_rsa.pub >> data/domain/beauvine.vm.yaml

Now open the file:

    vim data/domain/beauvine.vm.yaml

Create a new line to define a Hiera value for
`profile::base::dev_users::users:`. Here, we'll take advantage of
Hiera's structured data features to define two instances of the new `ssh_user`
and set the parameters for each. For now, just focus on entering this data
correctly into your YAML data file. You'll see a little later how this
structured data is actually implemented by a Puppet manifest.

The final content of the file is given below, but managing the big `pub_key`
block may be a little awkward, especially if you're not used to Vim. (If you
are comfortable with Vim, feel free to skip this paragraph) First,
you'll need to trim the "ssh-rsa" and "root@learning.puppetlabs.vm" strings
from the beginning and end of the key. First, position your cursor over the
line with the key. Be sure you're in command mode by hitting the `ESC` key.
From command mode, you can navigate easily to the beginning or end of the line
with the `^` and `$` keys, respectively. Once your cursor is over the `ssh-rsa`
or `root@learning.puppetlabs.vm` string, you can delete it from command mode
with the command `daW`. You'll use the same key from both users, so you'll also
need to copy it. You can copy a line with the command `yy` and paste it to the
position of your cursor with the `p` key.  You can also delete a line with the
`dd` command.

When your finished, your data file should look like the following example,
though your public key will be different from the one shown. Note that the
`pub_key:` must all be on a single line.

```yaml
---
profile::pasture::app::default_message: "Welcome to Beauvine!"
profile::base::dev_users::users:
  - title: 'bessie'
    comment: 'Bessie Johnson'
    pub_key: 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCVWbkvtB4G/x9eEHXUkFfQgJuxBNJ3MCJ
3BWbYHb+Ksmd2I92G9wSVFWRDvLzciOsWkbjfSWHrql+82lgplyxBHZZYlf0eK3ytkSL5hvQtOmLW
MDcWNbHnt7qZFA0j6/h43SG0POmkG1iHSHnlwvbcpJoYZZpKz5+Iq7P9JmOv7zf8UsJtQccWHxAHc
J+xJ6xZJ2EBziWUCMPxLnD3zNQaW0r/B3pRMT+7F1gDHJ8HuNVklcQGCpVS+WrfpNMJ5+L25Aw/H2
Bg33o+0esH5FL8M8IR3Xkgp80NAQqmyVi7cx+c9n4RjEdMGk3XtutPNsSLcgm8/YZqv/yTRH6wAQl
/'
  - title: 'gertie'
    comment: 'Gertie Philips'
    pub_key: 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCVWbkvtB4G/x9eEHXUkFfQgJuxBNJ3MCJ
3BWbYHb+Ksmd2I92G9wSVFWRDvLzciOsWkbjfSWHrql+82lgplyxBHZZYlf0eK3ytkSL5hvQtOmLW
MDcWNbHnt7qZFA0j6/h43SG0POmkG1iHSHnlwvbcpJoYZZpKz5+Iq7P9JmOv7zf8UsJtQccWHxAHc
J+xJ6xZJ2EBziWUCMPxLnD3zNQaW0r/B3pRMT+7F1gDHJ8HuNVklcQGCpVS+WrfpNMJ5+L25Aw/H2
Bg33o+0esH5FL8M8IR3Xkgp80NAQqmyVi7cx+c9n4RjEdMGk3XtutPNsSLcgm8/YZqv/yTRH6wAQl
/'
```

You can use a Ruby one-liner to validate that your YAML file can be parsed
correctly.

    ruby -e "require 'yaml';require 'pp';pp YAML.load_file('./data/domain/beauvine.vm.yaml')"

The output should look like the following:

```json
{"profile::pasture::app::default_message"=>"Welcome to Beauvine!",
 "profile::base::dev_users::users"=>
  [{"title"=>"bessie",
    "comment"=>"Bessie Johnson",
    "pub_key"=>
     "AAAAB3NzaC1yc2EAAAADAQABAAABAQCVWbkvtB4G/x9eEHXUkFfQgJuxBNJ3MCJ3BWbYHb+
Ksmd2I92G9wSVFWRDvLzciOsWkbjfSWHrql+82lgplyxBHZZYlf0eK3ytkSL5hvQtOmLWMDcWNbHn
t7qZFA0j6/h43SG0POmkG1iHSHnlwvbcpJoYZZpKz5+Iq7P9JmOv7zf8UsJtQccWHxAHcJ+xJ6xZJ
2EBziWUCMPxLnD3zNQaW0r/B3pRMT+7F1gDHJ8HuNVklcQGCpVS+WrfpNMJ5+L25Aw/H2Bg33o+0e
sH5FL8M8IR3Xkgp80NAQqmyVi7cx+c9n4RjEdMGk3XtutPNsSLcgm8/YZqv/yTRH6wAQl/"},
   {"title"=>"gertie",
    "comment"=>"Gertie Philips",
    "pub_key"=>
     "AAAAB3NzaC1yc2EAAAADAQABAAABAQCVWbkvtB4G/x9eEHXUkFfQgJuxBNJ3MCJ3BWbYHb+
Ksmd2I92G9wSVFWRDvLzciOsWkbjfSWHrql+82lgplyxBHZZYlf0eK3ytkSL5hvQtOmLWMDcWNbHn
t7qZFA0j6/h43SG0POmkG1iHSHnlwvbcpJoYZZpKz5+Iq7P9JmOv7zf8UsJtQccWHxAHcJ+xJ6xZJ
2EBziWUCMPxLnD3zNQaW0r/B3pRMT+7F1gDHJ8HuNVklcQGCpVS+WrfpNMJ5+L25Aw/H2Bg33o+0e
sH5FL8M8IR3Xkgp80NAQqmyVi7cx+c9n4RjEdMGk3XtutPNsSLcgm8/YZqv/yTRH6wAQl/"}]}
```

We'll also change the `common.yaml` data source to set a default for this key.
In this case, we'll set the value to an empty list. This way, when Hiera tries
to look up this value on a node outside of the `beauvine.vm` domain, it will
still get a valid result.

    vim data/common.yaml

Your `common.yaml` file should look like the following:

```yaml
---
profile::pasture::app::default_message: "Baa"
profile::pasture::app::sinatra_server: "thin"
profile::pasture::app::default_character: "sheep"
profile::pasture::app::db: "none"
profile::base::dev_users::users: []
```

<div class = "lvm-task-number"><p>Task 5:</p></div>

Now that this data is available in Hiera, create a `dev_users.pp` manifest
in `profile/manifests/base/`.

    vim profile/manifests/base/dev_users.pp

Your `user_accounts::ssh_user` defined resource type gives you a way to create
a new user account with an SSH key from a set of parameter inputs, and your
Hiera data file defines the list of inputs for each user, but we still haven't
addressed how to bring this data together with your code.

Here, we'll use a Puppet language feature called an
[iterator](https://puppet.com/docs/puppet/latest/lang_iteration.html). An
iterator allows you to repeat a block of Puppet code multiple times, using
data from a hash or array to bind different values to the variables in
the block for each iteration. In this case, the iterator goes through a
list of users accounts defined in your Hiera data source and declares an
instance of the `user_accoutns::ssh_user` defined resource type for each.

```puppet
class profile::base::dev_users {
  lookup(profile::base::dev_users::users).each |$user| {
    user_accounts::ssh_user { $user['title']:
        comment => $user['comment'],
        key => $user['pub_key'],
    }
  }
}
```

When using iteration, be very mindful of your code's readability and
maintainability. One of the Puppet language's benefits is that its declarative
nature tends to make Puppet code itself readible description of desired state
for your system. Used unnecessarily, iteration can increase your Puppet code's
complexity, making it more difficult to understand and maintain.

In this case, the roles and profiles pattern, Hiera, and the defined resource
type keep the rest of the code simple enough that the iterator's role is very
clear. With a basic understanding of Puppet syntax, you can easily translate
the class into a sentence along the lines of "Get the list of users from Hiera,
and for each, create an SSH user account." If you find yourself writing
iterators that go much beyond this level of complexity, it's a good cue to stop
and consider whether there's a clearer way to write your Puppet code.

<div class = "lvm-task-number"><p>Task 6:</p></div>

With this `profile::base::dev_users` class is set up, add it to the
`role::pasture_app` class.

    vim /etc/puppetlabs/code/environments/production/modules/role/manifests/pasture_app.pp

```puppet
class role::pasture_app {
  include profile::pasture::app
  include profile::base::dev_users
  include profile::base::motd
}
```

<div class = "lvm-task-number"><p>Task 7:</p></div>

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
