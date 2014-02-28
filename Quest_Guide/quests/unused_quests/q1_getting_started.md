# Quest #1: Getting Started

We're glad to see you're joining us on this exciting journey! First, and most important, it is important to download the latest version of the Learning VM. We will use the VM as a platform to write code in Puppet's Domain Specific Language (DSL) to configure certain aspects of the VM, as a means of learning about Puppet. You're going to be a fish out of water if you don't have it.

<!--Display two download buttons (1) VMX Version (2) OVF Version-->
<!--Underneath the VMX Version button display this text: Recommended for VMWare Fusion and VMWare Workstation as well as VMWare ESX and ESXi (vCenter Converter app needed for proper importing)-->
<!--Underneath the OVF Version button display this text: Recommended for VirtualBox (free) and all other non-VMWare virtualization software-->

## Lets get the right tools

The VM is available in the .vmx format for VMWare and .ovf format for VirtualBox. You can use either of these formats depending on whether you use a VMWare product or a VirtualBox product to open VMs.

### VMWare

If you have VMWare Fusion, VMWare Player ,or Workstation installed, you should be able to double-click on the .vmx file to open it with VMWare. It's that easy.


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



## Hi, I'm Billy Bones. It's a pleasure to meet you.

Puppet Enterprise has already been installed on the VM. Go ahead and start the Learning VM and log in as follows:

user: __root__<br>
password: __puppet__

Awesome! You just completed your first task. <!--task 1-->

Explore the system with the following commands: <!--task 2-->

    puppet -V

Just in case of an emergency: <!--task 3-->

	puppet help	

So, what happens when you run the following command?: <!--task 4-->
	
	puppet help help help help help

You're doing great so far! Please __clear__ your terminal for me. You're about to embark on your journey. Just a heads up, you're the newest member to the pirate crew. Make sure you read the story. This is going to be the quest theme as you progress through the Learning VM. Run the following command: <!--task 5-->

	quest one story

<!--Ay! Welcome to the crew! I’m Billy Bones. Second in command to the Captain, Captain Whiskey Jack that is. We're businessmen you see, and our website, Polly, is falling apart. The Captain is elated you two struck an accord on joining the crew. Our ship is home to our website Polly. It goes where we go ay...and we go where the seas take us...and the Captain's orders of course. So I'm to help you get acquainted with the way we do things here. We recently switched to using Puppet on this ship for various reasons, but we need you to be a master at it. For that, I will be your guide.-->

Feel free to type any of the following commands to learn more about Polly, Captain Whiskey Jack, levels, etc.

	polly
	whiskey jack
	levels

<!--If 'polly' is entered, then display the following-->
<!--You my friend are working among the best and brightest pirates in all the lands  and with a legendary Captain too. Captain Whiskey Jack, being a fine business man and all, started a new age website called Polly. You see, it gives pirates like us the opportunity to sell our findings all over the world. Truly revolutionary ay! I should also mention anything can be auctioned on Polly. In turn, the Captain takes a small percentage of each sale for offering his service. Genius if you ask me! But as Polly continues to grow, the harder it is to maintain. The more ships that need to be managed. The more booty sold. That's why you're here, to make it simpler. Ready to learn Puppet and make things better?-->

<!--If 'whiskey jack' is entered, then display the following-->
<!--Whiskey Jack is a mysterious fellow you see. You know, they say he put the salt in the sea. Crazy, I know, but that's what I hear. Anyways, Captain Whiskey Jack's previous ship, the OpsWave, parished at sea only after a few years of rough seas, but was the backbone to running Polly. I guess the ship wasn't strong enough to handle the ever changing environment, battle wounds, fires, and viruses that plagued the ship. It came to a point where he nor his crew could manage the OpsWave's repairs anymore and as a result Polly was going downhill. One night while the Captain was sleeping in his quarters, a rogue wave, in one gulp, swallowed the OpsWave and crew, sending them down to Davy Jones. Somehow though, the Captain managed to escape the depths of the sea. The only one ay. Legend has it, that he stuffed himself into an empty whiskey barrel and floated to the top ocean where he buoyed in the open water, no land in sight, for three nights, catching fish with his bare hands just to stay alive. That's how he got the name Whiskey Jack. The Captain will never say though. It's just pirate lore for now.-->

