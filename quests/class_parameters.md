{% include '/version.md' %}

# Class Parameters

## Quest objectives

- TBD

## Getting started

In the last quest, you used variables and parameters to introduce some
flexibility to your `pasture` module. So far, however, all of the variables
are assigned within the class itself.

A well-written module in Puppet should let customize all its important
important variables without editing the module itself. This is achieved through
**class parameters** which allow the class itself to be declared with a list
of parameters and values. 

When you're ready to get started, enter the following command:

    quest begin class_parameters

## Writing a parameterized class

A class parameter is a way to pass external data into a class. Once a class
parameter is set, its value is available within the class as a variable.

A comma-separated list of parameters can be added to a class enclosed in
parentheses (`(...)`) between the class name and the opening curly bracket
(`{`) that begins the body of the class. Multiple parameters will generally
be listed one per line, for example:

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
body of your class are individual statements.

Let's modify the main `pasture` class to use class parameters. Open your
`init.pp` manifest:

    vim pasture/manifests/init.pp

Your parameters will have the same names and values as the variable assignments
already set in the body of the class. With values assigned to these variables
set by your parameters, you will no longer need the variable assignments in the
body of the class. Move those lines up and reformat them to be parameters for
your class.

```puppet
class pasture (
  $port              = '80',
  $default_character = 'sheep',
  $default_message   = '',
  $config_file       = '/etc/pasture_config.yaml',
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
    ensure    => running.
  }

}
```

When you're done making these changes, save and exit your file, then use the
`puppet parser` tool to check your syntax.

    puppet parser validate pasture/manifests/init.pp

## Resource-like class declarations

Now that your class has parameters, we can go over how these can be set as the
class is declared.

Until now, you've been using `include` to declare the class as part of your
node classification in the `site.pp` manifest. This `include` function declares a
class without explicitly setting any parameters, allowing any parameters in the
class to use their default values.

To set class parameters, you need to use a **resource-like class declaration**.
As the name suggests, the syntax for a resource-like class declaration is very
similar to a resource declaration. It consists of the keyword `class` followed
by a set of curly braces (`{...}`) containing the class name with a colon (`:`)
with a list of parameters and values. Any values left out in this declaration
are set to the defaults defined within the class.

Unlike the `include` function, which can be used for the same class in multiple
places, resource-like class declarations can only be used once per class.
Because a class declared with the `include` uses defaults, it will always be
parsed into the same set of resources in your catalog. This means that Puppet
can safely ignore any additional instances of `include` for a class because it
knows that they would specify the same set of resources. Because a
resource-like class declaration isn't guaranteed to lead to the same set of
resources, Puppet can't safely ignore a second resource-like declaration of the
same class. If there were any differences between the two classes caused by
different parameters, it would have no way of resolving those conflicts.

Though we won't go into detail here, you should know that external data-sources
like `facter` and `hiera` can give you a lot of flexibility in your classes
even if with the include syntax. For now, you should be aware that though the
`include` function uses defaults, there are ways to make those defaults very
intelligent.

Now let's go ahead and use a resource-like class declaration to customize
the `pasture` class parameters from the `site.pp` manifest. We've been playing
with the defaults for cowsay's `character` option to let you see the changes,
but it is **cow**say after all, so we'll use the `default_character` parameter
to get back to the basics.

Open your `site.pp` manifest:

    vim /etc/puppetlabs/code/environments/production/manifests/site.pp

And modify your node definition for `pasture.puppet.vm` to include a
resource-like class declartion. We'll set the `default_character` parameter
to the string `'cow'`, and leave the other two parameters unset, letting them
take their default values.

```puppet
node pasture.puppet.vm {
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

Let's connect to the `pasture.puppet.vm` node.

    ssh learning@pasture.puppet.vm

And trigger a Puppet agent run to apply this parameterized class.

    puppet agent -t

When the run is complete, return to the master.

    exit

And check that your configuration changes have taken effect:

    curl 'pasture.puppet.vm:4567?string=Hello!'

## Review

TBD
