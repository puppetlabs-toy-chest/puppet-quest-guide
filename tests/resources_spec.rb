describe _("Task 1:") do
  it _('Inspect the root user resource') do
    file('/root/.bash_history')
      .content
      .should match /puppet\s+resource\s+user\s+root/
  end
end

describe _("Task 2:") do
  it _('View the description of the user resource') do
    file('/root/.bash_history')
      .content
      .should match /puppet\s+describe\s+user/
  end
end

describe _("Task 3:") do
  it _('Create the user galatea') do
    file('/etc/passwd')
      .should contain "galatea"
  end
end

describe _("Task 4:") do
  it _('Give the galatea user the comment Galatea of Cyprus') do
    file('/etc/passwd')
      .content
      .should match /Galatea\s+of\s+Cyprus/
  end
end
