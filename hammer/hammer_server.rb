# encoding: utf-8

require 'rubygems'
require 'bundler/setup'
require 'rbconfig'

require 'webrick'
require 'radius'
require 'pry'
require 'chronic'
require 'htmlentities'
require 'nokogiri'
require 'sanitize'
require 'colorize'

require 'optparse'
require 'ostruct'
require 'git'

require './hammer'

class HammerServlet < WEBrick::HTTPServlet::AbstractServlet
  include Hammer
end

def os
  @os ||= (
    host_os = RbConfig::CONFIG['host_os']
    case host_os
    when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
      :windows
    when /darwin|mac os/
      :macosx
    when /linux/
      :linux
    when /solaris|bsd/
      :unix
    else
      raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
    end
  )
end

options = OpenStruct.new
options.directory = (Pathname.new(Dir.pwd).parent.parent + "cleanslate_themes").to_s
options.port = 2000
options.daemon = WEBrick::SimpleServer

OptionParser.new do |o|
  o.on('-d', '--directory directory', String, 'Directory to start hammer in') do |d|
    options.directory = d
  end

  o.on('-q', '--quick directory', String, 'Quick access a default directory') do |q|
    options.directory = (Pathname.new(Dir.pwd).parent.parent + "cleanslate_themes/#{q}").to_s
  end

  o.on('-p', '--port port', Integer, 'Port to start hammer server on') do |p|
    options.port = p
  end

  o.on('-da', '--daemon daemon', Integer, 'If the server should run Daemonized') do |da|
    options.daemon = da == 1 ?  WEBrick::Daemon : WEBrick::SimpleServer
  end

  o.parse!(ARGV)
end


# g = Git.open("../")
hammer_branch_cmd = "cd ../ && git symbolic-ref --short HEAD"

begin
  hammer_branch = `#{hammer_branch_cmd}`
  hammer_ref_cmd = "cd ../ && git rev-parse #{hammer_branch}"
  hammer_remote_cmd = "cd ../ && git ls-remote"
  hammer_ref = `#{hammer_ref_cmd}`
  hammer_remote = `#{hammer_remote_cmd}`

  hammer_branch = hammer_branch.delete("\n")
  hammer_ref = hammer_ref.delete("\n")

  hammer_remote = hammer_remote.split("\n").collect{|ref| ref.split("\t")}
  hammer_remote = hammer_remote.select{|remote| remote[1] == "refs/heads/#{hammer_branch}"}[0][0]

  puts "Hammer is on branch: ".colorize(:light_white)+"#{hammer_branch}".colorize(:light_blue)
  puts "Hammer Local #{hammer_branch} branch ref is at: ".colorize(:light_white)+"#{hammer_ref}".colorize(:light_blue)
  puts "Hammer Remote #{hammer_branch} branch ref is at: ".colorize(:light_white)+"#{hammer_remote}".colorize(:light_blue)

  # branch = g.lib.send(:command, "symbolic-ref --short HEAD")
  # ref = g.lib.send(:command, "rev-parse #{branch}")
  # remote = g.lib.send(:command, "rev-parse origin/#{branch}")

  if hammer_ref != hammer_remote
    update_url = "https://github.com/wvuweb/hammer/wiki/Update"
    puts " "
    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!".colorize(:red)
    puts "!!!".colorize(:red)+" WARNING YOU ARE BEHIND ON HAMMER VERSIONS".colorize(:light_cyan)+" !!!".colorize(:red)
    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!".colorize(:red)
    puts " "
    puts "Repository is currently at ref: ".colorize(:light_white)+(ref.to_s+" ").colorize(:light_magenta)
    puts "Remote is currently at ref: ".colorize(:light_white)+(remote.to_s+" ").colorize(:light_magenta)
    # puts "Learn how to update Hammer at: ".colorize(:light_white)+update_url.colorize(:light_cyan)
    puts " "
    puts " "
    puts "Update Hammer by using using the following command: ".colorize(:light_white)
    puts " "
    puts "vagrant hammer update".colorize(:light_green)
    puts " "
    puts "Hammer will automatically restart after updating itself".colorize(:light_white)
    puts " "
    puts " "
  end
rescue => e
  binding.pry
  puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!".colorize(:red)
  puts "!!!".colorize(:red)+" COULD NOT CHECK HAMMER REPOSITORY FOR UPDATES".colorize(:light_cyan)+" !!!".colorize(:red)
  puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!".colorize(:red)
end


doc_root = options.directory
if File.directory?(doc_root+"/code")

  # code = Git.open(doc_root+"/code")

  code_ref_cmd = " ssh-agent bash -c 'ssh-add ./config/hammer; cd #{doc_root+'/code'} && git rev-parse master'"
  code_remote_cmd = "ssh-agent bash -c 'ssh-add ./config/hammer; cd #{doc_root+'/code'} && git ls-remote'"

  begin

    code_ref = `#{code_ref_cmd}`
    code_ref = code_ref.delete("\n")
    code_remote = `#{code_remote_cmd}`
    code_remote = code_remote.split("\n").collect{|ref| ref.split("\t")}.select{|remote| remote[1] == "refs/heads/master"}[0][0]

    puts "Code Local repo ref is at: ".colorize(:light_white)+"#{code_ref}".colorize(:light_blue)
    puts "Code Remote repo ref is at: ".colorize(:light_white)+"#{code_remote}".colorize(:light_blue)

    #code_ref = g.lib.send(:command, "rev-parse master")
    #code_remote = g.lib.send(:command, "rev-parse origin/master")

    if code_ref.to_s != code_remote.to_s
      puts " "
      puts "WARNING:".colorize(:red)
      puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!".colorize(:light_cyan)
      puts "Your ".colorize(:red)+"Code".colorize(:light_white)+" Repository is out of date, please update it ".colorize(:red)
      puts "by changing directory into ".colorize(:red)+"'/cleanslate_themes/code'".colorize(:light_green)
      puts "then running ".colorize(:red)+"git pull".colorize(:light_green)
      puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!".colorize(:light_cyan)
      puts " "
    end
  rescue
    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!".colorize(:red)
    puts "!!!".colorize(:red)+" COULD NOT CHECK CODE REPOSITORY FOR UPDATES".colorize(:light_cyan)+" !!!".colorize(:red)
    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!".colorize(:red)
  end

else
  puts " "
  puts "Code directory not found.  If you want to use the shared repository".colorize(:red)
  puts "please ".colorize(:red)+"git clone https://bitbucket.org/wvudigital/code.git".colorize(:light_green)
  puts "into your cleanslate_themes directory".colorize(:red)
  puts " "
end

puts " "
puts "                                    \\`.         ".colorize(:light_magenta)
puts "          .--------------.___________) \\        ".colorize(:light_magenta)
puts "          |//// WVU /////|___________[ ]        ".colorize(:light_magenta)
puts "          `--------------'           ) (        ".colorize(:light_magenta)
puts "                                     '-'        ".colorize(:light_magenta)
puts "    ############################################".colorize(:yellow)
puts "    #     HAMMER - Clean Slate Mock Server     #".colorize(:yellow)
puts "    ############################################".colorize(:yellow)
puts " "
puts "    Starting in #{doc_root}...     ".black.on_green
puts " "
puts " "

httpd = WEBrick::HTTPServer.new(
  :Port => options.port,
  :DocumentRoot => doc_root,
  :ServerType => options.daemon,
  :DirectoryIndex => []
)

httpd.mount("/", HammerServlet, doc_root, true)

trap(:INT){ httpd.shutdown }
httpd.start
