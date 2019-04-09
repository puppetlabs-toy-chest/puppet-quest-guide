require_relative './spec_helper'

# Placeholder test for quest with no tasks
describe "The quest", host: :localhost do
  it 'begins', :solution do
    command('/bin/true')
      .exit_status
      .should eq 0
  end
end
