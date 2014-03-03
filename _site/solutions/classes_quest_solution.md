# Classes Quest Solutions

1. Enter the following command:

		puppet apply /root/examples/modules1-ntp1.pp
	
	RETURN:

		Notice: Finished catalog run in 0.24 seconds

2. Enter the following command:

		nano /root/examples/modules1-ntp1.pp

	RETURNED VALUE:

		class ntp {
		  case $operatingsystem {
			centos, redhat: {
			$service_name = 'ntpd'
			$conf_file    = 'ntp.conf.el'
			}

		  debian, ubuntu: {
			$service_name = 'ntp'
			$conf_file    = 'ntp.conf.debian'
			}
		  }

		  package { 'ntp':
			ensure => installed,
		  }

		  file { 'ntp.conf':
			path    => '/etc/ntp.conf',
			ensure  => file,
			require => Package['ntp'],
			source  => "/root/examples/answers/${conf_file}"
		  }

		  service { 'ntp':
			name      => $service_name,
			ensure    => running,
			enable    => true,
			subscribe => File['ntp.conf'],
		  }
		}

3. Enter the following command at the bottom of the manifest:

		include ntp

	Should look like this:
	
		class ntp {
		  case $operatingsystem {
			centos, redhat: {
			$service_name = 'ntpd'
			$conf_file    = 'ntp.conf.el'
			}

		  debian, ubuntu: {
			$service_name = 'ntp'
			$conf_file    = 'ntp.conf.debian'
			}
		  }

		  package { 'ntp':
			ensure => installed,
		  }

		  file { 'ntp.conf':
			path    => '/etc/ntp.conf',
			ensure  => file,
			require => Package['ntp'],
			source  => "/root/examples/answers/${conf_file}"
		  }

		  service { 'ntp':
			name      => $service_name,
			ensure    => running,
			enable    => true,
			subscribe => File['ntp.conf'],
		  }
		}
		
		include ntp

4. To exit the shell script, do a 'Control X' on the keyboard

5. You will then be prompted to save the file you just created. Hit 'y' on the keyboard for "Yes".

6. You will be prompted to name your file. Keep it the same. Just hit 'Enter' on the keyboard.

	RETURNED VALUE:

        the learning vm will exit the shell script

7. Run the following command

		puppet apply /root/examples/modules1-ntp1.pp

	RETURNRED VALUE:

		Notice: /Stage[main]/Ntp/File[ntp.conf]/content: content changed '{md5}5baec8bdbf90f877a05f88ba99e63685' to '{md5}dc20e83b436a358997041a4d8282c1b8'
		Notice: /Stage[main]/Ntp/Service[ntp]/ensure: ensure changed 'stopped' to 'running'
		Notice: /Stage[main]/Ntp/Service[ntp]: Triggered 'refresh' from 1 events
		Notice: Finished catalog run in 0.88 seconds


