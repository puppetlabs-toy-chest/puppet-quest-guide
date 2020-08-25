{% include '/version.md' %}

# Control repository

## Quest objectives

- Create a control repository to manage the code for your production environment.
- Use Git to initialize your local control repository and push its contents to
  an upstream remote.
- Configure Puppet's Code Manager tool to access and deploy code from your
  upstream repository to your Puppet server.
- Understand and apply the workflow involved in promoting changes from your
  local development copy of the control repository through to deployment on the
  Puppet server.

## Getting started

In this quest, you'll learn how to set up a control repository and begin to
manage the Puppet code that defines your infrastructure through a Git
source-control management (SCM) workflow. Checking your Puppet code into SCM
makes it much easier for you and your team to collaborate, control change, and
safely test new features.

The concepts introduced in this quest mark an important transition in your
progress from learning Puppet basics to building a workflow suitable for
managing production infrastructure.

Though it is possible to use other SCM tools with Puppet, this quest focuses on
Git. Learning to use Git effectively can be an undertaking in itself. This
quest will provide all the Git commands necessary to complete the included
tasks, but it is not focused on teaching Git itself.

The Git workflow included here is intended only as a working example; if Git or
another SCM tool is already implemented in your organization, there may be
established practices that differ from the workflow outlined here.

If you would like to learn Git or brush up on your skills before continuing,
the *additional resources* section at the end of this quest includes links to
several options.

When you're ready to get started, type the following command:

    quest begin control_repository

## Control repository

So far, the work you've done on the Learning VM has been on modules included
directly in Puppet's modulepath. As a learning exercise, this has the advantage
of simplicity and directness. To manage production infrastructure with Puppet,
however, we strongly suggest adopting a workflow that allows for multiple
contributors to coordinate, review, and test their changes before modifying
production code.

A Puppet control repository is an SCM repository containing the code and
configuration that define your Puppet infrastructure.

Putting your Puppet codebase into source control allows each contributor to
work on a checked-out copy of the code without directly modifying anything in
your Puppet server's production modulepath. These code changes can then be reviewed
and tested before being merged into the production codebase and deployed to the
Puppet server's production environment.

We'll begin by creating a `control-repo` directory in your home directory. The
contents of this directory will ultimately be deployed to the
`/etc/puppetlabs/code/environments/production/` directory on your Puppet server, so
the content of your control repository will be similar to what currently exists
in that directory.

Take a look at the contents of that directory:

    ls /etc/puppetlabs/code/environments/production/

You should see the following list of files and subdirectories that define your
production Puppet environment:

    data  environment.conf  hiera.yaml  manifests  modules

