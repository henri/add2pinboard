#!/usr/bin/env ruby

# (C)2022 - Henri Shustak 
# Licenced under the GNUv3 or later licence
# https://www.gnu.org/licenses/gpl-3.0.en.html

# For now this script is for adding items to pinboard. It may be that it bceomes more than that. 
# Such features (full command line manipulation features) are for a later version / project.

# https://www.rubyinrails.com/2013/09/14/how-to-install-or-uninstall-a-gem-in-ruby/
# https://github.com/ryw/pinboard

# Note : Works with ruby 2.6.3 - The gem this script relies upon is not compatible with some of the later versions of ruby.

# version 0.1 - just barely working - probably has some bugs.
# version 0.2 - added a gemlist check.
# version 0.3 - added a current directory check.
# version 0.4 - report the last added pin (better approach may be checking for errors) or at least confirming the last added URL matches the URL submitted.
# version 0.5 - some basic error capture.
# version 0.6 - improved usage information.
# version 0.7 - improved option descriptions

partnet_dir = File.dirname(__FILE__) # use this approach if the API key is in the same directory as the script
file="#{partnet_dir}/api.key"
File.readlines(file).each do |line|
  @apikey=line.to_s.chomp
end

begin
  require 'pinboard'
rescue LoadError
  puts "ERROR! : Missing gem \"pinboard\"."
  puts "         Install missing gem using the following command : sudo gem install pinboard"
  exit -1
end

pinboard = Pinboard::Client.new(:token => "#{@apikey}") 

require 'optparse'
require 'optparse/URI'

@options = {}
@options[:url] = nil
@options[:description] = nil
@options[:tags] = nil
@options[:extended] = nil
@options[:flag] = nil

OptionParser.new do |opts|
  
  opts.on("-u", "--url \"url\"", "URL to add into pinboard") do |url|
    @options[:url] = true    
    @url = "#{url}"
  end
  opts.on("-d", "--description \"description\"", "the description - AKA title") do |description|
    @options[:description] = true
    @description = "#{description}"
  end
  opts.on("-t", "--tags \"tags\"", "list of tags seperatred by spaces") do |tags|
    @options[:tags] = true
    @tags = "#{tags}"
  end
   opts.on("-e", "--extended \"extended\"", "list of extended information or notes - AKA as description within pinboard web interface)") do |extended|
    @options[:extended] = true
    @extended = "#{extended}"
  end
  opts.on("-f", "--flag", "flag to read later - AKA to read") do
    @options[:flag] = true
  end
end.parse!



# Pre-Flight Checks
if @options.fetch(:url) == nil || @url == nil || @options.fetch(:description) == nil || @description == nil then
    puts ""
    puts `"#{__FILE__}" --help`
    puts "" ; puts ""
    puts "Examples and required option usage (you must specifiy at least these options) : "
    puts ""
    puts "          pinboard.rb --url \"http://myurl.com\" --description \"This is my URL!\""
    puts ""
    puts "          pinboard.rb -u \"http://myurl.com\" -d \"This is my URL!\""
    puts "" ; puts ""
    exit
	
end


# todo - check if the URL exits and if it exists and any of the values are nill - populate them so we are not removing data from pinboard unless there is a specific "" value wich removes data for a field within pinboard.


begin
  if @options.fetch(:flag) == nil  then
	  result = pinboard.add(:url => "#{@url}", :description => "#{@description}", :tags => "#{@tags}", :extended => "#{@extended}")
  else
	  result = pinboard.add(:url => "#{@url}", :description => "#{@description}", :tags => "#{@tags}", :extended => "#{@extended}", :toread => "")
  end
rescue SocketError
  puts "                     ERROR! : Network Connection Problem"
  exit -99
end

# report the last stored pin
if result == "done" then
  puts "                      ==>  pin updated / added succesfully"
  exit 0
end

	
# # report the last stored pin
# puts "last added pin"
# puts "*" * 50
# puts pinboard.posts(:results => 1).inspect
# $puts "*" * 50
	

#pinboard.posts(:tag => 'ruby')
#puts pinboard.posts.inspect
#puts pinboard.posts(:results => 6)
#puts pinboard.posts(:start => 20).inspect
