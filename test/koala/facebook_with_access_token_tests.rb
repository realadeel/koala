class FacebookWithAccessTokenTests < Test::Unit::TestCase
  describe "Koala GraphAPI with an access token" do
    before :each do
      token = $testing_data["oauth_token"]
      raise Exception, "Must supply access token to run FacebookWithAccessTokenTests!" unless token
      @graph = Koala::Facebook::GraphAPI.new(token)
    end
    
    after :each do 
      # clean up any temporary objects
      if @temporary_object_id
        puts "\nCleaning up temporary object #{@temporary_object_id.to_s}"
        result = @graph.delete_object(@temporary_object_id)
        raise "Unable to clean up temporary Graph object #{@temporary_object_id}!" unless result
      end
    end

    it "should get public data about a user" do
      result = @graph.get_object("koppel")
      # the results should have an ID and a name, among other things
      (result["id"] && result["name"]).should_not be_nil
    end

    it "should get private data about a user" do
      result = @graph.get_object("koppel")
      # updated_time should be a pretty fixed test case
      result["updated_time"].should_not be_nil
    end

    it "should get public data about a Page" do
      result = @graph.get_object("contextoptional")
      # the results should have an ID and a name, among other things
      (result["id"] && result["name"]).should
    end
  
    it "should get data about 'me'" do
      result = @graph.get_object("me")
      result["updated_time"].should
    end
  
    it "should be able to get multiple objects" do
      result = @graph.get_objects(["contextoptional", "naitik"])
      result.length.should == 2
    end
  
    it "should be able to access connections from users" do
      result = @graph.get_connections("lukeshepard", "likes")
      result["data"].length.should > 0
    end

    it "should be able to access connections from public Pages" do
      result = @graph.get_connections("contextoptional", "likes")
      result["data"].should be_a(Array)
    end
    
    # PUT
    it "should be able to write an object to the graph" do
      result = @graph.put_wall_post("Hello, world, from the test suite!")
      @temporary_object_id = result["id"]
      @temporary_object_id.should_not be_nil
    end

    # DELETE
    it "should be able to delete posts" do 
      result = @graph.put_wall_post("Hello, world, from the test suite delete method!")
      object_id_to_delete = result["id"]
      delete_result = @graph.delete_object(object_id_to_delete)
      delete_result.should == true
    end

    # additional put tests
    it "should be able to verify messages posted to a wall" do
      message = "the cats are asleep"
      put_result = @graph.put_wall_post(message)
      @temporary_object_id = put_result["id"]
      get_result = @graph.get_object(@temporary_object_id)
      
      # make sure the message we sent is the message that got posted
      get_result["message"].should == message
    end

    it "should be able to post a message with an attachment to a feed" do
      result = @graph.put_wall_post("Hello, world, from the test suite again!", {:name => "Context Optional", :link => "http://www.contextoptional.com/"})
      @temporary_object_id = result["id"]
      @temporary_object_id.should_not be_nil
    end
    
    it "should be able to verify a message with an attachment posted to a feed" do
      attachment = {"name" => "Context Optional", "link" => "http://www.contextoptional.com/"}
      result = @graph.put_wall_post("Hello, world, from the test suite again!", attachment)
      @temporary_object_id = result["id"]
      get_result = @graph.get_object(@temporary_object_id)

      # make sure the result we fetch includes all the parameters we sent
      it_matches = attachment.inject(true) {|valid, param| valid && (get_result[param[0]] == attachment[param[0]])}
      it_matches.should == true 
    end

    it "should be able to comment on an object" do
      result = @graph.put_wall_post("Hello, world, from the test suite, testing comments!")
      @temporary_object_id = result["id"]
      
      # this will be deleted when the post gets deleted 
      comment_result = @graph.put_comment(@temporary_object_id, "it's my comment!")
      comment_result.should_not be_nil
    end
    
    it "should be able to verify a comment posted about an object" do
      message_text = "Hello, world, from the test suite, testing comments!"
      result = @graph.put_wall_post(message_text)
      @temporary_object_id = result["id"]
      
      # this will be deleted when the post gets deleted 
      comment_text = "it's my comment!"
      comment_result = @graph.put_comment(@temporary_object_id, comment_text)
      get_result = @graph.get_object(comment_result["id"])

      # make sure the text of the comment matches what we sent
      get_result["message"].should == comment_text
    end

    it "should be able to like an object" do
      result = @graph.put_wall_post("Hello, world, from the test suite, testing comments!")
      @temporary_object_id = result["id"]
      like_result = @graph.put_like(@temporary_object_id)
    end

    # SEARCH
    it "should be able to search" do
      result = @graph.search("facebook")
      result["data"].should be_an(Array)
    end

    # API
    # the above tests test this already, but we should consider additional api tests
    
  end # describe

end #class
