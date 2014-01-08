require 'spec_helper'

describe Felis do
  
  let(:account_id) { "YOUR_ACCOUNT_ID" }
  let(:private_key) { "YOUR_PRIVATE_KEY" }
  let(:public_key) { "YOUR_PUBLIC_KEY" }
  let(:felis_with_creds) { Felis::API.new(account_id: account_id, private_key: private_key, public_key: public_key) }
  
  describe "attributes" do
    
    let(:felis) { Felis::API.new }
    
    context "when no base_uri is set by default" do
      it "sets the base_uri in constructor" do
        felis.base_uri.should eq "https://api.e2ma.net"
      end
    end
    
    context "when no account_id is passed to constructor" do
      context "when ENV contains Emma Account Id" do
        it "sets the account_id in constructor" do
          ENV["EMMA_ACCOUNT_ID"] = account_id
          @felis = Felis::API.new
          @felis.account_id.should eq ENV["EMMA_ACCOUNT_ID"]
        end
      end
      
      context "when ENV does not contain Emma Account Id" do
        it "sets the account_id to nil" do
          ENV['EMMA_ACCOUNT_ID'] = nil
          felis.account_id.should be_nil
        end
      end
    end
    
    context "when account_id is passed to constructor" do
      it "account_id is not nil" do
        @felis = Felis::API.new(account_id: account_id)
        @felis.account_id.should_not be_nil
        @felis.account_id.should eq account_id
      end
    end
    
    context "when no private key is passed to constructor" do
      context "when ENV contains Emma Private Key" do
        it "sets the private_key in constructor" do
          ENV["EMMA_PRIVATE_KEY"] = private_key
          @felis = Felis::API.new
          felis.private_key.should eq ENV['EMMA_PRIVATE_KEY']
        end
      end
      
      context "when ENV does not contain Emma Private Key" do
        it "sets the private_key to nil" do
          ENV['EMMA_PRIVATE_KEY'] = nil
          felis.private_key.should be_nil
        end
      end
    end
    
    context "when private_key is passed to constructor" do
      it "private_key is not nil" do
        @felis = Felis::API.new(private_key: private_key)
        @felis.private_key.should_not be_nil
        @felis.private_key.should eq private_key
      end
    end
    
    context "when no public key is passed to constructor" do
      context "when ENV contains Emma Public Key" do
        it "sets the public_key in constructor" do
          ENV["EMMA_PUBLIC_KEY"] = public_key
          @felis = Felis::API.new
          felis.public_key.should eq ENV['EMMA_PUBLIC_KEY']
        end
      end
      
      context "when public_key is passed to constructor" do
        it "public_key is not nil" do
          @felis = Felis::API.new(public_key: public_key)
          @felis.public_key.should_not be_nil
          @felis.public_key.should eq public_key
        end
      end
      
      context "when ENV does not contain Emma Public Key" do
        it "sets the public_key to nil" do
          ENV['EMMA_PUBLIC_KEY'] = nil
          felis.public_key.should be_nil
        end
      end
    end
    
    context "when no debug option is passed to constructor" do
      it "sets debug mode to false" do
        felis.debug.should be_false
      end
    end
  end
  
  describe "build api url" do
    
    let(:base_uri) { "https://api.e2ma.net" }
    
    context "with new instance" do
      it "will setup the base_uri with the account_id" do
        felis_with_creds.class.base_uri.should eq "#{base_uri}/#{account_id}"
      end
      
      it "will setup the basic auth variables for HTTP requests" do
        defaults = felis_with_creds.instance_variable_get(:"@defaults")
        defaults[:basic_auth][:username].should_not be_nil
        defaults[:basic_auth][:username].should eq public_key
        
        defaults[:basic_auth][:password].should_not be_nil
        defaults[:basic_auth][:password].should eq private_key
      end
    end
  end
  
  describe "API calls" do
    
    context "HTTP valid GET request" do
      it "will parse the response" do
        VCR.use_cassette 'get_members' do
          request = call(:get, '/members')
          request.should eq []
        end
      end
    end
    
    context "HTTP POST request" do
      it "will parse the respone" do
        VCR.use_cassette 'add_member' do
          request = call(:post, '/members/add', { email: "test.me@test.com", fields: {first_name: "Tester", last_name: "McTesterson"} })
          request.should have_key("member_id")
        end
      end
    end
    
    context "HTTP PUT request" do
      it "will parse the response" do
        VCR.use_cassette 'retrieve_member_for_put_request' do
          member = call(:get, '/members/email/test.me@test.com')
          
          VCR.use_cassette 'update_member' do
            request = call(:put, "/members/#{member['member_id']}", { fields: { first_name: "Jack", last_name: "Jill" }})
            request.should be_true
          end
        end
      end
    end
    
    context "HTTP DELETE request" do
      it "will parse the response" do
        VCR.use_cassette 'retrieve_member_for_put_request' do
          member = call(:get, '/members/email/test.me@test.com') 
          
          VCR.use_cassette 'delete_member' do
            request = call(:delete, "/members/#{member['member_id']}")
            request.should be_true
          end
        end
      end
    end
    
    context "invalid HTTP requests" do
      it "will raise an error" do
        VCR.use_cassette 'invalid_get_request' do
          expect { call(:get, '/members/123') }.to raise_error(Felis::EmmaError)
        end
        
        VCR.use_cassette 'invalid_post_request' do
          expect { call(:post, '/members/add', { fields: { first_name: "Jane" } }) }.to raise_error(Felis::EmmaError)
        end
        
        VCR.use_cassette 'invalid_put_request' do
          expect { call(:put, '/members/delete') }.to raise_error(Felis::EmmaError)
        end
        
        VCR.use_cassette 'invalid_delete_request' do
          expect { call(:delete, '/members/123') }.to raise_error(Felis::EmmaError)
        end
      end
    end
    
  end
  
  private
    def call(method, path, params = {})
      felis_with_creds.send(method, path, params)
    end
  
end