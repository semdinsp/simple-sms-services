#!/usr/bin/env ruby
# == Synopsis
#   get feed data
# == Usage
#   get_feed.rb  -U url -S title -a action -d 
# == Useful commands
# get_feed.rb  -U 'http://www.iht.com/rss/frontpage.xml' -S IHT -k ihtnews
# get_feed.rb  -U 'http://newsrss.bbc.co.uk/rss/newsonline_world_edition/front_page/rss.xml' -S BBC -k bbcnews
# == Author
#   Scott Sproule  --- Ficonab.com (scott.sproule@ficonab.com)
# == Copyright
#    Copyright (c) 2007 Ficonab Pte. Ltd.
#     See license for license details
  
   require 'optparse'
   gem 'stomp_message'
   require 'stomp_message'
   require 'rdoc/usage'

    arg_hash=StompMessage::Options.parse_options(ARGV)
    RDoc::usage if   arg_hash[:url]==nil || arg_hash[:subject] == nil || arg_hash[:help]==true


require 'rubygems'
gem 'simple_sms_services'
require 'simple_sms_services' 
gem 'subscription_manager'
require 'subscription_manager'  
     
     feed=SimpleSmsServices::Feed.new(arg_hash[:url],arg_hash[:subject])
     puts "data is ----\nBEGIN\n#{feed.filter_data(feed.get_data)}\n --- END DATA" if arg_hash[:debug]
     result=feed.send_mms_to_subscription(arg_hash)  # need to add flag for testing
     puts "result is #{result}"
    # puts "Response code: #{res.} body: #{res.code}"  if res.kind_of? Net::Http
    
