require 'spec_helper'

describe FilterSet do

  before :each do
    @user = FactoryGirl.create :user
    @filter_set = FactoryGirl.create :filter_set_with_title, user: @user
  end
  
  it "should contain media entries" do
    @filter_set.should respond_to :filtered_resources
    @filter_set.filtered_resources(@user).should respond_to :media_entries
  end

  it "should be producible by a factory" do
    (FactoryGirl.create :filter_set).should_not == nil
  end

  context "an existing MediaSet" do

    before :each do 
      @filter_set = FactoryGirl.create :filter_set
    end

    context "settings" do
      it "stores the filter" do
        @filter_set.should respond_to(:settings)
        f = {"public" => "true", "search" => "zhdk"}
        @filter_set.settings[:filter] = f
        @filter_set.save.should be_true
        @filter_set.reload
        @filter_set.settings[:filter].should == f 
      end
      
      it "returns child_media_resources based on the current_user" do
        all_fake_words = []
        # MediaResources
        3.times do
          type = rand > 0.5 ? :media_entry : :media_set
          mr = FactoryGirl.create type, :user => @user
          all_fake_words += fake_words = Faker::Lorem.words(2)
          mr.set_meta_data({meta_data_attributes: {"0" => {meta_key_label: "title",value: fake_words.join(' ')}}})
          mr.save # force full_text reindex
        end
        all_fake_words.each do |w|
          fs = FactoryGirl.create(:filter_set, user: @user, settings: {filter: {search: w}})
          fs.filtered_resources(@user).count.should_not be_zero
          fs.filtered_resources(@user).count.should == MediaResource.filter(@user, {search: w}).count
        end
        
      end
    end

  end
  
end
