jQuery ->
  target = $('#options_publish')
  target.on 'change', ->
    value = $(@).prop('checked')
    user_id = $(@).attr('data-user-id')
    jQuery.ajax({
      type: "PUT",
      url: "/users/#{user_id}/schedule",
      data: {published: value},
      dataType: "json",
      error: (jqXHR, textStatus, errorThrown) ->
        alert "Error: #{textStatus}"
    })

jQuery ->
  $('button.watch').on 'click', ->
    target = $(@)
    id = $(@).attr('data-id')
    value = $(@).text()
    if value == 'Add'
      new_text = 'Remove'
      data = { add_instructable: id }
    else
      new_text = 'Add'
      data = { remove_instructable: id }

    user_id = $(@).attr('data-user-id')
    jQuery.ajax({
      type: "PUT",
      url: "/users/#{user_id}/schedule",
      data: data,
      dataType: "json",
      error: (jqXHR, textStatus, errorThrown) ->
        alert "Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
        target.text(new_text)
        if new_text == 'Add'
          target.removeClass('btn-success')
        else
          target.addClass('btn-success')
    })
