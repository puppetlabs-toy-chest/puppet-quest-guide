{% include '/version.md' %}

# Learning VM Troubleshooting

For the most up-to-date version of this troubleshooting information, [check the
GitHub
repository](https://github.com/puppetlabs/puppet-quest-guide/blob/master/troubleshooting.md).

### I completed a task, but the quest tool doesn't show it as complete

The quest tool uses a series of [Serverspec](http://serverspec.org/) tests for
each quest to track task progress. Certain tasks simply check your bash history
for an entered command, so it's possible that you entered a valid alternate
version of the command that simply wasn't recognized by the check.

It is also possible that we have written the test for a task in a way that is
too restrictive and doesn't correctly capture a valid syntactical variation in
your Puppet code or another relevant file. You can check the specific matchers
by looking at a quest's spec file in the `/usr/src/puppet-quest-guide/tests`
directory. If you find an issue here, please let us know by sending an email to
learningvm@puppetlabs.com.

If you're willing to do a little archaeology, you can find the tests we use to
validate that quests can be completed in the
`/usr/src/puppet-quest-guide/tests/test_tests` directory. These aren't written
for legibility and use alternate methods such as `sed` and the PE API to
complete tasks, but they might offer some inspiration if you're stuck on a
task. (Note that the test script for the Application Orchestrator quest is
currently incomplete.)

### Password Required for the Quest Guide

The Learning VM's Quest Guide is accessible at `http://<VM's IP Address>`. Note
that this is `http` and not `https` which is reserved for the PE console. The
PE console will prompt you for a password, while no password is required for
the Quest Guide.  (The Quest Guide includes a password for the PE console in
the Power of Puppet quest: **admin/puppetlabs**)

### I can't find the VM password

The password to log in to the VM is generated randomly and will be displayed on
the splash page displayed on the terminal of your virtualization software when
you start the VM.

If you are already logged in via your virtualization software's terminal, you
can use the following command to view the password: `cat /var/local/password`.

If the password is not displayed on the splash page on startup, it is possible
that some error occured during the startup process. Restarting the VM should
regenerate this page with a valid password.

### Does the Learning VM work on vSphere, ESXi, etc.?

Possibly, but we don't currently have the resources to test or support the
Learning VM on these platforms.

### I cannot connect to the PE console

It may take some time after the VM is started before all the Puppet services
are fully started. If you recently started or restarted the VM, or restarted
any services in the PE stack, please wait a few minutes before you try to
access the PE console.

Because the Learning VM's puppet services are configured to run in an
environment with restricted resources, they are more prone to crashes than a
production PE installation.

You can check the status of puppet services with the following command:

    systemctl --all | grep pe-

If you notice any stopped puppet-related services (e.g. pe-console-services),
double check that you have sufficient memory allocated to the VM and available
on your host, then use the following script to restart these services in the
correct order:

    /usr/local/bin/restart_classroom_services.rb all -f

If you continue to have issues starting the PE services stack, please
contact us at learningvm@puppet.com and include your host system details, your
virtualization software and version, and the version of the Learning VM you're
running.

### My Puppet run fails!

There are several common reasons for a Puppet run to fail.

If a syntax error is indicated, please correct the specified file. Note that
due to the way syntax is parsed, an error may not always be on the line
indicated. If you can't locate an error on the line indicated in the error
message, check preceeding lines for missing commas or unmatched delimiters such
as parentheses, brackets, or quotation marks.

If you get an error along the lines of `Error 400 on SERVER: Unknown function
union...` it is likely because the `puppetlabs-stdlib` module has not been
installed. This module is a dependency for many modules, and provides a set of
common functions. If you are running the Learning VM offline, you cannot rely
on the Puppet Forge's dependency resolution. We have this module and all other
modules required for the Learning VM cached, with instructions to install them
in the Power of Puppet quest. If that installation fails, you may try adding
the `--force` flag after the `--ignore-dependencies` flag.

If you see an issue including `connect(2) for "learning.puppetlabs.vm" port
8140` this generally indicates that the `pe-puppetserver` service is down. See
the section above for instructions on checking and restarting PE services.

Similarly, an error including `Failed to find facts from PuppetDB at
learning.puppetlabs.vm:8140` generally indicates that the `pe-puppetdb` service
is down. Again, refer to the section above for instructions on checking and
restarting PE services.

### I can't import the OVA

Ensure that you have an up-to-date version of your virtualization software
installed.  Note that the "check for updates" feature of VirtualBox may not
always work as expected, so check the website for the most recent version.

Ensure that virtualization extensions enabled in the BIOS. The steps to do this
will be specific to your system, will generally available online.

If you are using Mac OS X and see `Unable to retrieve kernel symbols`,
`Failed to initialize monitor device`, or `Internal error`, please refer to
[this VMWare knowledge base page](https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2061791).

### The Learning VM has no IP address or the IP address will not respond.

If your network connection has changed since you loaded the VM, it's possible
that your IP address is different from that displayed on the Learning VM splash
screen. Log in to the VM via the virtualization directly (rather than SSH) and
use the `facter ipaddress` command the check the current address. If you
continue to get an no IP address or an invalid IP address, restarting the VM is
generally the quickest way to ensure that the network services are correctly
reset. (Unfortunately restarting the network service directly isn't always
reliable.)

Some network configurations may still prevent you from accessing the Learning
VM. If this is the case, we recommend that you speak to your site network
administrator to see if there are any firewall rules, proxies, or DHCP server
setting that might be preventing you from accessing the VM.

If you are unable to resolve your network issues, we suggest following the
instructions in the setup guide to run the Learning VM offline. You will be
able to complete all content offline with the exception of the final two
quests which require internet access.

### I can't scroll up in my terminal

The Learning VM uses a tool called tmux to allow us to display the quest
status. You can scroll in tmux by first hitting control-b, then [ (left
bracket). You will then be able to use the arrow keys to scroll. Press q to
exit scrolling.

### Running the VM in VirtualBox, I encounter a series of "Rejecting I/O input from offline devices"

You may try reducing the VM's processors to 1 and disabling the "I/O APIC"
option in the system section of the settings menu. Be aware, however, that
this might result in *very* slow start times for services in the PE stack.

### PE services will not start or take too long to start

Please ensure that your host machine matches the following minimum
requirements:

1. 4GB free memory (8GB is recommended)
1. 2 Core 2.5 Ghz (or better) CPU with 64-bit architecture Up-to-date VirtualBox
or VMware desktop virtualization software

Check that your host system actually has the available resources to allocate to
the VM. If another running process demanding CPU or memory resources, the VM
may not have enough available resources to run the PE stack.

### Still need help?

If your puppet runs still fail after trying the steps above, check the Puppet
Enterprise [Known
Issues](https://docs.puppetlabs.com/pe/latest/release_notes_known_issues.html)
page or feel free to contact us at learningvm@puppetlabs.com. Please include
details of your host OS, virtualization software and version, and any details
of the site network configuration where you're running the VM (for example,
whether there is a proxy or restrictive firewall rules). If there are logs
relevant to the issue, you can use scp from your host machine to copy them to
a local directory:

    scp root@<IPADDRESS>:/var/log/messages messages

On a Windows system wtih [PuTTY PSCP
installed](http://tartarus.org/~simon/putty-snapshots/htmldoc/Chapter5.html#pscp),
you can use `pscp` from a command prompt:

    pscp root@<IPADDRESS>:/var/log/messages messages
