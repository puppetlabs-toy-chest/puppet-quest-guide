# Use bin and gems in /opt/quest to avoid conflicts with puppet's
# bin and gems contents

ENV['PATH'] +=  ':/opt/quest/bin'
ENV['GEM_PATH'] = '/opt/quest/gems'

# Currently does nothing, but we can later use this to add functionality
# to the Rake update task without requiring a second run of the update tool.
