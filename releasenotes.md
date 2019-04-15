{% include '/version.md' %}

## Release Notes

### 2.5.1
  * Explain puppet-bolt package installation with host-only adapter

### 2.5.0
  * Updated to PE 2019.0.2
  * Added new quest content describing Bolt and the Puppet product portfolio
  * Incorporated user-reported bug fixes

### v2.4.0
  * Updated content for compatibility with PE 2019.0.1
  * Updated content for compatibility with currently-supported Puppet modules
  * Various typo, grammar and other verbiage fixes
  * Fixed control repository private key name
  * Added more specific instructions based on user feedback

### v2.3.0
  * Content tested for compatibility with puppet-2017.3.5-learning-6.5.ova VM build
  * Added Hiera, Control Repository, and Puppetfile quests localized for English and Japanese.
  * Removed some unused packages to reduce VM archive size.
  * Minor typo and punctuation fixes.

### v2.2.1
  * Content tested for compatibility with puppet-2017.3.2-learning-6.4 VM build
  * Modified the quest setup script to ensure that the Docker SSL directory
    tree exists before attempting to copy keys from the Puppet SSL direcory.
  * New VM release fixes regression in the build process that added ~0.5GB to
    the archive size.

### v2.2.0
  * Content tested for compatibility with puppet-2017.3.2-learning-6.2 VM build
  * Removed Application Orchestration content pending implementation of Tasks
    quest to replace it.
  * Made several improvements to the quest setup process.
  * Several typo fixes and content clarifications.
  * Modified the pasture class to use the string `'none'` to specify no database
    connection rather than `undef`.

### v2.1.0
  * Content tested for compatibility with puppet-2017.2.2-learning-6.1 VM build.
  * Added internationalization framework and Japanese translated content.
  * Replaced Stickler gem server with filesystem gem cache.

### v2.0.1
  * Content tested for compatibility with puppet-2017.2.2-learning-6.0 VM build
  * Added missing task labels to the Defined Resource Types quest.
  * Various typo and spelling fixes.
  * Several task validation test improvements.
  * Added some clarifications to the setup guide.

### v2.0.0
  * Complete re-write of quest content and task spec tests.
  * Content tested for compatibility with puppet-2017.2.1-learning-5.15 VM build
  * Updated the [quest tool](https://github.com/puppetlabs/quest) to improve quest setup process.
  * Merged [pltraining-learning](https://github.com/puppetlabs/pltraining-learning) module into [pltraining-bootstrap](https://github.com/puppetlabs/pltraining-bootstrap).
  * Updated [pltraining-bootstrap](https://github.com/puppetlabs/pltraining-bootstrap) module to include a local gem server and Forge server.
  * Updated [pltraining-bootstrap](https://github.com/puppetlabs/pltraining-bootstrap) module to cache all needed content to fully support offline use.
  * Updated [pltraining-dockeragent](https://github.com/puppetlabs/pltraining-dockeragent) to support quest containerized agent use cases, including support for local gem server, local yum repo, ssh login, Puppet certificates, and PostgreSQL dependencies.

### v1.2.6
  * Add instructions to create cowsayings directory structure in the manifests
    and classes quest instead of relying on it being pre-created in the build.

### v1.2.5
  * Content tested for compatibility with puppet-2016.2.1-learning-5.6 VM build.
  * Updated [pltraining-bootstrap](https://github.com/puppetlabs/pltraining-bootstrap) module turn off default line-numbering in vim.
  * Updated [pltraining-learning](https://github.com/puppetlabs/pltraining-learning) module to create module structure directories for cowsay module.

### v1.2.4
  * Content tested for compatibility with puppet-2016.2.1-learning-5.5 VM build.
  * Updated CSS styling.
  * Minor changes to tests to be compatible with RESTful quest tool version. 
  * Minor content fixes.

### v1.2.3
  * Content tested for compatibility with puppet-2016.2.0-learning-5.4 VM build.
  * Added privacy a link to Puppet's privacy policy.
  * Fixed a CSS alignment issue with the task icons.
  * Adjusted CSS for headers and sidebar.
  * Fixed an issue with a missing / in the instruction code for the Variable and Parameters quest.
  * Added a version header note with a link to this release notes page.
  * Specified gitbook 3.1.1 in book.json.

### v1.2.2
  * Cleaned up formatting for task specs, generalized some tests to better match possible variations in Puppet code.
  * Updated screenshots to match PE 2016.2 console style changes.
  * Updated file resource declarations to better match best practices.

### v1.2.1
  * Added instructions for updating the timezone.
  * Addressed clarity of instructions in Power of Puppet and NTP quests.
  * Build process has been modified to improve VirtualBox compatibility.
  * Increase suggested CPU allocation to 2.
  * Added test tests to test the quest tests.
  * Update troubleshooting guide.

### v1.2.0
  * Added branded CSS styling.
  * Fixed incorrect offline module installation instructions.
  * Added instructions for installing cached gems when working offline.
  * Added GA gitbook plugin.
  * Adjustments to splash screen. (In pltraining-bootstrap module)
  * Added script for restarting PE stack services in the correct order.
  * Misc typo fixes and minor content changes.

### v1.0.0
  * Initial release after migration to this repository. Content is now compatible with a Gitbook-based display format and the new gem quest tool.
  * Screenshot updates for 2016.1 release.
  * Various typo fixes and wording improvements.
  * Changed setup and troubleshooting instructions to address VirtualBox I/O APIC issues.
  * Fixed a few broken or overly-specific task specs.
  * Pinned the dwerder-graphite module version to avoid future breaking changes.
  * Added css styling for the Gitbook format.
