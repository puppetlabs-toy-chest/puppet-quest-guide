{% include '/version.md' %}

# Templates

## Quest objectives

- TBD
- TBD 

## Getting started

In the last quest, you used a `file` resource to manage your cowsay website's
`index.php` file. Often, however, you'll need a more flexible way to manage
a file's contents. This is where **templates** come in. Puppet's templating
language allows you to use variables from your Puppet manifest and language
features such as conditionals and iteration to customize the content of a file.

When you're ready to get started, enter the following command:

    quest begin templates

## Templates

A great many of the tasks involved in system configuration and administration
come down to managing the content of text files. Some of these tasks are
commonly managed by tools that offer a level of abstraction above this level of
the text file. To manage users on a *nix system, for example, you use a command
like `useradd` rather than directly edit the contents of `/etc/passwd` and
`/etc/shadow`. In these cases, Puppet's providers will use these higher-level
commands to interact with the underlying system state.

In many cases, however, editing a text file directly remains the best (or only)
way to configure some component of your system. This means that Puppet needs a
flexible way manage text files.

The most direct way to handle this is through a templating language. A template
is similar to a text file, but offers a syntax for inserting variables as well
as some more advanced language features like conditionals and iteration. This
flexibility lets you manage a wide variety of file formats. 

The main limitation of templates is that they're all-or-nothing. The template
must define the entire file you want to manage. If you need to manage only a
single line or value in a file, you may want to investigate
[Augeas](https://docs.puppet.com/guides/augeas.html),
[concat](https://forge.puppet.com/puppetlabs/concat), or the
[file_line](https://forge.puppet.com/puppetlabs/stdlib#file_line) resource
type.

## Embedded Puppet templating language

Puppet supports two templating languages, [Embedded Puppet
(EPP)](https://docs.puppet.com/puppet/latest/lang_template_epp.html) and
[Embedded Ruby
(ERB)](https://docs.puppet.com/puppet/latest/lang_template_erb.html).

EPP templates were released in Puppet 4 to provide a Puppet-native templating
language that would offer several improvements over the ERB templates that had
been inherited from the Ruby world. Because EPP is now the preferred method,
it's what we'll be using in this quest. Once you understand the basics of
templating, however, you can easily the ERB format by referring to the
documentation.

An EPP template is a plain-text document interspersed with tags that allow
you to customize the content.

Before diving into the details, let's set up a template for the `index.php`
file in your cowsay module so you'll have something concrete to refer to. Right
now, your cow is hard-wired to return the output of the `fortune` command.
We'll use a template to add a little flexibility.

At this point it's worth taking a moment to note that managing the content of a
PHP file is a little unusual for Puppet. In general, it's best to have a clean
separation your application from the Puppet code that deploys it, while any
configuration  In
this case, however, placing 

First, create a `cowsay/templates` directory in your module:

    mkdir cowsay/templates

Now copy your `index.php` to use as a base for your template. Note that you'll
append the `.epp` file extension after `.php` to mark this file as an EPP
template.

    cp cowsay/files/index.php cowsay/templates/index.php.epp

Now open this template file so we can make some changes.

    vim cowsay/manifests/index.php.epp

First, let's replace the string argument passed to the cowsay command with a
variable tag. This will let us customize that value in our Puppet code.

```php
<html>
  <head>
  </head>
  <body>
    <pre>
      <?php
        exec("cowsay $(fortune)", $output);
        echo implode("\n", $output);
      >
    </pre>
  </body>
</html>
```



## Review

TBD
