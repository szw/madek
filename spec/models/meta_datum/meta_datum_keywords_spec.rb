require 'spec_helper'

describe MetaDatumKeywords do

  describe "Creation" do

    it "should not raise an error" do
      expect {FactoryGirl.create :meta_datum_keywords}.not_to raise_error
    end

    it "should not be nil" do
      (FactoryGirl.create :meta_datum_keywords).should_not == nil
    end

    it "should be persisted" do
      (FactoryGirl.create :meta_datum_keywords).should be_persisted
    end

  end
  
  describe "Editing media_entry's meta_data" do
    before :each do
      @meta_key = FactoryGirl.create :meta_key, id: "keywords", :meta_datum_object_type => "MetaDatumKeywords"
      @user1 = FactoryGirl.create :user
      @user2 = FactoryGirl.create :user
    end
  
    before :each do
      @media_entry = FactoryGirl.create :media_entry
      @media_entry.meta_data.count.should == 0
      @term1 = FactoryGirl.create :meta_term
      @term2 = FactoryGirl.create :meta_term
    end
    
    it "should assign new keywords" do
      params = {meta_data_attributes: {"0" =>  {meta_key_id: @meta_key.id, value: [@term1.to_s, @term2.to_s]}}}
      @media_entry.set_meta_data(params)
      @media_entry.reload
      @media_entry.meta_data.count.should == 1
      @media_entry.meta_data.flat_map(&:value).map(&:meta_term).map(&:id).sort.should == [@term1.id, @term2.id].sort
    end
  
    it "should keep existing keywords assigning new keywords" do
      # the first user creates a keyword providing a term string
      params = {meta_data_attributes: {"0" =>  {meta_key_id: @meta_key.id, value: @term1.to_s}}}
      @media_entry.set_meta_data(params)
      @media_entry.reload
      @media_entry.meta_data.count.should == 1
      keywords = @media_entry.meta_data.flat_map(&:value) 
      keywords.map(&:meta_term).should == [@term1]

      # the second user creates a keyword providing a term string and the already existing term id
      params = {meta_data_attributes: {"0" =>  {meta_key_id: @meta_key.id, value: [@term1.id, @term2.to_s]}}}
      @media_entry.set_meta_data(params)
      @media_entry.reload
      @media_entry.meta_data.count.should == 1
      keywords = @media_entry.meta_data.flat_map(&:value) 
      keywords.map(&:meta_term).map(&:id).sort.should == [@term1, @term2].map(&:id).sort

      # the second user deletes the keyword provided by the first user
      params = {meta_data_attributes: {"0" =>  {meta_key_id: @meta_key.id, value: [@term2.id]}}}
      @media_entry.set_meta_data(params)
      @media_entry.reload
      @media_entry.meta_data.count.should == 1
      keywords = @media_entry.meta_data.flat_map(&:value) 
      keywords.map(&:meta_term).should == [@term2]
    end
  
  end

end

