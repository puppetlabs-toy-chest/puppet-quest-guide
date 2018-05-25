{% include '/version.md' %}

# Learning VM Troubleshooting

For the most up-to-date version of this troubleshooting information, [check the
GitHub
repository](https://github.com/puppetlabs/puppet-quest-guide/blob/master/en_us/troubleshooting.md).

### I can't find the Quest Guide for the Learning VM

The Quest Guide is hosted by the VM itself, at http://<IPADDRESS>, where `IPADDRESS` is the
IP address of the VM. Note that the Quest Guide is hosted on http, not https. If
you are prompted for a password, you're looking at the PE console login screen,
which is hosted on https.

### The agent node does not generate a certificate signing request or does not have a signed certificate

If the pe-puppetserver service on the master is not fully started when you begin
a quest, the certification signing request and certificate signing process may not
complete. In this case, use the `systemctl --all | grep pe-` command to validate that
all PE services are fully started, then use the `quest` tool to restart the quest.

### I get a "Connection refused" when trying to run a curl command against the Pasture API

It is likely that your Puppet code itself is correct and able to run without error,
but that there is a problem with the pasture_config.yaml file or pasture.service
file that causes the Pasture service to fail.

You can check the pasture log by connecting to the node and running `journalctl -u pasture`.

Check that the content of the pasture_config.yaml file and pasture.service
file exactly match what's given in the Quest Guide. Note that YAML is sensitive
to whitespace, so your line-breaks and indentations must be correct. If you
think there may be a mistake, but cannot identify it, it may be helpful to
use an online YAML parser such as the one found here: http://yaml-online-parser.appspot.com/

### I get a "Connection refused" error when attempting to install the puppet agent

It is likely that the pe-puppetserver service hasn't fully started or has
failed due to a lack of memory. Restart the machine and give the `pe-puppetserver`
service several minutes to complete startup before using the quest tool to
restart the quest and trying again. You can check the status of all the PE
services with the `systemctl --all | grep pe-` command. If you continue to
have issues, you may want to check that you have the correct amount of memory
allocated to the VM as specified in the setup guide, and that the host machine
actually has that memory available to provide for the VM.

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
`/usr/src/puppet-quest-guide/tests` directory on the Learning VM, or the latest
corresponding code in the Quest Guide [repository](https://github.com/puppetlabs/puppet-quest-guide/tree/master/tests).
You can also find the solution files we use in testing in the `solution_files`
subdirectory under that `tests` directory.

If you find an issue with the tests or fixtures, please let us know by sending an
email to learningvm@puppet.com.

### Do I need a password for the Quest Guide?

No. The Learning VM's Quest Guide is accessible at `http://<IPAddress>` where `IPAddress`
is the password of the Learning VM. Note that this is `http` and not `https`,
which is reserved for the PE console. The PE console will prompt you for a password,
while no password is required for the Quest Guide.

### I can't find the VM login password

The Learning VM's password is generated randomly and will be shown on
the splash page displayed on the terminal of your virtualization software when
you start the VM.

If you are already logged in via your virtualization software's terminal, you
can use the following command to view the password: `cat /var/local/password`.

Occasionally, the splash page will not be displayed on the web interface
console. This can generally be resolved by refreshing the page.

### Does the Learning VM work on vSphere, ESXi, etc.?

While the VM may be compatible with these platforms, we don't test or
support the VM in this context.

### I cannot connect to the PE console

The console uses a self-signed certificate, which means that most browsers will
show a security warning. To bypass this warning, you may have to click the
*advanced* link displayed on the warning page.

It may take some time after the VM is started before all the Puppet services
are fully started. If you attempt to connect to the console before the service
is started, you will see a 503 error. If you recently started or restarted the
VM, or restarted any services in the PE stack, please wait a few minutes before
you try to access the PE console. See the section on PE services below.

### I can't find the PE console login credentials

The PE console login credentials are listed in the Quest Guide when you need
to access the console as part of a lesson. The login is **admin** and the password
is **puppetlabs**. If you see the PE console login prompt when you are trying to
access the Quest Guide, it is because you are using `https` in the url rather than `http`.

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

    restart_classroom_services.sh

### I cannot SSH or apply the puppet job tool to one of the nodes used in a quest

When you use the quest tool to begin a quest, it uses docker to generate the
needed nodes for that quest. It may be helpful to use the `docker ps` command
to list running container nodes. If you restart the VM, the docker service will
be reset and the generated nodes will be removed. If this happens, you must use
the quest tool to restart the quest. You will have to redo any tasks that
involve changes on a generated node, such as triggering a Puppet run. Changes
to Puppet code or configuration on the master will be preserved.

If you are prompted for a password to connect with one of the alternate user
accounts in the Defined Resource Types quest, it is an indication that there
is a problem with your Puppet code, Hiera data, or ssh-keypair. If configured
correctly, you should be able connect without a password. You can check manually
by logging in to the system as the learning user and using sudo to check
/home/gertie/.ssh/authorized_keys. There should be an entry there matching the
key you generated and included in your Hiera file.
  
### Running the puppet agent returns "Server Error: Could not parse for environment production"

The Puppet agent returns this error when it is unable to parse your Puppet code. The error
message will indicate the file where the syntax error occurred. Use the `puppet parser validate`
command to check the syntax of the indicated file. Note that problems with unpaired quotation marks,
parentheses, and curly braces will often result in a syntax error shown for the end of the file
where the parser's scan for the matching character failed. If the output of this syntax validation
is not clear, compare your code against the example in the Quest Guide and against the solution
files used we use for automated testing: https://github.com/puppetlabs/puppet-quest-guide/tree/master/tests/solution_files.

### Running the puppet agent returns "connect(2) for learning.puppetlabs.vm port 8140"

This generally indicates that the `pe-puppetserver` service is down. See
the section above for instructions on checking and restarting PE services.

### Running the Puppet agent returns "Failed to find facts from PuppetDB at learning.puppetlabs.vm:8140"

This generally indicates that the `pe-puppetdb` service is down. Again,
refer to the section above for instructions on checking and restarting PE services.

### The puppet job tool returns an error indicating that the node is not connected to the PCP broker

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

There has been a history of issues with VirtualBox Host Only adapter settings
affecting some Windows systems. If the settings you apply in the network
adapter configuration interface seem to change or be re-set, please refer to
[this VirtualBox ticket](https://www.virtualbox.org/ticket/8796#comment:20)
for background information and a possible work-around.

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
status. You can scroll in tmux by first hitting control-b, then `[` (left
bracket). You will then be able to use the arrow keys to scroll. Press `q` to
exit scrolling.

### Is there a PDF version of the Quest Guide?

We decided to discontinue the PDF version of the Quest Guide, as a profusion
of PDFs of different versions was making it difficult for users of the
guide and VM to match the correct documentation to the correct version. If
you would like to look at the Quest Guide content without running the Learning
VM, you can refer to the project's GitHub page:
https://github.com/puppetlabs/puppet-quest-guide/blob/master/en_us/summary.md. Note,
however, that this may include unreleased changes and may not match with task
validation and content on your copy of the Learning VM.

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
