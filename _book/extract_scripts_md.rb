#!/usr/bin/env ruby
require 'kramdown'
require 'fileutils'

DEBUG = true 

def shbang(lang)
  case lang.to_sym
  when :puppet
    "#!/opt/puppetlabs/puppet/bin/puppet apply\n"
  when :shell
    "#!/bin/bash -x\n"
  end
end

def read_file(file,line_number)
  IO.readlines(file)[line_number]
end

def cputs(string)
  puts "\033[1m#{string}\033[0m"
end
@scripts = {}

markdown_file = ARGV[0] 
if File.exists?(markdown_file)
  cputs "Processing : #{markdown_file}"
  @scripts = Hash.new
  text = File.read(markdown_file)
  doc  = Kramdown::Document.new(text, input: 'GFM')
  doc.root.children.each do |section|
    case section.type
    when :codeblock
      case section.value.split("\n")[0]
      when /.*/ 
        puts "#{section.value.lines.to_a.delete_if{|l| l =~ /^puppet.*$\n/}.join}"
        markdown_comment = read_file(
          markdown_file,
          section.options[:location] - 3,
        )
      end
      match = markdown_comment.match(
        /^\[\/\/\]\:\s#\s\((?<filename>\S*\.\w+)\)$/
      )
      # Skip if we didn't find markdown comment ( still sent to stdout though )
      next if match.nil?
      filename = match['filename']
      # Add the shbang to the top of the file
      (@scripts[filename] ||= [])[0] = shbang(
        section.options[:lang]
      )
      @scripts[filename] << section.value
    end
  end
end

@scripts.each do |filename,lines|
  dirname = File.dirname(filename)
  unless File.directory?(dirname)
      FileUtils.mkdir_p(dirname)
  end
  puts "Writing file: #{filename}"
  File.open(filename, 'w+') do |f|
    lines.each { |element| f.puts(element) }
  end
  FileUtils.chmod 0755, filename
end
