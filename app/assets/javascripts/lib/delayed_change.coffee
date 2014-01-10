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
    @last_values = []
    @timeouts = []
    do @delegate_events 
    this
    
  delegate_events: ->
    @target.on "keydown keyup mousedown change", (e)=> 
      target = $(e.target)
      target_id = target.attr('id')
      if target_id and @last_values[target_id] != target.val()
        @last_values[target_id] = target.val()
        clearTimeout @timeouts[target_id] if @timeouts[target_id]
        target.attr("data-delay-timeout-pending",true)
        console.log ["setting delay attr", target_id]
        @timeouts[target_id] = setTimeout => 
          target.trigger("delayedChange") 
          target.removeAttr("data-delay-timeout-pending") 
          console.log ["removing delay attr", target_id]
        , @delay

