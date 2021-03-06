class MediaSet extends App.MediaResource

  constructor: (data)->
    super data
    for k,v of data
      @[k] = v
    @

  validate: ->
    @errors = []
    @errors.push {text: "Titel ist ein Pflichtfeld"} if not @title? or @title.length <= 0
    if @errors.length then false else true

  create: (callback)->
    $.ajax
      url: "/media_sets.json"
      type: "POST"
      data:
        media_set:
          meta_data_attributes:[{meta_key_label: "title",value: @getMetaDatumByMetaKeyName("title").value}]
      success: (data)=>
        for k,v of data
          @[k] = v
        $(@).trigger "created"
        callback(data) if callback?

  setChildren: (children)-> @children = children

  mediaEntries: -> _.select @children, (mr)-> mr.type == "media-entry"

  setCover: (mr)-> 
    (_.find @arcs, (arc)-> arc.cover == true).cover = false
    (_.find @arcs, (arc)-> arc.child_id == mr.id).cover = true

  setHighlight: (mr)-> (_.find @arcs, (arc)-> arc.child_id == mr.id).highlight = true

  unsetHighlight: (mr)-> (_.find @arcs, (arc)-> arc.child_id == mr.id).highlight = false

  fetchArcs: (callback)->
    $.ajax
      url: "/media_resource_arcs.json"
      data:
        parent_id: @id
      success: (data)=> 
        @arcs = data.media_resource_arcs
        callback(data) if callback?

  fetchAbstract: (min, callback)->
    $.ajax
      url: "/media_sets/#{@id}/abstract.json"
      data:
        min: min
      success: (data)=> 
        @abstract = data
        callback(data) if callback?    

  isHighlight: (mr)-> _.find(@arcs, (arc)-> arc.child_id == mr.id).highlight

  isCover: (mr)-> _.find(@arcs, (arc)-> arc.child_id == mr.id).cover

  persistArcs: (callback)->
    $.ajax
      url: "/media_resource_arcs.json"
      type: "PUT"
      data:
        media_resource_arcs: @arcs
      success: (data)=> callback(data) if callback?    

  @fromForm: (form)->
    metaData = _.map form.serializeArray(), (obj)=>
      name: obj.name
      value: obj.value
    new MediaSet {meta_data: metaData}

window.App.MediaSet = MediaSet
