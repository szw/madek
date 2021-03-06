require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe Admin::MetaContextGroupsController, :type => :controller do

  before :each do
    FactoryGirl.create :usage_term 
    @adam = FactoryGirl.create :user, login: "adam"
    Group.find_or_create_by_name("Admin").users << @adam
  end

  # This should return the minimal set of attributes required to create a valid
  # MetaContextGroup. As you add validations to MetaContextGroup, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {name: "MetaContextGroup-Name"}
  end
  
  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # MetaContextGroupsController. Be sure to keep this updated too.
  def valid_session
    {user_id: @adam.id}
  end

  describe "GET index" do
    it "assigns all meta_context_groups as @meta_context_groups" do
      get :index, {}, valid_session
      assigns(:meta_context_groups).should eq(MetaContextGroup.all)
    end
  end

  describe "GET new" do
    it "assigns a new meta_context_group as @meta_context_group" do
      get :new, {}, valid_session
      assigns(:meta_context_group).should be_a_new(MetaContextGroup)
    end
  end

  describe "GET edit" do
    it "assigns the requested meta_context_group as @meta_context_group" do
      meta_context_group = MetaContextGroup.create! valid_attributes
      get :edit, {:format => :js, :id => meta_context_group.to_param}, valid_session
      assigns(:meta_context_group).should eq(meta_context_group)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new MetaContextGroup" do
        expect {
          post :create, {:meta_context_group => valid_attributes}, valid_session
        }.to change(MetaContextGroup, :count).by(1)
      end

      it "assigns a newly created meta_context_group as @meta_context_group" do
        post :create, {:meta_context_group => valid_attributes}, valid_session
        assigns(:meta_context_group).should be_a(MetaContextGroup)
        assigns(:meta_context_group).should be_persisted
      end

    end

  end

  describe "PUT update" do
    describe "with valid params" do

      it "assigns the requested meta_context_group as @meta_context_group" do
        meta_context_group = MetaContextGroup.create! valid_attributes
        put :update, {:format => :js, :id => meta_context_group.to_param, :meta_context_group => valid_attributes}, valid_session
        assigns(:meta_context_group).should eq(meta_context_group)
      end

    end

    describe "with invalid params" do
      it "assigns the meta_context_group as @meta_context_group" do
        meta_context_group = MetaContextGroup.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        MetaContextGroup.any_instance.stub(:save).and_return(false)
        put :update, {:format => :js, :id => meta_context_group.to_param, :meta_context_group => {}}, valid_session
        assigns(:meta_context_group).should eq(meta_context_group)
      end

    end
  end

  describe "DELETE destroy" do
    it "destroys the requested meta_context_group" do
      meta_context_group = MetaContextGroup.create! valid_attributes
      expect {
        delete :destroy, {id: meta_context_group.to_param}, valid_session
      }.to change(MetaContextGroup, :count).by(-1)
    end

    it "redirects to the meta_context_groups list" do
      meta_context_group = MetaContextGroup.create! valid_attributes
      delete :destroy, {id: meta_context_group.to_param}, valid_session
      response.should redirect_to(admin_meta_context_groups_url)
    end
  end

end
