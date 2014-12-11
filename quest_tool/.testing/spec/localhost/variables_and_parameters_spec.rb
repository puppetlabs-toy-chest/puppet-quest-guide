require 'spec_helper'

# Task 1
describe "The directory structure for your web module" do
  it 'should be created' do
    file('/etc/puppetlabs/puppet/modules/web').should be_directory
    file('/etc/puppetlabs/puppet/modules/web/tests').should be_directory
    file('/etc/puppetlabs/puppet/modules/web/manifests').should be_directory
  end
end

# Task 2
describe "The web/manifests/init.pp manifest" do
  it 'should define the web class' do
    file('/etc/puppetlabs/puppet/modules/web/manifests/init.pp').content.should match /class\sweb/
  end
end

# Task 3
describe "The web/tests/init.pp manifest" do
  it 'should declare the web class' do
    file('/etc/puppetlabs/puppet/modules/web/tests/init.pp').should contain 'web'
  end
end

# Task 4
describe "The hello.html and bonjour.html files" do
  it 'should exist in the /var/www/html/lvmguide directory' do
    file('/var/www/html/lvmguide/hello.html').should be_file
    file('/var/www/html/lvmguide/bonjour.html').should be_file
  end
end

# Task 5
describe "The web class" do
  it 'should have $page_name and $message parameters and declare a new file resource using their values' do
    file('/etc/puppetlabs/puppet/modules/web/manifests/init.pp').content.should match /class\sweb\s\(\s*(\$page_name|\$message),\s(\$page_name|\$message)\s*\)/
    file('/etc/puppetlabs/puppet/modules/web/manifests/init.pp').content.should match /file\s\{\s\"\$\{doc_root\}\/\$\{page_name\}\.html\":/
  end
end

# Task 6 
describe "The web/tests/init.pp manifest" do
  it 'should declare the web class with parameters' do
    file('/etc/puppetlabs/puppet/modules/web/tests/init.pp').content.should match /class \{\s*\'web\':\s+(page_name\s+=>\s+\'\w+\'|message\s+=>\s+\'.+\'),\s+(\s+page_name\s+=>\s+\'\w+\'|message\s+=>\s+\'.+\'),\s}/
  end
end

# Task 7
describe "The hola.html file" do
  it 'should exist in the /var/www/html/lvmguide directory' do
    file('/var/www/html/lvmguide/hola.html').should be_file
  end
end
