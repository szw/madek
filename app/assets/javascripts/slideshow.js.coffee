#= require application

displayEmptyInfo = ->
  $content = $("#slideshow .container .slide .content")
  $content.html("""<h1>Empty slideshow</h1>""")

displayVideo = (slideObject) ->
  $content = $("#slideshow .container .slide .content")
  $content.html """
  <h1>Video content</h1>
  <a href="/media_entries/#{slideObject.id}" target="_blank">
    <img src="/media_resources/#{slideObject.id}/image?size=maximum" />
  </a>
  """

displayAudio = (slideObject) ->
  $content = $("#slideshow .container .slide .content")
  $content.html """
  <h1>Audio content</h1>
  <a href="/media_entries/#{slideObject.id}" target="_blank">
    <img src="/media_resources/#{slideObject.id}/image?size=medium" />
  </a>
  """

displayPDF = (slideObject) ->
  $content = $("#slideshow .container .slide .content")
  $content.html """
  <h1>PDF content</h1>
  <a href="/media_entries/#{slideObject.id}" target="_blank">
    <img src="/media_resources/#{slideObject.id}/image?size=large" />
  </a>
  """

displayImage = (slideObject) ->
  $content = $("#slideshow .container .slide .content")
  $content.html """
  <a href="/media_entries/#{slideObject.id}" target="_blank">
    <img src="/media_resources/#{slideObject.id}/image?size=maximum" />
  </a>
  """

displayMediaSet = (slideObject) ->
  $content = $("#slideshow .container .slide .content")
  $content.html """
  <h1>Media set</h1>
  <a href="/media_sets/#{slideObject.id}" target="_blank">
    <img src="/media_resources/#{slideObject.id}/image?size=medium" />
  </a>
  """

displaySlide = (slide) ->
  if !window.slideshow? || !window.slideshow.contents? || window.slideshow.contents.length == 0
    displayEmptyInfo()
    return

  if slide == "first"
    slide = 0
  else if slide == "last"
    slide = window.slideshow.contents.length - 1

  slideObject = window.slideshow.contents[slide]

  if window.slideshow.contents.length > 1
    if slide == 0
      previousObject = null
      nextObject = window.slideshow.contents[slide + 1]
    else if slide == window.slideshow.contents.length - 1
      previousObject = window.slideshow.contents[slide - 1]
      nextObject = null
    else
      nextObject = window.slideshow.contents[slide + 1]
      previousObject = window.slideshow.contents[slide - 1]
  else
    previousObject = null
    nextObject = null

  $back = $("#slideshow .container .slide .controls .back")

  if previousObject?
    $back.html("""<a href="#" id="prev">Prev</a>""")
    $("#slideshow .controls .back #prev").click -> displaySlide(slide - 1)
  else
    $back.html("")

  $next = $("#slideshow .container .slide .controls .next")

  if nextObject?
    $next.html("""<a href="#" id="next">Next</a>""")
    $("#slideshow .controls .next #next").click -> displaySlide(slide + 1)
  else
    $next.html("")

  $title = $("#slideshow .container .slide .controls .title")
  $title.html("#{slideObject.name}<br />#{slideObject.copyright}")

  if slideObject.content_type.search(/video/) > -1
    displayVideo(slideObject)
  else if slideObject.content_type.search(/audio/) > -1
    displayAudio(slideObject)
  else if slideObject.content_type.search(/image/) > -1
    displayImage(slideObject)
  else if slideObject.content_type.search(/pdf/) > -1
    displayPDF(slideObject)
  else # media_set
    displayMediaSet(slideObject)

jQuery ->
  mediaSetId = $("#slideshow .container").attr("data-media-set")
  sort       = $("#slideshow .container").attr("data-sort")

  $.getJSON "/slideshows/#{mediaSetId}.json?sort=#{sort}", (data)->
    window.slideshow = data
    displaySlide("first")
