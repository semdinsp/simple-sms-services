#!/usr/bin/env ruby
# == Synopsis
#   run the email tags subscriptions and send via mms
# == Usage
#  process_email_tags.rb  -h host -p port -d " 
# == Useful commands
#  process_email_tags.rb   -d 
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
    subscriptions=SimpleSmsServices::ProcessSubscriptions.new("email",arg_hash)
    email_do=subscriptions.subscriptions
    puts "found #{email_do.size} subscriptions"
    feed_messages=[]
    servers = { 'gmail' => ['pop.gmail.com', '995'],
          'yahoo' => ['pop.mail.yahoo.com', '995'],
           'cure' => ['mail2.cure.com.ph', '995']
       }
    email_do.each { |e| 
                       sub = e[:msisdn]
                       tagt = e[:keyword_params]
                       begin 
                       tag=tagt.split(':')
                       server=tag[0]
                       account=tag[1]
                       password=tag[2]
                       raise 'not enough elements' if tag.size!=3
                       puts "servername is #{servers[server][0]}"
                       arg_hash = {}
                       email=SimpleSmsServices::EmailToMMS.new(servers[server][0],
                                     servers[server][1],
                                    account,password,sub,arg_hash)
                       feed_messages << email.result
                       puts "MMS result is #{email}"
                             feed=nil
                         #  sleep(1)  #just to let smsc relax
                        rescue Exception => e
                          feed_messages << "exception: sub #{sub} #{tagt}: msg: #{e.message}"
                        end
                                              }              
                  puts "Result is #{feed_messages.join("\n")}"
                    email='scott.sproule@cure.com.ph'
                    StompMessage::StompSendTopic.send_email_stomp("scott.sproule@cure.com.ph","DAILY EMAIL", email,
                                    "email subscriptions: processed  #{feed_messages.size}", feed_messages.join('\n'))

exit!

