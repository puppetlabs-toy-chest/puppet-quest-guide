# Manifest Quest Solutions #

## Manifest Task(s)
NOTE: substitute `earthname` with the name your parents gave you.

1. In the command line, type the following command

        puppet describe user
   and/or

        puppet resource user

2. In the command line, type the following command:

        cd /root
   
   RETURNED VALUE:

        you will have nothing returned	
   
        
3. In the command line, type the following command:

        nano user.pp
   
   RETURNED VALUE:

        the learning vm will open a shell script for you 

4. In the shell script, type the following task in Puppet's DSL:

        user {'earthname':
        	ensure => 'present',
        }

        
5. To exit the shell script, do a 'Control X' on the keyboard

6. You will then be prompted to save the file you just created. Hit 'y' on the keyboard for "Yes".

7. You will be prompted to name your file. Delete 'puppet' which is prepopulated and replace with user.pp, then hit 'Enter' on the keyboard.

	RETURNED VALUE:

        the learning vm will exit the shell script


## Puppet Parser Task(s)

8. Enter the following command in the command line:

		puppet parser validate user.pp

	RETURNED VALUE:

		nothing should be returned. If something is returned there is an error.


## Puppet Apply Task(s)


9. In the command line, type the following command:

        puppet help apply	

	RETURNED VALUE: 

        information on how to use the command puppet apply

10. In the command line, type the following command:

        puppet apply --noop user.pp

	RETURNED VALUE: 

        Notice: Finished catalog run in 0.59 seconds

11. In the command line, type the following command:

        puppet apply user.pp

	RETURNED VALUE: 

        Notice: Finished catalog run in 0.26 seconds

12. In the command line, type the following command:

        puppet resource user earthname

	RETURNED VALUE: 

          user {'earthname':
        	ensure           => 'present',
        	gid              => '504',
        	home             => '/home/earthname',
        	password         => '!!',
        	password_max_age => '99999',
        	password_min_age => '0',
        	shell            => '/bin/bash',
        	uid              => '504',
        }