<!--If 'levels' is entered, then display the following-->
<!--
LEVEL             TASKS NEEDED
------------------------------
Captain                    100
First Mate                  90
Quarter Master              80
Sailing Master              70
Boatswain                   60
Master Gunner               50
Rigger                      40
Cooper                      35
Carpenter                   30
Surgeon                     25
Cook                        20
Musician                    15
Mate                        10
Powder Monkey                8
Cabin Boy                    5
Swabbie                      1
-->

<!--NOTE: We need a way to track all tasks completed by the user. Could we base this off the users unique system? This way no account registration is necessary-->

<!--NOTE: The header of this chart "LEVEL" and "TASKS NEEDED" should be the same size and font as each rank listed below it.-->

<!--NOTE: The "# of tasks" needed to reach each rank should be dynamic and able to fluctuate as we add more quests-->

<!--The following will be simple eastereggs describing what each level is with an ascii image. If the user enters any of the following commands in the command line, see the associated file in the levels folder for the expected outcome. This is still in process of being designed, but the 'captain' is done for testing purposes.

	captain
	first mate
	quarter master
	sailing master
	boatswain
	master gunner
	rigger
	cooper
	carpenter
	surgeon
	cook
	musician
	mate
	powder monkey
	cabin boy
	swabbie
-->

<!--

Captain                           _.-':::::::`.
                                  \::::::::::::`.-._
You have become the best pirate    \:::''   `::::`-.`.
on the seas and, along with the     \         `:::::`.\
help of the crew, have over          \          `-::::`:
thrown the captain. You are now       \______       `:::`.
in charge. Best of luck to you        .|_.-'__`._     `:::\
my friend.                           ,'`|:::|  )/`.     \:::
                                    /. -.`--'  : /.\     ::|
                                    `-,-'  _,'/| \|\\    |:|
                                     ,'`::.    |/>`;'\   |:|
                                     (_\ \:.:.:`((_));`. ;:|
                                     \.:\ ::_:_:_`-','  `-:|
                                       `:\\|     SSt:
                                          )`__...---'

-->

<!--

Carpenter

It's time for you to understand the details of the ship by
repairing battle damages and leaks

                                 .,____,.
                                 |      |
                                 |      |    T
      .--------------.___________|      |    |    T
      |//////////////|___________|      |    !  T |
      `--------------'           |      |       | !
                                 |      |       !
                                  "____"

-->

<!--

Musician                {}
                       oIIo            __
                       oIIo          |--|             __
We did not know you     ||           |  |            |~'
played the fiddle.      ||       I. () ()            |
We love some good       ||       |:         |\      ()
ol' drunken fun.       _||_      |:         | \                   
                     .' || `.    |:        ()  |
        ,           /   ||   \   |:            |
        |\         |    ::    |  |:           ()
        | |        )_   ::   _(  |:
        |/          _)( :: )(_   |:
       /|_         ) ._)::(_. (  |:
      //| \       /     II     \ |:
     | \|_ |      |  .-.||     | |:
      \_|_/        \(___)(    /  |:
        |           .__\/__.'   I'
       @'                  

-->

<!--

Swabbie                     ,.--'`````'--.,               / /
                           (\'-.,_____,.-'/)             / / 
Welcome aboard! You've      \\-.,_____,.-//             / /  
been given the privilege    ;\\         //|            / /
by the captain to mop       | \\  ___  // |           / /
the decks of our ship.      |  '-[___]-'  |          /_/
Enjoy!                      |             |      ___/_/___
                            |             |  __/' / / / / ')
                            `'-.,_____,.-''/__/_/_/_/_/___)'

-->

### Ready to start [Quest #2](docs.puppetlabs.com/learning) adventure?
