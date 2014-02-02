root = exports ? this
root.test_locations_controller_hack_hack_hack = ->
  $('#location-form').find('select[name="track"]').append('<option value="badbogusvalue">BadBogusValue')
  $('#freebusy-form').find('select[name="track"]').append('<option value="badbogusvalue">BadBogusValue')
  true
