---
title: Troubleshooting
layout: default
---

# Troubleshooting

If you have feedback or run into any issues with the Learning VM, please visit our public issue tracker or email us at learningvm@puppetlabs.com.

Puppet Labs maintains a list of [known Puppet Enterprise issues](https://docs.puppetlabs.com/pe/latest/release_notes.html#known-issues).

## Common Issues:

#### I've completed a task, but it hasn't registered in the quest tool.

Some tasks are verified on the presence of a specific string in a file, so a typo can prevent the task from registering as complete even if your Puppet code validates and your puppet agent run is successful. You can check the actual spec tests we use with the quest tool in the `~/.testing/spec/localhost` directory.