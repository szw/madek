# -*- encoding : utf-8 -*-
class SlideshowsController < ApplicationController
  layout "slideshow"

  def show
    sort = params[:sort] || "created_at"

    begin
      @media_set = MediaSet.accessible_by_user(current_user, :view).find(params[:id])
      @slideshow = Slideshow.new(@media_set, sort, current_user)
    rescue
      not_authorized!
    end

    respond_to do |format|
      format.html { render :show }
      format.json { render json: { media_set: @media_set, contents: @slideshow.contents } }
    end
  end
end
