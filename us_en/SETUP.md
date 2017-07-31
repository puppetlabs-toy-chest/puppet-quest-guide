{% include '/version.md' %}

# Set up the Learning VM

## Get the VM

If you haven't already, [download the Learning VM](https://puppet.com/download-learning-vm)

## Virtualization setup

Get an up-to-date version of your preferred virtualization software.
[VirtualBox](https://www.virtualbox.org/wiki/Downloads) is free and available
for Linux, Mac, and Windows systems. VMware has several desktop virtualization
applications, including [VMware
Fusion](https://www.vmware.com/products/fusion/) for Mac and [VMware
Workstation](https://www.vmware.com/products/workstation/) for Windows.

The Learning VM OVA file must be *imported* rather than opened directly.
Launch your virtualization software and find an **Import** or **Import
Appliance** option in the **File** menu. If you cannot locate an **Import**
option, refer to your virtualization software's documentation.

If you have enough available memory on your host machine, increasing the memory
allocation for the VM from the default 3GB to 4GB may improve performance and
stability. Memory allocation settings are found by selecting the VM in the
VirtualBox Manager window, opening the *Settings* dialog, and selecting the
*System* section.

## Networking configuration

All the packages and modules needed to complete the Quest Guide are hosted
locally on the VM itself, but you will need to set up networking to access the
VM from your host system.

Your virtualization software provides several options for network
configuration. If you are on a network that may have a proxy or restrictive
firewall rules (ask your network administrator if you're not sure), we strongly
suggest running the VM with an offline host-only network. This offline
configuration requires more complex initial setup with VirtualBox software, but
will help you avoid troubleshooting networking issues between your Puppet
master and agent systems.

If you are using VirtualBox on a network without a proxy or restrictive
firewall rules, you may find it simpler to use the bridged adapter described
in the online configuration section below.

### Offline

For **VirtualBox:**

To use host-only networking on VirtualBox, you will need to create and
configure a new network from the VirtualBox *preferences* panel. Note that this
may be called *settings* on some systems. Be sure that you're looking at the
preferences for VirtualBox itself, not the settings configurations for a
specific VM.

Open the VirtualBox preferences panel and select the **network** section.
Select **Host-only Networks**. Create a new network, and click the screwdriver
icon to the side of the dialog to edit the network configuration. In the
**Adapter** section, enter the following settings:  

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
you created from the **Name:** drop-down. Click **OK** to accept the setting
change.

For **VMWare:**  

Open the **Settings** dialog for the Learning VM and select the **Network**
Section. Under the **Custom** heading, select the private network adapter
option.

### Online

If you would like to run the Learning VM with internet access, set the
*Network Adapter* to *Bridged*. Use an *Autodetect* setting if available, or
accept the default Network Adapter name. (If you started the VM before making
these changes, you may need to restart the VM before the settings will be
applied correctly.)

Note that the Puppet module tool, yum, and RubyGems are configured to use local
repositories, so you will not be able to access remote content without manually
changing the settings for these tools. While we encourage exploration, we are
not currently able to support issues beyond the scope of the Quest Guide.

## Log in

Start the VM. Rather than logging in directly, we suggest using the
browser-based web terminal or SSH.

To access the web terminal, open your web browser and navigate to
`http://<VM's IP ADDRESS>:9091`. Follow the instructions show on the
splash page to log in.

On Mac systems, you can use the default Terminal application or a third-party
application like iTerm. For Windows, we suggest the free SSH client
[PuTTY](http://www.putty.org/). Use the credentials provided on the VM console
splash page to authenticate.

## Get started

Once the VM is set up and you have connected, you're ready to get started on
the interactive lessons in the Quest Guide. Access the Quest Guide by opening a
web browser on your host system and entering the Learning VM's IP address in
the address bar: `http://<IP-ADDRESS>`. (Note that you must use `http`, as 
`https` will connect you to the PE console interface.)

## Localization

The Learning VM's Quest Guide and Quest tool currently support English and
Japanese localization. The default language is English. If you would like to
use the Quest tool in Japanese, run the following command on the Learning VM:
`export LANG=ja_JP.utf-8`. Note that you must use SSH or the browser-based web
terminal to see Japanese characters. Japanese characters will not display
correctly on the default VirtualBox or VMware terminal.
