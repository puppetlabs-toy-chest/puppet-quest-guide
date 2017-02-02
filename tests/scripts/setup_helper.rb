require 'socket'

SCRIPT_DIR = File.dirname(__FILE__)

$stdout.sync = true

def create_node(name, image='agent', sign_cert=true, run_puppet=true)
  puts "Creating #{name}..."
  `puppet apply -e "dockeragent::node { '#{name}': ensure => present, image => '#{image}', privileged => true }"`
  if sign_cert
    wait_for_container(name)
    `puppet cert sign #{name}`
  end
  if run_puppet
    `docker exec #{name} puppet agent -t`
  end
end

def wait_for_container(name)
  count = 0
  while !system("docker ps | grep #{name}") && count < 10 do
    count =+ 1
    sleep 2
  end
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
