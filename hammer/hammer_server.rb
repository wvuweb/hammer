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
options.port = 8080
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
# hammer_branch_cmd = "cd ../ && git branch | grep \* | cut -d ' ' -f2"

hammer_current_tag_cmd = "git describe --exact-match --tags $(git log -n1 --pretty='%h')"
latest_tag_cmd = "git describe --tags `git rev-list --tags --max-count=1`"

current_tag = `#{hammer_current_tag_cmd}`
latest_tag = `#{latest_tag_cmd}`

if current_tag == ""
  current_tag = `git describe`
  current_version_info = current_tag.split('-')
  puts "\n"
  puts "You are running a development version of Hammer #{current_version_info[0]}".colorize(:green)
  puts "You are #{current_version_info[1]} commits ahead at hash #{current_version_info[2]}".colorize(:green)
else
  current_tag.slice! "v"
  latest_tag.slice! "v"

  if Gem::Version.new(current_tag) < Gem::Version.new(latest_tag)
    puts "Your Hammer Version #{current_tag} is behind the latest version #{latest_tag}".colorize(:red)
    puts "Run `vagrant hammer update` to upgrade to the latest version".colorize(:light_green)
  else
    puts "\n"
    puts "You are running the latest Hammer version: ".colorize(:green)+" v#{current_tag}"
    puts "\n"
  end
end


doc_root = options.directory

code_dir = doc_root+'/code'

if File.directory?(code_dir)

  begin

    # Add identity files for bitbucket
    File.chmod(0600,"./config/hammer")
    # puts "Adding SSH Identity for Code repository"

    code_ref_cmd = "ssh-agent bash -c 'ssh-add ./config/hammer &> /dev/null; cd #{code_dir} && git rev-parse master'"
    code_remote_cmd = "ssh-agent bash -c 'ssh-add ./config/hammer &> /dev/null; git ls-remote git@bitbucket.org:wvudigital/code.git master -q'"

    code_ref = `#{code_ref_cmd}`
    code_ref = code_ref.delete("\n")
    code_remote = `#{code_remote_cmd}`
    code_remote = code_remote.split("\n").collect{|ref| ref.split("\t")}.select{|remote| remote[1] == "refs/heads/master"}[0][0]

    #code_ref = g.lib.send(:command, "rev-parse master")
    #code_remote = g.lib.send(:command, "rev-parse origin/master")

    if code_ref.to_s != code_remote.to_s
      puts "Code Local repo ref is at: ".colorize(:light_white)+"#{code_ref}".colorize(:light_blue)
      puts "Code Remote repo ref is at: ".colorize(:light_white)+"#{code_remote}".colorize(:light_blue)

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
puts "    Starting in #{doc_root}...      ".black.on_green
puts "    Now available at http://localhost:#{options.port}...     ".black.on_green
puts " "
puts " "

log = nil
access_log = nil

if options.daemon == 1
  log_file = File.open '/var/log/webrick/error.log', 'a+'
  log = WEBrick::Log.new log_file

  access_file = File.open '/var/log/webrick/error.log', 'a+'
  access_log = WEBrick::Log.new access_file
end

httpd = WEBrick::HTTPServer.new(
  :BindAddress => "0.0.0.0",
  :Port => options.port,
  :DocumentRoot => doc_root,
  :ServerType => options.daemon,
  :DirectoryIndex => [],
  :Logger => log,
  :AccessLog => access_log
)

httpd.mount("/", HammerServlet, doc_root, true)

trap(:INT){ httpd.shutdown }
httpd.start
