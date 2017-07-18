{% include '/version.md' %}

# Class parameters

## Quest objectives

- Understand the value of writing configurable classes.
- Learn the syntax for creating a *parameterized class.*
- Learn how to use the *resource-like* class declaration syntax to set the
  parameters for a class.

## Getting started

In the last quest, you used variables to introduce some flexibility to your
`pasture` module. So far, however, all of the variables are assigned within the
class itself.

A well-written module in Puppet should let you customize all its 
important variables without editing the module itself. This is done with
*class parameters*. Writing parameters into a class allows you to declare
that class with a set of parameter-value pairs similar to the resource
declaration syntax. This gives you a way to customize all the important
variables in your class without making any changes to the module that defines
it. 

When you're ready to get started, enter the following command:

    quest begin class_parameters

## Writing a parameterized class

A class's parameters are defined as a comma-separated list of parameter name
and default value pairs (`$parameter_name = default_value,`). These parameter
value pairs are enclosed in parentheses (`(...)`) between the class name and
the opening curly bracket (`{`) that begins the body of the class. For
readability, multiple parameters should be listed one per line, for example:

```puppet
class class_name (
  $parameter_one = default_value_one,
  $parameter_two = default_value_two,
){
 ...
}
```

Notice that this list of parameters must be comma-separated, while variables
set within the body of the class itself are not. This is because the Puppet
parser treats these parameters as a list, while variable assignments in the
body of your class are individual statements. These parameters are available as
variables within the body of the class.

<div class = "lvm-task-number"><p>Task 1:</p></div>

To get started, let's modify the main `pasture` class to use class parameters.
Open your `init.pp` manifest.

    vim pasture/manifests/init.pp

Your parameter list will replace the variables assignments you used in the
previous quest. By setting the parameter defaults to the same values you had
assigned to those variables, you can maintain the same default behavior for the
class.

Remove the variables set at the beginning of your class and add a corresponding
set of parameters. When you're done, your class should look like the following
example.

```puppet
class pasture (
  $port                = '80',
  $default_character   = 'sheep',
  $default_message     = '',
  $pasture_config_file = '/etc/pasture_config.yaml',
){

  package {'pasture':
    ensure   => present,
    provider => 'gem',
    before   => File[$pasture_config_file],
  }

  $pasture_config_hash = {
    'port'              => $port,
    'default_character' => $default_character,
    'default_message'   => $default_message,
  }

  file { $pasture_config_file:
    content => epp('pasture/pasture_config.yaml.epp', $pasture_config_hash),
    notify  => Service['pasture'],
  }

  $pasture_service_hash = {
    'pasture_config_file' => $pasture_config_file,
  }

  file { '/etc/systemd/system/pasture.service':
    content => epp('pasture/pasture.service.epp', $pasture_service_hash),
    notify  => Service['pasture'],
  }

  service { 'pasture':
    ensure    => running,
  }

}
```

When you're done making these changes, save and exit your file. Use the
`puppet parser` tool to check your syntax.

    puppet parser validate pasture/manifests/init.pp

## Resource-like class declarations

Now that your class has parameters, let's see how these parameters are set.

Until now, you've been using `include` to declare the class as part of your
node classification in the `site.pp` manifest. This `include` function declares
a class without explicitly setting any parameters, allowing any parameters in
the class to use their default values. Any parameters without defaults take the
special `undef` value.

To declare a class with specific parameters, use the *resource-like class
declaration*. As the name suggests, the syntax for a resource-like class
declaration is very similar to a resource declaration. It consists of the
keyword `class` followed by a set of curly braces (`{...}`) containing the
class name with a colon (`:`) and a list of parameters and values. Any values
left out in this declaration are set to the defaults defined within the class,
or `undef` if no default is set.

```puppet
class { 'class_name':
  parameter_one => value_one,
  parameter_two => value_two,
}
```

Unlike the `include` function, which can be used for the same class in multiple
places, resource-like class declarations can only be used once per class.
Because a class declared with the `include` uses defaults, it will always be
parsed into the same set of resources in your catalog. This means that Puppet
can safely handle multiple `include` calls for the same class. Because 
multiple resource-like class declarations are not guaranteed to lead to the same
set of resources, Puppet has no unambiguous way to handle multiple
resource-like declarations of the same class. Attempting to make multiple
resource-like declarations of the same class will cause the Puppet parser to
throw an error.

Though we won't go into detail here, you should know that external data-sources
like `facter` and `hiera` can give you a lot of flexibility in your classes
even with the include syntax. For now, you should be aware that though the
`include` function uses defaults, there are ways to make those defaults very
intelligent.

<div class = "lvm-task-number"><p>Task 2:</p></div>

Now let's go ahead and use a resource-like class declaration to customize the
`pasture` class from the `site.pp` manifest. Most of the defaults will still
work well, but for the sake of this example, let's set this instance of our
Pasture application to use the classic cow character instead of the sheep we
had set as the parameter default.

Open your `site.pp` manifest.

    vim /etc/puppetlabs/code/environments/production/manifests/site.pp

And modify your node definition for `pasture.puppet.vm` to include a
resource-like class declartion. We'll set the `default_character` parameter
to the string `'cow'`, and leave the other two parameters unset, letting them
take their default values.

```puppet
node 'pasture.puppet.vm' {
  class { 'pasture':
    default_character => 'cow',
  }
}
```

Notice that with your class parameters set up, all the necessary configuration
for all the components of the Pasture application can be handled with a single
resource-like class declaration. The diverse commands and file formats that
would ordinarily be involved in managing this application are reduced to this
single set of parameters and values.

<div class = "lvm-task-number"><p>Task 3:</p></div>

Let's connect to the `pasture.puppet.vm` node.

    ssh learning@pasture.puppet.vm

And trigger a Puppet agent run to apply this parameterized class.

    sudo puppet agent -t

When the run is complete, return to the master.

    exit

And check that your configuration changes have taken effect.

    curl 'pasture.puppet.vm/api/v1/cowsay?message=Hello!'

## Review

In this quest, we introduced *class parameters*, a way to customize a class
as it's declared. These parameters let you set up a single interface for you
to customize any aspect of the system your Puppet module manages.

We also revisited the `include` function and covered the *resource-like class
declaration*, the syntax for specifying values for a class's parameters as they
are declared.

In the next quest, we'll introduce *facts*, which can be used to easily
introduce data about your agent system into your Puppet code.

## Additional Resources

* Check out our [docs page on classes](https://docs.puppet.com/puppet/latest/lang_classes.html) for more information.
* If you're interested in more advanced methods for adding data to your classes, you might want to read about [using modules with Hiera](https://docs.puppet.com/puppet/latest/hiera_migrate_modules.html).
