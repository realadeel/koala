require 'test/unit'
require 'rubygems'
require 'spec/test/unit'

# load the libraries
require 'koala'

# load the tests
require 'koala/facebook_no_access_token_tests'
require 'koala/facebook_with_access_token_tests'
require 'koala/facebook_oauth_tests'

class FacebookTestSuite
  def self.suite
    suite = Test::Unit::TestSuite.new
    suite << FacebookNoAccessTokenTests.suite
    suite << FacebookWithAccessTokenTests.suite
    suite << FacebookOAuthTests.suite
    suite
  end
end

# load testing data (see note in readme.md)
# I'm seeing a bug with spec and gets where the facebook_test_suite.rb file gets read in when gets is called
# until that's solved, we'll need to store/update tokens in the access_token file
$testing_data = YAML.load_file("facebook_data.yml") rescue {}

unless $testing_data["oauth_token"]
  puts "Access token tests will fail until you store a valid token in facebook_data.yml"
end

# TODO finish tests for OAuth class
# unless $testing_data["cookie_hash"] && $testing_data["app_id"] && $testing_data["secret"]
#   puts "Cookie tests will fail until you store valid data for the cookie hash, app_id, and app secret in facebook_data.yml"
# end