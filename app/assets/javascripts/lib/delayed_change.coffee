###

jQuery Plugin for having a delayedChange event triggered even when the field was not blured 

after the default waiting time of 500 ms or the one that is provided with options.delay

###

$ = jQuery

$.extend $.fn, delayedChange: (options)-> @each -> $(this).data('_delayed_change', new DelayedChange(this, options)) unless $(this).data("_delayed_change")?

class DelayedChange
  
  constructor:(element, options)->
    @delay = if options? and options.delay? then options.delay else 500 
    @target = $(element)
    @last_value = @target.val()
    do @delegate_events 
    this
    
  delegate_events: ->
    @target.on "keydown mousedown change", (e)=> 
      @target.attr("data-delay-timeout-pending",true)
      target = $(e.target)
      @last_value = target.val()
    @target.on "keyup", @validate
    
  validate: (e)=>
    target = $(e.target)
    clearTimeout @timeout if @timeout?
    @timeout = setTimeout =>
      if target.val() != @last_value
        target.trigger("delayedChange") 
        setTimeout => 
          @target.removeAttr("data-delay-timeout-pending") 
        , 200
      else
        @target.removeAttr("data-delay-timeout-pending") 
      @last_value = target.val()  
    , @delay
