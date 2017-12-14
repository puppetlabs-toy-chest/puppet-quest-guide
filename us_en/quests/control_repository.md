{% include '/version.md' %}

# Control repository

## Quest objectives

- Create a control repository to manage the code that defines your infrastructure.
- Learn the basics of source-control management with git.
- Use the Code Manager tool to deploy code to your production environment.

## Getting started

In this quest, you'll learn how to set up a control repository and begin to
manage the Puppet code that defines your infrastructure through a git
source-control management (SCM) workflow. Checking your Puppet code into SCM
makes it much easier for you and your team to collaborate, control change, and
safely test new features.

Though it is possible to use other SCM tools with Puppet, this quest focuses on
git. Learning to use git effectively can be an undertaking in itself. This
quest will provide all the git commands necessary to complete the included
tasks, but it is not focused on teaching git itself. Keep in mind that the git
workflow included here is intended only as a working example; if git or another
SCM tool is already implemented in your organization, there may be established
practices that differ from the workflow outlined here.

If you would like to learn git or brush up on your skills, you can start with
an excellent tutorial [here](https://try.github.io/levels/1/challenges/1).

When you're ready to get started, type the following command:

    quest begin control_repository

## Control repository

So far, the work you've done on the Learning VM has been on modules included
directly in Puppet's modulepath. As a learning exercise, this has the advantage
of simplicity and directness, but when you begin to manage production
infrastructure with Puppet, you'll need to adopt a workflow that allows room
for code review and testing before changes to your Puppet code are promoted to
your production infrastructure.

A control repository is an SCM repository containing the code and configuration
that define your Puppet infrastructure. By moving the code that defines your
infrastructure into a control repository, you can work on a checked-out copy
of the code in a separate directory (and generally on a different workstation)
from your Master's actual modulepath. You can then control the process of
introducing changes to your codebase and allow for testing and review before
those changes are deployed to your production infrastructure.

<div class = "lvm-task-number"><p>Task 1:</p></div>

Begin by creating a `control-repo` directory in your home directory. This
new directory will include `site` and `manifests` subdirectories.

    cd && mkdir -p control-repo/{site,manifests}

The `site` directory will contain your role and profile classes as well as the
site-specific component modules you developed in the previous quests.

The `manifests` directory will contain your `site.pp` manifest.

<div class = "lvm-task-number"><p>Task 2:</p></div>

Copy the `pasture`, `motd`, `user_accounts`, `role`, and `profile` Puppet
modules you created in the previous quests into the your control repository's
`site` directory. The name of this "site" directory refers to the fact that the
modules it contains should be site-specific. General purpose component modules
taken from the Forge or from other repositories will be managed by a
Puppetfile, which we will introduce later in this quest.

    cp -r /etc/puppetlabs/code/environments/production/modules/{pasture,motd,user_accounts,role,profile} ./control_repo/site/

Next, copy your existing `site.pp` module from the production `manifests`
directory into your control repository's `manifests` directory.

    cp -r /etc/puppetlabs/code/environments/production/manifests/site.pp ./control_repo/manifests/

Now that you've copied your Puppet code into this new repository, you're ready
to check it into source control. First, you will initialize your local
`control_repo` directory as a git repository. Next, you will set up a hosted
remote repository to act as an upstream source for your code. When you deploy
your code, Puppet will fetch it from this upstream repository.

This architecure allows multiple developers to all work on the same codebase
while ensuring that any changes they make can be tested and approved before
being committed to the upstream repository and deployed to production.

The Learning VM is running a lightweight git server application called Gitea.
Gitea will host the upstream remote version of your control_repo repository. If
you've used GitHub, you will find the Gitea interface familiar. (Outside of the
Learning VM, you will likely want to use a git hosting service such as GitHub,
GitLab, or Bitbucket.)

<div class = "lvm-task-number"><p>Task 3:</p></div>

Use the `git init` command to initialize your `control_repo` directory as a git
repository. This command will create a hidden `.git` subdirectory that git uses
to store repository data.

    git init

Stage the files in your control repository for a commit with the `git add`
command. In this case, you can easily add everything by using the `*` wildcard.
Be aware that in most cases it is best to use more specific `git add` commands
to ensure that you are always aware of which files you're staging for your
commit.

    git add *

Use the `git status` command to see the list of files that will be added in
your next commit.

    git status

