# Set up the Learning VM

1. Get an up-to-date version of your virtualization software. We suggest using
either VirtualBox or a VMware application appropriate for your platform.
[VirtualBox](https://www.virtualbox.org/wiki/Downloads) is free and available
for Linux, OS X, and Windows. VMware has several desktop virtualization applications,
including [VMWare Fusion](https://www.vmware.com/products/fusion/) for Mac and
[VMware Workstation](https://www.vmware.com/products/workstation/) for Windows.

2. The Learning VM's Open Virtualization Archive format must be *imported* rather
than opened directly. Launch your virtualization software and find an option for
*Import* or *Import Appliance*. (This will usually be in a *File* menu. If you
cannot locate an *Import* option, please refer to your virtualization software's
documentation.)

3. *Before* starting the VM for the first time, you will need to adjust its settings.
Allocate 2 CPUs and at least 2GB (2048 MB) of RAM. Set the *Network Adapter* to *Bridged*.
Use an *Autodetect* setting if available, or accept the default Network Adapter name.
(If you started the VM before making these changes, you may need to restart the VM
before the settings will be applied correctly.)

4. Start the VM. When it is started, make a note of the IP address and password displayed
on the splash page. Rather than logging in directly, we highly recommend using SSH. On OS X,
you can use the default Terminal application or a third-party application like iTerm.
For Windows, we suggest the free SSH client [PuTTY](http://www.putty.org/).
Connect to the Learning VM with the login `root` and password you noted from the splash page.
(e.g. `ssh root@<IPADDRESS>`)

5. To access the Quest Guide and get started, enter the Learning VM's IP address in
your browser's address bar. (Be sure to use `http://<ADDRESS>` for the Quest Guide,
as `https://<ADDRESS>` will take you to the PE console.)

# Troubleshooting

For the most up-to-date version of this troubleshooting information,
[check the GitHub repository](https://github.com/puppetlabs/courseware-lvm/blob/master/SETUP.md#troubleshooting).
If nothing here resolves your issue, feel free to email us at learningvm@puppetlabs.com
and we'll do our best to address your issue.

For issues with Puppet Enterprise that are not specific to the Learning VM, see the
Puppet Enterprise [Known Issues](https://docs.puppetlabs.com/pe/latest/release_notes_known_issues.html)
page.

### The cowsay package won't install

The Learning VM version 2.29 has an error in the instructions
for this quest. The cowsay package declaration should include `provider => 'gem'`,
rather than `ensure => 'gem'`.

If you continue to get puppet run failures related to the gem, you can install
the cached version manually: `gem install /var/cache/rubygems/gems/cowsay-0.2.0.gem`

### I completed a task, but the quest tool doesn't show it as complete

The quest tool uses a series of [Serverspec](http://serverspec.org/) tests for each
quest to track task progress. Certain tasks simply check your bash history for an
entered command. In some cases, the `/root/.bash_history` won't be properly initialized,
causing these tests to fail. Exiting the VM and logging in again will fix this issue.

It is also possible that we have written the test for a task in a way that is too
restrictive and doesn't correctly capture a valid syntactical variation in your
Puppet code or another relevant file. You can check the specific matchers by looking
at a quest's spec file in the `~/.testing/spec/localhost/` directory. If you find
an issue here, please let us know by sending an email to learningvm@puppetlabs.com.

### Password Required for the Quest Guide

The Learning VM's Quest Guide is accessible at `http://<VM's IP Address>`. Note that
this is `http` and not `https` which is reserved for the PE console. The PE console
will prompt you for a password, while no password is required for the Quest Guide.
(The Quest Guide includes a password for the PE console in the Power of Puppet quest:
**admin/puppetlabs**)

### I can't find the VM password

The password to log in to the VM is generated randomly and will be displayed on the
splash page displayed on the terminal of your virtualization software when you
start the VM.

If you are already logged in via your virtualization software's terminal, you can
use the following command to view the password: `cat /var/local/password`.

### Does the Learning VM work on vSphere, ESXi, etc.?

Possibly, but we don't currently have the resources to test or support the Learning VM
on these platforms.

### My puppet run fails and/or I cannot connect to the PE console

It may take some time after the VM is started before all the Puppet services
are fully started. If you recently started or restarted the VM, please wait a few
minutes and try to access the console or trigger your puppet run again.

Also, because the Learning VM's puppet services are configured to run in an environment
with restricted resources, they are more prone to crashes than a default installation
with dedicated resources.

You can check the status of puppet services with the following command:

    systemctl --all | grep pe-

If you notice any stopped puppet-related services (e.g. pe-puppetdb), double check
that you have sufficient memory allocated to the VM and available on your host
before you try starting them (e.g. `service pe-puppetdb start`).

If you get an error along the lines of `Error 400 on SERVER: Unknown function union...`
it is likely because the `puppetlabs-stdlib` module has not been installed. This module
is a dependency for many modules, and provides a set of common functions. If you are
running the Learning VM offline, you cannot rely on the Puppet Forge's dependency
resolution. We have this module and all other modules required for the Learning VM
cached, with instructions to install them in the Power of Puppet quest. If that installation
fails, you may try adding the `--force` flag after the `--ignore-dependencies` flag.

### I can't import the OVA

First, ensure that you have an up-to-date version of your virtualization software installed.
Note that the "check for updates" feature of VirtualBox may not always work as expected,
so check the website for the most recent version.

### The Learning VM has no IP address or the IP address will not respond.

If your network connection has changed since you loaded the VM, it's possible that your
IP address is different from that displayed on the Learning VM splash screen. Log
in to the VM via the virtualization directly (rather than SSH) and use the `facter ipaddress`
command the check the current address.

Some network configurations may still prevent you from accessing the Learning VM.
If this is the case, you can still access the Learning VM by configuring port forwarding.

Change your VM's network adapter to NAT, and configure port forwarding as follows:

```
Name   -   Protocol - HostIP -   HostPort - GuestIP - GuestPort
SSH        TCP        127.0.0.1  2222                 22
HTTP       TCP        127.0.0.1  8080                 80
HTTPS      TCP        127.0.0.1  8443                 443
GRAPHITE   TCP        127.0.0.1  8090                 90
```

Once you have set up port forwarding, you can use those ports to access the VM
via ssh (`ssh -p 2222 root@localhost`) and access the Quest Guide and PE console
by entering `http://localhost:8080` and `https://localhost:8443` in your browser address bar.

### I can't scroll up in my terminal

The Learning VM uses a tool called tmux to allow us to display the quest status. You
can scroll in tmux by first hitting control-b, then [ (left bracket). You will then
be able to use the arrow keys to scroll. Press q to exit scrolling.

### Running the VM in VirtualBox, I encounter a series of "Rejecting I/O input from offline devices"

Unfortunately we haven't been able to consistently reproduce this error to test fixes or workarounds.
You may try reducing the VM's processors to 1 and disabling the "I/O APIC" option in the system
section of the settings menu.

### Still need help?

If your puppet runs still fail after trying the steps above, feel free to contact us at
learningvm@puppetlabs.com or check the Puppet Enterprise [Known Issues](https://docs.puppetlabs.com/pe/latest/release_notes_known_issues.html) page.
