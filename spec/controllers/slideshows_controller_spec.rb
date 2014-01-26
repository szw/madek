require "spec_helper"

describe SlideshowsController do
  before :each do
    @owner   = FactoryGirl.create :user
    @top_set = FactoryGirl.create :media_set, user: @owner

    @top_set.child_media_resources << (@child_1 = FactoryGirl.create :media_set_with_title, user: @owner)
    @top_set.child_media_resources << (@child_2 = FactoryGirl.create :media_set_with_title, user: @owner)
    @top_set.child_media_resources << (@child_3 = FactoryGirl.create :media_entry_with_title, user: @owner)

    session[:user_id] = @owner.id
  end

  describe "GET 'show'" do
    context "with format JSON" do
      it "returns http success" do
        get :show, id: @top_set.id, format: :json
        expect(response).to be_success
      end

      it "returns JSON" do
        get :show, id: @top_set.id, format: :json
        json = JSON.parse(response.body)
        expect(json["media_set"]).to_not be_nil
        expect(json["contents"].count).to eq 3
      end
    end

    context "with HTML" do
      it "returns http success" do
        get :show, id: @top_set.id
        expect(response).to be_success
      end

      it "renders show template" do
        get :show, id: @top_set.id
        expect(response).to render_template :show
      end
    end
  end
end
