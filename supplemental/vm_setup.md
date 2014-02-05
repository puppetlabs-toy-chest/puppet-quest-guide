# VM Setup

## Lets get the right tools

Depending on which version of the VM you're using you need to use VMWare or VirtualBox virtualization software to spin up the VM.

### VMWare

If you have VMWare Fusion, VMWare Player, or Workstation installed, double-click on the .vmx file to open it with VMWare.

### VirtualBox

If you have VirtualBox installed there is a little more effort needed to get the Learning VM up and running. First off, the Learning VM works best with VirtualBox 4.x. If you have an older version of VirtualBox, you'll have to upgrade.

1. Choose “Import Appliance” from the File menu
2. Browse for the .ovf file included with your download

	NOTE: __DO NOT__ use the “New Virtual Machine Wizard” and select the included .vmdk file as the disk; machines created this way will kernel panic during boot. 

3. Change the VM's network mode to __Bridged__, as opposed to the default NAT before you start the VM for the first time.4. 

__Click on the Network Settings:__

![image](http://docs.puppetlabs.com/learning/images/vbox_network.png)
<br>
<br>
<br>
__Change the Network adapter the VM is attached to__![image](http://docs.puppetlabs.com/learning/images/vbox_network_bridged.png)

Please refer to [VirtualBox documentation on virtual networking for additional information](http://www.virtualbox.org/manual/ch06.html) as required