The role of most of these items should already be familiar from other quests.
The `hiera.yaml` file and `data` subdirectory contain the configuration
information and data for Hiera. The `manifests` directory contains the
`site.pp` manifest that includes node definitions and classification, and the
`modules` directory contains the modules you've installed from the Forge as
well as modules you've created yourself, including your role and profile
modules. The
[environment.conf](https://puppet.com/docs/puppet/latest/config_file_environment.html)
file allows you to override certain Puppet master configuration settings when
the Puppet master is serving nodes assigned to this environment. So far, you
haven't had to make any changes to these settings, so you haven't encountered
this file until now.

For the most part, a control repository should include the same contents you
see currently in the `production` directory. However, there is one notable
difference: rather than a `modules` subdirectory a control repository generally
has distinct subdirectory called `site`. Your site directory should contains
only the site-specific modules that you (or your team) have written
specifically to manage your infrastructure, as these are the modules whose code
should be managed through your source control process.

Any modules that come from an external source such as the Forge should not be
included directly in a control repository. Those modules generally have their
own dedicated public repositories on a site like [GitHub](https://github.com/)
and get published to the Forge whenever a new version is released. Attempting
to mirror all the changes to these modules in your own repository would be a
large duplication of effort. Instead, external modules are generally managed by
something called a
[Puppetfile](https://puppet.com/docs/pe/2019.8/puppetfile.html).

When you use the Puppet Code Manager tool to deploy your control repository's
code to an environment on the master, it reads the list of external modules in
your Puppetfile and automatically installs them to the environment's `modules`
directory. This lets you easily keep your list of external module dependencies
under version control without duplicating their Puppet code and managing
specific code changes in your control repository.

We'll create a Puppetfile in the next quest and cover its use in more depth.
For now, we'll be focusing on the modules in your `site` directory whose code
you will be directly managing in your control repository. Just be aware that
because the contents of the `modules` directory are typically defined by a
Puppetfile, your site-specific modules are kept in the distinct `site`
directory to avoid being removed or overwritten when external modules are
installed.

<div class = "lvm-task-number"><p>Task 1:</p></div>

Begin setting up your control repository by creating a `/root/control-repo`
directory and the `/root/control-repo/site` subdirectory.

    mkdir -p /root/control-repo/site

Next, navigate to your existing `modules` directory.

    cd /etc/puppetlabs/code/environments/production/modules

Here, we'll take a look at the existing modules to pick out the site-specific
modules to be included in the `site` directory of the control repository.

    ls

You should see a list like the following:

    apt concat cowsay epel motd  pasture  postgresql  profile  role  stdlib user_accounts

<div class = "lvm-task-number"><p>Task 2:</p></div>

Copy the site-specific `cowsay`, `pasture`, `motd`, `user_accounts`, `role`,
and `profile` Puppet modules into the your control repository's `site`
directory.

    cp -r {cowsay,pasture,motd,user_accounts,role,profile} /root/control-repo/site/

<div class = "lvm-task-number"><p>Task 3:</p></div>

Now that you're done bringing over your modules, we'll copy over the rest of
the production environment content to the control repository. Use `cd` to go up
a directory from the `modules` subdirectory to your `production` environment
directory.

    cd ..

Here, you need to make one more change to ensure that Puppet can actually find
the modules you just copied into the `site` directory. Remember, Puppet can
only find modules included in its `modulepath`. By default, this includes the
`modules` directory, but not the `site` directory. For Puppet to find these
site modules, this directory must be added to the `modulepath`. To do this,
we'll use the `environment.conf` configuration file to override the Puppet
master's default `modulepath` setting.

First, copy the existing `environment.conf` file to your control repository.
There aren't yet any settings specified in this file, but there are some useful
explanatory comments at the top of the file that we might as well preserve.

    cp environment.conf /root/control-repo/environment.conf

Next, edit this configuration file.

    vim /root/control-repo/environment.conf

Include the following line at the end of the file to ensure that both `site`
and `modules` are included in the `modulepath` setting for this environment.

    modulepath = site:modules:$basemodulepath

<div class = "lvm-task-number"><p>Task 4:</p></div>

Next, create your control repository's `manifests` directory.

    mkdir /root/control-repo/manifests

Copy over your existing `site.pp` manifest.

    cp manifests/site.pp /root/control-repo/manifests/site.pp

<div class = "lvm-task-number"><p>Task 5:</p></div>

The last remaining items to copy are those related to Hiera.

First, copy over your `hiera.yaml` configuration file.

    cp hiera.yaml /root/control-repo/hiera.yaml

Then recursively copy the Hiera data directory and its contents.

    cp -r data /root/control-repo/data

## Git repository initialization

With this done, your control repository includes everything needed to manage
your Puppet infrastructure. You're ready to check your Puppet code into source
control. To do this, you'll be using the `git` command-line tool. This quest
will provide all the Git commands needed to complete this process and address
steps that are specifically relevant to Puppet, but will not go into great
depth about the inner workings of Git—it is a complex tool in its own right,
and there are plenty of existing resources available online to help get you
up to speed. (See the *Additional Resources* section at the end of this quest
for a few examples.)

First, you will need to initialize the `control-repo` directory as a Git
repository. Next, you will set up a hosted remote repository to act as an
upstream source for your code. Finally, you will configure Puppet to fetch code
from the hosted control repository and deploy it to the Puppet master's
production environment.

This architecture allows multiple contributors to work on the same codebase
while ensuring that any changes they make can be tested and approved before
being committed to the upstream repository and deployed to production.

![image](../assets/git_workflow.png)

<div class = "lvm-task-number"><p>Task 6:</p></div>

First, navigate to the `control-repo` directory.

    cd /root/control-repo

Use the `git init` command to initialize your `control-repo` directory as a Git
repository. This command will create a hidden `.git` subdirectory to store
repository data.

    git init

Stage the files in your control repository for an initial commit with the `git
add` command. In this case, you can easily add everything by using the `*`
wildcard.  Be aware, however, that in most cases it is best to use more
specific `git add` commands to ensure that you are always aware of which files
you're staging for your commit.

    git add *

Use the `git status` command to see the list of files that will be added in
your commit.

    git status

Now that these files are staged, commit the changes. When you commit changes,
you will be prompted for a commit message. This message should include a
concise title separate by one line from a complete description of the changes
introduced by the commit. Projects and teams should develop their own
conventions around the specifics of a good commit message to ensure that there
is a complete record of all code changes.

    git commit

When prompted, enter something like the following as your commit message. When
you save and exit Vim, Git will pick up the commit message you entered and
complete the commit.

```
Initial commit

This initial commit includes Hiera configuration, site
modules developed in previous Learning VM quests,
classification defined by the site.pp manifest, and
an environment.conf configuration file.
```

<div class = "lvm-task-number"><p>Task 7:</p></div>

When you ran the `git status` command, you may have noticed that the output
began with the following line:

    On branch master

In Git, a branch represents a chain of commits—all all the individual changes
that have been made to your code to get it to its current state. Generally a
project in Git will have a main branch that includes all the commits that have
been reviewed and approved by the project owners. To keep track of work in
progress before it is approved and merged into the main branch, developers
generally create their own feature branches to keep one or more commits related
to their changes to the main code base.

When you initialize a new repository, Git creates a default main branch called
`master`. The convention for Puppet, however, is to call its main branch
`production`. This way, the branch name matches up with the `production` code
environment on your Puppet master.

Before continuing, then, rename the `master` branch to `production`.

    git branch -m master production

## Upstream remote setup

Now that the repository is initialized locally and your branch name is set
correctly, you're ready to push your local repository to an upstream remote.
This upstream remote is simply another copy of the repository hosted by a
service that makes it available to all collaborators and provides a permissions
system to manage access by these collaborators. By granting Puppet itself
permissions to this hosted repository by way of a deploy key, you will Puppet's
Code Manager tool the ability to fetch hosted Puppet code and deploy it to the
master.

In this case, we'll be using a tool called Gitea to host this upstream remote.
Gitea is an open-source Git hosting service with features generally similar to
[GitHub](https://github.com/). We chose to use Gitea here because we could
easily host an instance on the Learning VM itself. Because stability and
security of your upstream remote can be critical concerns, however, most PE
users use a SaaS option such as GitHub or a similar supported SCM service that
can run on-premise. Once you understand the setup and workflow using Gitea,
however, the principles should translate easily to any of these services.

Before pushing the content of your control repository to Gitea, you'll need to
set up your user account and create your new upstream repository through the
Gitea web interface.

<div class = "lvm-task-number"><p>Task 8:</p></div>

To connect to the Gitea web UI, go to `<VM IP ADDRESS>:3000` in your web
browser.

First, click the **Register** button near the top right of the interface.

![image](../assets/gitea_register.png)

When prompted, enter the following credentials.

**Username:** learning  
**Email:** learning@puppet.vm  
**Password** puppet  

(Note that the Gitea server is running locally on the Learning VM, so unlike an
account on a similar service like GitHub, this account exists only on the
Learning VM's own local Gitea instance.)

Once you have created an account, log in with your new credentials.

<div class = "lvm-task-number"><p>Task 9:</p></div>

Create a new repository by clicking on the `+` icon to the right of the
**My Repositories** header.

![image](../assets/gitea_new_repo.png)

Enter `control-repo` in the **Repository Name** field. Leave the other fields
empty or with their default values. Click the **Create Repository** button at
the bottom of the page.

Now that this Gitea repository is set up, return to the Learning VM command
line.

<div class = "lvm-task-number"><p>Task 10:</p></div>

From within your `/root/control-repo` directory, run the following command to
set the Gitea hosted repository as your local repository's upstream remote.

    git remote add upstream http://localhost:3000/learning/control-repo.git

To validate that your remote was correctly added, run:

    git remote -v

You should see the following output:

    upstream        http://localhost:3000/learning/control-repo.git (fetch)
    upstream        http://localhost:3000/learning/control-repo.git (push)

<div class = "lvm-task-number"><p>Task 11:</p></div>

Next, push your local `production` branch to this upstream remote. Note that
because this is the first time you're adding content to the upstream remote,
you're pushing it directly to the `production` branch. Normally you would
create a new branch and submit a pull request to avoid making changes to your
production infrastructure without review or testing. We'll go over that full
workflow a little later in this quest.

    git push upstream production

Enter the username `learning` and password `puppet` if prompted.

Return to the Gitea interface in your browser or refresh the page. You can now
access all the content of your control repository through the Gitea web
interface.

<div class = "lvm-task-number"><p>Task 12:</p></div>

Because you have changed your default branch to `production` locally, you
need to make a corresponding change to the upstream repository. Open the
**Settings** page in the Gitea interface, and click on the **Branches** tab.

![image](../assets/gitea_settings.png)

In the **Default Branch** section, select `production` from the dropdown menu
and click the **Update Settings** button to save your change.

![image](../assets/gitea_default_branch.png)

## Code Manager deploy key

The Code Manager tool lets you automate the deployment of Puppet code to your
master from a control repository. To configure code manager, we'll need to set
up authentication with an RSA keypair. This will allow Gitea to authenticate
the Puppet master when it requests code from the control repository to deploy.

First, we'll create the key on the Learning VM and give the `pe-puppet` user
access to it. Next, we'll add the public half of this key to the upstream
remote via the Gitea interface. Finally, we'll use the PE console to enable
Code Manager and tell it where to find the private half of the keypair it will
use to authenticate itself with Gitea.

<div class = "lvm-task-number"><p>Task 13:</p></div>

Begin by creating a new `ssh` subdirectory in `/etc/puppetlabs/puppetserver`:

    mkdir /etc/puppetlabs/puppetserver/ssh

Next, use the `ssh-keygen` command to generate a new keypair.

    ssh-keygen -t rsa -b 4096 -C "learning@puppet.vm"

When prompted, save the key to the following file:

    /etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa

When prompted for a passphrase, hit enter twice to create a key without a
passphrase.

Set the owner and group of this `ssh` subdirectory to `pe-puppet`:

    chown -R pe-puppet:pe-puppet /etc/puppetlabs/puppetserver/ssh

<div class = "lvm-task-number"><p>Task 14:</p></div>

Now that the keypair is set up, you'll need to add it to Gitea.

First, click on the **Settings** tab near the top right of the window. From
here, go to the **Deploy Keys** section.

To add your deploy key, you have two options. Your first option is to simply
copy and paste the key. You can view the public key on the vim with the `cat`
command.

    cat /etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa.pub

Copy only the actual key segment between `ssh-rsa` and `learning@puppet.vm` to
your clipboard. Click on the **Add Deploy Key** button in the Gitea interface,
and paste the key into the **Content** field of the form. If you are copying
from the Learning VM's web-based console, you will have to manually delete
several line-breaks to ensure that you're inputting a clean copy of the public
key. Set the **Title** field to "Code Manager", leave the **Enable Write Access**
checkbox unchecked, and click on the **Add Deploy Key** button to add the key.
If you get an error, check that what you inserted matches the key exactly,
without linebreaks or extra spaces before or after the key.

The other option is to run the following command on the Learning VM to add the
key via Gitea's API.

		curl -i \
		-H "Content-Type: application/json" \
		-X POST -d "{\"Title\": \"Code Manager\",\"Key\": \"$(cut -d' ' -f 2 /etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa.pub)\"}" \
		http://learning:puppet@localhost:3000/api/v1/repos/learning/control-repo/keys

Once you've run this command, refresh your browser window to confirm that the
key has been added successfully.

## Code Manager configuration

Before you can deploy code from your control repository, you need to enable and
configure Code Manager. Code Manager, like many of PE's internal configuration
options, is managed by Puppet itself. Most configuration options of your Puppet
master, including those related to Code Manager, are managed by the
`puppet_enterprise::profile::master` class. Like any Puppet class, this master
profile can be configured through its parameters.

So far, you've been using the `site.pp` manifest to assign classes to nodes and
set their parameters. The PE console's interface provides an alternative
interface for node classification. The PE console's node classifier includes a
built-in set of node groups and classifications that define configuration
related to Puppet itself.

<div class = "lvm-task-number"><p>Task 15:</p></div>

First, open the PE console interface in your browser by navigating to
`https://<VM IP ADDRESS>`. Log in with the credentials:

**user:** admin  
**password:** puppetlabs

Click on the **Classification** tab in the PE console navigation menu. From
there, expand the **All nodes** and **PE Infrastructure** groups and select
the **PE Master** node group.

![image](../assets/pe_console_master.png)

In the **PE Master** node group interface, select the **Configuration** tab.
Locate the `puppet_enterprise::profile::master` class in the class list.

Select the `code_manager_auto_configure` parameter from the drop-down menu and
set the value to `true`. Click the **Add parameter** button to the left.
Following the same method, set the `r10k_remote` parameter to
`http://localhost:3000/learning/control-repo.git`, the `r10k_private_key`
parameter to `/etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa`, and
`file_sync_enabled` to `true`.

Click the `Commit N changes` button to save your changes to the console.

![image](../assets/pe_console_code_manager.png)

<div class = "lvm-task-number"><p>Task 16:</p></div>

Trigger a puppet agent run to enforce these configuration changes on the
master.

    puppet agent -t

## Deploying Puppet code

With Code Manager configured and your deploy key set up, the Puppet master has
read access to the code in your repository. Before this code in your control
repository is actually used, however, it will need to be deployed to a code
environment on the master.

There are some options for further automation of this process. For example, you
can [configure a
webhook](https://puppet.com/docs/pe/2019.8/code_mgr_webhook.html)
to automatically trigger a deployment whenever new code is merged to the
upstream repository. In this case, we'll keep things simple and hands-on by
using the `puppet code deploy` command to manually trigger a code deployment.

Like the `puppet job run` command you've been using to trigger Puppet runs,
this command can be run from any workstation with the correct credentials and
network access to the Puppet master.

<div class = "lvm-task-number"><p>Task 17:</p></div>
 
From the PE console interface, click on **Access Control** in the left
navigation bar and select the **User Roles** link in the left navigation bar.
Click on the **Code Deployers** role.  From the **Member Users** tab, select
your `Learning` user from the dropdown menu and click **Add user** to add this
user to the role.

Click the `Commit 1 change` button to save your changes to the console.

<div class = "lvm-task-number"><p>Task 18:</p></div>

Now use the `puppet access` command to generate a token.

    puppet access login --lifetime 1d

When prompted, use the following credentials:

**Username:** learning  
**Password:** puppet  

Use the `puppet code deploy` command to deploy the production branch of your
control repository to your production code environment. Add the `--wait` flag
to tell the command to wait until the deploy is complete before exiting.

    puppet code deploy production --wait

When the deploy process completes, your production code directory at
`/etc/puppetlabs/code/environments/production` will by synchronized with your
control repository.

<div class = "lvm-task-number"><p>Task 19:</p></div>

Use the `puppet job` tool to trigger a Puppet agent run on the
`pasture-app.beauvine.vm` node. When this quest began, a new instance of this
node was created without any previous configuration applied, so this run will
test that the newly deployed code from your repository can create and apply a
correct catalog for this node. This Puppet run will apply the configuration
currently defined in your `role::pasture_app`, as specified by the `site.pp`
manifest.

    puppet job run --nodes pasture-app.beauvine.vm

Once the job is complete, validate that the service is running as expected on
the node:

    curl 'pasture-app.beauvine.vm/api/v1/cowsay'

## Control repository development workflow

Now that Puppet is running with code deployed from your control repository,
let's walk through the process of introducing changes to your local copy of
the repository, creating a PR to merge those changes to your upstream
repository, and finally deploying those changes to production.

<div class = "lvm-task-number"><p>Task 20:</p></div>

First, be sure you're working in this `control-repo` directory:

    cd ~/control-repo

Before beginning work, take a moment to check the status of the Git repository.

    git status

You should see the following message:

    # On branch production
    nothing to commit, working directory clean

You can see that you're currently on the production branch, and that there are
no uncommitted changes in the working directory.

Next, it's good practice to check for updates to the upstream remote before
beginning new work. Collaborators may have introduced changes to the upstream
repository. To avoid merge conflicts, pull any changes into your local
repository before starting new work.

    git pull upstream production

Git shows you that your local repository is up to date with the upstream
version, so no changes have been made.

    From http://localhost:3000/<yourname>/control-repo
    * branch            production -> FETCH_HEAD
    Already up-to-date.

Now that you've verified the status of your local repository, you're ready to
begin work on a new branch. The focus of this quest is the control repository
and code deployer workflow, so we'll make a small and easily tested change to
the `default_message` parameter in your `beauvine.vm` domain's Hiera data.

To begin work on this change, create a new branch. The branch name should be
brief, but still give good idea of what changes the branch will introduce.
Let's call it `beauvine_default_message`. Use the `git checkout` command to
switch to this branch. The `-b` flag tells Git to create a new branch with this
name if it doesn't already exist.

    git checkout -b beauvine_default_message

With this new branch set up, open the `data/domain/beauvine.vm.yaml` file
in Vim.

    vim data/domain/beauvine.vm.yaml

Here, edit the value of the `default_message` variable to read `'Hello control
repository!'`.

```yaml
profile::pasture::app::default_message: "Hello control repository!"
```

<div class = "lvm-task-number"><p>Task 21:</p></div>

Once you've made your change, check the status of the repository.

    git status

The output will show your current branch and give you a list of the changes
that have not yet been staged for commit:

```
# On branch beauvine_default_message
# Changes not staged for commit:
#   (use "git add <file>..." to update what will be committed)
#   (use "git checkout -- <file>..." to discard changes in working directory)
#
#       modified:   data/domain/beauvine.vm.yaml
#
no changes added to commit (use "git add" and/or "git commit -a")
```

To stage your change, use the `git add` command. This will tell Git to include
your change to this file in your next commit. If you had changed multiple
files, you would add each so that they could be included in the same commit.

    git add data/domain/beauvine.vm.yaml

Once your change is staged, check the status again to see the file listed as
a change to be committed.

```
# On branch beauvine_default_message
# Changes to be committed:
#   (use "git reset HEAD <file>..." to unstage)
#
#       modified:   data/domain/beauvine.vm.yaml
#
```

Now that your change is staged, you're ready to commit it.

    git commit

When prompted, enter the following commit message to describe your change.
Your commit message doesn't need to match exactly what is given below, but it's
important that you take the time to write out a complete message. Including a
useful commit message each time you make a change will ensure that you have a
detailed log of all changes to your code to use as a reference when
troubleshooting an issue or planning new changes. 

```
Change beauvine default_message in Hiera

Change the default_message value for the beauvine domain to "Hello
control repository!" to demonstrate the code management workflow with a
control repository.
# Please enter the commit message for your changes. Lines starting
# with '#' will be ignored, and an empty message aborts the commit.
#
# Committer: root <root@learning.puppetlabs.vm>
#
# On branch beauvine_default_message
# Changes to be committed:
#   (use "git reset HEAD <file>..." to unstage)
#
#       modified:   data/domain/beauvine.vm.yaml
#
```

<div class = "lvm-task-number"><p>Task 22:</p></div>

Now that you have committed your changes to your local branch, push the branch
to your upstream repository.

    git push upstream beauvine_default_message

When prompted, enter your Gitea user account name and password: `learning` and
`puppet`.

<div class = "lvm-task-number"><p>Task 23:</p></div>

To merge the changes in this branch into your production branch, you will first
create a pull request. A pull request is a way of suggesting that commits in
one branch of a project are merged into another. A pull request creates an
opportunity for collaborators on a project to do a final review of code changes
before incorporating them into the project's main branch.

Open the Gitea interface (`<VM's IP ADDRESS>:3000`) in a browser window.

From the **Branch:** dropdown menu, select your new `beauvine_default_message`
branch. Click the icon next to the dropdown menu to compare your branches and
begin a pull request. Fill out the pull request form with the title and
description of your pull request. Because this pull request consists of a
single commit, you may want to use the same title and commit message as that
commit.

Click the **Create Pull Request** button to create the pull request.

At this point, you would normally wait for one or more collaborators to review,
test, and merge your pull request. In this case, you'll have to do the
reviewing and merging yourself.

Click on the **Files changed** tab, and examine the difference in code shown.
We haven't introduced methods for doing more complete testing of Puppet code,
so you'll have to satisfy yourself with a quick review of the code change.

When you're satisfied that your change is good, return to the **Conversation**
tab and click the **Merge Pull Request** button.

<div class = "lvm-task-number"><p>Task 24:</p></div>

Now that your change has been merged into your upstream repository's production
branch, return the Learning VM command-line. Use `puppet code deploy`
command to deploy your new code to the production environment.

    puppet code deploy production --wait

<div class = "lvm-task-number"><p>Task 25:</p></div>

When the code deploy completes, trigger another Puppet run on your node to
apply the changes.

    puppet job run --nodes pasture-app.beauvine.vm

Validate that the service now returns the new default message.

    curl 'pasture-app.beauvine.vm/api/v1/cowsay'

## Review

In this quest, you learned about the importance of a source control system for
tracking and approving changes to your infrastructure by managing the
underlying Puppet code. You then walked through the set up of a control
repository and the workflow involved in developing and deploying code changes.

You began by using the `git` command-line tool to create and initialize a
control repository and moving your existing code into that repository.

Once your repository was set up locally, you used the Gitea service to create a
remote upstream repository. This upstream repository serves as the central
source for all the code you will be deploying to your Puppet master.

With that repository set up, you used the PE console to configure Puppet's
Code Manager tool to connect to your control repository hosted on Gitea.

After deploying the existing code to test the system, you triggered a Puppet
agent run on the `pasture-app.beauvine.vm` node to validate that your
master's Puppet code would still function as expected.

Finally, you went through the workflow of making a change in your local
repository, using a pull request to merge it into your upstream production
branch, and deploying and testing the new code.

## Additional Resources

* Read up on using a control repository, the Code Manager tool, and other
  relevant topics in the [managing and deploying Puppet code](https://puppet.com/docs/pe/2019.8/managing_puppet_code.html ) section of the Puppet docs.
* Puppet maintains a [template control repository](https://github.com/puppetlabs/control-repo)
  you can clone directly to get started on your own or use as reference.
* You can find some good discussion of how a control repository can fit with
  the roles and profiles patterns [here](http://garylarizza.com/blog/2017/01/17/roles-and-profiles-in-a-control-repo/)

