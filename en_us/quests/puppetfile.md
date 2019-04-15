{% include '/version.md' %}

# Puppetfile

## Quest objectives

- Create a Puppetfile to manage external module dependencies
- Use the `puppet module` tool to calculate dependencies and help determine
  which modules you need to include in your Puppetfile.

## Getting started

In this quest, you will add external module dependencies to your control
repository using a Puppetfile. 

When you're ready to get started, type the following command:

    quest begin puppetfile

## Puppetfile

In the Control Repository quest, you moved your Puppet modules into the
`control-repo` git repository. So far, however, this repository only includes
the Puppet code you wrote yourself as you worked through the previous quests
in this guide. It doesn't contain any of the Forge modules you installed with
the Puppet module tool.

There's a good reason to leave these external modules out of your control
repository. Adding them directly would result in a large amount of duplicated
code. You would then need to manually manage versioning and updates for each of
these modules. Your site-specific code, which should be the focus of your
control repository, would be quickly overwhelmed by the bulk of this externally
sourced code.

A Puppetfile provides a more efficient solution for managing external module
dependencies. It lets you use a single file to specify the desired version and
source for each external module. Puppet's Code Manager installs the modules
specified by your Puppetfile into your environment's modules directory during
the code deployment process.

This way, you can add, remove, and update external modules by changing one or
two lines of code in your Puppetfile.

<div class = "lvm-task-number"><p>Task 1:</p></div>

Because the database-backed version of the Pasture application depends on the
`puppetlabs-postgresql` module, you will need to include that module in your
Puppetfile before Puppet can manage the application.

First, ensure that you're working in the `~/control-repo` directory.

    cd ~/control-repo

Before starting work, check the current status of the repository.

    git status

If you're still on the feature branch from the previous quest, return to the
`production` branch.

    git checkout production

Remember, the upstream version of your `production` branch incorporated the
changes you introduced with your feature branch. Fetch and merge those changes
into your local `production` branch with the `git pull` command.

    git pull upstream production

Now that your local production branch matches the upstream remote's production
branch, you're ready to create a new feature branch for your new work.

    git checkout -b puppetfile

<div class = "lvm-task-number"><p>Task 2:</p></div>

Open a new file called `Puppetfile` in your editor.

    vim Puppetfile

Add the following line to include version 5.12.1 of the `puppetlabs-postgresql`
module:

```ruby
mod "puppetlabs/postgresql", '5.12.1'
```

