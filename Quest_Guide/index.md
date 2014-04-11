---
title: Welcome
layout: default
---

# Welcome 

## Quest Objectives

- Recognize the learning context of the Puppet Enterprise Learning Virtual Machine (VM)
- Recall, at a high level, the value of Puppet Open Soure and Puppet Enterprise
- Identify and interpret the Quest structure
- Identify and interpret the Quest tool
- Identify and interpret the Facter tool

## Getting Started

In this quest we'll introduce you to the context of learning Puppet through this Learning VM where we'll discuss just the right amount of information to get you started, as we don't want to spoil all the fun as you're about to embark on this learning adventure. When you're ready to get started, type the following command:

    quest --start welcome

## The Puppet Enterprise Learning Virtual Machine

> Any sufficiently advanced technology is indistinguishable from magic.

> -Arthur C. Clarke

Welcome to the Quest Guide for the Puppet Enterprise Learning Virtual Machine (VM). By now you should have SSH'd in to the Learning VM. If not, please do so. Once you have, feel free to take a look around. You will see the Learning VM is fairly typical of a Unix-based operating system, essentially containing a filesystem populated with many of the usual directories. You should be aware though, some services are running in the background, including the SSH service you're using to access this Learning VM from your own terminal.

We should give you a heads up; since you're logged in to the `root` account, which is garnished by the `uid => 0`, means you carry the mark of a _Superuser_. Your account gives you the ability to change just about anything you would like in this Learning VM, just as you would if you were tasked with administrating a machine.

By following this Quest Guide, you will learn how Puppet allows you to use these privileges easily and effectively.

## What is Puppet?

So what is Puppet? Why should I care? At a high level, Puppet manages your servers whether it's Puppet open source or Puppet Enterprise. You describe your machine configurations in an easy-to-read declarative language, known as the Puppet DSL, and Puppet will bring your systems into the desired state and keep them there.

However, Puppet Enterprise is a complete configuration management platform, with an optimized set of components proven to work well together. It combines Puppet (including a preconfigured production-grade puppet master stack), a web console for analyzing reports and controlling your infrastructure, powerful orchestration features, cloud provisioning tools, and professional support.

Puppet is the configuration management tool for your system infrastructure and consistently maintained to meet the ongoing demands of system administration. 

{% task 1 %}
Before we dig any deeper, let's check an see what version of Puppet Enterprise we are running on this Learning VM. Type the following command:

	puppet -V	# That's a captial 'V'

Awesome! This confirms we are running the latest version of Puppet Enterprise.

## What is a Quest?

Up to this point we've provided you with some basic context of this Learning VM and what Puppet is. We'll continue to dive into greater detail about these topics in future quests. Wait a minute! What's a quest? That's a great question! A quest is a structured tutorial consisting of a number of interactive tasks that will help you learn about a topic related to Puppet.

Each 'Quest' includes a number of 'Tasks' that gives you a hands-on opportunity to apply you're Puppet knowledge. But how would I keep track of everything as I progress? What if I forget what quest I am on? These are all great questions and that's why we specifically created a 'Quest Tool' for this Learning VM to help you when you're in need.

## The Quest Tool

To monitor your status as you progress through these Quests, we've created a quest tool you can use on the Learning VM command line. However, this quest tool is not part of Puppet itself. We have included this tool in the Learning VM to provide you with real-time feedback as you progress through the many Quests and Tasks on your journey to learn Puppet.

{% task 2 %}
To explore the command options for the quest tool, type the following command:

	quest --help

The `quest --help` command provides you with an understanding of several quest tools such as the following:

_(Carthik - Please update with the latest information)_

	quest --progress	# Display details of tasks completed (default: true)
	quest --brief		# Display number of tasks completed
	quest --name		# Name of the quest to track
	quest --completed	# Display completed quests
	quest --showall		# Show all available quests
	quest --start		# Provide name of the quest to start tracking
	
{% task 3 %}
For example, if you enter the command:

	quest --progess brief
	
_(Carthik - Enter the description of the command)_

{% task 4 %}
Or if you enter the command:

	quest --list
	
_(Carthik - Enter the description of the command)_

Using this quest tool is entirely optional, but we have gone ahead and integrated it into the first few quests to help you out if needed.

{% tip %}
Typing `clear` into your terminal will remove everything on your terminal screen.
{% endtip %}

{% figure 'assets/terminal.png' %} <!--This screenshot needs updating when the final LVM is ready-->

## The Facter Tool

Puppet Enterprise is often used in concert with other tools to help you administer your systems. Just as the quest tool can provide you feedback on your learning progress, you can use the Facter tool to help you obtain facts about your system. Facter is Puppet’s cross-platform system profiling library. It discovers and reports per-node facts, which are available in your Puppet manifests as variables. This tool becomes more handy in the Variables Quest, but the sooner you get familar with Facter, the better.  Go ahead and get to know your system a little better using the `facter` command.

{% tip %}
**Puppet Enterprise** comes with many prepackaged tools, including the Facter tool.
{% endtip %}

{% task 5 - 7 %}

	facter facterversion
	facter operatingsystem
	facter puppetversion

{% tip %}
You can see all the facts by running `facter -p`
{% endtip %}

As you can see, when you enter a `facter` command, Puppet will retrieve the facts about your system.

## Review

In this introductory quest we've provided you with context and a sample quest structure for learning Puppet on this Learning VM. As you progressed through this quest, you also learned (maybe subconsciously) about the game mechanics to successfully complete a quest. We don't want to tell you everything up front, that would spoil all the fun, but with the high level explantations of what Puppet is, what a quest is, and how to use the quest and facter tools, we hope you have a general understanding of what a quest is like and what is in store for you on your learning journey.