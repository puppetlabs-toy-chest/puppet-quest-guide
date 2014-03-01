# Running Puppet Quest

Up until this point we have discussed:

- resoures and their fundamental components
- constructing a manifest with such resources
- combining resources into a specific class for completeing tasks
- building a module that recognizes such a class

But now I want to run Puppet. How do I do that? In this quest we'll discuss taking all of this knowledge and truly applying it.

## The Puppet Agent (Your VM)

Puppet agent runs on each managed node. By default, it will wake up every 30 minutes (configurable), check in with puppetmasterd, send puppetmasterd new information about the system (facts), and receive a ‘compiled catalog’ describing the desired system configuration. Puppet agent is then responsible for making the system match the compiled catalog. If pluginsync is enabled in a given node’s configuration, custom plugins stored on the Puppet Master server are transferred to it automatically.

The puppet master server determines what information a given managed node should see based on its unique identifier (“certname”); that node will not be able to see configurations intended for other machines.

## Signing Node Certificates

The puppet cert command is used to sign, list and examine certificates used by Puppet to secure the connection between the Puppet master and agents. The most common usage is to sign the certificates of Puppet agents awaiting authorisation:

Certificates with a + next to them are signed. All others are awaiting signature.

## The Puppet Master

## Puppet Agent/Master Interaction

## Tasks

1. TBD