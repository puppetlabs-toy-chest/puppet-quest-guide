# Virtual Machine Setup

1. Be sure you have an up-to-date installation of VirtualBox. The Learning VM works best with VirtualBox 4.x. You can find a free download of the latest version at https://www.virtualbox.org/wiki/Downloads.

2. Choose “Import Appliance” from the File menu.
3. Select the .ovf file included with your download.

	NOTE: __Do not__ use the “New Virtual Machine Wizard” and select the included .vmdk file as the disk; machines created this way will kernel panic during boot. 

4. Before starting the VM for the first time, change the VM's network mode to __Bridged__. In the VirtualBox Manager panel, click __Network__ to access networking options.
![image](../assets/vbox_network.png)

5. Select __Bridged Adapter__ from the drop-down menu and click __OK__.
![image](../assets/vbox_network_bridged.png)

6. For everything to work smoothly, we suggest allocating at least four gigabytes of memory to the VM. In the VirtualBox Manager panel, click __System__ to access system options and use the slider to set your memory allocation. Note that the Learning VM will likely still function with less memory allocated, but you may encounter performance issues.
![image](../assets/vbox_memory.png)

7. Now that everything is configured, click the __Start__ button in the upper left to boot up the VM.

6. Refer to [VirtualBox documentation](http://www.virtualbox.org/manual) for additional information as required.
