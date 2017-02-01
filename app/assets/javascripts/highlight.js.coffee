window.hide_if_checked = (checkbox, target, immediate) ->
  return unless checkbox[0]
  immediate ||= false
  if checkbox[0].checked
    hide_and_remove_required(target, immediate)
  else
    show_and_add_required(target, immediate)
  true

window.show_if_checked = (checkbox, target, immediate) ->
  return unless checkbox[0]
  immediate ||= false
  if checkbox[0].checked
    show_and_add_required(target, immediate)
  else
    hide_and_remove_required(target, immediate)
  true

window.hide_and_remove_required = (target, immediate) ->
  if immediate
    target.hide()
  else
    target.slideUp()
  target.find("input.required").removeAttr("required")
  target.find("textarea.required").removeAttr("required")

window.show_and_add_required = (target, immediate) ->
  if immediate
    target.show()
  else
    target.slideDown()
  target.find("input.required").attr("required", "required")
  target.find("textarea.required").attr("required", "required")
