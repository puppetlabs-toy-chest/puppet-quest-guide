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
stability.

## Networking configuration

### Offline

We recommend running the VM on a host-only network without an external internet
connection. This avoids any issues related to your site network configuration
and changing dependencies provided by remote hosts. All the packages and
modules needed to complete the Quest Guide are hosted locally on the VM itself.

For **VirtualBox:**

To use host-only networking on VirtualBox, you will need to create and
configure a new network from the VirtualBox preferences menu.

Open the VirtualBOx preferences dialog and select the **network** section.
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

Start the VM. Rather than logging in directly, we suggest using the built-in
web terminal or SSH.

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
