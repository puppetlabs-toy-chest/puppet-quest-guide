{% include '/version.md' %}

# Portfolio Introduction

## Quest objectives

- Introduce Puppet the company
- Give an overview of the Puppet portfolio of products
- Describe Bolt

## Getting started

Now that you've been introduced to the Quest Guide for the Learning VM, this
lesson introduces Puppet the company and its portfolio of products.

Puppet was founded in 2005 by Luke Kanies and has offered its first commercial
product, Puppet Enterprise (PE), since 2011.

Puppet is a global company with headquarters in Portland and worldwide offices
located in London, Belfast, Sydney, Singapore, and elsewhere. The company has over
1000 enterprise customers, including 75 of the Fortune 100. Puppet has a robust
user community that has built many thousands of contributed modules comprising
over 7.5M lines of code. Additionally, tens of thousands of organizations use
open-source Puppet to manage their server infrastructure.

Over time, the company has expanded its offerings to the following portfolio
of enterprise products:

- Bolt: Perform ad hoc system configuration tasks on your infrastructure
- Puppet Enterprise: Build model-driven configuration for your IT infrastructure
- Puppet Pipelines: Simplify your application delivery and deployment process
- Puppet Insights: Visually measure and optimize your DevOps investment

Bolt and Puppet Enterprise will be the focus of the Learning VM. We
invite you to visit [https://puppet.com/products](https://puppet.com/products)
for additional information of the entire suite of Puppet products.

## Bolt

Bolt is an open-source remote task runner that automates the manual work that you do
to maintain your infrastructure. Use Bolt to automate tasks that you need to
perform on your infrastructure on an ad hoc basis, such as troubleshooting,
deploying an application, stopping and starting services, and upgrading a
database schema. Bolt connects directly to remote nodes with SSH or WinRM, so
you are not required to install any agent software.

In the Learning VM, Bolt will be installed and used to install the Puppet agent
on a target node much like you would do as you begin to deploy Puppet on your
infrastructure. Think of using Bolt as the first step of your infrastructure
automation journey. It can easily leverage existing scripts that you have
written in any language and allow you to execute them on remote nodes in
parallel.

Over time, you can then convert configuration tasks to Puppet code
for long-term management of your infrastructure. Even in that scenario, Bolt
is a powerful tool for performing tasks that are not as easily done with the
Puppet agent, such as stopping a database server, performing a schema upgrade,
and restarting the server.

## Review

In this quest, we introduced you to Puppet the company and its portfolio of
products. In the Learning VM, we will focus on the use of Bolt and
Puppet Enterprise to show how straightforward it is to begin your
infrastructure automation journey.
