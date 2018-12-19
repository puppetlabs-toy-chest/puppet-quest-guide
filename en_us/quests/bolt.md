{% include '/version.md' %}


# Bolt

## Quest Objectives

- Get started with the basics: What is Puppet Bolt and what does it do?
- Install Puppet Bolt on a new system.
- Navigate to Puppet Bolt modules directory
- Create a new module with PDK and add a plans directory
- Set up a new node to receive the plan
- Run the plan and install nginx with Puppet Bolt

## Get Started

This quest kicks off your hands-on introduction to Puppet Bolt. Use the `bolt apply` function to apply blocks of Puppet code (manifest blocks) that declaratively describe the state of a target on a group of remote nodes from the command line. This lets you manage the state of your resources on a one-off basis on one remote system. Bolt’s apply function is a great way to get started with Puppet code without any prior knowledge of Puppet. 

Ready to get started? Run the following command on your Learning VM to begin this quest:

    quest begin bolt

## What is Puppet Bolt?

Puppet Bolt is an open source, agentless multi-platform automation tool that reduces your time to automation and makes it easier to get started with DevOps. Puppet Bolt makes automation much more accessible without requiring any Puppet knowledge, agents, or master. It uses SSH or WinRM to communicate and execute tasks on remote systems.

Your teams can perform various tasks like starting and stopping services, rebooting remote systems, and gathering packages and systems facts from your workstation or laptop on any platform (Linux and Windows).

Bolt users are able to take advantage of more than 5,000 modules available in the Puppet Forge for everything from deploying database servers to setting up Docker or Kubernetes. With Puppet Bolt you can reuse existing scripts in Bash, PowerShell, Python or any other language.

Puppet Bolt allows your teams to get started with infrastructure automation with no prerequisites or prior Puppet knowledge. For teams already using scripts to automate provisioning and management of existing nodes, Puppet Bolt enables you to move a step further. Build shareable tasks and leveraging existing modules on the Puppet Forge from your own workstation or laptop to take your infrastructure automation even further.


## Agentless Deployment

We’re increasingly adding to the functionality and power of tasks, most recently with the addition of cross-platform tasks. This feature gives users the capability to have multiple implementations of a task and lets Puppet Bolt choose the right one based on the target platform. It’s perfect for when you might have an install task that is running bash on Linux and PowerShell on Windows — Puppet Bolt will run the right implementation without you having to think about it.

```
{
  "implementations": [
    {"name": "sql_linux.sh", "requirements": ["shell"]},
    {"name": "sql_windows.ps1", "requirements": ["powershell"]}
  ]
}
```

Last year, we shipped Puppet Bolt task plans as a beta and learned quite a bit from that. As of today, plans are now stable and allow for sophisticated orchestration across your environment. We've added improvements such as flexible error handling, complex interstep dependency support, and better logging for thorough reporting.

We have users running Puppet Bolt across tens of thousands of nodes so we know we need to make managing your infrastructure a tad bit easier. To do this, we've added an inventory file to manage nodes, groups of nodes, cloud endpoints, and all the credentials needed to connect. For those of you already using PuppetDB, we've built an integration to just use PQL and target those nodes.

## Bolt Apply

The apply function
Use the bolt apply function to apply blocks of Puppet code (manifest blocks) that declaratively describe the state of a target on a group of remote nodes from the command line. This lets you manage the state of your resources on a one-off basis on one remote system. Bolt’s apply function is a great way to get started with Puppet code without any prior knowledge of Puppet. Expand and scale this operation across your application stack using a Bolt plan.

```
plan profiles::nginx_install(
  TargetSpec $nodes,
  String $site_content = 'hello!',
) {
  # Install puppet on the target and gather facts
  $nodes.apply_prep

  # Compile the manifest block into a catalog 
  apply($nodes) {
    package { 'nginx':
      ensure => present,
    }

    file { '/var/www/html/index.html':
      content => $site_content,
      ensure  => file,
    }

    service { 'nginx':
      ensure  => 'running',
      enable  => 'true',
      require => Package['nginx'],
    }
  }
}
```

## Install Puppet Bolt

## Create a Module

## Deploy the Module to a Node