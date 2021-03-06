#!/usr/bin/env ruby
# == Synopsis
#   run the daily flickr tags subscriptions
# == Usage
#  daily_flickr_tags.rb  -h host -p port -d " 
# == Useful commands
# daily_flickr_tags.rb  -d 
# == Author
#   Scott Sproule  --- Ficonab.com (scott.sproule@ficonab.com)
# == Copyright
#    Copyright (c) 2007 Ficonab Pte. Ltd.
#     See license for license details
require 'rubygems'
require 'optparse'
#
begin
  gem 'simple_sms_services'
  require 'simple_sms_services'
rescue LoadError => e
  puts '---- simple sms services required'
  puts '---- install with the following command'
  puts '----- sudo gem install simple_sms_services'
  puts "----- #{e.backtrace}"
  exit(1)
end
require 'optparse'
gem 'stomp_message'
require 'stomp_message'
require 'rdoc/usage'

 arg_hash=StompMessage::Options.parse_options(ARGV)
 RDoc::usage if   arg_hash[:help]==true
require 'pp'

    arg_hash={}
    subscriptions=SimpleSmsServices::ProcessSubscriptions.new("flickr",arg_hash)
    flickr_do=subscriptions.subscriptions
    puts "found #{flickr_do.size} subscriptions"
    feed_messages=[]
     
    flickr_do.each { |e|   puts "processing #{e.inspect}"
                       sub = e[:msisdn]
                       tagt = e[:keyword_params]
                       begin 
                       tag=tagt.split(':')
                       tag=tag.join(' ')
                         puts "MMS Processing #{sub}: from flickr: #{tag}"
                       feed=SimpleSmsServices::FlickrImages.new(tag,
                      "Flickr: #{tag} images")
                      feed.unsubscribe_command="subscribe flickr:#{tagt} off"
                       arg_hash={}
                       
                       result=feed.send_to_mms_manager(arg_hash,sub)
                       feed_messages << result << "for #{feed.pictures.size} images"
                       puts "MMS result is #{result}"
                             feed=nil
                         #  sleep(1)  #just to let smsc relax
                        rescue Exception => e
                          feed_messages << "exception: sub #{sub} #{tagt}: msg: #{e.message}"
                        end
                                              }              
                  puts "Result is #{feed_messages.join("\n")}"
                    email='scott.sproule@cure.com.ph'
                    StompMessage::StompSendTopic.send_email_stomp("scott.sproule@cure.com.ph","DAILY FLICKR", email,
                                    "flickr subscriptions: processed  #{feed_messages.size}", feed_messages.join('\n'))
exit!


