require File.dirname(__FILE__) + '/test_helper.rb'

class TestSimpleSmsServices < Test::Unit::TestCase

  def setup
  end
  
  def test_flickr
       feed=SimpleSmsServices::FlickrImages.new("sexy girl",'flickr photos')
       data = feed.process
       puts "found #{data} pictures using sexy girl"
       assert data > 0, "no pictures found"
       feed.send_to_mms_manager({}, '639993130030')
      # feed.send_to_mms_manager({}, '639993130313')
     #  assert data.include?("title_by_scott"), "title wrong"
   end
   def test_flickr_bad_tag
         feed=SimpleSmsServices::FlickrImages.new("abc de234 zw34",'flickr bad tag')
         data = feed.process
         puts "found #{data} pictures using abc de234 zw34 "
         assert data == 0, " pictures found with bad tag"
         feed.send_to_mms_manager({}, '639993130030')
        # feed.send_to_mms_manager({}, '639993130313')
       #  assert data.include?("title_by_scott"), "title wrong"
     end
   def test_flickr_subscription
        feed=SimpleSmsServices::FlickrImages.new("bikini",'title_by_scott')
        data = feed.process
        puts "found #{data} pictures"
        assert data > 0, "no pictures found"
          arg_hash={}
         arg_hash[:keyword] = 'flickr_bikini'
        feed.send_mms_to_subscription(arg_hash)
      #  assert data.include?("title_by_scott"), "title wrong"
    end
     def test_flickr_process
          arg_hash={}
          subscriptions=SimpleSmsServices::ProcessSubscriptions.new("flickr",arg_hash)
          data=subscriptions.subscriptions
          puts "found #{data.size} subscriptions"
          assert data.size > 0, "no subs found"
    
        #  assert data.include?("title_by_scott"), "title wrong"
      end
       def test_email_test
            arg_hash={}
            email=SimpleSmsServices::EmailToMMS.new('pop.gmail.com','995',
                       'test@ficonab.com','321test123','639993130030',arg_hash)
            
            

          #  assert data.include?("title_by_scott"), "title wrong"
        end
  
  def test_feed
      feed=SimpleSmsServices::Feed.new( "http://www.iht.com/rss/frontpage.xml",'title_by_scott')
      data = feed.get_data
      assert data.include?("http"), "no http in message"
      assert data.include?("title_by_scott"), "title wrong"
  end
  def test_feed_mms
       feed=SimpleSmsServices::Feed.new( "http://www.iht.com/rss/frontpage.xml",'title_by_scott')
       data = feed.get_data_mms
       puts "data is #{data}"
       assert data.include?("http"), "no http in message"
       assert data.include?("title_by_scott"), "title wrong"
   end
  def test_data_manip
       feed=SimpleSmsServices::Feed.new( "http://www.iht.com/rss/frontpage.xml",'title_by_scott')
       data = feed.get_data
       d=feed.filter_data(d)
       assert data!=d, "data after filter is same possble but unlikely"
        d=feed.filter_data("this is '  bad [mov]")
        assert !d.include?('quot'), "data after filter is wrong"
       d=feed.filter_data("this is bad [mov]")
       assert !d.include?('['), "data after filter is wrong"
       d=feed.filter_data('this is bad " ')
       assert !d.include?('['), "data after filter is wrong" 
       assert !d.include?('quot'), "data after filter is wrong" 
       assert !d.include?('amp'), "data after filter is wrong"    
         d=feed.filter_data('bad_underscore " ')
          assert !d.include?('_'), "data after filter is wrong"      
      # assert data.include?("title_by_scott"), "title wrong"
   end
end
