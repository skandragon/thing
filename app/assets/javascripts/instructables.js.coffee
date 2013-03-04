# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  setup_click = (checkbox, target) ->
    checkbox = $(checkbox)
    target = $(target)
    window.show_if_checked(checkbox, target, true)
    checkbox.on 'click', ->
      window.show_if_checked(checkbox, target)

  setup_click('#instructable_adult_only', '#adult-only')
  setup_click('#instructable_heat_source', '#heat-source')

jQuery ->
  target = $('#instructable_location_type')

  value = target.find('option:selected').val()
  if value == 'track'
    $('#location-camp').hide()
  else
    $('#location-camp').show()

  target.on 'change', ->
    value = target.find('option:selected').val()
    if value == 'track'
      $('#location-camp').hide()
    else
      $('#location-camp').show()

jQuery ->
  if window.thing_topics
    update_select = ->
      target = $('#instructable_subtopic')
      topic = $('#instructable_topic')[0].value
      subtopic = $('#instructable_subtopic')[0].value
      options = window.thing_topics[topic]

      if topic and options.length > 0
        target.empty()
        target.append($('<option></option>'))
        for option in options
          item = $('<option></option>').attr('value', option).text(option)
          if option == window.thing_selected_subtopic
            item.attr('selected', 'selected')
          target.append(item)
        $('#subtopic').show()
      else
        $('#subtopic').hide()
    $('#instructable_topic').on 'change', ->
      update_select()
    update_select()
