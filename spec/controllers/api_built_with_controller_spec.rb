require 'rails_helper'
require 'fakeweb'
require 'json'

RSpec.describe ApiBuiltWithController, type: :controller do

  describe "POST #get_info" do
    json = nil
    before(:each) do
      FakeWeb.register_uri(:any, "http://www.google.com", :body => "<html><head><title>A</title><head><body><p>camera</p></body></html>")
      json  = { :format => 'json', :site => "http://www.google.com", :lookup => "camera" }
    end

    it "Shows there is no robot" do
      FakeWeb.register_uri(:any, "http://www.google.com/robots.txt", :body => "Not Found",
                           :status => ["404", "Not Found"])
      post :get_info, json
      json_resp = JSON.parse(response.body)
      assert(json_resp['robots_file_exists'] == false)
    end

    it "Shows there is lookup term in html response" do
      post :get_info, json
      json_resp = JSON.parse(response.body)
      assert(json_resp['lookup_term'] == "camera")
      assert(json_resp['has_lookup'] == true)
    end

    it "Shows there is no lookup term in html response" do
      json_new_term  = { :format => 'json', :site => "http://www.google.com", :lookup => "exist" }
      post :get_info, json_new_term
      json_resp = JSON.parse(response.body)
      assert(json_resp['lookup_term'] == "exist")
      assert(json_resp['has_lookup'] == false)
    end

    it "has a robots.txt and deny" do
      FakeWeb.register_uri(:any, "http://www.google.com/robots.txt", :body => "User-agent: *\nDisallow: /")
      post :get_info, json
      json_resp = JSON.parse(response.body)
      assert(json_resp['robots_file_exists'] == true)
      assert(json_resp['is_fetch_allowed'] == false)
    end

    it "has a robots.txt and allow" do
      FakeWeb.register_uri(:any, "http://www.google.com/robots.txt", :body => "User-agent: *\nDisallow: /non_exist.html")
      post :get_info, json
      json_resp = JSON.parse(response.body)
      assert(json_resp['robots_file_exists'] == true)
      assert(json_resp['is_fetch_allowed'] == true)
    end
  end
end
