{% include '/version.md' %}

# Quest Guide for the Puppet Learning VM

## About the Learning VM and this Quest Guide

The Learning VM is a self-contained environment
that includes everything a new user needs to get started learning Puppet.
Because learning Puppet requires making changes to a system's configuration,
it's not wise to play with it directly on your own laptop or desktop. You may not
have easy access to a system to freely experiment, and it is beneficial
to work in an environment with Puppet Enterprise pre-installed and a set of tools
to guide you through the basics of configuration management with Puppet.

The Quest Guide is the companion to the Learning VM. The content of the guide is
paired with a `quest` command line tool on the VM that provides live
feedback as you progress through the list of tasks associated with each
quest in this guide. By breaking each concept into a series of incremental
and validated steps, we ensure that you stay on track as you progress
through the guide.

## Who should use the Learning VM?

This guide is useful for any reader with an interest in configuration
management, system administration, or related tasks. We have done our best to
avoid any assumptions about a reader's familiarity with a specific operating
system. While users familiar with a Linux command line interface will already be
familiar with most of the commands used in this guide, those more accustomed
to a graphical user interface will find all necessary commands provided.

The Learning VM comes with Puppet Enterprise installed and some of the
content is specific to Puppet Enterprise. Users interested in the open source
version of Puppet will nonetheless benefit from the majority of the content.
Certain features, such as the graphical web console and Application Orchestration
tool, are exclusive to Puppet Enterprise. Content related to the Puppet
agent/master architecture, Puppet code, and module structure is generally
applicable to the open source version of Puppet, though there are some
differences in file locations.
