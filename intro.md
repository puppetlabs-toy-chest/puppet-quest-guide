Introction
=====

Get Apache
-----

Before getting down to the basics let’s have a look at what you can do with a few lines of high-level code.

By using pre-packaged Puppet modules, we can install and configure a server running wordpress on this virtual machine with only a few lines of code. Of course, you’ll eventually want to write your own puppet code.
The Puppet Forge contains a huge variety of modules created by Puppet Labs and by members of the Puppet community. We’ll get more into the details of the Forge in a later lesson.  If you want to get practice using the Forge, try downloading the Apache module now. Or, if you would rather, you can use the cached version already included on your Puppet Learning VM.

Now let’s apply the module by typing: [apply module]

We’ll get more into the details of this command later.  For now, note [some salient aspect of the command]

[Other commands to start the server?]

Now, open a web browser and type in the IP address 
(If you’ve forgotten the address, you can type xxx)

You should see:

If it doesn’t show up [troubleshooting possibilities?]

Pretty painless, right?

Now that we’ve seen how Puppet works on a high level, let’s take a look under the hood.

Navigate to [module directory] and type [tree view] to get an overview of the module’s architecture. For now, we’ll be digging deeper into the init.pp manifest file to get an overview of some basic aspects of Puppet code, but while we’re here, note the setup of the module directory.

Modules contain of Puppet code files, which we call “manifests,” and which have the .pp extension.

