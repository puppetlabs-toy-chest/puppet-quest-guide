# Learning VM Troubleshooting

For the most up-to-date version of this troubleshooting information, [check the
GitHub
repository](https://github.com/puppetlabs/puppet-quest-guide/blob/master/troubleshooting.md).

### The cowsay package won't install

The Learning VM version 2.29 has an error in the instructions for this quest.
The cowsay package declaration should include `provider => 'gem'`, rather than
`ensure => 'gem'`.

If you continue to get puppet run failures related to the gem, you can install
the cached version manually: `gem install
/var/cache/rubygems/gems/cowsay-0.2.0.gem`

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

    restart_pe_services.sh

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
always work as expected, so check the website for the most recent version. If
you are sure that your virtualization software is up to date and your host
system is 64 bit and has virtualization extensions enabled in the BIOS, please
let us know if you still cannot import the OVA.

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

If networking continues to cause trouble, you can connect to the Learning VM
via port forwarding. Change your VM's network adapter to NAT, and configure
port forwarding as follows:

```
Name   -   Protocol - HostIP -   HostPort - GuestIP - GuestPort
SSH        TCP        127.0.0.1  2222                 22
HTTP       TCP        127.0.0.1  8080                 80
HTTPS      TCP        127.0.0.1  8443                 443
GRAPHITE   TCP        127.0.0.1  8090                 90
```

Once you have set up port forwarding, you can use those ports to access the VM
via ssh (`ssh -p 2222 root@localhost`) and access the Quest Guide and PE
console by entering `http://localhost:8080` and `https://localhost:8443` in
your browser address bar.

### I can't scroll up in my terminal

The Learning VM uses a tool called tmux to allow us to display the quest
status. You can scroll in tmux by first hitting control-b, then [ (left
bracket). You will then be able to use the arrow keys to scroll. Press q to
exit scrolling.

### Running the VM in VirtualBox, I encounter a series of "Rejecting I/O input from offline devices"

You may try reducing the VM's processors to 1 and disabling the "I/O APIC"
option in the system section of the settings menu. Be aware, however, that
this might result in *very* slow start times for services in the PE stack.

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
