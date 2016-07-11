{% include '/version.md' %}

# Quest Guide for the Puppet Learning VM

## About the Learning VM and this Quest Guide

The Learning VM (Virtual Machine) is a self-contained learning environment
that includes everything a new user needs to get started learning Puppet.
Because learning Puppet requires making changes to a system's configuration,
it's not wise to play with it directly on your own laptop or desktop. Not
everyone who wants to learn Puppet, however, has easy access to a system
where he or she can experiment freely. And even those who do will benefit
from an environment with Puppet Enterprise pre-installed and a set of tools
to help guide you through the basics of configuration management with Puppet.

This guide is the companion to the Learning VM. The content of the guide is
paired with a `quest` command line tool on the VM that will provide live
feedback as you progress through the list of tasks associated with each
quest in this guide. By breaking each concept into a series of incremental
and validated steps, we can ensure that you stay on track as you progress
through the guide.

## Who should use the Learning VM?

This guide should be useful for any reader with an interest in configuration
management, system administration, or related tasks. We have done our best to
avoid any assumptions about a reader's familiarity with a specific operating
system. While users familiar with a Linux command-line interface will already be
familiar with most of the commands used in this guide, those more accustomed
to a graphical user interface will find all necessary commands provided.

The Learning VM comes with Puppet Enterprise installed, and some of the
content is specific to Puppet Enterprise. Users interested in the open source
version of Puppet will nonetheless benefit from the majority of the content.
Certain features, such as the graphical web console and Application Orchestration
tool, are exclusive to Puppet Enterprise. Content related to the Puppet
master-agent architecture, Puppet code, and module structure will be generally
applicable to the open source version of Puppet, though there are some
differences in file locations.
