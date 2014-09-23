---
title: MySQL
layout: default
---

# MySQL

### Prerequisites

- 

## Quest Objectives

- 

## Getting Started

In this quest you will

    quest --start mysql

## Why SQL

> 
-- 

While some modules are designed to manage a single service, the 

The `puppetlabs-mysql` module lets you manage your server and client MySQL installations, as well as several MySQL resources such as *users*, *grants*.

## Server Install

Install the `puppetlabs-mysql` module:

	puppet module install puppetlabs-mysql

Classify the LVM with the MySQL server	class. Using class parameters, specify a root password and set the server's max connections to '1024.'

	class { '::mysql::server':
	  root_password    => 'strongpassword',
	  override_options => { 'mysqld' => { 'max_connections' => '1024' } },
	}
	
In addition to some standard parameters like the `root_password`, the class takes a hash of `override_options`, which you can use to address any configuration options you would normally set in the `/etc/my.cnf` file. Using a hash lets you set any options you like in the MySQL configuration file without requiring each to be written into the class as a separate parameter. The structure of the `override_options` hash is analogous to the `[section]`, `var_name = value` syntax of a `my.cnf` file.

Grep the `/etc/my.cnf` file:

	cat /etc/my.cnf | grep -B 9 max_connections

And you'll see that Puppet translated the hash into appropriate syntax for the MySQL configuration file:

	[mysqld]
	...
	max_connections = 1024

## Scope

It was easy enough to use Puppet to install and manage a MySQL server. The `puppetlabs-mysql` module also includes a bunch of classes that help you manage other aspects of your MySQL deployment. 

These classes are organized within the module directory structure in a way that matches Puppet's scope syntax. Scope helps to organize classes, telling Puppet where to look within the module directory structure to find each class. It also separates namespaces within the module and your Puppet manifests, preventing conflicts between variables or classes with the same name.

Take a look at the directories and manifests in the MySQL module. Use the `tree` command with a filter to include only `.pp` manifest files:

	tree -P *.pp /etc/puppetlabs/modules/mysql/manifests/

You'll see something like the following:

	/etc/puppetlabs/puppet/modules/mysql/manifests/
	├── backup.pp
	├── bindings
	│   ├── java.pp
	│   ├── perl.pp
	│   ├── php.pp
	│   ├── python.pp
	│   └── ruby.pp
	├── bindings.pp
	├── client
	│   └── install.pp
	├── client.pp
	├── db.pp
	├── init.pp
	├── params.pp
	├── server
	│   ├── account_security.pp
	│   ├── backup.pp
	│   ├── config.pp
	│   ├── install.pp
	│   ├── monitor.pp
	│   ├── mysqltuner.pp
	│   ├── providers.pp
	│   ├── root_password.pp
	│   └── service.pp
	└── server.pp
	
Notice the `server.pp` manifest in the top level of the `mysql/manifests` directory. 

You were able to declare this class as `mysql::server`. Based on this scoped class name, Puppet knows to find the class definition in a manifest called `server.pp` in the manifest directory of the MySQL module.

So `mysql::server` corresponds to:

/etc/puppetlabs/modules/**mysql**/manifests/**server**.pp

To take an example one level deeper, the `mysql::server::account_security` class corresponds to:

/etc/puppetlabs/modules/**mysql**/manifests/**server**/**account_security**.pp

We won't be calling the `mysql` class directly in this quest, but it's worth reiterating the special case of a module's self-named class. This will always be found in a manifest called `init.pp` in the top level of the module's manifests directory.

So the `mysql` class is found here:

/etc/puppetlabs/modules/**mysql**/manifests/init.pp

For security reasons, you will generally want to remove the default users and the 'test' database from a new MySQL installation. The `account_security` class mentioned above does just this.

Go back to your `site.pp` manifest and include the `mysql::server::account_security` class. Remember, you don't need to pass any parameters to this class, so a simple `include` statement will work in place of a parameterized class declaration. 

Trigger a Puppet run, and you will see notices indicating that the test database and two users have been removed:

	Notice: /Stage[main]/Mysql::Server::Account_security/Mysql_database[test]/ensure: removed
	Notice: /Stage[main]/Mysql::Server::Account_security/Mysql_user[@localhost]/ensure: removed
	Notice: /Stage[main]/Mysql::Server::Account_security/Mysql_user[root@127.0.0.1]/ensure: removed

With these default users removed, you'll likely want to set up your own user account.

## Types and Providers

Luckily, the MySQL module includes some custom *types and providers* that let you manage some critical bits of MySQL as resources with Puppet DSL just like you would with a system user or service.

A **type** defines the interface for a resource: the set of *properties* you can use to define a desired state for the resource, and the *parameters* that don't directly map to things on the system, but tell Puppet how to manage the resource. Both properties and parameters appear in the resource declaration syntax as attribute value pairs.

A **provider** is what does the heavy lifting to bring the system into line with the state defined by a resource declaration. Providers are implemented for a wide variety of supported operating systems. They are a key component of the Resource Abstraction Layer (RAL), translating the universal interface defined by the **type** into system-specific implementations.

The MySQL module includes custom types and providers that make `mysql_user`, `mysql_database`, and `mysql_grant` available as resources.

### Create users:

	mysql_user { 'lvm@127.0.0.1':
	  ensure                   => 'present',
	  max_connections_per_hour => '0',
	  max_queries_per_hour     => '0',
	  max_updates_per_hour     => '0',
	  max_user_connections     => '0',
	  password_hash            => '*F3A2A51A9B0F2BE2468926B4132313728C250DBF',
	}
	

### Create database:

	mysql_database { 'marionettes':
  	  ensure  => 'present',
  	  charset => 'utf8',
	}

### Create grants:

	mysql_grant {

### Install client

	node 'client.puppetlabs.vm' {
	  include ::mysql::client
	}