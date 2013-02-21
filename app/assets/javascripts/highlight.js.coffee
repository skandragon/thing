window.hide_if_checked = (checkbox, target, immediate) ->
  return unless checkbox[0]
  immediate ||= false
  if checkbox[0].checked
    if immediate
      target.hide()
    else
      target.slideUp()
  else
    if immediate
      target.show()
    else
      target.slideDown()
  true

window.show_if_checked = (checkbox, target, immediate) ->
  return unless checkbox[0]
  immediate ||= false
  if checkbox[0].checked
    if immediate
      target.show()
    else
      target.slideDown()
  else
    if immediate
      target.hide()
    else
      target.slideUp()
  true
