require 'spec_helper'

describe "requests of the typo madek player plugin" do

  # !!!!!!!!!!
  # in the case that you dont know the difference between :each and :all
  # read here: https://www.relishapp.com/rspec/rspec-core/v/2-2/docs/hooks/before-and-after-hooks
  #
  # TS: maybe you don't need to read that; we almost never use :all; there are
  # some nasty side effects with database cleaner and truncations ....
  before :each do 
    FactoryGirl.create :meta_context_core
    FactoryGirl.create :meta_key_public_caption
    FactoryGirl.create :meta_key_copyright_status
    FactoryGirl.create :meta_key_copyright_usage
    FactoryGirl.create :meta_key_copyright_url
    @user = FactoryGirl.create :user
    @media_set = FactoryGirl.create :media_set, :user => @user
    @media_set.update_attribute :view, true
    meta_data_h = {meta_data_attributes: {
      a: {meta_key_label: "title", value: "My Set"}, 
      b: {meta_key_label: "author", value: @user.name}}}
      @media_set.set_meta_data meta_data_h
    5.times do
      me = FactoryGirl.create :media_entry, user: @user, view: true
      me.set_meta_data({meta_data_attributes: {a: {meta_key_label: "title", :value => Faker::Lorem.words(1).join(' ') }}})
      @media_set.child_media_resources << me
    end
    MediaResource.reindex
  end

  describe "search a set" do

    it "should responds with matched sets" do
      with = {:media_type => true, :image => {:as => "base64", :size => "small"}, :meta_data => {:meta_key_ids => ["author"]}}
      get "/media_resources.json", {type: "media_sets", search: @media_set.title, with: with}
      json = JSON.parse(response.body)
      ms = json["media_resources"].find{|mr| mr["id"] == @media_set.id}
      expect(ms["type"]).to eq "media_set"
      expect(ms.has_key? "image").to eq true
      expect(ms.has_key? "meta_data").to eq true
      expect(ms["meta_data"].find{|md| md["name"] == "author"}["value"]).to eq @user.name
      expect(ms["media_type"]).to eq "set"
    end
  end

  describe "play a set" do

    it "should responds with child_media_resources of a set" do
      meta_key_ids = ["title", "subtitle", "author", "portrayed object dates", "public caption", "copyright notice",
                      "copyright status","copyright usage","copyright url"]
      with = {:children => {:public => true, :with => {:media_type => true, :meta_data => {:meta_key_ids => meta_key_ids}}}}
      get "/media_resources.json", {ids: [@media_set.id], with: with}
      json = JSON.parse(response.body)
      ms = json["media_resources"][0]
      expect(ms["id"]).to eq @media_set.id
      children = ms["children"]["media_resources"]
      expect(children.size).to be > 0
      children.each do |child|
        expect(@media_set.child_media_resources.map(&:id).include? child["id"]).to be_true
        expect(child.has_key? "type").to eq true
        expect(child.has_key? "meta_data").to eq true
        meta_key_ids.each do |mkid|
          expect(child["meta_data"].find{|md| md["name"] == mkid}.nil?).to be_false
        end
      end
    end
  end
end

