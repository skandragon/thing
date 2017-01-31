# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $('.policy-accept-button').on 'click', (event) ->
    event.preventDefault()
    target = $(event.target)
    if target.hasClass('policy-not-accepted')
      console.log "marking as accepted"
      target.removeClass('policy-not-accepted').addClass('btn-success')
    else
      console.log "reversing acceptance"
      target.removeClass('btn-success').addClass('policy-not-accepted')
    enable_or_disable()

  $('#policy-accept-all-button').on 'click', (event) ->
    target = $(event.target)
    if target.attr('disabled')
      event.preventDefault()

  window.enable_or_disable = ->
    target = $('#policy-accept-all-button')
    if $('.policy-not-accepted').length > 0
      console.log "not yet accepted all"
      target.attr('disabled', true).removeClass('btn-primary')
    else
      console.log "All are accepted"
      target.attr('disabled', false).addClass('btn-primary')
