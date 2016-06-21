# Defined Resource Types

## Quest objectives

- Understand how to manage multiple groups of resources with defined resource
  types.
- Use a defined resource type to easily create home pages for users.

## Getting Started

In the quest on parameterized classes, you saw how you can use parameters to
customize a class as it is declared. If you recall that classes, like resources,
can only be realized a single time in a given catalog, you might be wondering
what to do if you want Puppet to repeat the same pattern multiple times, but
with different parameters.

In most cases, the simplest answer is the defined resource type. A defined
resource type is a block of Puppet code that can be declared multiple times with
different parameter values. Once defined, a defined resource type looks and acts
just like the core resource types you're already familiar with.

In this quest, you will create a defined resource type for a `web_user`. This
will let you bundle together the resources you need to create a user along with
their personal web homepage. This way you can handle everything with a single
resource declaration.

When you're ready to get started, type the following command:

    quest begin defined_resource_types

## Defined resource types

> Repetition - that is the actuality and the earnestness of existence.

> -Søren Kierkegaard

While you can do quite a bit with Puppet's core resource types, you're sure to
find sooner or later that you need to do things that don't fit well into
Puppet's existing set of core resource types. In the MySQL quest, you
encountered a few custom resource types that allowed you to configure MySQL
grants, users, and databases. The `puppetlabs-mysql` module includes Ruby code
that defines the behavior of these custom resource *types* and the *providers*
that implement them on a system. 

Writing custom providers, however, is a significant commitment. When you start
writing your own providers, you're taking on responsibility for all the
abstraction Puppet uses to handle the implementation of that resource on diverse
operating systems and configurations. Though this kind of project can be a great
contribution to the Puppet community, it's not generally appropriate for a
one-off solution.

Puppet's **defined resource types** are a lightweight alternative. Though they
don't have the same power to define wholly new functionality, you may be
surprised at how much can be achieved by bundling together Puppet's core
resource types and those provided by existing modules from the community.

<div class = "lvm-task-number"><p>Task 1:</p></div>

To get started, let's create the module structure where we'll put our `web_user` 
module.

Make sure you're in your modules directory:

    cd /etc/puppetlabs/code/environments/production/modules

And create the directories for your new module. We'll call it `web_user`.

    mkdir -p web_user/{manifests,examples}

Before we go into the details of what we're going to do with this module,
though, let's write a simple defined resource type so you can see what the
syntax looks like. For now, we'll create a user and a home directory for that
user. Normally, you could use the `managehome` parameter to tell Puppet to
manage the user's home directory, but we want a little more control over the
permissions of this home directory, so we'll do it ourselves.


<div class = "lvm-task-number"><p>Task 2:</p></div>

Go ahead and create a `user.pp` manifest where we'll define our defined resource
type:

    vim web_user/manifests/user.pp

We'll start simple. Enter the following code in your manifest, paying careful
attention to the syntax and variables.

```puppet
define web_user::user {
  $home_dir = "/home/${title}"
  user { $title:
    ensure => present,
  }
  file { $home_dir:
    ensure  => directory,
    owner   => $title,
    group   => $title,
    mode    => '0775',
  }
} 
```

What did you notice? First, you probably realized that this syntax is nearly
identical to that you would use for a class. The only difference is that you use
the `define` keyword instead of `class`.

Like a class, a **defined resource type** brings together a collection of
resources into a configurable unit. The key difference is that, as we mentioned,
a defined resource type can be realized multiple times on a single system, while
classes are always singleton.

This brings us to the second feature of the code you may have noticed. We use
the `$title` variable in several places, though we haven't explicitly assigned
it! Also notice that this `$title` variable is used in the titles of both the
`user` and `file` resources we're declaring. What's going on here?

<div class = "lvm-task-number"><p>Task 3:</p></div>

To understand the importance of this title variable in a defined resource type,
go ahead and create a test manifest:


    vim web_user/examples/user.pp

Declare a `web_user::user` resource

```puppet
web_user::user { 'shelob': }
```

