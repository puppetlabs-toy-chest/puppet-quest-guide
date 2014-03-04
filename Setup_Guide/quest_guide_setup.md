#Quest Guide Setup

1. It will be much easier to interact with the Learning VM from the comfort of your own terminal. Open a terminal window and SSH to the learning VM.

		ssh root@<LVM's IP address>

	Use the following credentials to log in:  
	**username:** root  
	**password:** puppet


2. Now that you are connected to the Learning VM, use Puppet to activate your Quest Guide:

		puppet apply setup/guide.pp

Congratulations; the Puppet manifest you just applied configured and activated an Apache server host your very own LVM Quest Guide. To access your Quest Guide and begin your journey, direct your web browser to **http://<LVM's IP address>/quests/welcome**.