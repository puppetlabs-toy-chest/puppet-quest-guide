Set up the Learning VM

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
your browser's address bar.
