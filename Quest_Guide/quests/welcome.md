---
title: Welcome
layout: default
---

# Welcome 

## Quest Objectives

In this quest you will be introduced to Elvium, the Learning Virtual Machine environment.

## Welcome to Elvium

> Any sufficiently advanced technology is indistinguishable from magic.

> -Arthur C. Clarke

Welcome to Elvium, user. Have a look around, if you like, but take note: what you see now is only the surface. The real channels of power in Elvium lie deeper. You will learn of these things. You see, you are not an ordinary user, for you have come into the Elvium with a user id of '0', the mark of the **Superuser**.

If you choose to follow the path set forth in this Quest Guide, you will learn to channel your powers by using the art of Puppet. With only a few words, shape the environment around as you see fit. Inscribe your wishes into potent Puppet manifests to ensure that your will continues to be done when journey beyond Elvium to bring other systems under your dominion.

## Getting Started

Your arrival has been foretold, user, and all the necessary arrangements were made to ensure that this Quest Guide would fall into your hands. By entering the command `puppet apply setup/guide.pp`, you activated a Puppet **manifest** we had prepared in anticipation of your arrival.

## Quest Navigation

In order to learn more about Puppet, and to work your way through Elvium, you will have to complete a series of Quests. Each Quest has Tasks that need to be completed. Transparent information is essential on Elvium. To monitor your status with the quests on Elvium we've created custom commands for you.

The following command will help you with using the quest tool:

	quest --help

The `quest --help` command provides you with an understanding of several quest tools such as the following:

	quest --progress	# Display details of tasks completed (default: true)
	quest --brief		# Display number of tasks compelted
	quest --name		# Name of the quest to track
	quest --completed	# Display completed quests
	quest --showall		# Show all available quests
	quest --start		# Provide name of the quest to start tracking
	
We'll explain the commands needed as we go.

<!-- Add a screenshot that informs the user of the following information:
We need to display an image of a command terminal outline the 'Completed Tasks' section and when it means.

We need to outline where one would type a command into the terminal.

We need to outline where the output is presented.

We need to inform the user to use `clear` as a method of removing information from their terminal.
-->

## Facter

You are a curious being. Would you like to further investigate Elvium? To do this on Elvium we use the tool `facter` to obtains `facts` about the system. Here are a few for you to try out:

	facter ipaddress
	facter facterversion
	facter memorysize
	facter operatingsystem
	facter osfamily
	facter puppetversion

{% tip %}
You can see all the facts by running facter -p
{% endtip %}