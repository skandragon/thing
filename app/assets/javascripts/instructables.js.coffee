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

jQuery ->
  if window.thing_tracks
    repopulate_targets = (options) ->
      pu_locations = window.all_locations
      for n in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        target = $('#instructable_instances_attributes_' + n + '_location')
        if $(target).size() > 0
          override = $('#instructable_instances_attributes_' + n + '_override_location')
          overridden = override.prop('checked')
          target.empty()
          target.append($('<option></option>'))
          if overridden
            locations = pu_locations
          else
            locations = options
          for location in locations
            item = $('<option></option>').attr('value', location).text(location)
            if location == window.thing_selected_locations[n]
              item.attr('selected', 'selected')
            target.append(item)
          target.enabled = true

    hide_targets = ->
      for n in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        target = $('#instructable_instances_attributes_' + n + '_location')
        if $(target).size() > 0
          target.empty()
          target.enabled = false

    update_select = ->
      track = $('#instructable_track')[0].value
      options = window.thing_tracks[track]
      if track
        repopulate_targets(options)
      else
        hide_targets()

    $('#instructable_track').on 'change', ->
      update_select()
    for n in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
      override = $('#instructable_instances_attributes_' + n + '_override_location')
      override.on 'change', ->
        update_select()
    update_select()
