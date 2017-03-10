{% include '/version.md' %}

## Release Notes

### v1.3.0
  * Content tested for compatibility with puppet-2016.5.2-learning-5.12 VM
  * Added puppet-forge-server to provide local Forge service.
  * Added browser-based terminal on port 9091.
  * Added stickler gem server to provide local rubygems service.
  * Various content clarifications.
  * Changed offline instructions to use host-only network adapter.
  * Resolved some issues with module dependency conflicts.
  * Updated troubleshooting section.

### v1.2.8
  * Content tested for compatibility with puppet-2016.5.1-learning-5.9 VM
  * Various minor typo fixes and content clarifications.

### v1.2.7
  * Content tested for compatibility with puppet-2016.4.2-learning-5.7 VM
build.
  * Add helpful error message for quest tool service failure.
  * Fixed sytling issue for bold text.
  * Fixed some issues with the task completion checks in the MySQL quest.
  * Update troubleshooting to fix reference to PE service restart script.

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
