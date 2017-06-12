{% include '/version.md' %}

# Learning VM Troubleshooting

For the most up-to-date version of this troubleshooting information, [check the
GitHub
repository](https://github.com/puppetlabs/puppet-quest-guide/blob/master/troubleshooting.md).

### I completed a task, but the quest tool doesn't show it as complete

The quest tool uses a series of [Serverspec](http://serverspec.org/) tests for
each quest to track task progress, but the match between a task and test isn't
always perfect.

Certain tasks that don't have other testable effects on the system rely on
checking your bash history for an entered command. It's possible that you have
entered a valid alternate version of the command that wasn't anticipated in our
tests.

For tasks that relate to Puppet code or the contents of other files,
we have written the test for a task in a way that doesn't capture a valid
syntactical variation.

You can check the specific matchers by looking at a quest's spec file in the
`/usr/src/puppet-quest-guide/tests` directory. If you find an issue with the
tests, please let us know by sending an email to learningvm@puppet.com.

### Password Required for the Quest Guide

The Learning VM's Quest Guide is accessible at `http://<VM's IP Address>`. Note
that this is `http` and not `https` which is reserved for the PE console. The
PE console will prompt you for a password, while no password is required for
the Quest Guide.  (The Quest Guide includes a password for the PE console in
the Power of Puppet quest: **admin/puppetlabs**)

### I can't find the VM password

The Learning VM's password is generated randomly and will be shown on
the splash page displayed on the terminal of your virtualization software when
you start the VM.

If you are already logged in via your virtualization software's terminal, you
can use the following command to view the password: `cat /var/local/password`.

Occasionally, the splash page will not be displayed on the web interface
console. This can generally be resolved by refreshing the page.

### Does the Learning VM work on vSphere, ESXi, etc.?

While the VM should be compatible with these platforms, we don't test or
support the VM in this context.

### I cannot connect to the PE console

To connect to the PE console, you must use `https` rather than `http`.

The console uses a self-signed certificate, which means that most browsers will
show a security warning. To bypass this warning, you may have to click the
*advanced* link displayed on the warning page.

It may take some time after the VM is started before all the Puppet services
are fully started. If you attempt to connect to the console before the service
is started, you will see a 503 error. If you recently started or restarted the
VM, or restarted any services in the PE stack, please wait a few minutes before
you try to access the PE console. See the section on PE services below.

### One of the PE services hasn't started or has crashed

Because the Learning VM's Puppet services are configured to run in an
environment with restricted resources, they may have a longer restart time and
may be less stable than is typical of a production installation.

On restarting the VM, it may take several minutes for the PE services to fully
start. If you have restarted the VM and immediately try to connect to the PE
console or trigger a Puppet agent run, you may encounter errors until these
services have had time to fully start.

You can check the status of Puppet services with the following command:

    systemctl --all | grep pe-

If still observe stopped Puppet-related services (e.g. pe-console-services)
several minutes after the VM has started, double check that you have sufficient
memory allocated to the VM and available on your host, then use the following
script to restart these services in the correct order:

    restart_pe_services.sh

### My Puppet run fails!

There are several common reasons for a Puppet run to fail.

If a syntax error is indicated, please correct the specified file. Note that
due to the way syntax is parsed, an error may not always be on the line
indicated. For example, a missing comma, bracket, or parenthesis will likely
cause a syntax error on a later line.

If you see an issue including `connect(2) for "learning.puppetlabs.vm" port
8140` this generally indicates that the `pe-puppetserver` service is down. See
the section above for instructions on checking and restarting PE services.

Similarly, an error including `Failed to find facts from PuppetDB at
learning.puppetlabs.vm:8140` generally indicates that the `pe-puppetdb` service
is down. Again, refer to the section above for instructions on checking and
restarting PE services.

When triggering a Puppet run via the `puppet job` tool, you may see an error
similar to `Error running puppet on pasture.puppet.vm: pasture.puppet.vm is not
connected to the PCP broker`. A node connects to the PCP broker on its initial
Puppet run. The agent nodes created by the `quest` tool will automatically run
Puppet as they are created, which should generally connect the node to the PCP
broker. If this initial Puppet run fails, however, the node will not be
connected to the PCP broker, resulting in the error shown. To troubleshoot this
issue, connect to the agent node directly and manually trigger a Puppet agent
run. This will either generate an error message to indicate the cause of the
agent run's failure or run successfully and connect the node to the PCP broker.

### I cannot import or start the OVA

Ensure that you have an up-to-date version of your virtualization software
installed.  Note that the "check for updates" feature of VirtualBox may not
always work as expected, so check the website for the most recent version.

Ensure that virtualization extensions enabled in the BIOS. The steps to do this
will be specific to your system, will generally available online.

If you are using Mac OS X and see `Unable to retrieve kernel symbols`,
`Failed to initialize monitor device`, or `Internal error`, please refer to
[this VMWare knowledge base page](https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2061791).

VirtualBox is not compatible with Hyper-V. You will need to disable Hyper-V on
your system to successfully run the VM with VirtualBox.

### The Learning VM has no IP address or the IP address will not respond.

If your network connection has changed since you loaded the VM, it's possible
that your IP address is different from that displayed on the Learning VM splash
screen. Log in to the VM via the virtualization directly (rather than SSH) and
use the `ifconfig | less` command to show the IP address associated with each
network interface. There will be several interfaces listed, including those
used for internal docker networking. The correct interface will usually start
with `eth` or `enp`. If you continue to get no IP address or an
invalid IP address, restarting the VM is generally the quickest way to ensure
that the network services are correctly reset. (Unfortunately restarting the
network service directly isn't always reliable.)

It is also possible that the bridged adapter interface configured in the VM
network settings menu of your virtualization software is incorrect. This can
happen if you change from a wired to wireless network after setting the
interface for the first time. In the Network setting dialog, check that the
name of the adapter matches that of the connection you are currently using. 

If you are using a bridged network adapter, some network configurations may
still prevent you from accessing the Learning VM. If this is the case, we
recommend that you speak to your site network administrator to see if there are
any firewall rules, proxies, or DHCP server setting that might be preventing
you from accessing the VM. If you are unable to resolve the issue, we recommend
following the directions in the setup guide to configure a host-only network
adapter for the VM.

### I can't scroll up in my terminal

The Learning VM uses a tool called tmux to allow us to display the quest
status. You can scroll in tmux by first hitting control-b, then [ (left
bracket). You will then be able to use the arrow keys to scroll. Press q to
exit scrolling.

### Still need help?

If your puppet runs still fail after trying the steps above, check the Puppet
Enterprise [Known
Issues](https://docs.puppet.com/pe/latest/release_notes_known_issues.html)
page or feel free to contact us at learningvm@puppet.com. Please include
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
