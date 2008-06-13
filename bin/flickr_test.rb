#!/usr/bin/env ruby
# == Synopsis
#   run the daily sms and mms commands
# == Usage
#  daily_sms_routines.rb  -h host -p port -d " 
# == Useful commands
# daily_sms_routines.rb  -d 
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



                  flickr_do = { 'flickr_sexy_girl' => 'sexy girl',
                               'flickr_sexy_man' => 'sexy man',
                                    'flickr_bikini' => 'bikini',
                                'flickr_interesting' => 'interesting ',
                                 'flickr_artistic' => 'artistic ',
                                'flickr_phils' => 'philippines',
                                  'flickr_deviantart' => 'deviantart'
                  
                           }
                  feed_messages = []
                  flickr_do.each { |keyword, tag|   puts "MMS Processing #{keyword}: from flickr: #{tag}"
                                                 feed=SimpleSmsServices::FlickrImages.new(tag,
                                                        "Flickr images: #{tag}")
                        
                                                  arg_hash={}
                                                 arg_hash[:keyword] = keyword
                                                 result=feed.send_mms_to_subscription(arg_hash)
                                                 feed_messages << result  << "for #{feed.pictures.size} images"
                                                 puts "MMS result is #{result}"
                                                 feed=nil
                                                 sleep(1)  #just to let smsc relax
                                              }              
                  puts "Result is #{feed_messages.join("\n")}"
                    email='scott.sproule@cure.com.ph'
                    StompMessage::StompSendTopic.send_email_stomp("scott.sproule@cure.com.ph","DAILY MMS", email,
                                    "sms feeds: processed  #{feed_messages.size}", feed_messages.join('\n'))

#{}`get_feed.rb  -U 'http://newsrss.bbc.co.uk/rss/newsonline_world_edition/front_page/rss.xml' -t bbcnews --k bbcnews `
#puts "iht news"
#{}`get_feed.rb  -U 'http://www.iht.com/rss/frontpage.xml' -t IHT -k ihtnews`
#puts "bbc sports"
# `get_feed.rb  -U 'http://www.iht.com/rss/frontpage.xml' -t IHT -k ihtnews`

exit!
