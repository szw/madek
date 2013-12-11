require 'spec_helper'
require 'pry'

describe MediaSetsController do
  render_views

  before :each do
    FactoryGirl.create :usage_term
    FactoryGirl.create :meta_context_core
  end

  context "API Tests" do

    before :each do
      @user = FactoryGirl.create :user
    end


    context "a user without session" do

      before :each do
        @media_set = FactoryGirl.create :media_set, view: true, user: @user
        AppSettings.create id: 0, splashscreen_slideshow_set_id: @media_set.id
      end


      context  "accesses splashscreen"  do

        let(:get_params) do
          {id: @media_set.id, format: :json, with: {children: true, meta_data:{meta_context_names: ["core"]}, image: {size: "large"}}}
        end

        it  "should not redirect" do
          get :show, get_params
          response.body.should_not match /redirected/
        end

        it  "should set the json response data correctly" do
          get :show, get_params
          json = JSON.parse(response.body)
          json["id"].should == @media_set.id
          json["type"].should == "media_set"
          json["children"].should be
        end
      end
    end



    context "a user with a session and user_id in that session" do 

      before :each do
        (1..5).each do
          @parent_media_set.child_media_resources << (FactoryGirl.create :media_entry, view: true, user: @user)
          media_set = FactoryGirl.create  :media_set, view: true, user: @user
          media_set.child_media_resources << (FactoryGirl.create  :media_entry, view: true, user: @user)
          parent_media_set.child_media_resources << media_set
        end

        context "when i get a set with nested resources, the json response"  do

          let :json_body do
            get_params= {id: @parent_media_set.id, format: :json, with: {media_set: {media_resources: {type: 1, image: {as: "base64", size: "small"}}}}} 
            get :show, get_params, {user_id: @user.id}
            JSON.parse(response.body)
          end

          it "should contain the correct id" do
            json_body["id"].should == @parent_media_set.id
          end

          it  "should have the right sum of contained resources"  do
            summed_sizes = @parent_media_set.child_media_resources.media_entries.size + @parent_media_set.child_media_resources.media_sets.size
            @parent_media_set.child_media_resources.size.should == summed_sizes
            json_body["media_resources"].size.should == summed_sizes
          end

          it  "should contain the internal properties of the resource" do 
            json_body["media_resources"].each do |entry|
              entry["id"].blank?.should_not == true
              entry["image"].blank?.should_not == true
              entry["type"].blank?.should_not == true
            end
          end
        end

      end

    end

  end

end

