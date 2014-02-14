# Module Quest Solutions

1. Enter the following command:

		puppet agent --configprint modulepath
	
	RETURN:

		/etc/puppetlabs/puppet/modules:/opt/puppet/share/puppet/modules

2. Enter the following command:

		cd /etc/puppetlabs/puppet/modules

3. Enter the following command:

		mkdir -p users/manifests

4. Enter the following command:

		nano users/manifests/init.pp

	RETURNED VALUE:

        the learning vm will open a shell script for you 

5. In the shell script, type the following task in Puppet's DSL:

        class users {
          user {'como':
        	  ensure => 'present',
          }
        }

6. To exit the shell script, do a 'Control X' on the keyboard

7. You will then be prompted to save the file you just created. Hit 'y' on the keyboard for "Yes".

8. You will be prompted to name your file. Delete 'puppet' which is prepopulated and replace with `users/manifests/init.pp`, then hit 'Enter' on the keyboard.

	RETURNED VALUE:

        the learning vm will exit the shell script

9. Enter the following command in the command line:

		puppet parser validate users/manifest/init.pp

	RETURNED VALUE:

		nothing should be returned. If something is returned there is an error.

10. In the same modulepath, type the following command:

		mkdir users/tests

11. Type the following command:

		nano users/tests/init.pp
	RETURNED VALUE:

        the learning vm will open a shell script for you 

12. In the shell script, type the following task in Puppet's DSL:

        include users

13. To exit the shell script, do a 'Control X' on the keyboard

14. You will then be prompted to save the file you just created. Hit 'y' on the keyboard for "Yes".

15. You will be prompted to name your file. Delete 'puppet' which is prepopulated and replace with `users/tests/init.pp`, then hit 'Enter' on the keyboard.

	RETURNED VALUE:

        the learning vm will exit the shell script

16. Enter the following command in the command line:

		puppet parser validate users/tests/init.pp

	RETURNED VALUE:

		nothing should be returned. If something is returned there is an error.

18. Enter the following command:

		nano users/manifests/init.pp

	RETURNED VALUE:

        the learning vm will open a shell script for you 

19. In the shell script, type the following task in Puppet's DSL:

        class users {
          user {'como':
        	  ensure => 'present',
        	  gid    => 'staff',
        	  shell  => '/bin/bash',
          }
          
          group {'staff':
            ensure => 'present',
          }
        }

20. To exit the shell script, do a 'Control X' on the keyboard

21. You will then be prompted to save the file you just created. Hit 'y' on the keyboard for "Yes".

22. You will be prompted to name your file. Delete 'puppet' which is prepopulated and replace with `users/manifests/init.pp`, then hit 'Enter' on the keyboard.

	RETURNED VALUE:

        the learning vm will exit the shell script

23. Enter the following command in the command line:

		puppet parser validate users/manifest/init.pp

	RETURNED VALUE:

		nothing should be returned. If something is returned there is an error.

24. Enter the following command:

		puppet apply --noop users/tests/init.pp

25. Enter the following command:

		puppet apply users/tests/init.pp