###

App.modal

This script provides functionalities for client side rendered modal dialogs,
it also keeps track to avoid multiple instances of the same dialog in the dom.

It also autofocus fields that have the autofocus attribute

###

class Modal

  constructor: (el)->
    @el = $(el)
    do @delegateEvents
    @el.modal @el

  delegateEvents: ->
    @el.on "hidden", @onHide
    @el.on "shown", @onShown
    $(window).on "resize", @setModalBodyMaxHeight
    
  setModalBodyMaxHeight: =>
    windowHeight = $(window).height()
    rim =  ( @el.position().top - $(document).scrollTop() )*2
    elHeight = @el.outerHeight()
    elBodyHeight = @el.find(".ui-modal-body").height()
    height =  windowHeight - rim - elHeight  + elBodyHeight 
    @el.find(".ui-modal-body").css "max-height", height

  onHide: =>
    @el.remove()
    $(window).off "resize", @setModalBodyMaxHeight

  onShown: =>
    @el.addClass "ui-shown"
    @el.find("[autofocus=autofocus]").focus()
    do @setModalBodyMaxHeight

window.App.Modal = Modal
