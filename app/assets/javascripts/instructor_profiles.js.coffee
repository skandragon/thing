# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  setup_click = (checkbox, target) ->
    checkbox = $(checkbox)
    target = $(target)
    window.hide_if_checked(checkbox, target, true)
    checkbox.on 'click', ->
      window.hide_if_checked(checkbox, target)

  setup_click('#user_no_contact', '#contact-fields')
