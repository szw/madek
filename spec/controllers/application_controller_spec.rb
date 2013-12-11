require 'spec_helper'

describe ApplicationController do

  before :each do
    AppSettings.create id: 0
  end

  describe "as guest user" do
    it "should respond with success" do
      get :root, {}, {}
      response.should be_success
    end
  end

  describe "as logged in user" do
    before :each do
      FactoryGirl.create :usage_term
      @user = FactoryGirl.create :user
    end
    it "should redirect to my dashboard" do
      get :root, {}, {user_id: @user.id}
      response.should redirect_to(my_dashboard_path)
    end
  end
  
end
