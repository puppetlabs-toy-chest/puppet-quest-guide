# Courseware Learning VM

## Synopsis

The Learning VM (Virtual Machine) is a self contained environment with everything a new user needs to get started learning Puppet. The courses are in an extensible quest-based format to allow users to explore and build on concepts at their own pace. The self-paced learning format lets users at any level, not just command-line ninjas, get started with Puppet quickly and painlessly.

Because the VM and Quest Guide are self contained, the user can learn Puppet anywhere; after the initial download, no internet connection is required.

## Markdown Conversion

To facilitate development of new quests, we have abstracted Quest Guide content from the delivery. Quest Guide content developed in a markdown format, and each quest is placed in the `quests` directory. To process markdown into the HTML files delivered by the VM, simply edit the `quest_guide.json` file to include the name of each new quest (without the `.md` extension). Be sure any images used in the markdown file are kept in the `assets  ` directory. Run the `quest_guide.rb` script. This script will convert the markdown files into HTML, and save them in the `html` directory.
