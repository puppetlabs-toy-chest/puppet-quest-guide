describe _("Task 1:", host: :localhost) do
  it _('Display the module path') do
    file('/root/.bash_history')
      .content
      .should match /puppet config print modulepath/
  end
end

describe _("Task 2:", host: :localhost) do
  it _('Make the cowsay module directory') do
    file("#{MODULE_PATH}cowsay/manifests")
      .should be_directory
  end
end

describe _("Task 3:", host: :localhost) do
  it _('Create the cowsay default manifest') do
    file("#{MODULE_PATH}cowsay/manifests/init.pp")
      .should be_file
    file("#{MODULE_PATH}cowsay/manifests/init.pp")
      .content
      .should match /^class\s+cowsay\s+{.*?package\s+{\s+(['"])cowsay\1:/m
    command("puppet parser validate #{MODULE_PATH}cowsay/manifests/init.pp")
      .exit_status
      .should be_zero
  end
end

describe _("Task 4:", host: :localhost) do
  it _('Update site.pp with classification for cowsay.puppet.vm') do
    file("#{PROD_PATH}manifests/site.pp")
      .content
      .should match /node\s+(['"])?cowsay\.puppet\.vm\1\s+\{.*?include\s+cowsay.*?\}/mi
    command("puppet parser validate #{PROD_PATH}manifests/site.pp")
      .exit_status
      .should be_zero
  end
end

describe _("Task 5:", host: :cowsay) do
  it _('Run the agent and test cowsay') do
    package('cowsay')
      .should be_installed
      .by('gem')
    file('/home/learning/.bash_history')
      .content
      .should match /^cowsay/
  end
end

describe _("Task 6:", host: :localhost) do
  it _('Create the cowsay::fortune class') do
    file("#{MODULE_PATH}cowsay/manifests/fortune.pp")
      .should be_file
    file("#{MODULE_PATH}cowsay/manifests/fortune.pp")
      .content
      .should match /^class\s+cowsay::fortune\s+{.*?package\s*{\s*(['"])fortune\-mod\1:/m
  end
end

describe _("Task 7:", host: :localhost) do
  it _('Include the cowsay::fortune class into the default class') do
    command("puppet parser validate #{MODULE_PATH}cowsay/manifests/fortune.pp")
      .exit_status
      .should be_zero
    file("#{MODULE_PATH}cowsay/manifests/init.pp")
      .content
      .should match /include\s+cowsay::fortune/
    command("puppet parser validate #{MODULE_PATH}cowsay/manifests/init.pp")
      .exit_status
      .should be_zero
  end
end

describe _("Task 8:", host: :cowsay) do
  it _('Run the agent and test cowsay with fortune') do
    package('fortune-mod')
      .should be_installed
    file('/home/learning/.bash_history')
      .content
      .should match /^fortune\s+\|\s+cowsay/
  end
end
