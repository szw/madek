require 'spec_helper'

describe MetaDatum do

  before :each do
    @mk = MetaKey.find_by_id("title") || FactoryGirl.create(:meta_key_title) 
    @mr = FactoryGirl.create :media_set
  end

  it "should raise an error when created without type and meta_key" do
    expect {MetaDatum.create }.to raise_error
  end

  it "should raise an error when instantiated without type and meta_key" do
    expect {MetaDatum.create }.to raise_error
  end

end
