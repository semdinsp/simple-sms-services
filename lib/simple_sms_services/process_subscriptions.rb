require 'rubygems'
gem 'subscription_manager'
require 'subscription_manager'
require 'erb'
require 'yaml'

module SimpleSmsServices 
  # grab a subscription, get the parameters
  # process them
  class ProcessSubscriptions
    attr_accessor :service_id, :subscriptions
    def initialize(svc_id, arg_hash)
      self.service_id =svc_id
      get_subscriptions(arg_hash)
    end
    
    def get_subscriptions(arg_hash)
         arg_hash[:action]='action_get_subscriptions'
         arg_hash[:keyword]=self.service_id
           arg_hash[:topic]='subscription'
         puts "about to send  command  #{arg_hash[:action]} for #{arg_hash[:keyword]}"  if arg_hash[:debug]
         submgr=SubscriptionManager::SubscriptionSendTopic.new(arg_hash)
         result=submgr.send_subscription_response(arg_hash)
         puts "result is #{result.to_s}"
         self.subscriptions=YAML.load(result)
    end
  end
end