Now that these files are staged, commit the changes. When you commit changes,
you will be prompted for a commit message, which should consist of a concise
title separate by one line from a complete description of the changes
introduced by the commit. Projects and teams should develop their own
conventions around the specifics of a good commit message to ensure that there
is a complete record of all code changes.

    git commit

Enter something like the following as your commit message. When you save and
exit Vim, git will pick up the commit message you entered and complete the
commit.

```
Initial commit of existing modules

Add existing modules developed in prior Learning VM quests
to this control repository.
```

When you initialize a new git repository, git creates a default branch called
`master`. Rename this `master` branch to `production`.

    git branch -m master production

Each branch in git represents a different line of development. Branching allows
a contributor make changes in a new branch without impacting the main version
of the repository. Once changes in a branch are reviewed and tested, they can
be merged into the main branch with a pull request. In the case of a Puppet
control repository, this main branch of code corresponds to your production
infrastructure, so we call it `production` rather than `master`.

<div class = "lvm-task-number"><p>Task 4:</p></div>

Now that the repository is initialized locally, you're ready to push it up to
the host server.

To connect to the Gitea service UI, go to <VM IP ADDRESS>:3000 in your web
browser.

First, create a new account. The Gitea server is running locally on the
Learning VM, so this account will exist only on the Learning VM itself.

Once you have created an account, log in.

Create a new repository by clicking on the `+` icon to the left of the **My
Repositories** header.

Name the repository `control-repo`, and click the **Create Repository** button
at the bottom of the page.

Once the repository is created, return to the Learning VM. From within your
`control-repo` directory, run the following commands to set the Gitea hosted
repository as your local repository's upstream remote, replacing `<gitea_name>`
with the account name you selected for Gitea.

    git remote add upstream http://localhost:3000/<gitea_name>/control-repo.git

To validate that your remote was correctly added, run:

    git remote -v

You should something like the following, but with your own username
substituted.

    upstream        http://localhost:3000/<gitea_name>/control-repo.git (fetch)
    upstream        http://localhost:3000/<gitea_name>/control-repo.git (push)

Next, push your local production branch to this upstream remote. Note that this
initialization step should be the **only** time you push changes directly to
the production branch of your control repository!

    git push upstream production

Return to the Gitea interface in your browser or refresh the page. You can now
browse all the content of your control repo through this interface.

Because you have changed your default branch to `production` locally, you will
now need to make a corresponding change to the upstream repository. Open the
**Settings** page in the Gitea interface, and click on the **Branches** tab.
In the **Default Branch** section, select `production` from the dropdown menu
and click the **Update Settings** button to save your change.

The next step is to add a deploy key to this repository. This will give the
Puppet code manager read access to the repository.

First, create a new `ssh` subdirectory in `/etc/puppetlabs/puppetserver`:

    mkdir /etc/puppetlabs/puppetserver/ssh

    ssh-keygen -t rsa -b 4096 -C "learning@puppet.vm"

    /etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa

Set the owner and group of this `ssh` subdirectory to `pe-puppet`:

    chown -R pe-puppet:pe-puppet /etc/puppetlabs/puppetserver/ssh

Now that this key is set up, view the public half of the keypair.

    cat /etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa.pub

Copy *only* the actual key portion between `ssh-rsa` and `learning@puppet.vm` (not
inclusive) to your clipboard.

Return to your control repository in the Gitea web UI and open the **Settings**
tab. Go to the **Deploy Keys** section and click the **Add Deploy Key** button.
Paste the public key into the **Content** textbox and enter the **Title**
Puppet Code Manager. Click the **Add Deploy Key** button to save the key.

If you get an error, double-check that you copied the key from the public key
with the `.pub` extension, that you only copied the key itself, and that you
don't have extra spaces or newline characters before or after the key.

Before you can deploy code from your control repository, you need to enable
code manager via the PE console.

To do this, first open the PE console interface in your browser by navigating
to `https://<VM IP ADDRESS>`. Log in with the credentials:

**user:** admin  
**password:** puppetlabs

Click on the **Classifaction** tab in the PE console navigation menu. From
there, select the **PE Master** node group. (This node group is nested under
**All Nodes** > **PE Infrastructure**)

In the **PE Master** node group interface, select the **Classes** tab. Locate
the `puppet_enterprise::profile::master` class in the class list. Select the
`code_manager_auto_configure` parameter from the drop-down menu and set the
value to `true`. Click the **Add parameter** button to the left. Following the
same method, set the `r10k_remote` parameter to
`localhost:3000/<gitea_name>/control-repo.git`, the `r10k_private_key`
parameter to `/etc/puppetlabs/puppetserver/ssh/id-control.rsa.pub`, and
`file_sync_enabled` to `true`.

