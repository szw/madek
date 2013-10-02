# encoding: utf-8

class VisualizationController < ApplicationController
  layout 'visualization'
  respond_to 'html','json'

  before_filter :set_layout_and_control_variables, except: :put

  def my_component_with
    @resources = MediaResource.connected_resources(
      MediaResource.find(params[:id]),
      MediaResource.where("user_id = ?",current_user.id))
    @arcs = MediaResourceArc.connecting @resources
    min_id = @resources.map(&:id).min
    @resource_identifier = "my-component-#{min_id}"
    set_layout_and_control_variables
    @main_title = @origin_resource.title
    @sub_title = "Zusammenhänge mit Inhalten, für die ich verantwortlich bin"
    @title = "#{@main_title} - #{@sub_title}"
    render 'index'
  end

  def component_with
    @resources = MediaResource.connected_resources(
      MediaResource.find(params[:id]),
      MediaResource.accessible_by_user(current_user,:view))
    @arcs = MediaResourceArc.connecting @resources
    min_id = @resources.map(&:id).min
    @resource_identifier = "component-#{min_id}"
    set_layout_and_control_variables

    @main_title = @origin_resource.title
    @sub_title = "Zusammenhänge mit allen verbundenen Inhalten"
    @title = "#{@main_title} - #{@sub_title}"

    render 'index'
  end

  def my_sets
    @resource_identifier = "my-sets"
    set_layout_and_control_variables
    @resources = MediaSet.where(user_id: current_user.id)
    @arcs = MediaResourceArc.connecting @resources

    @main_title = "Zusammenhänge zwischen Sets, für die ich verantwortlich bin"
    @sub_title = nil
    @title = "#{@main_title}"

    render 'index'
  end

  def my_descendants_of
    set = MediaSet.find(params[:id])
    @resource_identifier = "descendants-#{set.id}"
    set_layout_and_control_variables
    @resources = MediaResource.descendants_and_set(set,
                     MediaResource.where("user_id = ?",current_user.id))
    @arcs = MediaResourceArc.connecting @resources

    @main_title = @origin_resource.title
    @sub_title = "Zusammenhänge mit untergeordneten Inhalten, für die ich verantwortlich bin"
    @title = "#{@main_title} - #{@sub_title}"

    render 'index'
  end

  def descendants_of
    set = MediaSet.find(params[:id])
    @resource_identifier = "descendants-#{set.id}"
    set_layout_and_control_variables
    @resources = MediaResource.descendants_and_set(set,
                  MediaResource.accessible_by_user(current_user,:view))
    @arcs = MediaResourceArc.connecting @resources

    @main_title = @origin_resource.title
    @sub_title = "Zusammenhänge mit allen untergeordneten Inhalten"
    @title = "#{@main_title} - #{@sub_title}"

    render 'index'
  end

  def my_media_resources
    @resource_identifier = "my-resouces"
    set_layout_and_control_variables
    @resources = MediaResource.filter current_user, MediaResource.get_filter_params(params)
    @resources = @resources.where(user_id: current_user.id)
    @arcs =  MediaResourceArc.connecting @resources

    @main_title = "Zusammenhänge zwischen Inhalten, für die ich verantwortlich bin"
    @sub_title = ""
    @title = "#{@main_title} "

    render 'index'
  end

  def my_favorites
    @resource_identifier = "my-favorites"
    set_layout_and_control_variables
    @resources = MediaResource.filter(current_user, {:favorites => "true"}) \
      .filter(current_user, MediaResource.get_filter_params(params))
    @arcs = MediaResourceArc.connecting @resources

    @main_title = "Zusammenhänge zwischen meinen Favoriten"
    @sub_title = ""
    @title = "#{@main_title} "

    render 'index'
  end

  def filtered_resources
    @filter = MediaResource.get_filter_params params
    @title = view_context.media_resources_index_title.join(" ")
    # we store the filter in a digested form to keep it short, there is sofar no usecase to reconstruct the filter itself
    @resource_identifier = 
      UUIDTools::UUID.md5_create(UUIDTools::UUID.parse("00000000-0000-0000-0000-000000000000"), 
                                 ZHDK::Sort.nested_sort(@filter).to_s).to_s
    @resources = MediaResource.filter(current_user, @filter)
    set_layout_and_control_variables
    @arcs = MediaResourceArc.connecting @resources
    render 'index'
  end

  def put
    visualization =  \
      Visualization.find_or_falsy(current_user.id,params[:resource_identifier])  \
      || Visualization.create({
        user_id: current_user.id, 
        resource_identifier: params[:resource_identifier]})

    visualization.update_attribute :control_settings, params[:control_settings]
    visualization.update_attribute :layout, params[:layout]

    if visualization.errors.size == 0
      render json: {}, status: 200
    else
      render json: visualization.errors, status: 422
    end

  end

  def set_layout_and_control_variables
    if params[:id]
      @origin_resource = MediaResource.find(params[:id])
    end
    if visualization = Visualization.find_or_falsy(current_user.id, @resource_identifier)
      @control_settings = visualization.control_settings
      @layout = visualization.layout
    else
      @control_settings = {}
      @layout = {}
    end
  end


end
