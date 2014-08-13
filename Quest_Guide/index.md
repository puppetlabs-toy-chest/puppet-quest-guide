---
title: Welcome
layout: default
---

# Welcome 

## Quest Objectives

- Learn about the value of Puppet and Puppet Enterprise
- Familiarize yourself with the Quest structure and tool

## The Puppet Enterprise Learning Virtual Machine

> Any sufficiently advanced technology is indistinguishable from magic.

> -Arthur C. Clarke

Welcome to the Quest Guide for the Puppet Enterprise Learning Virtual Machine (VM). This guide is your companion to learning Puppet using the Learning VM. You should have started up the VM by now, and have an open SSH session from your terminal or SSH client.

If you need to, return to the Setup section and review the instructions to get caught up. Remember, the credentials to log in to the Learning VM via SSH are:

 * username: **root**  
 * password: **puppet**

Once you're logged in, feel free to take a look around. You will see the Learning VM is fairly typical of a Unix-based operating system. You should be aware though, that some services are running in the background, including the SSH service you're using to access this Learning VM from your own terminal.

## Getting Started

We've created a quest tool to to provide structure and feedback as you progress through each Quest included with the Learning VM. You'll have a chance to learn more about this tool below, but for now, type the following command into your terminal to tell the quest tool you've started the "Welcome" quest.

    quest --start welcome

## What is Puppet?

So what is Puppet, and why should you care? At a high level, Puppet manages your machines' configurations. You describe your machine configurations in an easy-to-read declarative language, known as the Puppet DSL, and Puppet will bring your systems into the desired state and keep them there.

*Puppet Enterprise* is a complete configuration management platform, with an optimized set of components proven to work well together. It combines Puppet (including a preconfigured production-grade Puppet master stack), a web console for analyzing reports and controlling your infrastructure, powerful orchestration features, cloud provisioning tools, and professional support.

At first, it may seem simpler to run a shell command or write a script to configuration of a system. As long as you're only concerned with a single change or changes to a single system, this may be true. Puppet allows you to describe all the details of the configuration for multiple systems in a composable manner. It allows you to manage the configuration of these systems (think hundreds or thousands) in a way that is simpler to maintain and understand than a collection of complicated scripts and doesn't require you to log in to each system in turn to run the required commands or scripts. Though it may take a little upfront Puppet automates the full process of configuration, maintenance, inventory, and reporting for all the systems in your infrastructure.

But a journey of a thousand miles starts with a single step. This guide will get you started with Puppet by walking through tasks to configure the Learning VM. While doing the exercises, keep in mind that the modular tools you'll apply to the Learning VM can adapted to automate the maintenance of hundreds of differing systems with little extra effort.

{% task 1 %}
Before digging any deeper, check and see what versions of Puppet and Puppet Enterprise are running on this Learning VM. Type the following command:

	puppet -V	# That's a capital 'V'

You will see something like the following:

_3.4.3 (Puppet Enterprise 3.2.1)_

This indicates that Puppet Version 3.4.3 Puppet Enterprise 3.2.1 are installed on the Learning VM. Note that the Puppet version and Puppet Enterprise versions are different. This is because Puppet Enterprise includes a version of the Puppet open source software, along with MCollective, PuppetDB, Hiera, and more than 40 other open source projects that we’ve integrated, certified, performance-tuned, and security-hardened in order to make PE a complete solution suitable for automating mission-critical enterprise infrastructure. In addition to these integrated open source projects, PE includes many of its own features, including event inspection, supported modules, role-based access control, certification management and VMware cloud provisioning.

## What is a Quest?

At this point we've introduced you to the Learning VM and Puppet. We'll continue to dive into greater detail about Puppet in future quests. But first, what's a quest? This guide contains collection structured tutorials that we call *quests*. Each *quest* consists of a number of interactive *tasks* that will give you hands-on experience with a topic related to Puppet.

If you executed the `puppet -V` command earlier, you've already completed your first task. (If not, go ahead and do so now.)

But how do you keep track of everything as you progress? What if you forget what quest you are on, or which tasks you've already completed? These are all great questions and that's why we created a quest tool to provide feedback and keep you on track as you work through the quests included in this guide.

## The Quest Tool

To help you get comfortable with the quest tool, we've included a few tasks to demonstrate the tool itself.

{% warning %}

The VM comes with several adjustments to enable the use of the quest tool and progress tracking, including changes to how bash is configured. Please don't replace the .bashrc file, instead append your changes

{% endwarning %}
{% task 2 %}
To explore the command options for the quest tool, type the following command:

	quest --help

The `quest --help` command provides you with a list of all the options for the `quest` command. You can invoke the quest command with each of those options, such as:  

    quest --progress     # Displays details of tasks completed
    quest --completed    # Displays completed quests
    quest --list         # Shows all available quests
    quest --start <name> # Provide the name of a quest to start tracking progress
	
{% task 3 %}
Find out how much progress you have made so far:

	quest --progress

{% tip %}
Typing `clear` into your terminal will remove everything on your terminal screen.
{% endtip %}

While you can use the quest commands to find more detailed information about your progress through the quests, you can check on your progress real time by having a look at the quest status display at the bottom right of your terminal window. A process running in the background of the VM updates this status every two seconds so you can easily keep up with your progress as you complete each task.

{% figure 'assets/terminal.png' %} 

## Review

In this introductory quest we provided a very high level explanation of what Puppet is, what a quest is, and how to use the quest tool. As you progressed through this quest, you learned about the mechanics of successfully completing a quest by means of completing the associated tasks. We hope you have a general understanding of how to complete a quest and what is in store for you on your learning journey.
