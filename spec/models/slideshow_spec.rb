require "spec_helper"

describe Slideshow do
  before :each do
    @owner   = FactoryGirl.create :user
    @top_set = FactoryGirl.create :media_set, user: @owner

    @top_set.child_media_resources << (@child_1 = FactoryGirl.create :media_set_with_title, user: @owner)
    @top_set.child_media_resources << (@child_2 = FactoryGirl.create :media_set_with_title, user: @owner)
    @top_set.child_media_resources << (@child_3 = FactoryGirl.create :media_entry_with_title, user: @owner)
  end

  let(:slideshow) { Slideshow.new(@top_set, :created_at, @owner) }

  describe "#initialize" do
    it "sets fields properly" do
      expect(slideshow.media_set).to eq(@top_set)
      expect(slideshow.current_user).to eq(@owner)
      expect(slideshow.order).to eq(:created_at)
    end
  end

  describe "#contents" do
    it "returns contents hash" do
      expect(slideshow.contents.size).to eq(3)
      expect(slideshow.contents.map { |c| c[:content_type] }).to include("image/jpeg")
      expect(slideshow.contents.map { |c| c[:content_type] }).to include("media_set")
    end
  end

  describe "#order=" do
    it "changes the order accordingly" do
      expect(slideshow.contents.sort { |a, b| b[:created_at] <=> a[:created_at] }).to eq(slideshow.contents)
      slideshow.order = :title
      expect(slideshow.contents.sort { |a, b| a[:title] <=> b[:title] }).to eq(slideshow.contents)
    end
  end
end
