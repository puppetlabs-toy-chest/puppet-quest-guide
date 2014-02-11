# Quest #4: Solutions #

## Tasks
NOTE: substitute `yourname` with your [name of fantasy world] name

1. In the command line, type the following command:

        puppet resource user yourname
   
   RETURNED VALUE:

        user {'yourname':
        	ensure => 'absent',
        }	
   
        
2. In the command line, type the following command:

        useradd -r yourname
   
   RETURNED VALUE:

        you should not have a value returned   

3. In the command line, type the following command:

        puppet resource user yourname
        
   RETURNED VALUE:

        user {'yourname':
        	ensure           => 'present',
        	gid              => '502',
        	home             => '/home/yourname',
        	password         => '!!',
        	password_max_age => '99999',
        	password_min_age => '0',
        	shell            => '/bin/bash',
        	uid              => '502',
        }	     
        

4. In the command line, type the following command:

        passwd yourname
        
   RETURNED VALUE:

        Changing password for user yourname
        New password:	     

   In the command line, type puppetlabs as your new password: (nothing will visibily show as you type the password, but its there. We promise.)

        puppetlabs

   RETURNED VALUE:

        Retype new password:

   In the command line, type puppetlabs again: (again nothing will visibily show as you type the password again, but its there. We promise.)
   
        passwd yourname   
   
   RETURNED VALUE:

        passwd: all authentication tokens updated successfully


5. In the command line, type the following command: (password value is an example. The value will be unique to your user account.)

        puppet resource user yourname

   RETURNED VALUE:

        user {'yourname':
        	ensure           => 'present',
        	gid              => '502',
        	home             => '/home/yourname',
        	password         => 'ghdHjfnskLKd.32402/DSlakfhvs',
        	password_max_age => '99999',
        	password_min_age => '0',
        	shell            => '/bin/bash',
        	uid              => '502',
        }	     

6. In the command line, type the following command: (password value is an example. The value will be unique to your user account.)

        puppet resource user root

   RETURNED VALUE:

         user {'root':
        	ensure           => 'present',
        	comment          => 'root',
        	gid              => '0',
        	home             => '/root',
        	password         => '$1$jrm5tnjw$h8JJ9mCZLmJvIxvDLjw1M/',
        	password_max_age => '99999',
        	password_min_age => '0',
        	shell            => '/bin/bash',
        	uid              => '0',
        }	     

   QUESTIONS:

	6a. Answer: `user`

	6b. Answer: `root`

	6c. Answer: `/root`

