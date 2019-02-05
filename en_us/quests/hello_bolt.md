{% include '/version.md' %}

# Hello Bolt

## Quest objectives

- Install Puppet Bolt
- Verify the Puppet Bolt installation
- Run simple commands using Bolt

## Get started

In this quest, you will install Puppet Bolt and run some introductory commands.
As described in the previous quest, Bolt is a task runner that enables you
to invokes commands on one or more target nodes. It is well-suited to
performing actions in an ad hoc manner instead of managing a node on a
long-term basis.

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

<div class = "lvm-task-number"><p>Task 3:</p></div>

Bolt provides a command-line interface for running commands, scripts, tasks
and plans on the local machine or remote nodes. Now let's practice running some
simple commands:

    bolt command run 'free -th' --nodes localhost

This command shows a human-readable report of the total memory allocated to
the local machine, how much is used and how much is free. The output should
look something like this:

```
Started on localhost...
Finished on localhost:
  STDOUT:
                  total        used        free      shared  buff/cache   available
    Mem:           3.7G        2.3G        143M        183M        1.2G        878M
    Swap:          1.0G         10M        1.0G
    Total:         4.7G        2.3G        1.1G
Successful on 1 node: localhost
Ran on 1 node in 0.01 seconds
```

This demonstrates trivial usage of bolt, but since the command is running on
the local machine, you could just as easily run `free -th` to get the same
output.

Bolt is better suited to running commands on one or more remote nodes so the
output can be collected and potentially acted upon by another tool. And instead
of using a tool like ssh in a `for` loop, you provide a list of nodes to Bolt,
and it will connect to each one and running the desired command. Now let's
try some examples using a Docker-hosted machine as target node:

    bolt command run hostname --nodes docker://bolt.puppet.vm

    bolt command run 'cat /etc/hosts' --nodes docker://bolt.puppet.vm
