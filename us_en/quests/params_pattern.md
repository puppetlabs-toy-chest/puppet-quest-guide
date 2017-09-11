## The params.pp Pattern

While conditionals allow you to set intelligent defaults for your module's
variables, you will generally want to preserve the ability to set these values
directly through class parameters. Remember, class parameters and their
defaults are set within a set of parentheses just after the class title. The
parameters for the Pasture class, for example, look like the following:

```puppet
class pasture (
  $pasture_port        = '80',
  $environment         = 'production',
  $default_character   = 'sheep',
  $default_message     = '',
  $config_file         = '/etc/pasture_config.yaml',
){
 ...
}
```

Though it would be possible to pack a one-liner conditional into this parameter
block, anything more complex quickly becomes unwieldly or impossible.

A common solution is to create a separate `params.pp` class where the all the
default values for class parameters are calculated and assigned to variables.
These variables are then used to set parameter defaults in the main class's
parameter block. This `params.pp` pattern allows you to use complex conditional
logic to determine defaults, while maintining the simple parameter interface
for your main class.

We'll start by creating a `params.pp` manifest to contain the `pasture::params`
class.

    vim pasture/manifests/params.pp

Exactly how you want these parameters to be set will depend on how you intend
the module to be used. A module intended to be published on the Forge for
general use by the community will generally be as flexible as possible, while
a

The `pasture::params` class will assign static defaults to the `$pasture_port`
and `$pasture_config_file` variables, then use a conditional statement to
assign a different value to the `$default_character` depending on the
`os.family` fact.

```puppet
class pasture::params {
  $pasture_port = '80',
  $
}
