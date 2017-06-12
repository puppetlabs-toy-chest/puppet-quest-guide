{% include '/version.md' %}

# Welcome 

## Quest objectives

- Familiarize yourself with the Quest structure and tool

## Getting Started

Welcome to the Quest Guide for the Puppet Learning VM. This guide will be
your companion as you make your way through the Learning VM's series of
interactive lessons.

At this point, you should have the Learning VM set up and an open session in
your browser-based terminal or SSH client. If not, please return to the Setup
section for instructions on getting started.

Before we get into Puppet itself, this lesson provides with a brief
introduction to the `quest` tool that you will use throughout the rest of this
guide to track your progress.

Ready to get started? Run the following command on the VM to begin the
"Welcome" quest.

    quest begin welcome

## An introduction to the quest tool

One logging in to the Learning VM, you may have noticed a colored bar at the
bottom of the terminal window. This status bar is provided by a tool called
[tmux](http://www.hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/). This
status bar gives you quick access to your current *quest*, and your progress
through the *tasks* included in that quest.

Go ahead and use the `--help` flag with the `quest` command to list the
available subcommands.

<div class = "lvm-task-number"><p>Task 1:</p></div>

    quest --help

A couple of seconds after entering that command, you will see the status bar
update to show 1 of 2 tasks complete. The small delay is the time it takes for
the quest tool to complete its check against a list of task completion criteria
and for tmux to run its periodic update of the status line.

<div class = "lvm-task-number"><p>Task 2:</p></div>

You can use the `status` subcommand to get a more verbose list of tasks and
their status. Give it a try now.

    quest status

You'll see that `Task 2: View the list of available quests` is still
incomplete. To complete this task, run the `list` subcommand:

    quest list

Now check the status again to see it marked as complete:

    quest status

(If you're curious about how these tasks work, take a look at the set of tests
in the `/usr/src/puppet-quest-guide/tests/` directory on the Learning VM. The
source code for the quest tool itself is
[here](https://github.com/puppetlabs/quest).)

## Review

In this quest, we introduced the concept of the quest and interactive task. You
tried out the quest tool and reviewed the mechanics completing quests and
tasks.

Now that you're familiar with the quest tool, you're ready to move on to the
next quest: Hello Puppet.
