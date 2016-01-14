require 'spec_helper'

describe "Task 1:" do
  it 'Create the directory structure for your web module' do
    file("#{MODULE_PATH}web").should be_directory
    file("#{MODULE_PATH}web/examples").should be_directory
    file("#{MODULE_PATH}web/manifests").should be_directory
  end
end

describe "Task 2:" do
  it 'Define the web class' do
    file("#{MODULE_PATH}web/manifests/init.pp").content.should match /class\sweb/
  end
end

describe "Task 3:" do
  it 'Include the web class in a test manifest' do
    file("#{MODULE_PATH}web/examples/init.pp").should contain 'web'
  end
end

describe "Task 4:" do
  it 'Apply your test manifest to create your website files' do
    file('/var/www/html/questguide/hello.html').should be_file
    file('/var/www/html/questguide/bonjour.html').should be_file
  end
end

describe "Task 5:" do
  it 'Add $page_name and $message parameters and create a file using their values' do
    file("#{MODULE_PATH}web/manifests/init.pp").content.should match /class\s+web\s+\(\s*(\$page_name|\$message),\s+(\$page_name|\$message)\s*\)/
    file("#{MODULE_PATH}web/manifests/init.pp").content.should match /file\s+\{\s+\"\$\{doc_root\}\$\{page_name\}\.html\":/
  end
end

describe "Task 6:" do
  it 'Declare the web class with parameters in your test manifest' do
    file("#{MODULE_PATH}web/examples/init.pp").content.should match /class \{\s*\'web\':\s+(page_name\s+=>\s+\'\w+\'|message\s+=>\s+\'.+\'),\s+(\s+page_name\s+=>\s+\'\w+\'|message\s+=>\s+\'.+\'),\s}/
  end
end

describe "Task 7:" do
  it 'Apply your test manifest to generate a new file with parameterized values' do
    file('/var/www/html/questguide/hola.html').should be_file
  end
end
