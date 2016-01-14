require 'spec_helper'

describe "Task 1:" do
  it 'Create the web_user module directory with manifests and examples subdirectories' do
    file("#{MODULE_PATH}web_user").should be_directory
    file("#{MODULE_PATH}web_user/manifests").should be_directory
    file("#{MODULE_PATH}web_user/examples").should be_directory
  end
end

describe "Task 2:" do
  it 'Define a simple web_user::user resource type' do
    file("#{MODULE_PATH}web_user/manifests/user.pp").content.should match /define\s+web_user::user/
    file("#{MODULE_PATH}web_user/manifests/user.pp").content.should match /user\s+{\s+\$title:/
    file("#{MODULE_PATH}web_user/manifests/user.pp").content.should match /file\s+{\s+/
  end
end

describe "Task 3:" do
  it "Create a test manifest to apply your new defined resource type" do
    file("#{MODULE_PATH}web_user/examples/user.pp").content.should match /web_user::user\s+{\s*'shelob':\s*}/
  end
end

describe "Task 4:" do
  it "Apply your test manifest" do
    file('/home/shelob').should be_directory
    user('shelob').should exist
  end
end

describe "Task 5:" do
  it "Extend your web_user::user resource type to create a public_html directory and an index.html document" do
    file("#{MODULE_PATH}web_user/manifests/user.pp").content.should match /user\s+{\s+\$title:/
    file("#{MODULE_PATH}web_user/manifests/user.pp").content.should match /file\s+{\s+\"\${public_html}\/index\.html\":/
  end
end

describe "Task 6:" do
  it "Apply your test manifest again to create your user's public_html directory and index.html document" do
    file('/home/shelob/public_html').should be_directory
    file('/home/shelob/public_html/index.html').should be_file
  end
end

describe "Task 7:" do
  it 'Add $content and $password parameters to your defined resource type' do
    file("#{MODULE_PATH}web_user/manifests/user.pp").content.should match /\$content\s+=\s+"<h1>Welcome to \${title}'s home page!<\/h1>",/
    file("#{MODULE_PATH}web_user/manifests/user.pp").content.should match /\$password\s+\=\s+undef,/
  end
end

describe "Task 8:" do
  it "Declare a new web_user::user in your test manifest with parameters" do
    file("#{MODULE_PATH}web_user/examples/user.pp").content.should match "web_user::user\s+{\s*'frodo':"
  end
end


describe "Task 9:" do
  it "Apply your test manifest a final time to make use of your specified parameters" do
    file('/home/frodo/public_html').should be_directory
    file('/home/frodo/public_html/index.html').should be_file
  end
end
