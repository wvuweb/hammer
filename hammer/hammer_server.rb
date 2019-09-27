# encoding: utf-8

require 'rubygems'
require 'bundler/setup'
require 'dotenv'
Dotenv.load('../.env')

if ENV['ENVIRONMENT'] == "development"
  Bundler.require(:default, :development)
  require 'pry'
else
  Bundler.require(:default)
end

require 'webrick'
require 'radius'
require 'chronic'
require 'htmlentities'
require 'nokogiri'
require 'sanitize'
require 'colorize'
require 'optparse'
require 'ostruct'

require_relative './hammer'

# Set Options defaults
options = OpenStruct.new
options.directory = (Pathname.new(Dir.pwd).parent.parent + "cleanslate_themes").to_s
options.port = 8080
options.host_port = 2000
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

  o.on('-h', '--host port', Integer, 'Host Port to access hammer server on') do |h|
    options.host_port = h
  end

  o.on('-de', '--debug value', Integer, 'Debug mode shows logging in console, only works in standard mode') do |de|
    options.debug = de == 1 ? true : false
  end

  o.parse!(ARGV)
end


hammer_current_tag_cmd = "git describe --always"
latest_tag_cmd = "git ls-remote --tags origin | cut -d/ -f3- | sort -t '/' -k3 -V | awk '/^[^{]*$/{version=$1}END{print version}'"

# Execute command on bash
current_tag = `#{hammer_current_tag_cmd}`
latest_tag = `#{latest_tag_cmd}`

current_tag.slice!("v")
current_tag.slice!("\n")
latest_tag.slice!("v")
latest_tag.slice!("\n")

version_behind = false

# Split on tag with dash
# Example dev version tag from describe v1.0.13-6-a234agh
if current_tag.split('-')[1] != nil
  current_version_info = current_tag.split('-')
  puts "\n"
  puts "You are running a development version of Hammer v#{current_version_info[0]}".colorize(:green)
  puts "You are #{current_version_info[1]} commits ahead at hash #{current_version_info[2]}".colorize(:green)
else
  if Gem::Version.new(current_tag) < Gem::Version.new(latest_tag)
    version_behind = true
    puts "\n".colorize(:red)
    puts "Your installed Hammer version: ".colorize(:red)+" #{current_tag} ".colorize(background: :white, color: :black)+" is behind the latest version: ".colorize(:red)+" #{latest_tag} ".colorize(background: :white, color: :black)
    puts "Run `vagrant hammer update` to upgrade to the latest version".colorize(:light_green)
  else
    puts "\n".colorize(:green)
    puts "You are running the latest Hammer version: ".colorize(:green)+" v#{current_tag}"
  end
end
puts "\n"
puts "View the latest changes at:"
puts "https://github.com/wvuweb/hammer/blob/master/CHANGELOG.md".colorize(:light_cyan)

doc_root = options.directory

code_dir = doc_root+'/code'

if File.directory?(code_dir)

  begin

    # Add identity files for bitbucket
    File.chmod(0600,"./config/hammer")
    code_ref_cmd = "ssh-agent bash -c 'ssh-add ./config/hammer -o LogLevel=ERROR &> /dev/null; cd #{code_dir} && git rev-parse master'"
    code_remote_cmd = "ssh-agent bash -c 'ssh-add ./config/hammer -o LogLevel=ERROR &> /dev/null; git ls-remote git@bitbucket.org:wvudigital/code.git master -q'"

    code_ref = `#{code_ref_cmd}`
    code_ref = code_ref.delete("\n")
    code_remote = `#{code_remote_cmd}`
    code_remote = code_remote.split("\n").collect{|ref| ref.split("\t")}.select{|remote| remote[1] == "refs/heads/master"}[0][0]

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
puts "    Starting in #{doc_root}...   ".black.on_green
puts "    Now available at http://localhost:#{options.host_port}...   ".black.on_green
puts " "
puts " "

if options.daemon == WEBrick::Daemon
  access_log_stream = File.open('/var/log/webrick/access.log', 'w')
  access_log = [ [ access_log_stream, WEBrick::AccessLog::COMBINED_LOG_FORMAT ] ]
  server_logger = WEBrick::Log.new('/var/log/webrick/error.log')
else
  unless options.debug
    access_log_stream = File.open('../tmp/access.log', 'w')
    access_log = [ [ access_log_stream, WEBrick::AccessLog::COMBINED_LOG_FORMAT ] ]
    server_logger = WEBrick::Log.new('../tmp/error.log')
  end
end

httpd = WEBrick::HTTPServer.new(
  :BindAddress => "0.0.0.0",
  :Port => options.port,
  :DocumentRoot => doc_root,
  :ServerType => options.daemon,
  :DirectoryIndex => [],
  :Logger => server_logger,
  :AccessLog => access_log
)

httpd.mount("/", HammerServlet, {version: current_tag, version_behind: version_behind})

trap(:INT){ httpd.shutdown }
httpd.start
