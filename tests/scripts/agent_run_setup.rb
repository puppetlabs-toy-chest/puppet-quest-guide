#!/bin/ruby

require_relative './setup_helper.rb'

clear_nodes
create_node('hello.puppet.vm', 'agent', false)
update_docker_hosts
wait_for_ssh(['hello.puppet.vm'])
