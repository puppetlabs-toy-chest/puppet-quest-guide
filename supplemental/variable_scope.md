## Variable Scope

A variable's **scope** is defined by the portion of Puppet code in a manifest that can access that variable.

Scope is often described using a family analogy: a child scope inherits all the variables set by its parent (and parent's parent, etc.). It can access those inherited variables, but cannot access variables set by its siblings or its own children.

{% task 4 %}
To see how variable scopes work, we will create a manifest that assigns variables with a few different scopes. We will reference these variables in a resource declaration and see which scopes that resource declaration has access to. 

Create a new manifest called `scopes.pp`:
	
	nano ~/scopes.pp

Put the following Puppet code into your new `scopes.pp` manifest:

{% warning %}
In actual practice, classes are defined in a separate manifest file and referred to with an `include` statement. For the sake of simplicity of this demonstration, we've defined a simple class right in the manifest.
{% endwarning %}

{% highlight puppet %}
$top = 'Top scope available'

class child {
  $child = 'Child scope available!'
}

class local {
  include child
  $local = "Local scope available!"
  file { '/root/scope_example.txt' :
    ensure  => file,
    content => "${top}\n${local}\n${sibling}\n${child}\n",
  }
}

class sibling {
  $sibling = "Sibling scope available!"
}
{% endhighlight %}

Use the `puppet apply` command to apply your manifest, and use the `cat` command or a text editor to inspect the `~/scope_example.txt` file your manifest created. It should look like the following:

{% highlight bash %}
Local scope is available!
Top scope is available!
	
	
{% endhighlight %}

Notice the two blank lines at the end of the file? You included four variables as content of this file, but only two appear. This is because the resource declaration that created the file was outside the scope of the `$sibling` and `$child` variables.

{% figure '../assets/scope-diagram.png' %}

When Puppet is unable to find a variable, references to that variable resolve to `nil`, a special data type inherited from Ruby. `nil` displays an empty string, hence the blank lines where the Puppet parser was unable to find the `$sibling` and `$child` variables.

{% task 5 %}
We will do one more task to demonstrate how to make variable scoping productive.