Here, we assign the title (in this case `shelob`), as we would for any other
resource type. This title is passed through to our defined resource type as the
`$title` variable. You may recall from the Resources quest that the title of a
resource must be unique, as it's the key Puppet uses to refer to a resource
internally.  When you create a defined resource type, you must ensure that all
the included resources are given a title unique to their type. The best way to
do that is to pass the `$title` variable into the title of each resource. Though 
the title of the file resource you declared for your user's home directory is 
set to the `$home_dir` variable, this variable is assigned a string that 
includes the `$title` variable: `"/home/${title}"`

You might also be wondering about the lack of parameters. If a resource or class
has no parameters or has acceptable defaults for all of its parameters, it is
possible to declare it in this brief form without the list of parameter key value
pairs. (You will see this less often in the case of classes, as the idempotent
`include` syntax is almost always preferred.) 

<div class = "lvm-task-number"><p>Task 4:</p></div>

Go ahead and run a `--noop`, then apply your test manifest:

    puppet apply web_user/examples/user.pp

Now take a look at the `/home` directory:

    ls -la /home

You should now see a home directory for `shelob` with the permissions you
specified:

    drwxr-xr-x   4 shelob    shelob    4096 Nov  4 18:20 shelob

### Public HTML homepages

Now that you've seen a simple example of the syntax for a defined resource type,
let's do something a little more useful with it.

We've already configured the Nginx server hosting the Quest Guide to alias any
location beginning with a `~` to a `public_html` directory in the corresponding
user's home directory.

You don't need to understand the details of this configuration for this quest.
That said, the Puppet code we used for this configuration is a real-world
example of a defined resource type, so it's worth taking a quick look. The
defined resource type we used comes from the `jfryman-nginx` module. We
declared it with a few parameters to set up a location that will automatically
deal with our special `~` pages. Don't worry about the scary-looking regular
expression in the title. That's specific to how our Nginx configuration works,
and nothing you need to understand to use defined resource types in general.

```puppet
nginx::resource::location { '~ ^/~(.+?)(/.*)?$':
  vhost          => '_',
  location_alias => '/home/$1/public_html$2',
  autoindex      => true,
}
```

That regular expression in the title (`~ ^/~(.+?)(/.*)?$`) captures any URL path
segment preceded by a `~` as a first capture group, then the remainder of the
URL path as a second capture group. It then maps that first group to to a user's
home directory, and the rest to the contents of that user's `public_html`
directory. So `/~username/index.html` will correspond to
`/home/username/public_html/index.html`.

If you're interested, you can check the `_.conf` file to see how this defined
resource type is translated into a location block in our Nginx configuration
file:

    cat /etc/nginx/sites-enabled/_.conf

<div class = "lvm-task-number"><p>Task 5:</p></div>

So let's see about giving our `web_user::user` resource a `public_html`
directory and a default `index.html` page. We'll need to add a directory and a
file.  Because the parameters for our `public_html` directory will be identical
to those of the home directory, we can use an array to declare both at once.
Note that Puppet's autorequires will take care of the ordering in this case,
ensuring that the home directory is created before the `public_html` directory
it contains. 

We'll set the `replace` parameter for the `index.html` file to `false`.
This means that Puppet will create that file if it doesn't exist, but won't
replace an existing file. This will allow us to create a default page for the
user, but will allow the user to replace that default content without having
it over-written again on the next Puppet run.

Finally, we can use string interpolation to customize the default content of the
user's home page. (Puppet also supports `.erb` and `.epp` style templates, which
would give us a more powerful way to customize a page. We haven't covered
templates, though, so string interpolation will have to do!)

Reopen your manifest:

    vim web_user/manifests/user.pp

And add code to configure your user's `public_html` directory and default
`index.html` file:

```puppet
define web_user::user {
  $home_dir    = "/home/${title}"
  $public_html = "${home_dir}/public_html"
  user { $title:
    ensure     => present,
  }
  file { [$home_dir, $public_html]:
    ensure  => directory,
    owner   => $title,
    group   => $title,
    mode    => '0775',
  }
  file { "${public_html}/index.html":
    ensure  => file,
    owner   => $title,
    group   => $title,
    replace => false,
    content => "<h1>Welcome to ${title}'s home page!</h1>",
    mode    => '0664',
  }
}
```

