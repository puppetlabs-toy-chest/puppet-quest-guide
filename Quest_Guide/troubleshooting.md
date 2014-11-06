---
title: Troubleshooting
layout: default
---

# Troubleshooting

If you have feedback or run into any issues with the Learning VM, please visit
our public issue tracker or email us at learningvm@puppetlabs.com.

Puppet Labs maintains a list of [known Puppet Enterprise
issues](https://docs.puppetlabs.com/pe/latest/release_notes.html#known-issues).

## Common Issues:

#### I've completed a task, but it hasn't registered in the quest tool.

Some tasks are verified on the presence of a specific string in a file, so a
typo can prevent the task from registering as complete even if your Puppet code
validates and your puppet agent run is successful. You can check the actual spec
tests we use with the quest tool in the `~/.testing/spec/localhost` directory.

While most tasks validate some change you have made to the system, there are a
few that check for a specific line in your bash history. The file that tracks
this history isn't created until you log out from the VM for the first time. In
the setup instructions, we suggest that you log out from the VM before
establishing an SSH connection. If you haven't done this, certain tasks won't
register as complete. Also, because the quest tool looks for a specific command,
the tasks may not register as complete if you've included a slight variation
even if it has the same effect.

#### I can't access the PE Console with Safari.

This is a [known
issue](https://docs.puppetlabs.com/pe/latest/release_notes.html#safari-certificate-handling-may-prevent-console-access)
with the way Safari handles certificates. You may encounter a dialog box
prompting you to select a certificate.  If this happens, you may have to click
`Cancel` several times to access the console. This issue will be fixed in a
future release of PE.

#### The Learning VM cannot complete a Puppet run, or does so very slowly.

It's likely that you haven't assigned enough memory or processor cores to the
Learning VM, or that your host system doesn't have the available resources to
allocate. Power down the VM and increase the processor cores to 2 and the memory
to 4 GB. You may also need to close other processes running on the host machine
to free up resources.
