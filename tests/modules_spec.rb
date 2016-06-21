describe "Task 1:" do 
  it 'Use puppet master --configprint find the modulepath' do
    file('/root/.bash_history')
      .content
      .should match /puppet\s+master\s+--configprint\s+modulepath/
  end
end

describe "Task 2:" do
  it 'Create a directory for your vimrc module' do
    file("#{MODULE_PATH}vimrc")
      .should be_directory
  end
end

describe "Task 3:" do
  it 'Create manifests, examples, and files subdirectories' do
    file("#{MODULE_PATH}vimrc/manifests")
      .should be_directory
    file("#{MODULE_PATH}vimrc/examples")
      .should be_directory
    file("#{MODULE_PATH}vimrc/files")
      .should be_directory
  end
end

describe "Task 4:" do
  it 'Copy the .vimrc into the module files directory' do
    file("#{MODULE_PATH}vimrc/files/vimrc")
      .should be_file
  end
end

describe "Task 5:" do
  it "Add the 'set nu' command to the vimrc file" do
    file("#{MODULE_PATH}vimrc/files/vimrc")
      .content
      .should match /set\s+nu/
  end
end

describe 'Task 6:' do
  it 'Define the vimrc class' do
    file("#{MODULE_PATH}vimrc/manifests/init.pp")
      .should contain 'class vimrc'
  end
end

describe 'Task 7:' do
  it 'Include the vimrc class in a test manifest' do
    file("#{MODULE_PATH}vimrc/examples/init.pp")
      .should contain 'include vimrc'
  end
end

describe 'Task 8:' do
  it "Apply the test to add the 'set nu' command to your .vimrc" do
    file('/root/.vimrc')
      .content
      .should match /set\s+nu/
  end
end