Trigger a puppet agent run to enforce these configuration changes on the
master.

    puppet agent -t

We recommend that you manage permissions to deploy code with a dedicated user
in Puppet's role-based access control system. From the PE console interface,
click on **Access Control** in the left navigation bar and select **Users**.
Create a new user with the name `Deployer` and login `deployer`. Once the user
is added, click on the user's name to go to that new user's configuration page.
Find the **Generate password reset** button towards to top right of the screen.
Use the password reset link provided to set the user's password to `puppet`.

Now that this user is created and its password configured, click on the **User
Roles** link in the left navigation bar. Click on the **Code Deployers** role.
From the **Member Users** tab, select your `Deployer` user from the dropdown
menu and click **Add user** to add this user to the role.

With this user created and endowed with the needed permissions, use the
`puppet access` command to generate a token.

    puppet access login --lifetime 1d

When prompted, use the following credentials:

**Username:** deployer  
**Password:** puppet  

Use the `puppet code deploy` command to deploy the production branch of your
control repository to your production code environment. Add the `--wait` flag
to tell the command to wait until the deploy is complete before exiting.

    puppet code deploy production --wait

When the deploy process completes, your production code directory at
`/etc/puppetlabs/code/environments/production` will by synchronized with your
control repository.

Use the `puppet job` tool to trigger a Puppet agent run on the new
`pasture-app-small.puppet.vm` node that was created for this quest. This Puppet
run will apply the configuration currently defined in your `role::pasture_app`
to the node.

    puppet job run --nodes pasture-app-small.puppet.vm

Once the job is complete, validate that the service is running as expected on
the node:

    curl 'pasture-app-small.puppet.vm/api/v1/cowsay'

Now that Puppet is running with code depolyed from your control repository,
let's walk through the process of introducing changes to your control repository
and deploying those changes to production.

Remember, now that the code management workflow is in place, there's no need to
make any direct changes to Puppet code on the master itself. You can check out
your `control-repo` repository to any workstation, make local changes from
there, and submit a pull request to incorporate those changes into your
upstream repository.

For the sake of simplicity, however, the Learning VM itself will also double
as your workstation in this quest. In this quest, we're keep our working copy
of the `control-repo` in the root user's home directory.

First, be sure you're working in this `control-repo` directory:

    cd ~/control-repo

Before beginning work, take a moment to check the status of the git repository.

    git status

You should see the following message:

    # On branch production
    nothing to commit, working directory clean

You can see that you're currently on the production branch, and that there are
no uncommitted changes in the working directory.

Next, it's good practice to check for updates to the upstream remote before
beginning new work. Collaborators may have introduced to the upstream
repository. To avoid merge conflicts, pull any changes into your local
repository before starting new work.

    git pull upstream production

Git shows you that your local repository is up to date with the upstream
version, so no changes have been made.

    From http://localhost:3000/<yourname>/control-repo
    * branch            production -> FETCH_HEAD
    Already up-to-date.

Now that you've verified the status of your local repository, you're ready to
begin work on a new branch. We want to focus on the control repository and
code deployer workflow, so we'll make a minimal change to the code itself.
Modifying the `default_message` parameter is a good candidate because it will
be easy to test.

To begin work on this change, create a new branch. We want the branch name to
be consise, but still give us a good idea of what the branch represents. Let's
call it `update_cowsay_message`. Use the `git checkout` command to switch to
this branch. The `-b` flag tells git to create a new branch with this name it
doesn't already exist.

    git checkout -b update_cowsay_message

Now that your new branch is set up, go ahead and open the manifest that defines
your `profile::pasture::app` manifest.

    vim site/profile/manifests/pasture/app.pp

Here, edit the value of the `default_message` parameter to read `'Hello Code
Manager!'`.

```puppet
class profile::pasture::app {
  if $facts['fqdn'] =~ 'large' {
    $default_character = 'elephant'
    $db                = 'postgres://pasture:m00m00@pasture-db.puppet.vm/pasture'
  } elsif $facts['fqdn'] =~ 'small' {
    $default_character = undef
    $db                = undef
  } else {
    fail("The ${facts['fqdn']} node name must match 'large' or 'small'.")
  }
  class { 'pasture':
    default_message   => 'Hello Code Manager!',
    sinatra_server    => 'thin',
    default_character => $default_character,
    db                => $db,
  }
}
```

