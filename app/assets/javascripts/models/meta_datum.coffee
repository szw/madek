class MetaDatum

  constructor: (data)->
    for k,v of data
      @[k] = v
    @

  formattedValue: -> MetaDatum.formattedValue @

  setValue: (value, additionalData)->
    switch @type
      when "people"
        @value = _.map(additionalData, (person)->person.toString()).join("; ")
        @raw_value = additionalData
      when "keywords"
        @value = _.map(additionalData, (keyword)->keyword.label).join("; ")
        @raw_value = additionalData
      when "copyright"
        @value = value
        @raw_value = additionalData
      when "meta_terms"
        @value = value
        @raw_value = additionalData
      else
        @value = value
        @raw_value = value

  @formattedValue: (metaDatum)->
    return metaDatum.value unless metaDatum.value?
    switch metaDatum.type
      when "date"
        App.MetaDatumDate.formattedValue metaDatum
      else  
        metaDatum.value

  @anyValue: (metaData)-> !! _.find metaData, (metaDatum)-> metaDatum.value?

  @getValueFromField: (field)->
    field = $(field)
    switch field.data "type"
      when "meta_datum_people"
        _.map field.find(".multi-select-tag"), (entry)-> 
          if $(entry).data("id")?
            $(entry).data("id")
          else if $(entry).data("string")?
            $(entry).data("string")
      when "meta_datum_date"
        field.find("input.value-target").val()
      when "meta_datum_keywords"
        _.map field.find(".multi-select-tag"), (entry)-> $(entry).find("input").val()
      when "meta_datum_copyright"
        field.find("input.value-target").val()
      when "meta_datum_meta_terms"
        if field.find(".multi-select").length
          _.map field.find(".multi-select-tag"), (entry)-> $(entry).find("input").val()
        else
          _.map field.find("input:checked"), (input)-> $(input).val()
      when "meta_datum_country"
        field.find("option:selected").val()
      else
        field.find("input:visible").val()

  @getAdditionalDataFromField: (field)->
    field = $(field)
    switch field.data "type"
      when "meta_datum_people"
        _.map field.find(".multi-select-tag"), (entry)-> new App.Person $(entry).data()
      when "meta_datum_keywords"
        _.map field.find(".multi-select-tag"), (entry)-> $(entry).data()
      when "meta_datum_copyright"
        id: field.find("input.value-target").val()
        parent_id: field.find("select.copyright-roots option:selected").data('id')
      when "meta_datum_meta_terms"
        if field.find(".multi-select").length
          _.map field.find(".multi-select-tag"), (entry)-> $(entry).data()
        else
          _.map field.find("input:checked"), (input)-> {id: $(input).val()}

  @applyToAll: (options)->
    $.ajax
      url: "/meta_data/apply_to_all.json"
      data: 
        collection_id: options.collectionId
        id: options.metaKeyName
        overwrite: options.overwrite
        value: options.value
      type: "PUT"
      success: -> options.callback() if options.callback?

window.App.MetaDatum = MetaDatum
