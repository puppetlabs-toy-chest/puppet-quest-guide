describe _("Task 1:") do
  it _('Create the directory structure for your web module') do
    file("#{MODULE_PATH}web")
      .should be_directory
    file("#{MODULE_PATH}web/examples")
      .should be_directory
    file("#{MODULE_PATH}web/manifests")
      .should be_directory
  end
end

describe _("Task 2:") do
  it _('Define the web class') do
    file("#{MODULE_PATH}web/manifests/init.pp")
      .content
      .should match /class\s+web/
  end
end

describe _("Task 3:") do
  it _('Include the web class in a test manifest') do
    file("#{MODULE_PATH}web/examples/init.pp")
      .should contain 'web'
  end
end

describe _("Task 4:") do
  it _('Apply your test manifest to create your website files') do
    file('/var/www/quest/hello.html')
      .should be_file
    file('/var/www/quest/bonjour.html')
      .should be_file
  end
end

describe _("Task 5:") do
  it _('Add $page_name and $message parameters and create a file using their values') do
    file("#{MODULE_PATH}web/manifests/init.pp")
      .content
      .should match /class\s+web\s+\(\s*(\$page_name|\$message)\s*,\s*(\$page_name|\$message)\s*\)/
    file("#{MODULE_PATH}web/manifests/init.pp")
      .content
      .should match /file\s*\{\s*\"\$\{doc_root\}\/?\$\{page_name\}\.html\"\s*:/
  end
end

describe _("Task 6:") do
  it _('Declare the web class with parameters in your test manifest') do
    file("#{MODULE_PATH}web/examples/init.pp")
      .content
      .should match /class\s* \{\s*['"]web['"]\s*:
                       \s+
                       (page_name\s*=>\s*['"]\w+['"]|message\s*=>\s*['"].+?['"]),
                       \s+
                       (page_name\s*=>\s*['"]\w+['"]|message\s*=>\s*['"].+?['"]),?
                     \s*}/x
  end
end

describe _("Task 7:") do
  it _('Apply your test manifest to generate a new file with parameterized values') do
    file('/var/www/quest/hola.html')
      .should be_file
  end
end
