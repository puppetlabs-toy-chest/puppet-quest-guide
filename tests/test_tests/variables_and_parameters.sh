#!/bin/bash
quest begin variables_and_parameters
#Task 1
cd /etc/puppetlabs/code/environments/production/modules/
mkdir -p web/{manifests,examples}
#Task 2
cat << "EOL" > web/manifests/init.pp
class web {

  $doc_root = '/var/www/quest'

  $english = 'Hello world!'
  $french  = 'Bonjour le monde!'

  file { "${doc_root}/hello.html":
    ensure  => file,
    content => "<em>${english}</em>",
  }

  file { "${doc_root}/bonjour.html":
    ensure  => file,
    content => "<em>${french}</em>",
  }

}
EOL
#Task 3
echo "include web" > web/examples/init.pp
#Task 4
puppet apply web/examples/init.pp
#Task 5
cat << "EOL" > web/manifests/init.pp
class web ( $page_name, $message ) {

  $doc_root = '/var/www/quest'

  $english = 'Hello world!'
  $french  = 'Bonjour le monde!'

  file { "${doc_root}/hello.html":
    ensure  => file,
    content => "<em>${english}</em>",
  }

  file { "${doc_root}/bonjour.html":
    ensure  => file,
    content => "<em>${french}</em>",
  }

  file { "${doc_root}/${page_name}.html":
    ensure  => file,
    content => "<em>${message}</em>",
  }

}
EOL
#Task 6
cat << EOL > web/examples/init.pp
class {'web': 
  page_name => 'hola',
  message   => 'Hola mundo!',
}
EOL
#Task 7
puppet apply web/examples/init.pp
