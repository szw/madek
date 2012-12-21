###

MediaResources#Edit

Controller for MediaResources Edit

###

MediaResourcesController = {} unless MediaResourcesController?
class MediaResourcesController.Edit

  el: "#edit-media-resource"

  constructor: ->
    @el = $(@el)
    new App.FormWidgets.Person {el: @el}
    new App.FormAutocompletes.Person {el: @el}
    new App.FormWidgets.Keywords {el: @el}
    new App.FormAutocompletes.Keywords {el: @el}
    new App.FormBehaviours.MetaDatumDate {el: @el}
    new App.FormAutocompletes.ExtensibleList {el: @el}
    new App.FormBehaviours.Collapse {el: @el}
    new App.FormBehaviours.Copyrights {el: @el}
    new App.FormAutocompletes.Departments {el: @el}
    do @delegateEvents

  delegateEvents: ->
    @el.on "click", ".form-widget-toggle", (e)=> @openFormWidget $(e.currentTarget)
    @el.on "click", ".form-widget .button", (e) => e.preventDefault(); return false
    @el.on "click", ".multi-select-tag-remove", (e) => $(e.currentTarget).closest(".multi-select-tag").remove()
    #@el.on "submit", (e)=> debugger

  openFormWidget: (toggle)->
    widget = toggle.next ".form-widget"

    if toggle.is ".active"
      toggle.removeClass "active"
      do widget.hide
    else
      toggle.addClass "active"
      do widget.show

    $(@el).trigger "widget-toggled"

window.App.MediaResourcesController = {} unless window.App.MediaResourcesController
window.App.MediaResourcesController.Edit = MediaResourcesController.Edit