<div class = "lvm-task-number"><p>Task 6:</p></div>

Use the `puppet parser validate` tool to check your manifest, then run a `--noop`
before applying your test manifest again:

    puppet apply web_user/examples/user.pp

Once the Puppet run completes, take a look at your user's new default
at `<VM'S IP>/~shelob/index.html`.

### Parameters

As it is, your defined resource type doesn't give you any way to specify anything
other than the resource title. Using parameters, we can pass some more information
through to the contained resources to customize them to our liking. Let's
add some parameters that will allow us to set a password for the user
and use some custom content for the default web page.


<div class = "lvm-task-number"><p>Task 7:</p></div>

The syntax for adding parameters to defined resource types is just like that
used for parameterized classes. Within a set of parentheses before the opening
brace of the definition, include a comma separated list of the variables to be
defined by parameters. The `=` operator can optionally be used to assign default
values.

```puppet
  define web_user::user (
    $content  = "<h1>Welcome to ${title}'s home page!</h1>",
    $password = undef,
  ) {
```

There are a couple of details you should be sure to notice here.

First, though we're using the `$title` variable to set the default for content,
we cannot use the value of one parameter to set the default for another.
Binding of these parameters to their values happens in parallel, not
sequentially.  Any assignment that relies on the values of other parameters must
be handled within the body of the defined resource type. The `$title` variable
is assigned prior to the binding of other parameters, so it is an exception.

Second, we've given the `$password` parameter the special value of `undef` as a
default. Any parameter without a default value specified will cause an error if
you declare your defined resource type without specifying a value for that
parameter. If we left the `$password` parameter without a default, you would
always have to specify a password. For the underlying `user` resource type,
however, the `password` parameter is actually optional on Linux systems. By
using the special `undef` value as a default, we can explicitly tell Puppet
to treat that value as undefined, and act as if we simply hadn't included it
in our list of key value pairs for our `user` resource.

Now that you have these parameters set up, go ahead and update the body
of your defined resource type to make use of them.

```puppet
define web_user::user (
  $content  = "<h1>Welcome to ${title}'s home page!</h1>",
  $password = undef,
) {
  $home_dir    = "/home/${title}"
  $public_html = "${home_dir}/public_html"
  user { $title:
    ensure   => present,
    password => $password,
  }
  file { [$home_dir, $public_html]:
    ensure => directory,
    owner  => $title,
    group  => $title,
    mode    => '0775',
  }
  file { "${public_html}/index.html":
    ensure  => file,
    owner   => $title,
    group   => $title,
    replace => false,
    content => $content,
    mode    => '0664',
  }
}
```

<div class = "lvm-task-number"><p>Task 8:</p></div>

Edit your test manifest, and add a new user to try this out:

```puppet
web_user::user { 'shelob': }
web_user::user { 'frodo':
  content  => 'Custom Content!',
  password => pw_hash('sting', 'SHA-512', 'mysalt'),
}
```

Note that we're using the `pw_hash` function to generate a SHA-512
hash from the password 'sting' and salt 'mysalt'.

<div class = "lvm-task-number"><p>Task 9:</p></div>

Once you've made your changes, do a `--noop` run, then apply your test
manifest:

    puppet apply web_user/examples/user.pp

Once the Puppet run completes, check your new user's page at `<VM'S IP>/~frodo/index.html`.

## Review

In this quest, we introduced defined resource types, a lightweight
and repeatable way to bundle a group of resource declarations into a
repeatable and configurable group.

We covered a few key details you should keep in mind when you're working
on a defined resource type:

  * Defined resource type definitions use similar syntax to class declarations,
    but use the `define` keyword instead of `class`.
  * Use the `$title` variable in constituent resource titles to ensure
    uniqueness.
  * A resource with no parameters can be declared in the short `type { 'title': }`
    form.
  * Binding of parameter variables to values happens in parallel, meaning that
    you cannot use the value of one parameter to set another. The exception
    is the `$title` variable.
  * Parameters without a default value are required when you declare a defined
    resource type. However, you can use the `undef` value as a default if you
    want to allow a value to remain unspecified.
