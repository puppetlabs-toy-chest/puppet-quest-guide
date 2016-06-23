# Set up the Learning VM

1. Before beginning, you may want to use the MD5 sum provided at the VM
download page to verify your download. On Mac OS X and *nix systems, you can
use the command `md5 learning_puppet_vm.zip` and compare the output to the text
contents of the `learning_puppet_vm.zip.md5` file provided on the download
page. On Windows systems, you will need to download and use a tool such as the
[Microsoft File Checksum Integrity Verifier](https://www.microsoft.com/en-us/download/details.aspx?id=11533).

1. Get an up-to-date version of your virtualization software. We suggest using
either VirtualBox or a VMware application appropriate for your platform.
[VirtualBox](https://www.virtualbox.org/wiki/Downloads) is free and available
for Linux, OS X, and Windows. VMware has several desktop virtualization
applications, including [VMWare
Fusion](https://www.vmware.com/products/fusion/) for Mac and [VMware
Workstation](https://www.vmware.com/products/workstation/) for Windows.

1. The Learning VM's Open Virtualization Archive format must be *imported*
rather than opened directly. Launch your virtualization software and find an
option for *Import* or *Import Appliance*. (This will usually be in a *File*
menu. If you cannot locate an *Import* option, please refer to your
virtualization software's documentation.)

1. *Before* starting the VM for the first time, you will need to adjust its
settings.  We recommend allocating 4GB of memory for the best performance. If
you don't have enough memory on your host machine, you may leave the allocation
at 3GB or lower it to 2GB, though you may encounter stability and performance
issues. Set the *Network Adapter* to *Bridged*. Use an *Autodetect* setting if
available, or accept the default Network Adapter name. (If you started the VM
before making these changes, you may need to restart the VM before the settings
will be applied correctly.) If you are unable to use a bridged network, we
suggest using the port-forwarding instructions provided in the troubleshooting
guide.

1. Start the VM. When it is started, make a note of the IP address and password
displayed on the splash page. Rather than logging in directly, we highly
recommend using SSH. On OS X, you can use the default Terminal application or a
third-party application like iTerm.  For Windows, we suggest the free SSH
client [PuTTY](http://www.putty.org/).  Connect to the Learning VM with the
login `root` and password you noted from the splash page.  (e.g. `ssh
root@<IPADDRESS>`) Be aware that it might take several minutes for the services
in the PE stack to fully start after the VM boots. Once you're connected to the
VM, we suggest updating the clock with `ntpdate pool.ntp.org`.

1. You can access this Quest Guide via a webserver running on the Learning VM
itself. Open a web broswer on your host and enter the Learning VM's IP address
in the address bar. (Be sure to use `http://<ADDRESS>` for the Quest Guide, as
`https://<ADDRESS>` will take you to the PE console.)
