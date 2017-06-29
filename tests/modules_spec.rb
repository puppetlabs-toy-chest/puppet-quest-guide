describe _("Task 1:") do 
  it _('Use puppet master --configprint find the modulepath') do
    file('/root/.bash_history')
      .content
      .should match /puppet\s+master\s+--configprint\s+modulepath/
  end
end

describe _("Task 2:") do
  it _('Create a directory for your vimrc module') do
    file("#{MODULE_PATH}vimrc")
      .should be_directory
  end
end

describe _("Task 3:") do
  it _('Create manifests, examples, and files subdirectories') do
    file("#{MODULE_PATH}vimrc/manifests")
      .should be_directory
    file("#{MODULE_PATH}vimrc/examples")
      .should be_directory
    file("#{MODULE_PATH}vimrc/files")
      .should be_directory
  end
end

describe _("Task 4:") do
  it _('Copy the .vimrc into the module files directory') do
    file("#{MODULE_PATH}vimrc/files/vimrc")
      .should be_file
  end
end

describe _("Task 5:") do
  it _("Add the 'set nu' command to the vimrc file") do
    file("#{MODULE_PATH}vimrc/files/vimrc")
      .content
      .should match /set\s+nu/
  end
end

describe _('Task 6:') do
  it _('Define the vimrc class') do
    file("#{MODULE_PATH}vimrc/manifests/init.pp")
      .should contain 'class vimrc'
  end
end

describe _('Task 7:') do
  it _('Include the vimrc class in a test manifest') do
    file("#{MODULE_PATH}vimrc/examples/init.pp")
      .should contain 'include vimrc'
  end
end

describe _('Task 8:') do
  it _("Apply the test to add the 'set nu' command to your .vimrc") do
    file('/root/.vimrc')
      .content
      .should match /set\s+nu/
  end
end
