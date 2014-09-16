---
title: Manifests and Classes
layout: default
---

# Manifests and Classes

### Prerequisites

- Welcome Quest
- Power of Puppet Quest
- Resources Quest

## Quest Objectives

- Understand the concept of a Puppet manifest
- Construct and apply manifests to manage resources
- Understand what a *class* means in Puppet's Language
- Learn how to use a class definition
- Understand the difference between defining and declaring a class

## Getting Started

In the Resources quest you learned about resources and the syntax used to declare them in the Puppet DSL. You used the `puppet resource`, `puppet describe`, and `puppet apply` tools to inspect, learn about, and change resources on the system. In this quest, we're going to cover two key Puppet concepts: *classes* and *manifests*. Proper use of classes and manifests is be the first step towards writing testable and reusable Puppet code.

When you're ready to get started, enter the following command to begin:

    quest --start manifests_and_classes

### Manifests

A manifest is a text file that contains Puppet code and is appended by the `.pp` extension. It's basically the same stuff you saw using the `puppet resource` tool and applied with the `puppet apply` tool, except that a manifest is saved as a file. While it's nice to be able to edit and save your Puppet code as a file, manifests also give you a way to keep your code organized in a way that Puppet itself can understand.

In theory, you could put whatever bits and pieces of syntactically valid Puppet code you like into a manifest. However, for the broader Puppet architecture to work properly, you'll need to follow some patterns in how you write your manifests and where you put them. A key aspect of proper manifest management is related to Puppet *classes*.

### Classes

In Puppet's DSL a **class** is a named block of Puppet code. A class will generally manage a set of resources related to a single function or system component. Classes often contain other classes; this nesting provides a structured way to bring together functions of different classes as components of a larger solution.

Using a Puppet class requires two steps. First, you'll need to *define* it by writing a class definition and saving it as a manifest file. Puppet will parse this manifest and store your class definition. The class can then be *declared* to apply it to nodes in your infrastructure.

There are a few different ways to tell Puppet where and how to apply classes to nodes. You already saw the PE Console's node classifier in the Power of Puppet quest, and we'll discuss other methods of node classification in a later quest. For now, though, we'll show you how to write a class definitions and use a *test* manifest to declare your classes locally.

### Cowsay
{% task 1 %}
You had a taste of how Puppet can manage users in the Resources quest, so we'll see what we can do with the `package`.

We've already created a module directory for you to work in and placed it in Puppet's *modulepath*. Before getting started editing, change directories to save yourself some typing:

	cd /etc/puppet/puppetlabs/modules/motd/


