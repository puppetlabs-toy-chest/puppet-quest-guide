require_relative './spec_helper'

describe "The quest", host: :localhost do
  it _('begins'), :solution do
    command('quest begin welcome')
      .exit_status
      .should eq 0
  end
end

describe _("Task 1:") do
  it _('has a working solution'), :solution do
    command('quest --help')
      .exit_status
      .should eq 0
  end
  it _('View the options for the quest tool') do
    file('/root/.bash_history')
      .content
      .should match /quest\s+(-h|--help)/
  end
end

describe _("Task 2:") do
  it _('has a working solution'), :solution do
    command('quest list')
      .exit_status
      .should eq 0
  end
  it _('View the list of available quests') do
    file('/root/.bash_history')
      .content
      .should match /quest\s+list/
  end
end
