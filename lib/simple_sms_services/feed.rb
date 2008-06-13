require 'rubygems'
gem 'subscription_manager'
require 'subscription_manager'
gem 'feed-normalizer'
require 'feed-normalizer'
require 'open-uri'
require 'erb'
# concept stolen from http://www.rubyinside.com/build-a-feed-reader-in-26-lines-of-ruby-431.html
# equire 'open-uri'
#require 'feed-normalizer'
#require 'erubis'
#require 'mongrel'
 
#class RSSHandler < Mongrel::HttpHandler
 # def process(request, response)
  #  response.start(200) do |head,out|
  #    head["Content-Type"] = "text/html"

  #    stories = []
  #    File.open('feeds.txt', 'r').each_line { |f|
  #      feed = FeedNormalizer::FeedNormalizer.parse open(f.strip)
  #      stories.push(*feed.entries)
  #    }     

  #    eruby = Erubis::Eruby.new(File.read('news.eruby'))
  #    out.write(eruby.result(binding()))
  #  end
 # end
# end
 
#h = Mongrel::HttpServer.new("0.0.0.0", "80")
#h.register("/", RSSHandler.new)
# h.register("/files", Mongrel::DirHandler.new("files/"))
# h.run.join
module SimpleSmsServices #:nodoc:
  # grab a feed and get results
  # sample feed is: http://www.iht.com/rss/frontpage.xml
  class Feed
    attr_accessor :feed_url, :stories, :title, :unsubscribe_command
    def initialize(url, title)
      self.feed_url =url
      self.title=title
      self.unsubscribe_command="subscribe #{title} off"
    end
    def process
      data = FeedNormalizer::FeedNormalizer.parse open(self.feed_url)
      self.stories=[]
      self.stories.push(*data.entries)
      
    end
    # get the result, could be iproved to only check oce a day etc.
     def get_data_mms
        process
        puts " Feed #{self.feed_url} generated #{self.stories.size} stories"
         result = "News from #{self.title}"
           len =   self.stories.size
          result << build_data(len)
          result <<  "\r\n To unsubscribe from this service '#{self.unsubscribe_command}'  to 888"
        result
      end
    def get_data
      process
      puts " Feed #{self.feed_url} generated #{self.stories.size} stories"
       result = "#{self.title}"
          len =   self.stories.size >9  ? 9 : self.stories.size
         result << build_data(len)
         result
    end
    def build_data(len)
       res=""
       0.upto(len-1) { |i| 
         	sms_msg = <<EOF__RUBY_END_OF_MESSAGE
         	
#{self.stories[i].title}
#{self.stories[i].content}
#{self.stories[i].id}
EOF__RUBY_END_OF_MESSAGE
       #  puts "building message #{sms_msg}"
         res << "#{sms_msg}"   
          }
          
     res
    end
    def filter_data(d)
      #puts "before filter BEGIN #{d}  \n END"
      
        data=d.to_s
       data2= data.gsub(/<\/?[^>]*>/, "")
       data2.gsub!('"',' ')
        data2.gsub!("'",'')
        data2.gsub!('$','dollar ')
        data2.gsub!('%','percent ')
        data2.gsub!("_",'')
        data2.gsub!("“",' ')
      
        
          data2.gsub!("@",' ')
         data2.gsub!("”",' ')
         data2.gsub!("<", "")
         data2.gsub!(">", "")
       data2.gsub!(/\[/, "")
       data2.gsub!(/\]/, "")
      #  data2=ERB::Util.h(data2)
           data2.gsub!("&amp;quot;",' ')
           data2.gsub!("&quot;",' ')
     #   data=ERB::Util.h(data2)
    #   data.gsub!('&amp;quot;', "--")
    #   puts "after filter #{data}"
       data2
    
    end

    def send_mms_to_subscription(arg_hash)
       data=self.get_data_mms
        
        arg_hash[:broadcast]=""
        arg_hash[:broadcast] << data
          arg_hash[:broadcast] << " "
         arg_hash[:action]= 'action_broadcast_text_mms'
         self.send_to_subscription_manager(arg_hash)
    end
    def send_sms_to_subscription(arg_hash)
       data=self.filter_data(self.get_data)
        # 10 sms is roughly 1400 characters, 1300 is approximate...
       
        len =   data.size > 1300 ? 1300 : data.size
        puts "data size is #{data.size} len is #{len}"
        len=len-1
        arg_hash[:broadcast]=""
        arg_hash[:broadcast] << data[0..len]
          arg_hash[:broadcast] << " "
         arg_hash[:action]= 'action_broadcast_sms'
         self.send_to_subscription_manager(arg_hash)
    end
    def send_to_subscription_manager(arg_hash)
         
       
         puts "about to send  command  #{arg_hash[:action]}  with data of length: #{arg_hash[:broadcast].size} to all subscribers of keyword #{arg_hash[:keyword]}"
         puts "---DEBUG Broadcast #{arg_hash[:broadcast]}" if arg_hash[:debug]
         submgr=SubscriptionManager::SubscriptionSendTopic.new(arg_hash)
         result=submgr.send_subscription_response(arg_hash)
       #  puts "result is #{result}"
         result
    end
  end
end
