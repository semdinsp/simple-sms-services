require 'rubygems'
gem 'subscription_manager'
require 'subscription_manager'
gem 'flickr'
require 'flickr'
require 'base64'
require 'yaml'

module SimpleSmsServices 
  # grab a feed and get results
  # sample feed is: http://www.iht.com/rss/frontpage.xml
  class FlickrImages
    attr_accessor :tag, :pictures, :title, :unsubscribe_command
    def initialize(tag, title)
      self.tag =tag
      self.title=title
      self.pictures=[]
      self.unsubscribe_command="subscribe flickr:#{tag} off"
    end
    def process
      flickr = Flickr.new('476ed9d31ee00435e8b8421602db55d6')
       self.pictures=[]
      rand_page=3*rand
      page_num=rand_page.to_i
      count=0
        criteria = { 'tags' => "#{self.tag}", 'page' => page_num.to_s, 'per_page' => '20' }
         begin
          for photo in flickr.photos( criteria ) 
            val = rand
            self.pictures << photo.file( 'Medium' ) if val>=0.5 and count <5 and photo!=nil
            count+=1 if val>=0.5
            break if count>5 or photo==nil
            
           # puts " random var: #{val} photo #{photo.inspect}"
          end
         rescue NoMethodError
           puts 'likely no images '  # see flickr_gem method photos in flickr.rb at line 103
         end
     self.pictures.size  
    end
    # get the result, could be iproved to only check oce a day etc.
     def get_data_mms
        process
        puts " Feed #{self.tag} generated #{self.pictures.size} pictures"
         self.pictures.size  
      end
    def build_content
      
       data=self.get_data_mms
       
       content=[]
      
       self.pictures.each { |photo|
         content <<  MmscManager::MmsMessage.build_image_content(
              photo,  'jpeg')
            }
            content <<  MmscManager::MmsMessage.build_text_content("Sorry we were unable to find any images for flickr tag: #{self.tag}") if self.pictures.size==0
             content <<  MmscManager::MmsMessage.build_text_content("To unsubscribe from this service '#{self.unsubscribe_command}'  to 233")
              content <<  MmscManager::MmsMessage.build_text_content("All content is from flickr.com and copyright flickr.com and the image owner.  The above images are public images found using flickr tags: #{self.tag}")
       content
    end
    def send_mms_to_subscription(arg_hash)
      
         content=build_content
         puts "content size is #{content.size}"
         arg_hash[:broadcast]=Base64.encode64(content.to_yaml)
         arg_hash[:action]= 'action_broadcast_mms'
        
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
     def send_to_mms_manager(arg_hash,msisdn)
                content=build_content
             mms=MmscManager::MmsMessage.new('999',
                      msisdn,"Flickr photos #{self.tag}" ,content)
               arg_hash[:soap_header]=mms.soap_header_part
                arg_hash[:message]=mms.get_mms_message
                puts "Message #{arg_hash[:message]}"  if arg_hash[:debug]==true
                mmsmgr=MmscManager::MmsSendTopic.new(arg_hash)
                result=mmsmgr.send_mms_jms_ack(arg_hash)
                 puts "result is #{result}"
         #  puts "result is #{result}"
           result
      end
  end
end
