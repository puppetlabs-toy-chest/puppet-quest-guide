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