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

4. Start the VM. When it is started, make a note of the IP address displayed on the
splash page. Rather than logging in directly, we highly recommend using SSH. On OS X,
you can use the default Terminal application or a third-party application like iTerm.
For Windows, we suggest the free SSH client [PuTTY](http://www.putty.org/).
Connect to the Learning VM with the login `root` and password `puppet`.
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

### Does the Learning VM work on vSphere, ESXi, etc.?

Possibly, but we don't currently have the resources to test or support the Learning VM
on these platforms. If you do get it to work smoothly on a different platform and
want to share, we're all ears!

### My puppet run fails!

The Learning VM generally runs the puppet master stack in an environment with less
resources and less consistent network settings than a production installation. This
means that components of the puppet master may crash. This is the most common reason
for a puppet run to fail. Rather than troubleshooting individual services, the easiest
way to address this is to restart the VM. Also note that on restarting the VM or
restarting a service, it may take some time for all component services of puppet to
fully come on line. If your puppet runs still fail after restarting, please wait a minute
and try again.

If you get an error along the lines of `Error 400 on SERVER: Unknown function union...`
it is likely because the `puppetlabs-stdlib` module has not been installed. This module
is a dependency for many modules, and provides a set of common functions. If you are
running the Learning VM offline, you cannot rely on the Puppet Forge's dependency
resolution. We have this module and all other modules required for the Learning VM
cached, with instructions to install them in the Power of Puppet quest. If that installation
fails, you may try adding the `--force` flag after the `--ignore-dependencies` flag.

If your puppet runs still fail after trying the steps above, feel free to contact us at
learningvm@puppetlabs.com or check the Puppet Enterprise [Known Issues](https://docs.puppetlabs.com/pe/latest/release_notes_known_issues.html)
page.
