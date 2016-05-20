#!/usr/bin/env ruby
require 'pathname'
require 'optparse'
require 'fileutils'
require 'pp'

options = {}
options[:name]    = File.basename(Dir.pwd).split(/[-\.]/)[1]

Origin = File.expand_path(File.dirname(File.dirname(__FILE__)))
if Origin.eql?(Dir.pwd)
  options[:destination] = File.join(Dir.pwd, options[:name])
else
  options[:destination] = Dir.pwd
end
OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)} [options]\n" +
      "  Create a skeleton of salt and pillar directories for a new installation of an Elexis Server"
  opts.on("-n", "--name name", "Name of praxis (subdir). Defaults to  #{options[:name]}") do |v|
    options[:name] = v
  end
  opts.on("-d", "--destination dir", "Install into this directory. Defaults to  #{options[:destination]}") do |v|
    options[:destination] = v
  end
  opts.on("-h", "--help", "Show this help") do |v|
    puts opts
    exit
  end
end.parse!

def system(cmd, dryRun = DryRun)
  puts cmd if dryRun
  return if dryRun
  res = Kernel::system(cmd)
  unless res
    Kernel::system("logger #{__FILE__}: failed running '#{cmd}'")
    exit 2
  end
  res
end
files_to_copy = {
  File.join(Origin, 'saltstack', 'salt', 'top.sls') => File.join(options[:destination], 'salt', 'top.sls'),
  # File.join(Origin, 'saltstack', 'pillar', 'top.sls') => File.join(options[:destination], 'pillar', 'top.sls'),
}
[ 'common', 'network', 'rsnapshot_home', 'users',
  # 'defaults' are not copied
  # 'hinclient',
  # 'goodies',
  ].each do |definition|
  files_to_copy[File.join(Origin, 'saltstack', 'pillar', "#{definition}.sls")] =
      File.join(options[:destination], 'pillar', options[:name], "#{definition}.sls")
end

lines = [
  'base:',
  "  '*':",
  ]
files_to_copy.each do |src, dest|
  lines << "    - #{options[:name]}.#{File.basename(dest, '.sls')}" if /pillar/.match(File.dirname(src))
  if File.exist?(dest)
    puts "#{sprintf('%-40s', dest.sub(Dir.pwd + '/', ''))} already present. Compare it with #{src}"
    next
  end
  FileUtils.makedirs(File.dirname(dest)) unless File.directory?(File.dirname(dest))
  FileUtils.cp(src, dest, verbose: true, preserve: true)
end
top_name = File.join(options[:destination], 'pillar', 'top.sls')
if File.exist?(top_name)
  puts "Don't overwrite #{top_name} with"
  puts lines.join("\n")
else
  puts "Creating #{top_name}"
  File.open(top_name, 'w+') { |f| f.write lines.join("\n") }
end
