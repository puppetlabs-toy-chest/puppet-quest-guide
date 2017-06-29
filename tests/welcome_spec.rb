describe _("Task 1:")) do
  it _('View the options for the quest tool') do
    file('/root/.bash_history')
      .content
      .should match /quest\s+(-h|--help)/
  end
end

describe _("Task 2:")) do
  it _('View the list of available quests') do 
    file('/root/.bash_history')
      .content
      .should match /quest\s+list/
  end
end
