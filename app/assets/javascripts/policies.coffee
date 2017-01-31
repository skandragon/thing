# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $('.policy-accept-input').on 'change', (event) ->
    event.preventDefault()
    target = $(event.target)
    if target.is(':checked')
      target.removeClass('policy-not-accepted')
    else
      target.addClass('policy-not-accepted')
    enable_or_disable()

  $('#policy-accept-all-button').on 'click', (event) ->
    target = $(event.target)
    if target.attr('disabled')
      event.preventDefault()

  window.enable_or_disable = ->
    target = $('#policy-accept-all-button')
    if $('.policy-not-accepted').length > 0
      target.attr('disabled', true).removeClass('btn-primary')
    else
      target.attr('disabled', false).addClass('btn-primary')
