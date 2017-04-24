{% include '/version.md' %}

# Set up the Learning VM

1. Ensure you have an up-to-date version of virtualization software installed. We suggest using
either VirtualBox or a VMware application appropriate for your platform.
[VirtualBox](https://www.virtualbox.org/wiki/Downloads) is free and available
for Linux, OS X, and Windows. VMware has several desktop virtualization
applications, including [VMware
Fusion](https://www.vmware.com/products/fusion/) for Mac and [VMware
Workstation](https://www.vmware.com/products/workstation/) for Windows.

1. The Learning VM's Open Virtualization Archive format must be *imported*
rather than opened directly. Launch your virtualization software and find an
option for **Import** or **Import Appliance**. This will usually be in a **File**
menu. If you cannot locate an **Import** option, refer to your
virtualization software's documentation.

1. *Before* starting the VM for the first time, adjust its
settings.  Allocate 4GB of memory for the best performance. If
you don't have enough memory on your host machine, you can leave the allocation
at 3GB, but you might encounter stability and performance
issues. Set the **Network Adapter** to **Bridged**. Use an autodetect setting if
available, or accept the default network adapter name. If you are unable to use 
a bridged network, use the port-forwarding instructions provided in the Troubleshooting
chapter.

1. Start the VM. Write down the IP address and password
displayed on the splash page. Rather than logging in directly, use SSH. On 
OS X, use the default Terminal application or an
application like iTerm.  For Windows, we suggest the free SSH
client [PuTTY](http://www.putty.org/).  Connect to the Learning VM  by running: `ssh
root@<IPADDRESS>` and use the login `root` and password you noted from the splash 
page. It can take several minutes for the services
in the Puppet Enterprise stack to fully start. Once you're connected to the
VM, update the clock by running `ntpdate pool.ntp.org`.

1. Access this Quest Guide by opening a web browser on your host and entering
the Learning VM's IP address in the address bar. Use `http://<ADDRESS>`, not `https`, which
will open the PE console.
