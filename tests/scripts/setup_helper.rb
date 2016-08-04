require 'socket'

SCRIPT_DIR = File.dirname(__FILE__)

$stdout.sync = true

def create_node(name, image='agent')
  puts "Creating #{name}..."
  `puppet apply -e "dockeragent::node { '#{name}': ensure => present, image => '#{image}' }"`
end

def clear_nodes
  `puppet apply #{File.join(SCRIPT_DIR, 'clear_nodes.pp')}`
end

def update_docker_hosts
  puts 'Updating /etc/hosts...'
  `puppet apply #{File.join(SCRIPT_DIR, 'docker_hosts.pp')}`
end

def wait_for_ssh(hosts)
  puts "Waiting for node SSH services to become available..."
  hosts.each do |host|
    retries = 0
    begin
      Socket.tcp(host, 22, connect_timeout: 5)
    rescue Errno::ECONNREFUSED
      retries +=1
      if retries > 5
        puts "Timed out waiting for node SSH services to become available. Please refer the the Learning VM troubleshooting guide."
      end
      sleep 8
      retry
    end
  end
end