Once you've made your change, use `git` to check the status of the repository.

    git status

The output will show your current branch and give you a list of the changes
that have not yet been staged for commit:

```
# On branch update_cowsay_message
# Changes not staged for commit:
#   (use "git add <file>..." to update what will be committed)
#   (use "git checkout -- <file>..." to discard changes in working directory)
#
#       modified:   site/profile/manifests/pasture/app.pp
#
no changes added to commit (use "git add" and/or "git commit -a")
```

To stage your changes, use the `git add` command:

    git add site/profile/manifests/pasture/app.pp

Once your changes are staged, check the status again to see that the right
file has been staged:

```
# On branch update_cowsay_message
# Changes to be committed:
#   (use "git reset HEAD <file>..." to unstage)
#
#       modified:   site/profile/manifests/pasture/app.pp
#
```

Now that your change is staged, you're ready to commit it.

    git commit

When prompted, enter the following commit message to describe your change.
Your commit message doesn't need to match exactly, but it's important that you
take the time to write out a complete message. Stopping to write a useful
commit message each time you make a change will ensure that you have a complete
and detailed log of all changes to your code to use as a reference when
troubleshooting an issue or planning new changes. 

```
Edit default message for small pasture instance 

Change the default message in the profile::pasture::app class to "Hello
Code Manager!" to demonstrate the code management workflow with a control
repository. 
# Please enter the commit message for your changes. Lines starting
# with '#' will be ignored, and an empty message aborts the commit.
#
# Committer: root <root@learning.puppetlabs.vm>
#
# On branch update_cowsay_message
# Changes to be committed:
#   (use "git reset HEAD <file>..." to unstage)
#
#       modified:   site/profile/manifests/pasture/app.pp
#
```

Now that you have committed your changes to your local branch, push that branch
to your remote upstream repository.

    git push upstream update_cowsay_message

When prompted, enter the credentials you set up for your Gitea user account.

Now that you've pushed your new branch to the upstream repository, you're ready
to create a pull request. A pull request is the process by which changes you've
made in a feature branch are incorporated back into your production branch.

Go to your Gitea interface (<IP ADDRESS>:3000).

From the **Branch:** dropdown menu, select your new `update_cowsay_message`
branch. (If you get a 404 error here, but sure you followed the instructions
earlier in this quest to change to default branch from `master` to `production`
in the Gitea repo's **Settings** section.) Click the icon net to the dropdown
menu to compare your branches and begin a pull request. Re-enter the title of
your commit in the title field of the pull request. (A more feature-complete
SCM would auto-fill the title and description of your PR with the corresponding
fields of your last commit, but unfortunately this hasn't yet been implemented
in Gitea.)

Click the **Create Pull Request** button to create a new pull request.

At this point, you would normally wait for one or more reviewers to approve
your changes and merge your pull request. In this case, you'll have to do the
reviewing and merging yourself.

Click on the **Files changed** tab, and examine the difference in code shown.
We haven't introduced methods for doing more complete testing of Puppet code,
so for the moment you will have to satisfy yourself that the change is good
simply by examing the code difference.

Once you are confident that your change is good, return to the **Conversation**
tab and click the **Merge Pull Request** button.

Now that your change has been merged into your production branch, you're ready
to deploy your new code to your production infrastructure!

    puppet code deploy production --wait

Once your new code is deployed, trigger another Puppet run on your node.

    puppet job run --nodes pasture-app-small.puppet.vm

Validate that the service now returns the new default message.

    curl 'pasture-app-small.puppet.vm/api/v1/cowsay'

## Review

We covered a lot of ground in this quest and introduced several new tools and
interfaces. Don't worry if you feel a little overwhelmed. Much of the work done
here pertains only to the initial setup of the system, and the steps of the
workflow itself will be much simpler after this setup is complete.

You began by using the `git` command-line tool to create and initialize a
control repository and moving your existing code into that repository.

Once your repository was set up locally, you also created a remote upstream
repository in Gitea to serve as the central source for all the code you will
be deploying to your Puppet master.

With that repository set up, you used the PE console to configure Puppet's
Code Manager tool to connect to your control repository hosted on Gitea.

After deploying the existing code to test the system, you triggered a Puppet
agent run on the `pasture-app-small.puppet.vm` node to validate that your
master's Puppet code would still function as expected.

Finally, you went through the workflow of making a change in your local
repository, using a pull request to merge it into your upstream production
branch, and deploying and testing the new code.

## Additional Resources
