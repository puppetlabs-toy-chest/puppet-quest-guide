#Quest Guide Setup

It will be much easier to interact with the Learning VM from the comfort of your own terminal. Open a terminal window and SSH to the learning VM.

		ssh root@<LVM's IP address>

	Use the following credentials to log in:  
	**username:** root  
	**password:** puppet


Now that you are connected to the Learning VM, use Puppet to activate your Quest Guide:

		puppet apply setup/guide.pp
		
Note that this might take a few minutes to complete. Puppet is working behind the scenes to apply the `guide.pp` manifest. We prepared this manifest both as an effecient way to get your Learning VM Quest Guide up and accessible from your web browser, but also as a demonstration of what Puppet is capable of.

To access your Quest Guide and begin your journey, direct your web browser to **http://<LVM's IP address>/quests/welcome**.