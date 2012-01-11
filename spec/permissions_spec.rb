require 'spec_helper'

describe "Permissions" do

  before :all do
    DataFactory.create_small_dataset
    @permissionset_view_false  = FactoryGirl.create :permissionset, view: false, download: false, edit: false, manage: false
    @permissionset_view_true  = FactoryGirl.create :permissionset, view: true, download: false, edit: false, manage: false
  end

  describe "A public viewable Mediaresource" do

    before(:each) do
      @owner = FactoryGirl.create :user
      @media_resource = FactoryGirl.create :media_resource, owner: @owner, permissionset: @permissionset_view_true
      @user = FactoryGirl.create :user
    end

    it "should be viewalbe by an unrelated user" do
      (Permissions.authorized? @user, :view , @media_resource).should == true
    end

    context "the user is not allowed by user permissions" do

      before(:each) do
        FactoryGirl.create :userpermission, user: @user, media_resource: @media_resource, permissionset: @permissionset_view_false
      end

      it "should be viewable by the user" do
        (Permissions.authorized? @user, :view, @media_resource).should == true
      end

    end
  end


  describe "A non public viewable Mediaresource" do 


    before(:each) do
      @owner = FactoryGirl.create :user
      @media_resource = FactoryGirl.create :media_resource, owner: @owner, permissionset: @permissionset_view_false
      @user = FactoryGirl.create :user
    end

    it "can be viewed by its owner"  do
      (Permissions.authorized? @owner, :view , @media_resource).should == true
    end

    it "can be viewed by its owner even if the owner is disallowed by a userpermission"  do
      FactoryGirl.create :userpermission, user: @owner, media_resource: @media_resource, permissionset: @permissionset_view_false
      (Permissions.authorized? @owner, :view , @media_resource).should == true
    end

    it "should not be viewable by an user without any permissions" do
      (Permissions.authorized? @user, :view , @media_resource).should == false
    end

    context "when a userpermission allows the user" do

      before(:each) do
        FactoryGirl.create :userpermission, user: @user, media_resource: @media_resource, permissionset: @permissionset_view_true
      end

      it "should be be viewable by the user" do
        (Permissions.authorized? @user, :view , @media_resource).should == true
      end

    end

    context "a mediaresourcegrouppermission allows the user to view" do

      before(:each) do
        @group = FactoryGirl.create :group
        @group.users << @user
        FactoryGirl.create :grouppermission, permissionset: @permissionset_view_true, group: @group, media_resource: @media_resource
      end

      it "should be be viewable for the user" do
        (Permissions.authorized? @user, :view , @media_resource).should == true
      end

      context "when a userpermission denies the user to view" do
        before(:each) do
          FactoryGirl.create :userpermission, user: @user, media_resource: @media_resource, permissionset: @permissionset_view_false
        end

        it "should not be viewable for the user" do
          (Permissions.authorized? @user, :view , @media_resource).should == false
        end
      end
    end
  end
end