Unfortunately you're not quite done yet. Unlike the `puppet module` tool, Code
Manager does not automatically manage dependency trees for modules. If you have
a large number of modules for which you need to resolve dependencies, there are
a few third-party tools such as
[puppet-generate-puppetfile](https://github.com/rnelson0/puppet-generate-puppetfile)
and [librarian-puppet](https://github.com/voxpupuli/librarian-puppet) that can
help with this.

<div class = "lvm-task-number"><p>Task 3:</p></div>

In this case, however, you're only dealing with one external module, so you can
resort to a common work-around. Install the desired version of the
`puppetlabs/postgresql` module into a temporary directory using the `puppet
module` tool and use the tool's output to determine the needed dependencies.

    mkdir temp  
    puppet module install puppetlabs/postgresql --version 5.12.1 --modulepath=temp

The tool will return the following:

```
Notice: Preparing to install into /root/control-repo/tmp ...
Notice: Downloading from https://forge.puppet.com ...
Notice: Installing -- do not interrupt ...
/root/control-repo/tmp
└─┬ puppetlabs-postgresql (v5.12.1)
  ├─┬ puppetlabs-apt (v6.3.0)
  │ └── puppetlabs-translate (v1.1.0)
  ├── puppetlabs-concat (v5.3.0)
  └── puppetlabs-stdlib (v5.2.0)
```

Clean up after yourself by removing the temporary directory.

    rm -rf temp

Return to your Puppetfile and add entries for the `puppetlabs-apt`,
`puppetlabs-translate`, `puppetlabs-concat`, and `puppetlabs-stdlib`
modules using the listed versions.

Your finished Puppetfile should look like this:

```ruby
mod "puppetlabs/postgresql", '5.12.1'
mod "puppetlabs/apt", '6.3.0'
mod "puppetlabs/translate", '1.1.0'
mod "puppetlabs/concat", '5.3.0'
mod "puppetlabs/stdlib", '5.2.0'
```

<div class = "lvm-task-number"><p>Task 4:</p></div>

Stage your new Puppetfile to be committed:

    git add Puppetfile

And commit the change:

    git commit

Enter a commit message like the following:

```
Add Puppetfile with puppetlabs-postgresql module

The Pasture module depends on the `puppetlabs-postgresql` module for
the database-backed version of the application. Add a Puppetfile
to include this module and its dependencies. 
```

Push your branch to the upstream remote.

    git push upstream puppetfile

<div class = "lvm-task-number"><p>Task 5:</p></div>

From the Gitea UI (`<IP ADDRESS>:3000`), create a new pull request.

Review and merge the pull request. (Keep in mind that in a real production
environment, you should establish a team process for these review and merge
steps. This ensures that all changes to your code base are reviewed and
approved before being merged into production and deployed.)

<div class = "lvm-task-number"><p>Task 6:</p></div>

Now that this change has been integrated into your control repository, use the
`puppet code` tool to deploy to the production environment. (If your token has
expired since you last authenticated, use `puppet access login --lifetime 1d`
and supply the credentials `deployer`:`puppet` generate a new token.)

    puppet code deploy production --wait

Once the deployment completes, check the list of installed modules to verify
that the correct modules have been installed.

    puppet module list --tree --modulepath /etc/puppetlabs/code/environments/production/modules

The modules you added to your Puppetfile should now be included in your
production environment's modulepath.

```
/etc/puppetlabs/code/environments/production/modules
└─┬ puppetlabs-postgresql (v5.12.1)
  ├── puppetlabs-stdlib (v5.2.0)
  ├─┬ puppetlabs-apt (v6.3.0)
  │ └── puppetlabs-translate (v1.1.0)
  └── puppetlabs-concat (v5.3.0)
```

<div class = "lvm-task-number"><p>Task 7:</p></div>

Now that these external Forge modules are included in your Puppetfile, your
control repository can support your Pasture application's database server.

Use the `puppet job` tool to trigger Puppet agent runs on the `pasture-db.auroch.vm`
and `pasture-app.auroch.vm` nodes.

    puppet job run --nodes pasture-app.auroch.vm,pasture-db.auroch.vm

Now that your nodes are configured, take a moment to test that your application
can store a value in the connected database and retrieve it.

    curl -X POST 'pasture-app.auroch.vm/api/v1/cowsay/sayings?message=Hello!'
    curl pasture-app.auroch.vm/api/v1/cowsay/sayings/1

## Review

In this quest, we introduced the the use of a Puppetfile to manage external
module dependencies.

After learning the basic syntax of the Puppetfile, you used the `puppet module
tool` to resolve your set of module dependencies and versions for the
`puppetlabs-postgresql` module by installing it to a temporary directory.

With your external modules specified in your Puppetfile, you used a pull
request to add these changes to your upstream control repository and used the
`puppet code deploy` command to deploy that repository to the master's
production environment. As part of the deploy process, Puppet's Code Manager
parsed the Puppetfile and installed each listed module to the
`/etc/puppetlabs/code/environments/production/modules` directory.

With these modules installed, you were able to configure your database server
and the application server that connects to it.

## Additional Resources

You can find more information on how to use a Puppetfile on the Puppet [docs
page](https://puppet.com/docs/pe/latest/code_management/puppetfile.html).

The Puppetfile is covered in several of our [instructor-led trainings](https://learn.puppet.com/course-catalog).

The example [control-repo repository](https://github.com/puppetlabs/control-repo) includes a Puppetfile
you may use as reference when creating your own.
