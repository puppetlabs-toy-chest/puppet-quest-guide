{% include '/version.md' %}

# Roles and Profiles

## Quest objectives

- Learn how to organize your code into **profile** classes specific to your
  site's infrastructure.
- Bring multiple profile classes together to define a **role** class that will
  allow you to fully specify the role of a server in your infrastructure with a
  single class.

## Getting started

In the last quest, we shifted from managing the Pasture application on a single
system to distributing its components across the `pasture-prod.puppet.vm` and
`pasture-db.puppet.vm` hosts. The application server and database server you
configured each play a different role in your infrastructure and have a
different classification in Puppet. As your Puppetized infrastructure grows in
scale and complexity, you'll need to manage more and more kinds of systems. The
**roles and profiles** pattern gives you a consistent and modular way to define
how the components provided your Puppet modules come together to define each
different kind of system you need to manage.

When you're ready to get started, enter the following command:

    quest begin roles_and_profiles

## What are roles and profiles?

The **roles and profiles** pattern we cover in this quest isn't a new tool or
feature in the Puppet ecosystem. Rather, it's a way of using the tools we've
already introduced to create something you can maintain and expand as your
Puppetized infrastructure evolves.

The explanation of roles and profiles begins with what we call **component
modules**. Component modules—like your Pasture module and the PostgreSQL module
you downloaded from the Forge—are designed to configure a specific piece of
technology on a system. The classes these modules provide are written to be
flexible. Their parameters provide an API you can use to specify precisely how
you need the component technology to be configured.

The roles and profiles pattern gives you a consistent way to organize these
component modules according to the specific applications in your
infrastructure.

A **profile** is a class that calls declares one or more related component
modules and sets their paramaters as needed. The set of profiles on a system
defines and configures the the technology stack it needs to fulfull its
business role.

A **role** is a class that combines one or more profiles to define the desired
state for a whole system. A role should correspond to the business purpose of a
server. If your CTO asks what a system is for, the role should fit that
high-level answer: something like "a database server for the Pasture
application." A role itself should **only** compose profiles and set their
parameters—it should not have any parameters itself.

## Writing roles and profiles

Technically speaking, there's nothing special about a role or profile class.
Each is a class like any other. By convention, all your profiles will exist in
a module called `profile` and your roles in a module called `role`. Unlike the
kind of general-use component modules you might find published on the Forge,
these modules are site-specific and are not generally published.

To get started setting up your roles and profiles, create these two module
directories in your modulepath.

    mkdir -p roles/manifests

and

    mkdir -p profiles/manifests

## Review

TBD
