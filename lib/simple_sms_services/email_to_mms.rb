require 'rubygems'
gem 'mmsc_manager'
require 'mmsc_manager'
#gem 'tmail'    SCOTT NEEDS FIxinG
#require 'tmail'
require 'erb'
require 'yaml'
#require 'net/pop'
require 'openssl'
#require 'pop_ssl'

module SimpleSmsServices 
  # grab a subscription, get the parameters
  # process them
  class EmailToMMS
    attr_accessor :host, :port, :account, :password, :msisdn, :result,  :unsubscribe_command
    def initialize(host,port,account,pass,subscriber,arg_hash)
      self.host=host
      self.port=port
      self.account=account
      self.password=pass
      self.msisdn=subscriber
      self.unsubscribe_command="subscribe email off"
      begin
         grab_email(arg_hash) { |arg_hash, email | send_mms(arg_hash,email)
                               }
      rescue Exception => e
        puts "Exception in grab_email #{e.message}"
      end
    end
    def send_mms(arg_hash, email)   
        
               email2=TMail::Mail.parse(email)
              # puts "manipulating email2"
            
           #    puts "after from"
               content=[]
               content[0]=MmscManager::MmsMessage.build_text_content(email2.body.to_s)
              content <<  MmscManager::MmsMessage.build_text_content("To unsubscribe from this service '#{self.unsubscribe_command}'  to 999")
               mms=MmscManager::MmsMessage.new(email2.from,self.msisdn,email2.subject,content)
               mmsmgr=MmscManager::MmsSendTopic.new(arg_hash)
               result=mmsmgr.send_mms_response_from_mms(mms)
               puts "result is #{result}"
               self.result=result   
        end
    
    def grab_email(arg_hash)
        puts "#{Time.now} Running Mail Importer... for server: #{self.host} user: #{self.account}" 
        Net::POP3.enable_ssl(OpenSSL::SSL::VERIFY_NONE) if self.port=='995'  # for ssl
        Net::POP3.start(self.host, self.port, self.account,self.password) do |pop|
          if pop.mails.empty?
            puts "NO MAIL" 
            self.result='NO MAIL'
          else
            pop.mails.each do |email|

              begin
                puts "receiving email..." 
                 yield arg_hash, email.pop

              rescue Exception => e
                puts "Error receiving email at " + Time.now.to_s + "::: " + e.message
              ensure
                 # puts "deleteing email"
                #  email.delete
                pop.finish if pop!=nil
              end
            end # pop mails .eac
          end
        end   #do pop3
      end
end
end
