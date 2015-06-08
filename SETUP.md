Set up the Learning VM

1. Be sure you have an up-to-date version of your virtualization software.
We suggest using either VirtualBox or a VMware appropriate for your platform.
(VirtualBox)[https://www.virtualbox.org/wiki/Downloads], is free and available
for Linux, OS X, and Windows. VMware has several desktop virtualization applications,
including (VMWare Fusion)[https://www.vmware.com/products/fusion/] for Mac and
(VMware Workstation)[https://www.vmware.com/products/workstation/] for Windows.

2. Once you have downloaded the Learning VM .OVA file and (if needed)
your virtualization software, you're ready to import the Learning VM. Please
read all the instructions below *before* you begin, as certain configuration
options might not apply properly if they are changed after starting the VM.

3. The Learning VM comes in the Open Virtualization Archive format. While this
format is compatible with all major desktop virtualization applications, it must
be *imported* rather than opened directly. (If your virtualization software
presents you with a default wizard or dialogue for opening a VM, please ignore
this, as it will certainly lead you astray.) Find an option for *Import* or
*Import Appliance*. This will usually be in a *File* menu. If you cannot locate
an *Import* option, please refer to your virtualization software's documentation.

4. *Before* starting the VM for the first time, you will need to make some adjustments
to the *network* and *system* settings. Allocate 2 CPUs and at least 2GB of RAM to
the VM. The VM can run with less memory allocated, but you may encounter errors and
performance issues. Set the *Network Adapter* to *Bridged*. Use an *Autodetect*
setting if available, or accept the default Network Adapter name. If you started
the VM before making these changes, you may need to restart the VM before the settings
will be applied correctly.

5. Once you have made the settings described above, start the VM. Wait for it to
boot, then make note of the IP address. You will have a much better experience
if you connect to the VM via SSH, rather than interacting with it directly through
your virtualization software. On OS X, you can use the default Terminal application
or a third-party application like iTerm. For Windows, we suggest the free SSH
client (PuTTY)[http://www.putty.org/]. Connect to the Learning VM with the login
`root` and password `puppet`.

6. The Learning VM comes with a pre-configured webserver hosting the Quest Guide
materials. To access the Quest Guide and get started, just enter your Learning VM's
IP address in your browser's address bar.
