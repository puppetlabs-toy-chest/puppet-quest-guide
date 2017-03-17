{% include '/version.md' %}

# Set up the Learning VM

## Get the VM

If you haven't already, please [download the Learning VM](https://puppet.com/download-learning-vm)

Before beginning, you may want to use the MD5 sum provided at the VM
download page to verify your download. On Mac OS X and *nix systems, you can
use the command `md5 learning_puppet_vm.zip` and compare the output to the text
contents of the `learning_puppet_vm.zip.md5` file provided on the download
page. On Windows systems, you will need to download and use a tool such as the
[Microsoft File Checksum Integrity Verifier](https://www.microsoft.com/en-us/download/details.aspx?id=11533).

## Virtualization setup

Get an up-to-date version of your virtualization software. We suggest using
either VirtualBox or a VMware application appropriate for your platform.
[VirtualBox](https://www.virtualbox.org/wiki/Downloads) is free and available
for Linux, OS X, and Windows. VMware has several desktop virtualization
applications, including [VMWare
Fusion](https://www.vmware.com/products/fusion/) for Mac and [VMware
Workstation](https://www.vmware.com/products/workstation/) for Windows.

The Learning VM's Open Virtualization Archive format must be *imported*
rather than opened directly. Launch your virtualization software and find an
option for *Import* or *Import Appliance*. (This will usually be in a *File*
menu. If you cannot locate an *Import* option, please refer to your
virtualization software's documentation.)

*Before* starting the VM for the first time, you will need to adjust its
settings.  We recommend allocating 4GB of memory for the best performance. If
you don't have enough memory on your host machine, you may leave the allocation
at 3GB or lower it to 2GB, though you may encounter stability and performance
issues.

## Networking configuration

### Online

If you would like to run the Learning VM with internet access, set the
*Network Adapter* to *Bridged*. Use an *Autodetect* setting if available, or
accept the default Network Adapter name. (If you started the VM before making
these changes, you may need to restart the VM before the settings will be
applied correctly.)

### Offline

If you would prefer to run the Learning VM without internet
access, you will need to configure a host-only network adapter in your
virtualization software.

For **VirtualBox:**

Open the preferences dialog and select the **network** section. Select
**Host-only Networks**. Create a new network, and click the screwdriver icon to
the side of the dialog to edit the network configuration. In the **Adapter**
section, enter the following settings:  

**IPv4 Address: 192.168.56.1**  
**IPv4 Network Mask: 255.255.255.0**  

In the **DHCP Server** section, enter the following settings:

Check the **Enable Server** box  
**Server Address: 192.168.56.1**  
**Server Mask: 255.255.255.0**  
**Lower Address Bound: 192.168.56.110**  
**Upper Address Bound: 192.168.56.200**  

Click **OK** to accept the adapter configuration changes, and again to exit the
preferences dialog. Open the settings section for the Learning VM from the
VirtualBox Manager window. Go to the **Network** section, select **Host-only
Adapter** from the drop-down menu, and select the name of the host-only adapter
you set up from the **Name:** drop-down. Click **OK** to accept the setting
change.

For **VMWare:**  

Open the **Settings** dialog for the Learning VM and select the **Network**
Section. Under the **Custom** heading, select the private network adapter
option.

## Get started!

Start the VM. When it is started, make a note of the IP address and password
displayed on the splash page. Rather than logging in directly, we highly
recommend using the built-in web terminal or SSH. To access the web-terminal,
go open a web-browser and navigate to `http://<VM's IP ADDRESS>:9091`. If you
prefer SSH, on OS X, you can use the default Terminal application or a
third-party application like iTerm.  For Windows, we suggest the free SSH
client [PuTTY](http://www.putty.org/). If you are unable to connect to the VM
via the web-terminal or SSH, it is possible that your network has changed since
the VM initialized its networking service. To resolve this, restart the VM, log
in directly through the virtualization application console, and run `facter
ipaddress` to determine the correct ipaddress. If you continue to have issues,
please try running the VM with the host-only adapter as described above or
contact us at learningvm@puppet.com for further assistance.

You can access this Quest Guide via a webserver running on the Learning VM
itself. Open a web browser on your host and enter the Learning VM's IP address
in the address bar. (Be sure to use `http://<ADDRESS>` for the Quest Guide, as
`https://<ADDRESS>` will take you to the PE console.) Follow along with the
instructions provided in the Quest Guide to get started learning Puppet!
