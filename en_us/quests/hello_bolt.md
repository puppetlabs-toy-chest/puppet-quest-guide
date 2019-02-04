{% include '/version.md' %}

# Hello Bolt

## Quest objectives

- Install Puppet Bolt
- Verify the Puppet Bolt installation
- Run a simple command using Bolt

## Get started

In this quest, you will install Puppet Bolt and run some introductory commands.

Ready to get started? Run the following command on your Learning VM to begin
this quest:

    quest begin hello_bolt

## Install Puppet Bolt

<div class = "lvm-task-number"><p>Task 1:</p></div>

Packaged versions of Bolt are available for Red Hat Enterprise Linux 6 and 7,
SUSE Linux Enterprise Server 12, as well as Windows and macOS. The Learning
VM is based on a CentOS 7 image, so run the following commands to install
Bolt:

    rpm -Uvh https://yum.puppet.com/puppet6/puppet6-release-el-7.noarch.rpm

    yum install puppet-bolt

## Verify the Puppet Bolt installation

<div class = "lvm-task-number"><p>Task 2:</p></div>

Now that you have installed Puppet Bolt successfully, let's run some commands
to verify that it works correctly.

    bolt --help

    bolt --version
